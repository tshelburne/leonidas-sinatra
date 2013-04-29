module TestClasses

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

		def persist(command)
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

		def persist(command)
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

end