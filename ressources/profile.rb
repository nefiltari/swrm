# Ruby Version: ruby-2.0.0-p0

# Require gems
require 'bundler'
Bundler.require :default

module SWRM
  class Ressource::Profile < Ressource
    def read params

      # Ressources
      ret = { }
      return ret
    end
    
    def write params
      ret = { success: true }
      return ret
    end

    def remove params
      # not allowed
      ret = { error: 101, message: "You can't remove WebID profiles" }
      return ret
    end

    def update params
      ret = { success: true }
      return ret
    end

    # Refresh extern Profile from params[:owner]
    def refresh params
      ret = { success: true }
      return ret
    end
  end
end