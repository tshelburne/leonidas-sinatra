module Leonidas
	module Commands

		module Aggregator

			def add_command!(command)
				raise TypeError, "Argument must be a Leonidas::Commands::Command" unless command.is_a? ::Leonidas::Commands::Command
				@active_commands << command
			end

			def add_commands!(commands)
				commands.each {|command| add_command!(command)}
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