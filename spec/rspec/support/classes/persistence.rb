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

		def load(app_name)

		end

		def persist(app)

		end

		def delete(app)

		end

	end

	class TestAppStateBuilder
		include Leonidas::PersistenceLayer::StateBuilder

		def handles?(app)
			
		end

		def build_state(app)

		end

	end

end