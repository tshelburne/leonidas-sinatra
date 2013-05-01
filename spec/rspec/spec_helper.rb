require 'leonidas'
%w(app commands persistence).each {|file| require_relative "support/classes/#{file}"}
require_relative 'support/mocks'
require_relative 'support/objects'