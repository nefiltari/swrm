require 'spec_helper'
require 'foafssl'

describe "FOAFSSL::Reader::FOAF" do
  it "requires a webid, or will return FOAFSSL::NONE" do
    lambda { FOAFSSL::Reader::FOAF.new({}) }.should_not raise_error(ArgumentError)
    @foaf = FOAFSSL::Reader::FOAF.new({}, 'http://hellekin.cepheide.org/foafssl#test')
    @foaf.should respond_to(:identify!)
    @foaf.identify!
  end
end
