module Test

	class TestApp
		include Leonidas::App::App
		
		def initialize
			@id = "1234"
			@locked_state = { value: 0 }
			@active_state = { value: 0 }
			@connections = [ ]
			@processor = Leonidas::Commands::Processor.new([ IncrementHandler.new, MultiplyHandler.new ])
		end

	end

	class IncrementHandler < Leonidas::Commands::Handler

	end

	class MultiplyHandler < Leonidas::Commands::Handler

	end

	class TestAggregator
		include Leonidas::Commands::Aggregator

		def initialize
				@active_commands = [ ]
				@inactive_commands = [ ]
			end
	end

end