module TestClasses

	class PersistentState

		@@value = 0
		
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
		include ::Leonidas::PersistenceLayer::AppPersister

		def initialize(apps=[])
			@apps = [ ]
			apps.each {|app| persist(app)}
		end

		def clear_apps!
			@apps = [ ]
		end

		def load(app_name)
			@apps.select {|app| app.name == app_name}.first
		end

		def persist(app)
			app.instance_variable_set(:@cached_active_commands, nil)
			app.instance_variable_set(:@cached_stable_commands, nil)
			@apps << app
		end

		def delete(app)
			@apps.delete app
		end

	end

	class TestAppStateBuilder
		include ::Leonidas::PersistenceLayer::StateBuilder

		def handles?(app)
			app.is_a? TestClasses::TestApp
		end

		def build_stable_state(app)
			app.state = 0
			app.state
		end

	end

end