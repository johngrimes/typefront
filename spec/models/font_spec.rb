require 'spec_helper'

describe Font do
  describe 'validation' do
    before do
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

  describe 'log_request' do
    it 'should be successful' do
      LoggedRequest.any_instance.expects(:save)
      fonts(:duality).log_request('show',
        :format => :woff,
        :remote_ip => '193.485.378.485',
        :referer => 'http://johnsmith.com/index.php',
        :user_agent => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_8; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5',
        :response_time => 5.458)
    end

    it 'should be successful with a blank referer' do
      LoggedRequest.any_instance.expects(:save)
      fonts(:duality).log_request('show',
        :format => :eot,
        :remote_ip => '193.485.378.485',
        :user_agent => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_8; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5',
        :response_time => 2.456)
    end

    it 'should not log a request with a TypeFront referer' do
      LoggedRequest.any_instance.expects(:save).never
      fonts(:duality).log_request('show',
        :remote_ip => '193.485.378.485',
        :referer => "#{$HOST}/fonts/15",
        :user_agent => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_8; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5')
    end
  end

  describe 'full_name' do
    it 'should be successful' do
      fonts(:doradani_regular).full_name.should == 'Doradani Regular'
    end

    it 'should return family name when subfamily is blank' do
      font = fonts(:doradani_regular)
      font.font_subfamily = nil
      font.full_name.should == 'Doradani'
    end
  end

  describe 'format' do
    it 'should raise an error if retrieving a missing format with the raise error option' do
      doing {
        fonts(:duality).format(:pfb, :raise_error => true)
      }.should raise_error(ActiveRecord::RecordNotFound, 'Could not find the specified format for that font.')
    end

    it 'should not raise an error if retrieving a missing format without the raise error option' do
      fonts(:duality).format(:pfb)
    end
  end

  describe 'post_process' do
    it 'should generate all formats' do
      Resque.expects(:enqueue).times(5)
      Font.any_instance.expects(:update_attribute)
      fonts(:duality).generate_all_formats
    end

    it 'should generate new format successfully' do
      adapter = mock
      FontAdapter.expects(:new).returns(adapter)
      adapter.expects(:to_doc)
      ActionController::TestUploadedFile.expects(:new)
      FontFormat.any_instance.expects(:save!)
      FileUtils.expects(:rm_f)
      fonts(:duality).generate_format('doc', 'Word Document')
    end

    it 'should regenerate existing format successfully' do
      adapter = mock
      FontAdapter.expects(:new).returns(adapter)
      adapter.expects(:to_ttf)
      ActionController::TestUploadedFile.expects(:new)
      FontFormat.any_instance.expects(:save!)
      FileUtils.expects(:rm_f)
      fonts(:duality).generate_format('ttf', 'TrueType')
    end
  end
end
