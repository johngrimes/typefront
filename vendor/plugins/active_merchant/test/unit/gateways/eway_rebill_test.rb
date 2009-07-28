require File.dirname(__FILE__) + '/../../test_helper'

class EwayRebillTest < Test::Unit::TestCase
  def setup
    @gateway = EwayGateway.new(
      :login => '87654321'
    )
  end
  
  def test_interval_type
    interval_types = {
      :daily => 1,
      :weekly => 2,
      :biweekly => 2,
      :quadweekly => 2,
      :monthly => 3,
      :bimonthly => 3,
      :quarterly => 3,
      :yearly => 4,
      :biyearly => 4
    }

    interval_types.each { |key, value| assert_equal(value, @gateway.interval_type(key)) }
  end
end