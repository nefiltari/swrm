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
    class CERT < Reader::Base
      ##
      # Extract identity from an X509 SSL Certificate.
      #
      # @return [Array<RDF:URI, OpenSSL::BN, OpenSSL::BN>, FOAFSSL::NONE]
      #   If the detected certificate contains a WebID, then the
      #   @identity will be set with WebID, the public exponent and
      #   modulus of the RSAPublicKey of the certificate.
      #   Otherwise, the null-identity [] will be returned.
      # @see FOAFSSL::Reader::Base
      def identify
        c = OpenSSL::X509::Certificate.new(clean_certificate)
	[webid_from_cert(c), c.public_key.e, c.public_key.n]
      rescue OpenSSL::X509::CertificateError
        FOAFSSL::NONE
      end
      
      private

      ##
      # Returns a cleanly-formatted PEM representation of an X509 Certificate.
      #
      # This shouldn't be necessary, but it seems that without it,
      # OpenSSL::X509::Certificate will throw an ASN.1 Syntax Error.
      #
      # @return [String]
      # @private
      def clean_certificate
        "-----BEGIN CERTIFICATE-----\n" +
	@env['HTTP_SSL_CLIENT_CERT'].to_s.
          gsub(/([\s\0\x0B]+|-----(BEGIN|END) CERTIFICATE-----)/,'').
	    gsub(/(.{64})/, "\\1\n") +
	"\n-----END CERTIFICATE-----\n"
      end

      # Regular expression to match an URI in the subjectAltName of
      # an X509 Certificate.  The URI is the first match.
      RE_SAN_WEBID = %r{^.*URI:([^\s]+([^,\s])).*$}

      ##
      # Extract the WebID from a given X509 Certificate.
      #
      # @param [::OpenSSL::X509::Certificate] cert a valid SSL
      #                                       Certificate
      # @return [String, nil] webid if there, or nil
      # @private
      def webid_from_cert(cert)
        san = cert.extensions.find { |x| x.oid == 'subjectAltName' }
        san = san.value if san.respond_to?(:value)
        san.to_s.gsub!(RE_SAN_WEBID,'\1')
      end
    end
  end
end
