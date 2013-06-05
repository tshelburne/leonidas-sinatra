module Leonidas
	module Commands

		class Processor

			def initialize(handlers)
				@handlers = [ ]
				handlers.each do |handler|
					raise TypeError, "Argument must extend Leonidas::Commands::Handler" unless handler.is_a? ::Leonidas::Commands::Handler
					@handlers << handler
				end
			end
			
			def run(commands, persist=false)
				commands.sort! {|command1, command2| command1.timestamp <=> command2.timestamp}
				commands.each do |command|
					raise TypeError, "Argument must be a Leonidas::Commands::Command" unless command.is_a? ::Leonidas::Commands::Command
					@handlers.each do |handler|
						if handler.handles? command
							handler.run_wrapper(command) 
							handler.persist_wrapper(command) if persist
						end
					end
				end
			end

			def rollback(commands)
				commands.sort! {|command1, command2| command2.timestamp <=> command1.timestamp}
				commands.each do |command|
					raise TypeError, "Argument must be a Leonidas::Commands::Command" unless command.is_a? ::Leonidas::Commands::Command
					@handlers.each do |handler|
						if handler.handles? command
							handler.rollback_wrapper(command)
							handler.rollback_persist_wrapper(command) if command.has_been_persisted?
						end
					end
				end
			end

		end
		
	end
end