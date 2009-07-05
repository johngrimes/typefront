require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Font do
  before(:each) do
    @valid = Factory.build(:font)
  end

  it 'should be valid given valid attributes' do
    @valid.should be_valid
  end

  it 'should not be valid with missing distribution file' do
    @invalid = @valid
    @invalid.distribution = nil
    @invalid.should_not be_valid
  end
end
