require 'spec_helper'
require 'foafssl'

#
# A valid FOAF+SSL environment requires HTTPS and an X509 Client
# Certificate including an URI in the subjectAltName (the WebID).
#
FOAFSSL_ENV = {
  'HTTP_X_FORWARDED_PROTO' => 'https',
  'HTTP_SSL_CLIENT_CERT'   => IO.read(File.dirname(__FILE__)+'/../../fixtures/test_client_certificate.pem')
}
#
# A valid X509 Client Certificate without a WebID does not constitute
# a valid FOAF+SSL environment: it is silently ignored.
#
NOTFOAFSSL_ENV = {
  'HTTP_X_FORWARDED_PROTO' => 'https',
  'HTTP_SSL_CLIENT_CERT'   => IO.read(File.dirname(__FILE__)+'/../../fixtures/test_client_certificate_no_webid.pem')
}
#
# Of course, if the protocol isn't HTTPS...
#
NOTHTTPS_ENV = {}

describe "given a proper environment" do

  before do
    @foafssl_env   = {
  'HTTP_X_FORWARDED_PROTO' => 'https',
  'HTTP_SSL_CLIENT_CERT'   => IO.read(File.dirname(__FILE__)+'/../../fixtures/test_client_certificate.pem')
    }
  end
  
  it "is an ssl request" do
    FOAFSSL.send(:ssl_request?, @foafssl_env).should be_true
  end
    
  it "provides an X509 client certificate" do
    FOAFSSL.send(:ssl_client_cert?, @foafssl_env).should be_true
  end
    
  it "provides a WebID in the subjectAltName" do
    FOAFSSL.send(:ssl_cert_has_webid?, @foafssl_env).should be_true
  end

end

describe "FOAF+SSL Authentication Class" do

  before do
    @nohttps_env   = {}
    @nofoafssl_env = {
  'HTTP_X_FORWARDED_PROTO' => 'https',
  'HTTP_SSL_CLIENT_CERT'   => IO.read(File.dirname(__FILE__)+'/../../fixtures/test_client_certificate_no_webid.pem')
    }
    @foafssl_env   = {
  'HTTP_X_FORWARDED_PROTO' => 'https',
  'HTTP_SSL_CLIENT_CERT'   => IO.read(File.dirname(__FILE__)+'/../../fixtures/test_client_certificate.pem')
    }
  end

  it "requires an environment argument" do
    lambda { FOAFSSL::Authentication.new }.should raise_error(ArgumentError)
    lambda { FOAFSSL::Authentication.new(@nohttps_env) }.should_not raise_error(ArgumentError)
  end
  
  describe "when instanciated" do
    
    before { @foafssl = FOAFSSL::Authentication.new(@nohttps_env) }
  
    it "gives a cert reader" do
      @foafssl.instance_variable_get(:"@cert").should be_a FOAFSSL::Reader::CERT
    end
    
    it "is not authenticated" do
      @foafssl.should_not be_authenticated
    end

    describe "without a proper environment" do
    
      it "gives a nil WebID" do
        @foafssl.webid.should be_nil
      end
    
      it "gives a nil foaf reader" do
        @foafssl.instance_variable_get(:"@foaf").should be_nil
      end
      
      it "gives an empty identity" do
        @foafssl.identity.should == FOAFSSL::NONE
      end
      
    end
    
  end

  describe "given a proper environment" do
  
    before { @foafssl = FOAFSSL::Authentication.new(@foafssl_env) }

    it "gives a foaf reader" do
      @foafssl.instance_variable_get(:"@foaf").should be_a FOAFSSL::Reader::FOAF
    end

    it "responds to :webid with a non-empty ::RDF::URI" do
      @foafssl.webid.should be_a ::RDF::URI
      @foafssl.webid.to_s.should_not be_empty
    end
    
  end

  describe "authentication" do

    before do
      @foafssl_env   = {
    'HTTP_X_FORWARDED_PROTO' => 'https',
    'HTTP_SSL_CLIENT_CERT'   => IO.read(File.dirname(__FILE__)+'/../../fixtures/test_client_certificate.pem')
      }
      @foafssl = FOAFSSL::Authentication.new(@foafssl_env)
#      @foafssl.authenticate!
    end

    it "provides an non-empty identity" do
      @foafssl.identity.should_not be_empty
    end

    it "provides the WebID as first element of the identity" do
      @foafssl.webid.to_s.should_not be_empty
      @foafssl.webid.should be_a ::RDF::URI
      @foafssl.identity[0].should == @foafssl.webid
    end

  end
end
