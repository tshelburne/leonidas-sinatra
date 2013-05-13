module Leonidas
	module App

		module App

			def name
				@name
			end

			def current_state
				@state
			end

			def create_connection!
				connection = ::Leonidas::App::Connection.new
				connections << connection
				connection.id
			end

			def close_connection!(id)
				connections.delete connection(id) if has_connection? id
			end

			def connection_list
				connections.map {|connection| connection.to_hash}
			end

			def stable_timestamp
				earliest_connection = connections.min_by {|connection| connection.last_update }
				earliest_connection.nil? ? Time.at(0) : earliest_connection.last_update
			end

			def add_commands!(connection_id, commands)
				commands.each {|command| raise TypeError, "Argument must be a Leonidas::Commands::Command" unless command.is_a? ::Leonidas::Commands::Command}
				raise TypeError, "Argument must be a valid connection id" unless has_connection? connection_id

				connection(connection_id).add_commands! commands
				process_commands!
			end

			def commands_from(connection_id, timestamp=nil)
				connection(connection_id).commands_since(timestamp || Time.at(0))
			end

			def process_commands!
				new_stable_commands = @cached_stable_commands.nil? ? stable_commands : stable_commands.select {|command| not @cached_stable_commands.include? command} 

				processor.rollback @cached_active_commands unless @cached_active_commands.nil?
				processor.run new_stable_commands, persistent_state?
				processor.run active_commands

				@cached_active_commands = active_commands
				@cached_stable_commands = stable_commands
			end

			private 

			def connections
				@connections ||= [ ]
			end

			def connection(id)
				connections.select {|connection| connection.id == id}.first
			end

			def has_connection?(id)
				not connection(id).nil?
			end

			def processor
				@processor ||= ::Leonidas::Commands::Processor.new(handlers)
			end

			def active_commands
				connections.reduce([ ]) {|commands, connection| commands.concat connection.commands_since(stable_timestamp)}
			end

			def stable_commands
				connections.reduce([ ]) {|commands, connection| commands.concat connection.commands_through(stable_timestamp)}
			end

			def persistent_state?
				@persist_state || false
			end

		end
		
	end
end