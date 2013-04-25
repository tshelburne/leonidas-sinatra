module Commands

	class CommandProcessor

		def initialize
			@command_handlers = [ ]
		end

		def add_handler!(handler)
			raise TypeError, "Argument must be an extension of Commands::CommandHandler." unless handler < Commands::CommandHandler
			@command_handlers << handler
		end
		
		def run(commands)
			commands.each do |command|
				raise TypeError, "Argument must be a Commands::Command." unless command.is_a? Commands::Command
				@command_handlers.each do |command_handler|
					command_handler.run(command) if command_handler.handles? command
				end
			end
		end

		def commit(commands)
			commands.each do |command|
				raise TypeError, "Argument must be a Commands::Command." unless command.is_a? Commands::Command
				@command_handlers.each do |command_handler|
					command_handler.commit(command) if command_handler.handles? command
				end
			end
		end

	end
	
end