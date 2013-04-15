## License
#
# FOAF+SSL Authentication Library for Ruby and Rack
# Copyright (C) 2010 Hellekin O. Wolf <hellekin@cepheide.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
##

module FOAFSSL
  
  class Authentication
    def initialize(env)
      @env  = env
      @cert = FOAFSSL::CERT(env)
      @foaf = @cert.webid && FOAFSSL::FOAF(env, @cert.webid)
      
      @authorization = NONE
    end
    
    def identity
      @authorization
    end
    alias_method :authenticated, :identity
    
    def authenticate!
      authenticated? && @authorization = @cert.identity
    end
    
    def authenticated?
      @foaf && @cert.identity != NONE &&
      @cert.identity === @foaf.identity
    end
    
    def webid
      @cert.webid
    end
  end
end
