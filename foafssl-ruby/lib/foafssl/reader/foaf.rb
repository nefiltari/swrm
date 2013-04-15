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
    class FOAF < Reader::Base
      ##
      # Read identity from the FOAF file at WebID.
      #
      # FIXME: This implementation takes the first match, assuming
      # there's only one key per WebID.  That should be considered as
      # a bug.
      #
      # @return [Array<String, Number, Number>, FOAFSSL::NONE]
      # identity array or the empty identity
      def identify
        keys = graph.query(:object => ::RDF::RSA.RSAPublicKey)
        keys.each do |key|
          rsa_key = graph.query([key.subject])
          g_webid = rsa_key.query(:predicate => ::RDF::CERT.identity).first_object
          next unless webid == g_webid
          return [g_webid, g_exp(rsa_key), g_mod(rsa_key)]
        end
        NONE
      end

      # TODO: Add some auto-detection of format...  Support all
      # formats available to ::RDF
      # Only supports RDFXML and RDFa for now.
      def graph
        @graph ||= begin
                     ::RDF::Graph.load(webid, :format => :rdfa,   :base_uri => webid)
                   rescue RDF::FormatError
                     ::RDF::Graph.load(webid, :format => :rdfxml, :base_uri => webid)
                   end
      end

      # REFACTOR: g_mod and g_exp should both check for the datatype
      def modulus_from_graph(rsa_key)
        g_mod = rsa_key.query(:predicate => ::RDF::RSA.modulus).first_object
        if g_mod.resource?
          g_mod = graph.query([g_mod, ::RDF::CERT.hex]).first_object
        end
        # Henry Story makes it clear input requires proper checking :)
        g_mod = g_mod.value.to_s.gsub(/[^0-F]/i,'').to_i(16).to_s
      end
      alias_method :g_mod, :modulus_from_graph

      def public_exponent_from_graph(rsa_key)
        g_exp = rsa_key.query(:predicate => ::RDF::RSA.public_exponent).first_object
        if g_exp.resource?
          g_exp = graph.query([g_exp, RDF::CERT.decimal]).first_object
        end
        g_exp = g_exp.value if g_exp.respond_to?(:value)
        g_exp.to_s.gsub(/[^0-9]/,'')
      end
      alias_method :g_exp, :public_exponent_from_graph
      
    end
  end
end
