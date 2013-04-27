require 'rspec/core/rake_task'
require 'jasmine-headless-webkit'
require 'keystone'

desc "Default"
task default: :'test:rspec'

namespace :test do

	desc "Run Rspec tests"
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = "-dcfd --require rspec/spec_helper"
  end

	desc "Run Jasmine tests"
	Jasmine::Headless::Task.new(jasmine: :assets) do |t|
	  t.colors = true
	  t.keep_on_error = true
	  t.jasmine_config = './spec/jasmine/jasmine.yml'
	end
	
end

desc "Build assets"
Keystone::RakeTask.new :assets do |t|
  t.config_file = "config/assets.rb"
  t.output_path = 'bin'
end