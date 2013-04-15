# Ruby Version: ruby-2.0.0-p0

# Require gems
require 'bundler'
Bundler.require :default

# Access Control
module SWRM
  module AccessControl
    def self.check action
      # Im Falle des Aufrufs einer Ressource
      if action[:section] == "ressource"
        unless [:rurl,:name,:owner,:requester, :actionlink].inject(true) { |akk,val| akk && action.member?(val) }
          return SWRM.error action, 1000
        end

        # Requester und Owner gleich ? Dann sofortiger Zugriff gestattet
        if action[:owner] == action[:requester]
          return action
        end
        
        # Check Conditions from Ressource action[:rurl]
        grants = TS.query ([
          [ action[:rurl], RDF::DC.accessRights, :rights],
          [ :rights, RDF::OREL.grant, :grant],
          [ :grant, RDF::OREL.precondition, :condition ],
          [ :condition, RDF::SWRM.conditionType, :type ],
          [ :condition, RDF::SWRM.value, :value ]
        ])

        no_right_found = true

        # Keine Regeln und Rechte gefunden? Abbruch und Zugriff verweigert (Systemschutz)
        if grants.matched?
          # Specifications
          sol = grants.solutions

          # Nur noch die SWRL Implikationen zählen, wenn der Requester anonym ist
          unless action[:requester] == "anonym"
            # Vorbedingung im Falle von Personenregeln
            owner = sol
            owner.filter({ type: RDF::SWRM['ConditionType/Person'] }) do |sol|
              if sol[:value] == action[:requester]
                case self.check_right(action, sol[:grant])
                when :forbidden
                  return SWRM.error action, 1002
                when :permitted
                  return action
                end
              end
            end
            # Vorbedingung im Falle von Gruppenregeln
            group = sol
            glist = []
            TS.query([[ :group, RDF::FOAF.member, action[:requester]]]) { |sol| glist.push(sol[:group]) }
            unless glist.empty?
              group.filter({ type: RDF::SWRM['ConditionType/Group'] }) do |sol|
                if glist.include? sol[:value]
                  case self.check_right(action, sol[:grant])
                  when :forbidden
                    return SWRM.error action, 1002
                  when :permitted
                    return action
                  end
                end
              end
            end
            # Vorbedingung im Falle von Beziehungsregeln
            relation = sol
            rlist = []
            TS.query([
              [ action[:owner], RDF::FOAF.knows, action[:requester] ],
              [ action[:requester], :relation, action[:owner] ]
            ]) { |sol| rlist.push(sol[:relation]) }
            unless rlist.empty?
              relation.filter({ type: RDF::SWRM['ConditionType/Relation'] }) do |sol|
                if rlist.include? RDF::FOAF["#{sol[:value].to_s[/(\w+)$/].downcase}Of"]
                  case self.check_right(action, sol[:grant])
                  when :forbidden
                    return SWRM.error action, 1002
                  when :permitted
                    return action
                  end
                end
              end
            end
          end
          # Vorbedingung im Falle von SWRL Regeln
          sol.filter({ type: RDF::SWRM['ConditionType/SWRL'] }) do |sol|
            case self.check_swrl_rule action, sol[:value]
            when :forbidden
              return SWRM.error action, 1002
            when :permitted
              return action
            end
          end
        end

        # Kein Recht gefunden, suche in Ressourcengruppe (Vererbung)
        if no_right_found
          # Check Parent
          tempaction = action
          # Ist Ressource teil einer Gruppe?
          pq = TS.query([[ action[:rurl], RDF::DC.isPartOf, :parent ]]) do |sol|
            tempaction[:rurl] = sol.parent
          end
          return SWRM.error action, 1002 if pq.count < 0

          tempaction = self.check tempaction
          
          action = SWRM.error action, 1002 if tempaction[:error]
        end
      # Zugriffskontrolle im Falle von sozialen Profilen (Ausnahmen)
      elsif action[:section] == "user"
        unless [:rurl,:name,:owner,:requester, :actionlink].inject(true) { |akk,val| akk && action.member?(val) }
          return SWRM.error action, 1000
        end
        # You can only create a profile, if Requester == Owner (also for "anonym")
        if action[:name] == "create"
          if (action[:owner] == action[:requester]) && (action[:owner] == "anonym")
            if TS.query([[ action[:owner], RDF::FOAF.name, :name ]]).count < 0
              return action
            end
          end
          SWRM.error action, 1006
        end

        if action[:name] == "update"
          if (action[:owner] == action[:requester]) && (action[:owner] != "anonym")
            if TS.query([[ action[:owner], RDF::FOAF.name, :name ]]).count > 0
              return action
            end
          end
          SWRM.error action, 1006
        end


      else
        return SWRM.error action, 1000
      end
      return action
    end

    def self.check_swrl_rule action, rule
      # true return permit Object
      # false
    end

    def self.check_right action, grant
      # Prohibitions
      return :forbidden if TS.sparql.ask.whether([ grant, RDF::OREL.forbiddenAction, action[:actionlink]]).true?
      # Permits
      return :permitted if TS.sparql.ask.whether([ grant, RDF::OREL.permittedAction, action[:actionlink]]).true?
      return :not_found
    end
  end
end

