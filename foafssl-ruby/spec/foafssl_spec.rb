require 'spec_helper'
require 'foafssl'

describe "FOAF+SSL Authentication Library" do

  describe "dependencies" do

    it "requires openssl" do
      lambda { OpenSSL }.should_not raise_error(NameError)
    end

    it "requires rdf" do
      lambda { RDF }.should_not raise_error(NameError)
    end

    it "requires rdf/raptor" do
      lambda { RDF::Raptor }.should_not raise_error(NameError)
    end
  end
  
  it "provides a FOAFSSL::Authentication class" do
    lambda { FOAFSSL::Authentication }.should_not raise_error(NameError)
  end
    
  it "provides a FOAFSSL::Rack middleware" do
    lambda { FOAFSSL::Rack }.should_not raise_error(NameError)
  end

  it "implements a generic FOAFSSL::Reader" do
    lambda { FOAFSSL::Reader }.should_not raise_error(NameError)
  end
    
  it "provides an X509 Certificate Reader: FOAFSSL::Reader::CERT" do 
    lambda { FOAFSSL::Reader::CERT }.should_not raise_error(NameError)
  end
    
  it "provides a FOAF RDF Reader: FOAFSSL::Reader::FOAF" do 
    lambda { FOAFSSL::Reader::FOAF }.should_not raise_error(NameError)
  end

  it "defines NONE, an empty/failed identity/authorization" do
    lambda { FOAFSSL::NONE }.should_not raise_error(NameError)
    FOAFSSL::NONE.should == []
  end

end
