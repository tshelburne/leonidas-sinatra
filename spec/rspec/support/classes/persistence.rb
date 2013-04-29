module TestClasses

	class PersistentState
		
		def self.reset
			@@value = 0
		end

		def self.value
			@@value
		end

		def self.value=(val)
			@@value = val
		end
	end

	class TestAppPersister
		include Leonidas::PersistenceLayer::AppPersister

		def initialize(apps=[])
			@apps = apps
		end

		def clear_apps!
			@apps = [ ]
		end

		def load(app_name)
			@apps.select {|app| app.name == app_name}.first
		end

		def persist(app)
			@apps << app
		end

		def delete(app)
			@apps.delete app
		end

	end

	class TestAppStateBuilder
		include Leonidas::PersistenceLayer::StateBuilder

		def handles?(app)
			app.is_a? TestApp
		end

		def build_stable_state(app)
			app.state = { value: 3 }
		end

	end

end