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
  module Reader

    autoload :CERT, 'foafssl/reader/cert'
    autoload :FOAF, 'foafssl/reader/foaf'

    class Base
    
      attr_reader :identity
      
      def initialize(env, webid = nil)
        @env, @identity, @webid = env, FOAFSSL::NONE, webid
      end
      
      def identify!
        @identity = identify
	normalize_identity!
      end
      
      def identify
        raise NotImplementedError, 'should return [Array(webid, rsakey_public_exponent, rsakey_modulus)]'
      end
      protected :identify

      ##
      # Return the WebID or nil
      #
      def webid
        @webid ||= begin
          identify!
	  identity[0]
	rescue
          nil
	end
      end
    
      private

      ##
      # Prepare the indentity for comparison
      #
      # @return [Array(::RDF::URI, ::OpenSSL::BN, ::OpenSSL::BN),
      # Array()]  Unless the identity is valid, it returns [].
      # Otherwise, an Array with three elements.
      # @private
      def normalize_identity!
        return reset_identity! if @identity.empty?
        @identity.each { |c| if c.nil? then reset_identity! and return; end  }
        w, e, m = @identity
        w = normalize_webid(w)
        e = normalize_pkexp(e)
        m = normalize_pkmod(m)
        @identity = [w, e, m]
      end

      ##
      # Normalize the WebID
      #
      # @param  [#to_s]           the WebID
      # @return [::RDF::URI, nil] the RDF representation of the WebID
      #                           or nil
      # @private
      def normalize_webid(webid)
        ::RDF::URI.new(webid.to_s)
      rescue
        nil
      end

      def normalize_bn(bn)
        ::OpenSSL::BN.new(bn.to_s)
      rescue
        nil
      end
      alias_method :normalize_pkexp, :normalize_bn
      alias_method :normalize_pkmod, :normalize_bn

      def reset_identity!
        @identity = FOAFSSL::NONE
      end

    end
  end
end
