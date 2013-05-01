module TestClasses

	class TestApp
		include ::Leonidas::App::App
		
		def initialize(name="app 1")
			@name = name
			@persist_state = false
			@locked_state = { value: 0 }
			@active_state = { value: 1 }
			@connections = [ ]
			@processor = ::Leonidas::Commands::Processor.new([ IncrementHandler.new(self), MultiplyHandler.new(self) ])
		end

		def state=(val)
			@locked_state = val.dup
			@active_state = val.dup
		end

	end

	class TestRepositoryContainer
		include ::Leonidas::App::AppRepository
	end

end