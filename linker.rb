# Ruby Version: ruby-2.0.0-p0

# Require gems
require 'bundler'
Bundler.require :default

module SWRM
  module Linker
    def self.resolve action
      unless [:requester, :path, :host, :method, :parameters].inject(true) { |akk,val| akk && action.member?(val) }
        return SWRM.error action, 1001
      end

      # Auflösen der Aktion im Falle eines Ressourcenaufurfs
      if ! (result = action[:path].scan(/^\/([a-z_\-\.]+)( \/ressource( \/([a-z_\/\-]+))? \/([0-9]+))( \/(\w+))?$/x)).empty?
        # Ressource Link                       domaine       ressource      subcategory        rid        action
        action[:rurl] = RDF::URI.new("http://#{result[0][0]}#{result[0][1]}")
        # Ressource muss existieren
        return SWRM.error action, 1007 if TS.query([[ action[:rurl], RDF::DC.type, :type ]]).count.zero?
        # Ressource ID  and Category ([0-9]+)
        action[:rsubcat] = result[0][3]
        action[:rid] = result[0][4]
        action[:section] = "ressource"
        # Auslesen der WebID des Eigentümers
        TS.query([[ action[:rurl], RDF::DC.creator, :owner]]) { |sol|  action[:owner] = sol[:owner] }
        action[:name] = result[0][6]

      # Auswerten der Nutzerprofilaufrufe
      # Im Falle eines internen Users (nur existente WebID Profile)
      elsif ! (result = action[:path].scan(/^\/([a-z_\-\.]+)( \/user\/ ([0-9]+))( \/(\w+))?/x)).empty?
        # Owner WebID                            domaine        user      uid         action
        action[:owner] = RDF::URI.new("http://#{result[0][0]}#{result[0][1]}")
        # exist User with WebID ?
        return SWRM.error action, 1004 if TS.query([[ action[:owner], RDF::FOAF.name, :name ]]).count.zero?
        action[:section] = "user"
        action[:name] = result[0][4]
      
      # Im Falle eines externen Users oder Platzhalters
      elsif ! (result = action[:path].scan(/^ \/user   \/(\w+)   \/(\w+)/x)).empty?
        #                                       user  me/action     action
        # Auswertung des Platzhalters "me"
        if result[0][0] == "me"
          action[:owner] = action[:requester]
          return SWRM.error action, 1006 if action[:requester] == "anonym"
          action[:section] = "user"
          action[:name] = result[0][1]
       
        # Auswertung des Aufrufs im Falle eines WebID parameters
        elsif action[:parameters][:webid]
          action[:owner] = action[:parameters][:webid]
          return SWRM.error action, 1004 if TS.query([[ action[:owner], RDF::FOAF.name, :name ]]).count.zero?
          action[:section] = "user"
          action[:name] = result[0][1]
        else
          return SWRM.error action, 1004
        end
      else
        return SWRM.error action, 1004
      end

      action[:name] = if action[:name].empty?
        case action[:method].downcase
        when "get"
          "read"
        when "post"
          "create"
        when "put"
          "update"
        when "delete"
          "remove"
        end
      else
        action[:name]
      end

      # Construct real Action Link
      if action[:section] == "ressource"
        action[:actionlink] = RDF::URI.new("#{action[:rurl]}/#{action[:name]}")
      end

      return action
    end
  end
end