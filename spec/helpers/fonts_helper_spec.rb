require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FontsHelper do
  include FontsHelper

  before do
    @font = Factory.build(:font)
    @font.stubs(:id).returns(12345)
    @font.stubs(:font_family).returns('Duality')
    @font.stubs(:font_subfamily).returns('Regular')
    @font.expects(:format).with(:svg, :ignore_inactive => true, :raise_error => false).returns(true)
    @font.expects(:format).with(:eot, :ignore_inactive => true, :raise_error => false).returns(true)
    @font.expects(:format).with(:woff, :ignore_inactive => true, :raise_error => false).returns(true)
    @font.expects(:format).with(:otf, :ignore_inactive => true, :raise_error => false).returns(true)
    @font.expects(:format).with(:ttf, :ignore_inactive => true, :raise_error => false).returns(true)
  end

  it 'should generate include code' do
    result = include_code(@font)
    result.should == '@font-face {
  font-family: "Duality";
  src: url("http://staging.typefront.com/fonts/12345.eot");
  src: local("☺"),
       url("http://staging.typefront.com/fonts/12345.woff") format("woff"),
       url("http://staging.typefront.com/fonts/12345.ttf") format("truetype"),
       url("http://staging.typefront.com/fonts/12345.otf") format("opentype"),
       url("http://staging.typefront.com/fonts/12345.svg") format("svg");
  font-weight: normal;
  font-style: normal;
}'
  end

  it 'should generate include code with unique font names' do
    result = include_code(@font, :unique_font_names => true)
    result.should == '@font-face {
  font-family: "Duality 12345";
  src: url("http://staging.typefront.com/fonts/12345.eot");
  src: local("☺"),
       url("http://staging.typefront.com/fonts/12345.woff") format("woff"),
       url("http://staging.typefront.com/fonts/12345.ttf") format("truetype"),
       url("http://staging.typefront.com/fonts/12345.otf") format("opentype"),
       url("http://staging.typefront.com/fonts/12345.svg") format("svg");
  font-weight: normal;
  font-style: normal;
}'
  end

  it 'should generate include code with markup' do
    result = include_code(@font, :include_markup => true)
    result.should == '@font-face {
  font-family: "Duality";
<span class="eot-code">  src: url("http://staging.typefront.com/fonts/12345.eot");
</span><span class="noneot-code">  src: local("☺"),
       <span class="woff-code">url("http://staging.typefront.com/fonts/12345.woff") format("woff")</span><span class="woff-ttf-separator">,
       </span><span class="ttf-code">url("http://staging.typefront.com/fonts/12345.ttf") format("truetype")</span><span class="ttf-otf-separator">,
       </span><span class="otf-code">url("http://staging.typefront.com/fonts/12345.otf") format("opentype")</span><span class="otf-svg-separator">,
       </span><span class="svg-code">url("http://staging.typefront.com/fonts/12345.svg") format("svg")</span>;
</span><span class="style-descriptors">  font-weight: normal;
  font-style: normal;
</span>}'
  end
end
