module Leonidas
	module App
		module AppRepository
			def app_repository
				@repository ||= Repository.new
			end
		end
		
		class Repository

			def find(app_name)
				app = Leonidas::MemoryLayer::MemoryRegistry.retrieve_app app_name
				app = Leonidas::PersistenceLayer::Persister.load app_name if app.nil?
				app
			end

			def watch(app)
				Leonidas::MemoryLayer::MemoryRegistry.register_app! app
			end

			def save(app)
				Leonidas::PersistenceLayer::Persister.persist app
			end

			def archive(app)
				Leonidas::MemoryLayer::MemoryRegistry.close_app! app.name
				Leonidas::PersistenceLayer::Persister.persist app
			end

			def delete(app)
				Leonidas::MemoryLayer::MemoryRegistry.close_app! app.name
				Leonidas::PersistenceLayer::Persister.delete app
			end

		end

	end
end