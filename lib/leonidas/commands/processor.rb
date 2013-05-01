module Leonidas
	module Commands

		class Processor

			def initialize(handlers)
				@handlers = [ ]
				handlers.each do |handler|
					raise TypeError, "Argument must include Leonidas::Commands::Handler" unless handler.class < ::Leonidas::Commands::Handler
					@handlers << handler
				end
			end
			
			def process(commands, persist=false)
				commands.sort! {|command1, command2| command1.timestamp <=> command2.timestamp}
				commands.each do |command|
					raise TypeError, "Argument must be a Leonidas::Commands::Command" unless command.is_a? ::Leonidas::Commands::Command
					@handlers.each do |command_handler|
						if command_handler.handles? command
							command_handler.run(command) 
							command_handler.persist(command) if persist
						end
					end
				end
			end

		end
		
	end
end