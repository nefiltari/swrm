require 'foafssl'

describe 'Semantic Version' do

  it "is called VERSION" do
    lambda { FOAFSSL::VERSION }.should_not raise_error(NameError)
  end

  %w(MAJOR MINOR PATCH).each do |component|
    it "has a #{component} component" do
      lambda { FOAFSSL::VERSION.const_get(component) }.should_not raise_error(NameError)
    end
    it "#{component} MUST be a positive integer or 0" do
      c = FOAFSSL::VERSION.const_get(component)
      c.class.should == Fixnum
      c.should >= 0
    end
  end

  it "has an optional EXTRA component" do
    lambda { FOAFSSL::VERSION::EXTRA }.should_not raise_error(NameError)
  end

  it "EXTRA can be nil, or alphanumerics starting with a letter" do
    x = FOAFSSL::VERSION::EXTRA
    (x.nil? || x.match(/^[a-zA-Z][a-zA-Z0-9]+$/)).should be_true
  end

  it "can be respresented as a String" do
    FOAFSSL::VERSION.should respond_to(:to_s)
    FOAFSSL::VERSION.to_s.should == FOAFSSL::VERSION::STRING
    FOAFSSL::VERSION::STRING.should == [FOAFSSL::VERSION::MAJOR, FOAFSSL::VERSION::MINOR, FOAFSSL::VERSION::PATCH].join('.') << FOAFSSL::VERSION::EXTRA.to_s
  end

  it "can be represented as an Array" do
    FOAFSSL::VERSION.to_a.should == [FOAFSSL::VERSION::MAJOR, FOAFSSL::VERSION::MINOR, FOAFSSL::VERSION::PATCH]
  end

  it "can be represented as a String suitable for tagging a commit" do
    FOAFSSL::VERSION.should respond_to(:to_tag)
    FOAFSSL::VERSION.to_tag.should == "v#{FOAFSSL::VERSION::STRING}"
  end
end
