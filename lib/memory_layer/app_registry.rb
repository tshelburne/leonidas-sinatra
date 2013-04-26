module Leonidas
	module MemoryLayer

		class AppRegistry
			
			@@apps = [ ]

			def self.register_app!(app)
				raise TypeError, "Argument must be a Leonidas::MemoryLayer::App" unless app.is_a? Leonidas::MemoryLayer::App
				@@apps[app.id] = app
			end

			def self.retrieve_app(id)
				@@apps[id]
			end

			def self.app_is_registered?(id)
				AppRegistry.retrieve_app(id).nil?
			end

			def self.close_app!(id)
				@@apps[id] = nil
			end

		end

	end
end