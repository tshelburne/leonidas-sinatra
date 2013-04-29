module Leonidas
	def self.bootstrap(config_path)
		dsl = Leonidas::Dsl::ConfigurationExpression.new
		dsl.instance_eval File.read(config_path)
	end
end