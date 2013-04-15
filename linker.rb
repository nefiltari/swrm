# Ruby Version: ruby-2.0.0-p0

# Require gems
require 'bundler'
Bundler.require :default

module SWRM
  module Linker
    def self.resolve action
      unless [:requester, :link, :method, :parameters].inject(true) { |akk,val| akk && action.member?(val) }
        return SWRM.error action, 1001
      end

      # Auflösen der Aktion im Falle eines Ressourcenaufurfs
      if ! (result = action[:link].scan(/^(http\:\/\/[.a-z\-0-9\:]+\/ressource\/([0-9]*))(\/(\w+))?/)).empty?
        action[:rurl] = RDF::URI.new(result[0][0])
        return SWRM.error(action, 1004) if result[0][1].empty?
        action[:rid] = result[0][1]
        TS.query([[ action[:rurl], RDF::DC.creator, :owner]]) { |sol| action[:owner] = sol[:owner] } # Auslesen der WebID des Eigentümers
        action[:name] = result[0][3]

      # Auswerten der Nutzerprofilaufrufe
      # Im Falle eines internen Users (nur existente WebID Profile)
      elsif ! (result = action[:link].scan(/^(http\:\/\/[.a-z\-0-9\:]+\/user\/([0-9]*))(\/(\w+))?/)).empty?
        action[:owner] = RDF::URI.new(result[0][0])
        return SWRM.error action, 1004 unless TS.query([[ action[:owner], RDF::FOAF.name, :name ]]).count > 0 # exist ?
        action[:section] = "user"
        action[:name] = result[0][2]
      
      # Im Falle eines externen Users oder Platzhalters
      elsif ! (result = action[:link].scan(/^http\:\/\/[.a-z\-0-9\:]+\/user\/(\w*)\/(\w*)/)).empty?
       
        # Auswertung des Platzhalters "me"
        if result[0][0] == "me"
          action[:owner] = action[:requester]
          return SWRM.error action, 1006 if action[:requester] == "anonym"
          action[:section] = "user"
          action[:name] = result[0][1]
       
        # Auswertung des Aufrufs im Falle eines webid Parameters
        elsif action[:parameters][:webid]
          action[:owner] = action[:parameters][:webid]
          action[:section] = "user"
          action[:name] = result[0][0]
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