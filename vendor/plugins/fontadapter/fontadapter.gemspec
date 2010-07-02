require 'rubygems'

SPEC = Gem::Specification.new do |s|
  s.name = "fontadapter"
  s.version = "0.3.0"
  s.author = "Small Spark"
  s.email = "contact@smallspark.com.au"
  s.homepage = "http://www.smallspark.com.au"
  s.platform = Gem::Platform::RUBY
  s.summary = "A validation and conversion utility for font files."
  s.files = Dir.glob("{lib,spec}/**/*")
  s.require_path = "lib"
  s.autorequire = "fontadapter"
end
