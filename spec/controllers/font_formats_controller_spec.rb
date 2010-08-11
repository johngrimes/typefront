require 'spec_helper'

describe FontFormatsController do
  before do
    login users(:bob)
  end

  describe 'update action' do
    it 'should be successful' do
      FontFormat.any_instance.expects(:valid?).returns(true)
      put 'update',
        :font_id => fonts(:duality).id,
        :id => font_formats(:duality_ttf).id
      response.should be_redirect
    end

    it 'should render font show page if unsuccessful' do
      FontFormat.any_instance.expects(:valid?).returns(false)
      put 'update',
        :font_id => fonts(:duality).id,
        :id => font_formats(:duality_ttf).id
      response.should render_template('fonts/show')
    end
  end

  describe 'AJAX' do
    describe 'update action' do
      it 'should be successful' do
        FontFormat.any_instance.expects(:valid?).returns(true)
        put 'update',
          :font_id => fonts(:duality).id,
          :id => font_formats(:duality_ttf).id,
          :format => 'js'
        response.should be_success
        response.content_type.should =~ /text\/javascript/
      end

      it 'should render font show page if unsuccessful' do
        FontFormat.any_instance.expects(:valid?).returns(false)
        put 'update',
          :font_id => fonts(:duality).id,
          :id => font_formats(:duality_ttf).id,
          :format => 'js'
        response.should be_success
        response.content_type.should =~ /text\/javascript/
      end
    end
  end

  describe 'API' do
    describe 'update action' do
      it 'should be successful' do
        FontFormat.any_instance.expects(:valid?).returns(true)
        put 'update',
          :font_id => fonts(:duality).id,
          :id => font_formats(:duality_ttf).id,
          :format => 'json'
        flash[:notice].should_not be(nil)
        response.should be_success
        response.content_type.should =~ /application\/json/
      end

      it 'should render font show page if unsuccessful' do
        FontFormat.any_instance.expects(:valid?).returns(false)
        put 'update',
          :font_id => fonts(:duality).id,
          :id => font_formats(:duality_ttf).id,
          :format => 'json'
        response.code.should == '422'
        response.content_type.should =~ /application\/json/
      end
    end
  end
end
