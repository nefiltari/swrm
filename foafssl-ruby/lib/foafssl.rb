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

require 'openssl'

# Support for RDF formats
require 'rdf'         # RDFXML
require 'rdf/raptor'  # RDFa

require_relative 'foafssl/version'

module FOAFSSL

  # Define an empty authorization when no identity is provided.
  NONE = [] 

  autoload :Authentication, 'foafssl/authentication'
  autoload :Rack,           'foafssl/rack'
  autoload :Reader,         'foafssl/reader'

  class << self
    ##
    # Check if the request is usable for FOAF+SSL authentication.
    #
    # @param  [Hash]    env The Rack +environment+ hash
    # @return [Boolean] Whether we can authenticate with FOAF+SSL
    def can_authenticate_this_request?(env)
      ssl_request?(env) && ssl_client_cert?(env) && ssl_cert_has_webid?(env)
    end

    ##
    # Rack middleware implementation
    #
    # @param                  `app` The current Rack application
    # @return [FOAFSSL::Rack]       The FOAFSSL Rack middleware
    # @see    FOAFSSL::Rack
    def new(app)
      Rack.new(app)
    end
    
    ##
    # Shortcut for an X509 Certificate reader
    #
    # @param  [Hash]                  `env` the Rack environment
    # @return [FOAFSSL::Reader::CERT] An X509 Certificate reader Object
    # @see    FOAFSSL::Reader::CERT
    def CERT(env)
      Reader::CERT.new(env)
    end
    
    ##
    # Shortcut for a FOAF reader
    #
    # @param  [Hash]                  `env` the Rack environment
    # @param  [RDF::URI]              `webid` the WebID to read
    # @return [FOAFSSL::Reader::FOAF] A FOAF reader Object
    # @see    FOAFSSL::Reader::FOAF
    def FOAF(env, webid)
      Reader::FOAF.new(env, webid)
    end
    
    private
    
    ##
    # Check if the request is using SSL
    #
    # @param  [Hash]     `env` the Rack environment
    # @return [Boolean]  whether the request is HTTPS or not
    # @private
    def ssl_request?(env)
      env['HTTP_X_FORWARDED_PROTO'] == 'https'
    end
    
    ##
    # Check if the request provides a client SSL Certificate
    #
    # Apache2 users MUST configure the server to provide the
    # +SSL_CLIENT_CERT+ header filled with the actual certificate
    #
    #   <Location /protected>
    #     SSLOptions +ExportClientCert ...
    #     ...
    #   </Location>
    #    
    # and:
    #
    #   set RequestHeader 'SSL_CLIENT_CERT', %{SSL_CLIENT_CERT}e
    #
    # @param  [Hash]     `env` the Rack environment
    # @return [Boolean]  whether a client certificate was provided
    # @private
    def ssl_client_cert?(env)
      env['HTTP_SSL_CLIENT_CERT'] && !env['HTTP_SSL_CLIENT_CERT'].empty?
    end

    ##
    # Check if the client SSL certificate contains a WebID
    #
    # The WebID is stored in the subjectAltName of the certificate, as
    # an URI.
    #
    # @param  [Hash]     `env` the Rack environment
    # @return [Boolean]  whether the client certificate includes an
    #                    URI in its subjectAltName
    # @private
    def ssl_cert_has_webid?(env)
      !CERT(env).webid.nil?
    end
  end
end
