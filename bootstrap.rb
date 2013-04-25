require 'bundler'
Bundler.require

require_rel 'app'

Keystone::Server.pipeline = Keystone.bootstrap("#{File.dirname(__FILE__)}/config/assets.rb")