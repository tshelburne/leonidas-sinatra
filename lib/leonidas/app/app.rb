module Leonidas
	module App

		module App
			include ::Leonidas::Commands::Filterer

			attr_accessor :name

			def app_type
				self.class.to_s
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

			def commands_from_client(client_id, timestamp=nil)
				client = client(client_id)
				client.nil? ? nil : client.commands_since(timestamp || 0)
			end

			def process_commands!
				@cached_active_commands ||= [ ]
				@cached_stable_commands ||= [ ]

				current_active_commands = active_commands
				current_stable_commands = stable_commands

				# rollback to previous stable state
				processor.rollback @cached_active_commands

				new_stable_commands = current_stable_commands.select {|command| not @cached_stable_commands.include? command}
				unless new_stable_commands.empty?
					oldest_new_stable_command = new_stable_commands.min_by {|command| command.timestamp}

					# rollback to the oldest of the new stable commands
					cached_stable_commands_since_oldest  = commands_from(oldest_new_stable_command, @cached_stable_commands)
					processor.rollback cached_stable_commands_since_oldest, persistent_state?
					
					# run all stable commands since the oldest new stable command to the new stable state
					current_stable_commands_since_oldest = commands_from(oldest_new_stable_command, current_stable_commands)
					processor.run current_stable_commands_since_oldest, persistent_state?
				end

				# run all active commands to new active state
				processor.run current_active_commands

				@cached_active_commands = current_active_commands
				@cached_stable_commands = current_stable_commands
			end

			def require_reconciliation!
				@checked_in_clients = [ ]
				@reconciled = false
			end

			def check_in!(client_id, other_client_ids)
				unless reconciled?
					@checked_in_clients << recreate_client!(client_id)
					other_client_ids.each {|id| recreate_client! id}
				end
				check_reconciliation!
			end

			def has_checked_in?(client_id)
				@checked_in_clients.include? client(client_id)
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

			def all_commands
				clients.reduce([ ]) {|commands, client| commands + client.all_commands}
			end

			def active_commands
				commands_since(stable_timestamp)
			end

			def stable_commands
				commands_through(stable_timestamp)
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
				clients.each {|client| @reconciled = false unless has_checked_in? client.id}
			end

		end
		
	end
end