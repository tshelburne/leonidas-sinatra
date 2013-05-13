module Leonidas
	module App

		module App

			def name
				@name
			end

			def current_state
				@state
			end

			def create_client!
				client = ::Leonidas::App::Client.new
				clients << client
				client.id
			end

			def close_client!(id)
				clients.delete client(id) if has_client? id
			end

			def client_list
				clients.map {|client| client.to_hash}
			end

			def stable_timestamp
				earliest_client = clients.min_by {|client| client.last_update }
				earliest_client.nil? ? Time.at(0) : earliest_client.last_update
			end

			def add_commands!(client_id, commands)
				commands.each {|command| raise TypeError, "Argument must be a Leonidas::Commands::Command" unless command.is_a? ::Leonidas::Commands::Command}
				raise TypeError, "Argument must be a valid client id" unless has_client? client_id

				client(client_id).add_commands! commands
				process_commands!
			end

			def commands_from(client_id, timestamp=nil)
				client(client_id).commands_since(timestamp || Time.at(0))
			end

			def process_commands!
				new_stable_commands = @cached_stable_commands.nil? ? stable_commands : stable_commands.select {|command| not @cached_stable_commands.include? command} 

				processor.rollback @cached_active_commands unless @cached_active_commands.nil?
				processor.run new_stable_commands, persistent_state?
				processor.run active_commands

				@cached_active_commands = active_commands
				@cached_stable_commands = stable_commands
			end

			def require_reconciliation!
				@reconciled = false
			end

			def check_in!(client_id, other_clients)
				@checked_in_clients ||= [ ]
				unless reconciled?
					@checked_in_clients << recreate_client!(client_id)
					other_clients.each {|client_hash| recreate_client! client_hash[:id]}
				end
				check_reconciliation!
			end

			def reconciled?
				@reconciled.nil? ? true : @reconciled
			end

			private

			def clients
				@clients ||= [ ]
			end

			def client(id)
				clients.select {|client| client.id == id}.first
			end

			def has_client?(id)
				not client(id).nil?
			end

			def processor
				@processor ||= ::Leonidas::Commands::Processor.new(handlers)
			end

			def active_commands
				clients.reduce([ ]) {|commands, client| commands.concat client.commands_since(stable_timestamp)}
			end

			def stable_commands
				clients.reduce([ ]) {|commands, client| commands.concat client.commands_through(stable_timestamp)}
			end

			def persistent_state?
				@persist_state || false
			end

			def recreate_client!(id)
				return client(id) if has_client? id

				client = ::Leonidas::App::Client.new(id)
				clients << client
				client
			end

			def check_reconciliation!
				@reconciled = true
				clients.each {|client| @reconciled = false unless @checked_in_clients.include? client}
			end

		end
		
	end
end