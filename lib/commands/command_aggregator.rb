module Leonidas
	module Commands

		class CommandAggregator

			attr_accessor :commands

			def initialize
				@commands = [ ]
			end

			def add_command!(command, sort=true)
				raise TypeError, "Argument must be a Commands::Command." unless command.is_a? Commands::Command
				@commands << command
				@commands.sort! {|command1, command2| command1.timestamp <=> command2.timestamp} if sort
			end

			def add_commands!(commands)
				commands.each {|command| add_command!(command, false)}
				@commands.sort! {|command1, command2| command1.timestamp <=> command2.timestamp}
			end

			def stable_commands(stable_timestamp)
				@commands.select {|command| command.timestamp <= stable_timestamp}
			end

			def deactivate_commands!(commands)
				@commands.select! {|command| not commands.include? command}
			end

		end

	end
end