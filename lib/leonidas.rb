require 'leonidas/symbols'
%w(aggregator command handler processor).each {|file| require "leonidas/commands/#{file}"}
%w(app client repository).each {|file| require "leonidas/app/#{file}"}
%w(configuration_expression).each {|file| require "leonidas/dsl/#{file}"}
%w(memory_registry).each {|file| require "leonidas/memory_layer/#{file}"}
%w(state_loader persister state_builder).each {|file| require "leonidas/persistence_layer/#{file}"}
%w(sync).each {|file| require "leonidas/routes/#{file}"}

module Leonidas
	def self.bootstrap(config_path)
		dsl = ::Leonidas::Dsl::ConfigurationExpression.new
		dsl.instance_eval File.read(config_path)
	end
end