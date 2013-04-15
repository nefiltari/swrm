# Ruby Version: ruby-2.0.0-p0

# Require gems
require 'bundler'
Bundler.require :default

# Ressource Management
module SWRM
  class Ressource
    # Basisaufrufmethode des Ressourcenmanagements zum Ausführen von action[:name]
    def self.execute_action action={}
      return nil unless action.member?(:rurl) && action.member?(:name) && action.member?(:parameters)
      # Calling
      action[:rclass] = self.get_class action # Wahl der Ressourcenzuorndung
      res = action[:rclass].new
      action[:parameters][:owner] = action[:owner]
      action[:parameters][:requester] = action[:requester]
      # Aufruf der Aktion, wenn sie auch vorhanden ist
      if res.respond_to?(action[:name])
        action[:return] = res.send(action[:name].to_sym, action[:parameters])
      else
        action = SWRM.error action, 1005
      end
      action[:rformat_http] = (action[:return][:format]) ? action[:return][:format] : "text/json"
      action
    end

    # Implementierung des Ressourcenaufrufs
    def self.get_class action
      return nil unless action.member?(:rurl)
      return Ressource::Profile if action[:section] = "user"

      # Find Ressource Type and Format
      action[:rtype] = DCTYPE['Dataset']
      action[:rformat] = MIME['text/json']

      TS.query([
        [action[:rurl], RDF::DC.type, :type], 
        [action[:rurl], RDF::DC.format, :format]
      ]) do |sol|
        action[:rtype] = sol.type
        action[:rformat] = sol.format
      end

      # Vorläufige Festlegung
      action[:rformat_http] = action[:rformat].to_s.scan(/[\w\-]+\/[\w\-]+$/)[0]

      # Switch between classes through actions
      case action[:rtype]
      when DCTYPE['Dataset']
        case action[:rformat]
        when MIME['text/blog']
          Ressource::Blog
        end
      when DCTYPE['Image']
        case action[:rformat]
        when MIME['image/png'], MIME['image/jpeg'], MIME['image/gif']
          Ressource::Image
        end
      when DCTYPE['Collection']
        case action[:rformat]
        when MIME['text/photoalbum']
          Ressource::PhotoAlbum
        else
          Ressource::Collection
        end
      else
        Ressource
      end
    end

    # Serialisierung des Aktionsaufrufs in das entsprechende Antwortformat
    def self.serialize_action action={}
      data={}
      if action.member?(:error)
        action[:rformat] = "text/json"
        data[:error] = action[:error]
        data[:errorcode] = action[:errorcode]
        data[:link] = action[:link]
        data[:method] = action[:method]
        data[:params] = action[:parameters]
        return data.to_json # Debug: action.to_json
      end
      if action[:return][:format] == "text/json"
        data[:link] = action[:link]
        data[:method] = action[:method]
        data[:params] = action[:params]
        data[:ressource_owner] = action[:owner]
        data[:return] = action[:return][:value]
        data.to_json
      elsif action[:return][:format] == "text/xml"
        data[:link] = action[:link]
        data[:method] = action[:method]
        data[:params] = action[:params]
        data[:ressource_owner] = action[:owner]
        data[:return] = action[:return][:value]
        data.to_xml
      else
        action[:return][:value].to_s
      end
    end

    # Basic Action Methods
    def read params
    end
    
    def write params
    end

    def remove params
    end

    def update params
    end
  end

  class Ressource::Blog < Ressource
  end

  class Ressource::Collection < Ressource
  end

  class Ressource::PhotoAlbum < Ressource::Collection
  end
end

# Include Ressource Type Classes
Dir.chdir "#{File.expand_path(File.dirname(__FILE__))}/ressources"
Dir.glob("*.rb") { |bib| require_relative "ressources/#{File.basename(bib,".rb")}" }