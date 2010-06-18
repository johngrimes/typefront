require 'spec_helper'

describe DomainsController do
  before do
    login users(:bob)
  end

  describe 'create action' do
    it 'should be successful' do
      Domain.any_instance.expects(:valid?).returns(true)
      post 'create',
        :format => 'json',
        :font_id => fonts(:duality).id
      assigns[:domain].should_not be_new_record
      flash[:notice].should_not be(nil)
      response.should be_success
      response.content_type.should =~ /application\/json/
    end

    it 'should return an error message if unsuccessful' do
      Domain.any_instance.expects(:valid?).returns(false)
      post 'create',
        :format => 'json',
        :font_id => fonts(:duality).id
      assigns[:domain].should be_new_record
      response.code.should == '422'
      response.content_type.should =~ /application\/json/
    end
  end

  describe 'destroy action' do
    it 'should be successful' do
      Domain.any_instance.expects(:destroy).returns(domains(:typefront))
      delete 'destroy', :font_id => fonts(:duality), :id => domains(:typefront)
      response.should redirect_to(font_url(fonts(:duality)))
    end

    it 'should not allow removal of a domain that does not belong to the current user' do
      doing {
        delete 'destroy', :font_id => fonts(:doradani_regular), :id => domains(:johns)
      }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should not allow removal of a domain that does not belong to the specified font' do
      delete 'destroy', :font_id => fonts(:triality), :id => domains(:typefront)
      response.code.should == '403'
    end
  end

  describe 'API' do
    describe 'destroy action' do
      it 'should be successful' do
        Domain.any_instance.expects(:destroy).returns(domains(:typefront))
        delete 'destroy', 
          :font_id => fonts(:duality), 
          :id => domains(:typefront),
          :format => 'json'
        response.should be_success
        response.content_type.should =~ /application\/json/
      end
    end
  end
end
