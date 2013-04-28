module Leonidas
	module MemoryLayer

		class MemoryRegistry
			
			@@apps = { }

			def self.register_app!(app)
				raise TypeError, "Argument must include Leonidas::App::App" unless app.class < Leonidas::App::App
				@@apps[app.name] = app
			end

			def self.retrieve_app(name)
				@@apps[name]
			end

			def self.has_app_registered?(name)
				not MemoryRegistry.retrieve_app(name).nil?
			end

			def self.close_app!(name)
				@@apps.delete name
			end

		end

	end
end