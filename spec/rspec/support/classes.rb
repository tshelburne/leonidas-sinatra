module TestClasses

	class TestApp
		include Leonidas::App::App
		
		def initialize(name="app 1")
			@name = name
			@persistent = false
			@locked_state = { value: 0 }
			@active_state = { value: 1 }
			@connections = [ ]
			@processor = Leonidas::Commands::Processor.new([ IncrementHandler.new(self), MultiplyHandler.new(self) ])
		end

	end

	class IncrementHandler 
		include Leonidas::Commands::Handler

		def initialize(app)
			@app = app
		end

		def handles?(command)
			command.name == "increment"
		end

		def run(command)
			@app.current_state[:value] += command.data[:increment_by]
		end

		def commit(command)
			TestClasses::PersistentState.value += command.data[:increment_by]
		end
	end

	class MultiplyHandler 
		include Leonidas::Commands::Handler

		def initialize(app)
			@app = app
		end

		def handles?(command)
			command.name == "multiply"
		end

		def run(command)
			@app.current_state[:value] *= command.data[:multiply_by]
		end

		def commit(command)
			TestClasses::PersistentState.value *= command.data[:multiply_by]
		end
	end

	class TestAggregator
		include Leonidas::Commands::Aggregator

		def initialize
				@active_commands = [ ]
				@inactive_commands = [ ]
			end
	end

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

end