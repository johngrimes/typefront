require 'action_controller/test_process.rb'

Factory.define :font do |font|
  font.name 'Duality'
  font.original ActionController::TestUploadedFile.new(
    "#{RAILS_ROOT}/spec/fixtures/duality.ttf",
    'font/ttf')
  font.domains {|font| [font.association(:domain)]}
  font.verification '1'
end
