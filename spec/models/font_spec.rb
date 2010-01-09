require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Font do
  fixtures :all

  describe 'attributes' do
    before(:each) do
      @valid = Factory.build(:font)
    end

    it 'should be valid given valid attributes' do
      @valid.should be_valid
    end

    it 'should not be valid with missing file' do
      @invalid = @valid
      @invalid.original = nil
      @invalid.should_not be_valid
    end

    it 'should not be valid with an unrecognised file format' do
      @invalid = @valid
      @invalid.original = ActionController::TestUploadedFile.new(
        "#{RAILS_ROOT}/spec/fixtures/symbol.pfb",
        'font/pfb')
      @invalid.should_not be_valid
    end
  end

  it 'should return full name when subfamily is blank' do
    font = fonts(:doradani_regular)
    font.font_subfamily = nil
    font.full_name.should == 'Doradani'
  end

  it 'should return full name when both family and subfamily are present' do
    fonts(:doradani_regular).full_name.should == 'Doradani Regular'
  end

  it 'should raise an error if retrieving a missing format with the raise error option' do
    doing {
      fonts(:duality).format(:woff, :raise_error => true)
    }.should raise_error(ActiveRecord::RecordNotFound, 'Could not find the specified format for that font.')
  end

  it 'should create and generate new formats successfully' do
    FontAdapter.any_instance.expects(:to_otf)
    FontAdapter.any_instance.expects(:to_woff)
    FontAdapter.any_instance.expects(:to_eot)
    ActionController::TestUploadedFile.expects(:new).times(3)
    Format.any_instance.expects(:save!).times(3)
    FileUtils.expects(:rm).times(3)
    font = Factory.create(:font)
  end
end
