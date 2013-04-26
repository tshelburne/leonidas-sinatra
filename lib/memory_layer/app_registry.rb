module Leonidas
	module MemoryLayer

		class AppRegistry

			def self.retrieve_app(id)
				@@apps[id]
			end
			
			def self.register_app!(app)
				raise TypeError, "Argument must be a Leonidas::App::CommanderApp" unless app.is_a? Leonidas::App::CommanderApp
				@@apps[app.id] = app
			end

			def self.close_app!(id)
				@@apps[id] = nil
			end

		end

	end
end