require 'spec_helper'
require 'foafssl'

describe "A proper FOAF+SSL environment" do

  before do
    @foafssl_env   = {
  'HTTP_X_FORWARDED_PROTO' => 'https',
  'HTTP_SSL_CLIENT_CERT'   => IO.read(File.dirname(__FILE__)+'/../fixtures/test_client_certificate.pem')
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
  
  it "can therefore be used for FOAF+SSL authentication" do
    FOAFSSL.can_authenticate_this_request?(@foafssl_env).should be_true
  end

end
