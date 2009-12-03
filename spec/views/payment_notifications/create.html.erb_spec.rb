require 'spec_helper'

describe "/payment_notifications/create" do
  before(:each) do
    render 'payment_notifications/create'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/payment_notifications/create])
  end
end
