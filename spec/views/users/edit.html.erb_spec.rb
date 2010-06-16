require 'spec_helper'

describe 'users/edit.html.erb' do
  before do
    login users(:john)
    assigns[:user] = users(:john)
  end

  it 'should render successfully' do
    render 'users/edit', :layout => 'standard'
    response.should be_success
  end

  it 'should render successfully when upgrading or downgrading' do
    assigns[:subscription_level] == User::PLUS
    render 'users/edit', :layout => 'standard'
    response.should be_success
  end
end
