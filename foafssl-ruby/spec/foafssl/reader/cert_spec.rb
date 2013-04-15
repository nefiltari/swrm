require 'spec_helper'
require 'foafssl'

describe "FOAFSSL::Reader::CERT" do
  it "extracts WebID from the certificate's subjectAltName" do
    webids  = [
      "http://example.net/#me", 
      "https://fo.o.example.net/wtf,comma",
      "http://foo.example.net/o/m/g/l,o,l,#foaf"
    ]
    altnames = [
      "URI:%s",
      "URI:%s, email:foo@bar",
      "DNS:foo.example.net, URI:%s, email:foo@bar"
    ]
    webids.each do |webid|
      altnames.each do |san|
        san % webid =~ FOAFSSL::Reader::CERT::RE_SAN_WEBID
	webid.should === $1
      end
    end
  end

  describe "given a valid FOAF+SSL certificate" do
  
    before do
      @foafssl_env = {
    'HTTP_X_FORWARDED_PROTO' => 'https',
    'HTTP_SSL_CLIENT_CERT'   => IO.read(File.dirname(__FILE__)+'/../../../fixtures/test_client_certificate.pem')
      }
      @cert = FOAFSSL.CERT(@foafssl_env)
    end

    describe "when instanciated" do
      it "has an empty identity" do
        @cert.identity.should == FOAFSSL::NONE
      end

      it "responds to :identify!" do
        @cert.should respond_to(:identify!)
      end
    end

    describe "once identified" do
      before { @cert.identify! }

      it "provides an non-empty identity containing 3 elements" do
        @cert.identity.should_not be_empty
        @cert.identity.size.should == 3
      end

      describe "identity" do
        before { @cert.identify! }
        
        it "includes the WebID as first element" do
          @cert.webid.should == @cert.identity[0]
        end

        it "includes the RSA Public Key public_exponent as second element" do
          @cert.identity[1].should == OpenSSL::BN.new('65537')
        end

        it "include the RSA Public Key modulus as third element" do
          @cert.identity[2].should == OpenSSL::BN.new('157143852980810065063960747457240689725887446325116187948701810544560742040057764087906369728144529443575818113175185227127395281969184922917176540851479582252999962400739262887366432506014429440906036510569833074651872557324450190076828969206211603266769849089965937310254832692836386230086329139744955193627')
        end
      end
    end
  end
  
end
