require 'spec_helper'
require 'foafssl'

describe "FOAFSSL::Reader" do
  it "is a module" do
    FOAFSSL::Reader.should be_a Module
  end

  it "provides an abstract Base class" do
    lambda { FOAFSSL::Reader::Base }.should_not raise_error(NameError)
    FOAFSSL::Reader::Base.should be_a Class
  end
end

describe "FOAFSSL::Reader::Base" do
  it "takes one argument: an environment hash" do
    lambda { FOAFSSL::Reader::Base.new }.should raise_error(ArgumentError)
    lambda { FOAFSSL::Reader::Base.new({}) }.should_not raise_error(ArgumentError)
  end

  it "may take a WebID as an optional second argument" do
    lambda { FOAFSSL::Reader::Base.new({}, 'foo') }.should_not raise_error(ArgumentError)
  end

  describe "when instanciated" do

    before { @base = FOAFSSL::Reader::Base.new({}, 'foo')}
    it "raises a NotImplementedError if called with :identify!" do
      @base.should respond_to(:identify!)
      lambda { @base.identify! }.should raise_error(NotImplementedError)
    end

    it "responds to :identity and returns an empty one" do
      @base.should respond_to(:identity)
      @base.identity.should == FOAFSSL::NONE
    end

  end

end
