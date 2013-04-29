module Leonidas
	module PersistenceLayer
		module AppPersister
			
			def load(app_name)
				# load your app
			end

			def persist(app)
				# save your app (this excludes state saving, that happens in the command handlers)
			end

			def delete(app)
				# delete your app
			end

		end
		
		class Persister

			@@persister = nil

			def self.set_app_persister!(persister)
				raise TypeError, "Argument must include Leonidas::PersistenceLayer::AppPersister" unless persister.class < Leonidas::PersistenceLayer::AppPersister
				@@persister = persister
			end

			@@state_loader = Leonidas::PersistenceLayer::StateLoader.new

			def self.add_state_builder!(builder)
				@@state_loader.add_builder! builder	
			end
			
			def self.load(app_name)
				app = @@persister.load app_name unless @@persister.nil?
				unless app.nil?
					@@state_loader.load_state app
					app.process_commands!
				end
				app
			end

			def self.persist(app)
				@@persister.persist app unless @@persister.nil?
			end

			def self.delete(app)
				@@persister.delete app unless @@persister.nil?
			end

		end

	end
end