module TestClasses

	class IncrementHandler < ::Leonidas::Commands::Handler

		def initialize(app)
			@app = app
			@name = "increment"
		end

		def run(command)
			@app.current_state[:value] += command.data[:number].to_i
		end

		def persist(command)
			TestClasses::PersistentState.value += command.data[:number].to_i
		end

		def rollback(command)
			@app.current_state[:value] -= command.data[:number].to_i
		end

		def rollback_persist(command)
			TestClasses::PersistentState.value -= command.data[:number].to_i
		end
	end

	class MultiplyHandler < ::Leonidas::Commands::Handler

		def initialize(app)
			@app = app
			@name = "multiply"
		end

		def run(command)
			@app.current_state[:value] *= command.data[:number].to_i
		end

		def persist(command)
			TestClasses::PersistentState.value *= command.data[:number].to_i
		end

		def rollback(command)
			@app.current_state[:value] /= command.data[:number].to_i
		end

		def rollback_persist(command)
			TestClasses::PersistentState.value /= command.data[:number].to_i
		end
	end

	class TestCommandContainer
		include ::Leonidas::Commands::Aggregator
		include ::Leonidas::Commands::Filterer

		def initialize
			@commands = [ ]
		end

		def all_commands
			@commands
		end
	end

	class InvalidTestCommandContainer
		include ::Leonidas::Commands::Aggregator
		include ::Leonidas::Commands::Filterer

	end

end