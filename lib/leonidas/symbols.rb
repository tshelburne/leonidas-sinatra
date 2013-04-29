module Leonidas

	@@pipeline ||= ::Keystone.bootstrap("#{File.dirname(__FILE__)}/../../config/assets.rb")
	
	def self.keystone_compiler
		@@keystone_compiler ||= @@pipeline.compiler("leonidas.js")
	end

end