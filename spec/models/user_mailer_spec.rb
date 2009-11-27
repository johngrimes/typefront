require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserMailer do
  fixtures :all

  it "should deliver activation email" do
    doing {
      UserMailer.deliver_activation users(:bob)
    }.should change(ActionMailer::Base.deliveries, :size).by(+1)
  end
end
