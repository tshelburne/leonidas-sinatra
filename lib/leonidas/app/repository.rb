module Leonidas
	module App
		module AppRepository
			def app_repository
				@repository ||= Repository.new
			end
		end
		
		class Repository

			def find(app_name, app_type)
				app = ::Leonidas::MemoryLayer::MemoryRegistry.retrieve_app app_name
				if app.nil?
					app_class = app_type.to_s.split('::').inject(Object) {|o,c| o.const_get c}
					app = app_class.new
					app.name = app_name
					app.require_reconciliation!
					watch app
				end
				app
			end

			def load(app_name)
				app = ::Leonidas::PersistenceLayer::Persister.load app_name
				watch app unless app.nil?
				app
			end

			def watch(app)
				::Leonidas::MemoryLayer::MemoryRegistry.register_app! app
			end

			def save(app)
				::Leonidas::PersistenceLayer::Persister.persist app
			end

			def archive(app)
				::Leonidas::MemoryLayer::MemoryRegistry.close_app! app.name
				::Leonidas::PersistenceLayer::Persister.persist app
			end

			def delete(app)
				::Leonidas::MemoryLayer::MemoryRegistry.close_app! app.name
				::Leonidas::PersistenceLayer::Persister.delete app
			end

		end

	end
end