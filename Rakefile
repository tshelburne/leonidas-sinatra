$: << File.expand_path("#{File.dirname(__FILE__)}/lib")

require 'leonidas'

require 'rspec/core/rake_task'
require 'echoe'

Echoe.new("leonidas") do |p|
  p.author = "Tim Shelburne"
  p.email = "shelburt02@gmail.com"
  p.url = "https://github.com/tshelburne/leonidas-rb"

  p.ignore_pattern = FileList[".gitignore"]
end

desc "Default"
task default: :test

desc "Run Rspec tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = "-dcfd --require spec_helper"
  # t.pattern = 'spec/**/app_spec.rb'
end