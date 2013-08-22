module Leonidas
	module MemoryLayer

		class MemoryRegistry
			
			@@apps = { }

			def self.register_app!(app)
				raise TypeError, "Argument must include Leonidas::App::App" unless app.class < ::Leonidas::App::App
				raise StandardError, "An app with the name '#{app.name}' is already registered" if ::Leonidas::MemoryLayer::MemoryRegistry.has_app? app.name
				@@apps[app.name] = app
			end

			def self.all_apps
				@@apps.map {|app_name, app| app}
			end

			def self.retrieve_app(name)
				@@apps[name]
			end

			def self.has_app?(name)
				not MemoryRegistry.retrieve_app(name).nil?
			end

			def self.close_app!(name)
				@@apps.delete name
			end

			def self.clear_registry!
				@@apps = { }
			end

		end

	end
end