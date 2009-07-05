require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Domain do
  before(:each) do
    @valid = Factory.create(:domain)
  end

  it 'should be valid given valid attributes' do
    @valid.should be_valid
  end
   
  it 'should not be valid with missing domain' do
    @invalid = @valid
    @invalid.domain = nil
    @invalid.should_not be_valid
  end
end
