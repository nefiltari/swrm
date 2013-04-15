# Ruby Version: ruby-2.0.0-p0# Ruby Version: ruby-2.0.0-p0

# Require gems
require 'bundler'
Bundler.require :default

# Vacabularies
RDF::DCTYPE = RDF::Vocabulary.new("http://purl.org/dc/dcmitype/")
RDF::MIME = RDF::Vocabulary.new("http://www.iana.org/assignments/media-types/")
RDF::SWRM = RDF::Vocabulary.new("http://example.org/swrm/")
RDF::OREL = RDF::Vocabulary.new("http://example.org/orel/")
RDF::SWRL = RDF::Vocabulary.new("http://www.w3.org/2003/11/swrlx")
RDF::RULEML = RDF::Vocabulary.new("http://www.w3.org/2003/11/ruleml")
# Extended FOAF Relationships by Eric Vitiello and Eric Sigler
# http://wiki.foaf-project.org/w/Using_Relationship_vocabulary

module SWRM
  def self.setup
    # Extended Media Types for RDF::DC.format
    TS.repo << [ RDF::MIME['text/blog'], RDF.type, RDF::DC['MediaType'] ]
    # Condition Types
  end
end