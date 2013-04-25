module Commands

	class CommandAggregator

		attr_accessor :commands, :sources

		def initialize
			@commands = [ ]
			@command_sources = [ ]
		end

		def add_source!(source)
			raise TypeError, "Argument must be an extension of Commands::CommandSource." unless source < Commands::CommandSource
			@command_sources << source
		end
		
		def add_command!(command, sort=true)
			raise TypeError, "Argument must be a Commands::Command." unless command.is_a? Commands::Command
			@commands << command
			@commands.sort! {|command1, command2| command1.timestamp <=> command2.timestamp } if sort
		end

		def add_commands!(commands)
			commands.each {|command| add_command!(command, false)}
			@commands.sort! {|command1, command2| command1.timestamp <=> command2.timestamp }
		end

		def shift_persistable_commands!
			current_common_timestamp = common_timestamp
			num_persistable_commands = @commands.count {|command| command.timestamp < current_common_timestamp}
			@commands.shift(num_persistable_commands)
		end

		def command_hashes
			commands.map {|command| { name: command.name, data: command.data, timestamp: command.timestamp }}
		end

		private

		def common_timestamp
			@command_sources.sort! {|source1, source2| source1.last_update <=> source2.last_update}.first.last_update
		end

	end

end