module Leonidas
	module MemoryLayer

		class MemoryRegistry
			
			@@apps = { }

			def self.register_app!(app)
				raise TypeError, "Argument must include Leonidas::App::App" unless app.class < Leonidas::App::App
				@@apps[app.id] = app
			end

			def self.retrieve_app(id)
				@@apps[id]
			end

			def self.has_app_registered?(id)
				not MemoryRegistry.retrieve_app(id).nil?
			end

			def self.close_app!(id)
				@@apps.delete id
			end

		end

	end
end