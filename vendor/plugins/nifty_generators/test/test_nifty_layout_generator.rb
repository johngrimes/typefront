require File.join(File.dirname(__FILE__), "test_helper.rb")

class TestNiftyLayoutGenerator < Test::Unit::TestCase
  include NiftyGenerators::TestHelper
  
  # Some generator-related assertions:
  #   assert_generated_file(name, &block) # block passed the file contents
  #   assert_directory_exists(name)
  #   assert_generated_class(name, &block)
  #   assert_generated_module(name, &block)
  #   assert_generated_test_for(name, &block)
  # The assert_generated_(class|module|test_for) &block is passed the body of the class/module within the file
  #   assert_has_method(body, *methods) # check that the body has a list of methods (methods with parentheses not supported yet)
  #
  # Other helper methods are:
  #   app_root_files - put this in teardown to show files generated by the test method (e.g. p app_root_files)
  #   bare_setup - place this in setup method to create the APP_ROOT folder for each test
  #   bare_teardown - place this in teardown method to destroy the TMP_ROOT or APP_ROOT folder after each test
  
  context "generator without name" do
    rails_generator :nifty_layout
    should_generate_file 'app/views/layouts/application.html.erb'
  end
  
  context "generator with name" do
    rails_generator :nifty_layout, "foobar"
    should_generate_file 'app/views/layouts/foobar.html.erb'
    should_generate_file 'public/stylesheets/foobar.css'
    should_generate_file 'app/helpers/layout_helper.rb'
  end
  
  context "generator with CamelCase name" do
    rails_generator :nifty_layout, "FooBar"
    should_generate_file 'app/views/layouts/foo_bar.html.erb'
  end
  
  context "generator with haml option" do
    rails_generator :nifty_layout, "foobar", :haml => true
    should_generate_file 'app/views/layouts/foobar.html.haml'
    should_generate_file 'public/stylesheets/sass/foobar.sass'
  end
end
