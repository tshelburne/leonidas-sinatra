module Leonidas
	module Commands

		class Stabilizer
			
			def initialize(app, processor)
				raise TypeError, "Argument must include Leonidas::App::App" unless app < Leonidas::App::App
				@app = app

				raise TypeError, "Argument must be a Leonidas::Commands::Processor" unless processor.is_a? Leonidas::Commands::Processor
				@processor = processor
			end

			def stabilize
				@app.revert_state!
				stable_commands = @app.connections.reduce([ ]) {|commands, connection| commands.concat! connection.commands_through(@app.stable_timestamp)}
				@processor.process stable_commands
				@app.lock_state!
				@app.connections.each {|connection| connection.deactivate_commands!(stable_commands)}
			end

		end
		
	end
end