require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FontsHelper do
  include FontsHelper

  it 'should generate include code for font with all three formats' do
    font = Factory.build(:font)
    font.stubs(:id).returns(12345)
    font.stubs(:font_family).returns('Duality')
    font.stubs(:font_subfamily).returns('Regular')
    font.expects(:format).with(:svg, :raise_error => false).returns(true)
    font.expects(:format).with(:eot, :raise_error => false).returns(true)
    font.expects(:format).with(:woff, :raise_error => false).returns(true)
    font.expects(:format).with(:otf, :raise_error => false).returns(true)
    font.expects(:format).with(:ttf, :raise_error => false).returns(true)
    include_code(font, :unique_font_names => true, :include_markup => true)
  end
end
