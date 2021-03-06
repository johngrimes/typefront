require 'spec_helper'

describe GenerateFormatJob do
  it 'should perform job' do
    @font = mock()
    Font.expects(:find).with(1).returns(@font)
    @font.expects(:generate_format)
    @font.expects(:generate_jobs_pending).returns(3)
    @font.expects(:update_attribute).with(:generate_jobs_pending, 2)
    GenerateFormatJob.perform(:font_id => 1, :format => 'ttf', :description => 'TrueType')
  end
end
