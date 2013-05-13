module TestClasses

	class TestApp
		include ::Leonidas::App::App
		
		def initialize(name="app-1")
			@name = name
			@persist_state = false
			@state = { value: 0 }
		end

		def handlers
			[ 
				IncrementHandler.new(self), 
				MultiplyHandler.new(self) 
			]
		end

		def state=(val)
			@state = val.dup
		end

	end

	class TestRepositoryContainer
		include ::Leonidas::App::AppRepository
	end

end