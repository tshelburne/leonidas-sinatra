require 'rspec/core/rake_task'
require 'jasmine-headless-webkit'
require 'keystone'

desc "Default"
task default: :test

desc "Run tests"
Jasmine::Headless::Task.new(test: :assets) do |t|
  t.colors = true
  t.keep_on_error = true
  t.jasmine_config = './spec/jasmine/jasmine.yml'
end

desc "Build assets"
Keystone::RakeTask.new :assets do |t|
  t.config_file = "config/assets.rb"
  t.output_path = 'bin'
end