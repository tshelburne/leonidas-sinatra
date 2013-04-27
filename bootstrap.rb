require 'bundler'
Bundler.require

require_rel 'lib'

Keystone::Server.pipeline = Keystone.bootstrap("#{File.dirname(__FILE__)}/config/assets.rb")