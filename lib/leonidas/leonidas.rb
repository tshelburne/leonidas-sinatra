module Leonidas
	def self.bootstrap(config_path)
		dsl = Leonidas::Dsl.new
		dsl.instance_eval File.read(path)
	end
end