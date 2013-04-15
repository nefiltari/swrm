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
  #
  # The FOAFSSL Ruby library follows Semantic Versioning specification.
  #
  # @see http://semver.org/
  #
  class VERSION
    MAJOR = 0
    MINOR = 1
    PATCH = 0
    EXTRA = nil
    
    STRING = [MAJOR, MINOR, PATCH].join('.') << EXTRA.to_s

    ##
    # @return [Array(Integer, Integer, Integer)]
    def self.to_a
      [MAJOR, MINOR, PATCH]
    end

    ##
    # @return [String]
    def self.to_s
      STRING
    end
    alias_method :to_str, :to_s

    ##
    # @return [String]
    def self.to_tag
      "v#{to_s}"
    end

  end
end
