module Leonidas
	module Commands

		module Aggregator

			def add_command!(command)
				raise TypeError, "Argument must be a Leonidas::Commands::Command" unless command.is_a? ::Leonidas::Commands::Command
				@commands << command
			end

			def add_commands!(commands)
				commands.each {|command| add_command!(command)}
			end

			def commands_through(timestamp)
				@commands.select {|command| command.timestamp <= timestamp}
			end

			def commands_since(timestamp)
				@commands.select {|command| command.timestamp > timestamp}
			end

		end

	end
end