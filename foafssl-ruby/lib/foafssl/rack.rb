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
  class Rack
    def initialize(app)
      @app = app
    end
    
    def call(env)
      if FOAFSSL.can_authenticate_this_request?(env)
        foafssl, session = FOAFSSL::Authentication.new(env), env['rack.session']
	foafssl.authenticate!
        session[:foafssl_authenticated] = foafssl.authenticated
      end
      @app.call(env)
    end
  end
end
