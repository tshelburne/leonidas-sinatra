module Leonidas
	module Commands

		module Aggregator

			def add_command!(command, sort=true)
				raise TypeError, "Argument must be a Leonidas::Commands::Command." unless command.is_a? Leonidas::Commands::Command
				@active_commands << command
				@active_commands.sort! {|command1, command2| command1.timestamp <=> command2.timestamp} if sort
			end

			def add_commands!(commands)
				commands.each {|command| add_command!(command, false)}
				@active_commands.sort! {|command1, command2| command1.timestamp <=> command2.timestamp}
			end

			def commands_through(timestamp)
				@active_commands.select {|command| command.timestamp <= timestamp}
			end

			def commands_since(timestamp)
				@active_commands.select {|command| command.timestamp > timestamp}
			end

			def deactivate_commands!(commands)
				commands.each {|command| @inactive_commands << command if @active_commands.include? command}
				@active_commands.select! {|command| not commands.include? command}
			end

		end

	end
end