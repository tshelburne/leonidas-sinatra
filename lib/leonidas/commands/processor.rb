module Leonidas
	module Commands

		class Processor

			def initialize(handlers)
				handlers.each do |handler|
					raise TypeError, "Argument must be an extension of Commands::Handler" unless handler < Commands::Handler
				end
				@command_handlers = handlers
			end
			
			def process(commands)
				commands.each do |command|
					raise TypeError, "Argument must be a Commands::Command" unless command.is_a? Commands::Command
					@command_handlers.each do |command_handler|
						command_handler.run(command) if command_handler.handles? command
					end
				end
			end

			def commit(commands)
				commands.each do |command|
					raise TypeError, "Argument must be a Commands::Command" unless command.is_a? Commands::Command
					@command_handlers.each do |command_handler|
						command_handler.commit(command) if command_handler.handles? command
					end
				end
			end

		end
		
	end
end