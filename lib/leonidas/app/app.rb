module Leonidas
	module App

		module App
			include ::Leonidas::Commands::Filterer

			attr_accessor :name

			def app_type
				self.class.to_s
			end

			def create_client!(id=nil)
				unless id.nil?
					return id if has_client? id
				end 

				client = ::Leonidas::App::Client.new id
				clients << client
				client.id
			end

			def close_client!(id)
				clients.delete client(id) if has_client? id
			end

			def clients
				@clients ||= [ ]
			end

			def client(id)
				clients.select {|client| client.id == id}.first
			end

			def has_client?(id)
				not client(id).nil?
			end

			def client_list
				clients.map {|client| client.to_hash}
			end

			def stable_timestamp
				return @cached_reconcile_timestamp unless reconciled?

				earliest_client = clients.min_by {|client| client.last_update }
				earliest_client.nil? ? Time.at(0) : earliest_client.last_update
			end

			def add_commands!(client_id, commands)
				commands.each {|command| raise TypeError, "Argument must be a Leonidas::Commands::Command" unless command.is_a? ::Leonidas::Commands::Command}
				raise ArgumentError, "Argument '#{client_id}' is not a valid client id" unless has_client? client_id

				client(client_id).add_commands! commands
				stabilize_commands! commands if (not reconciled?) && persistent?
				process_commands!
			end

			def commands_from_client(client_id, timestamp=nil)
				client = client(client_id)
				client.nil? ? nil : client.commands_since(timestamp || 0)
			end

			def process_commands!
				# find the oldest unrun or unpersisted command, AKA oldest among newly added commands
				all_current_commands = all_commands
				oldest_unrun_command = all_current_commands.select {|command| not command.has_run?}.min_by {|command| command.timestamp}
				oldest_unpersisted_command = all_current_commands.select {|command| not command.has_been_persisted?}.min_by {|command| command.timestamp} if persistent?
				
				# this just doesn't seem necessary... review for a better / prettier method
				if oldest_unrun_command.nil? && oldest_unpersisted_command.nil?
					return
				elsif oldest_unrun_command.nil?
					oldest_active_command = oldest_unpersisted_command
				elsif oldest_unpersisted_command.nil?
					oldest_active_command = oldest_unrun_command
				else
					oldest_active_command = [ oldest_unrun_command, oldest_unpersisted_command ].min_by {|command| command.timestamp}
				end

				# break the commands into lists of persistable and only runnable commands
				active_commands = commands_from oldest_active_command, all_current_commands
				persistable_commands = commands_between oldest_active_command, stable_timestamp, active_commands
				runnable_commands = commands_since stable_timestamp, active_commands

				# rollback those commands that have been run, and then run all commands
				processor.rollback runnable_commands.select {|command| command.has_run?}
				processor.rollback persistable_commands.select {|command| command.has_run?}
				processor.run persistable_commands, persistent?
				processor.run runnable_commands
			end

			def require_reconciliation!
				@checked_in_clients = [ ]
				@reconciled = false
				@has_been_unreconciled = true
			end

			def check_in!(client_id, other_client_ids, client_stable_timestamp, all_commands)
				unless reconciled?
					# guarantee the current client exists
					create_client!(client_id)
					@checked_in_clients << client(client_id)
					
					# guarantee the referenced external clients exist
					other_client_ids.each {|id| create_client! id}
					
					# set the cached timestamp to whatever the most recent stable timestamp of all checkins is
					@cached_reconcile_timestamp = @cached_reconcile_timestamp.nil? ? client_stable_timestamp : [ client_stable_timestamp, stable_timestamp ].max

					# add all commands
					all_commands.each {|client_id, commands| add_commands! client_id, commands}
				end
				check_reconciliation!
				@cached_reconcile_timestamp = nil if reconciled?
			end

			def has_checked_in?(client_id)
				@checked_in_clients.include? client(client_id)
			end

			def reconciled?
				@reconciled.nil? ? true : @reconciled
			end

			def has_been_unreconciled?
				@has_been_unreconciled || false
			end


			# ====== PRIVATE ====== #

			private

			def processor
				@processor ||= ::Leonidas::Commands::Processor.new(handlers)
			end

			def all_commands
				clients.reduce([ ]) {|commands, client| commands + client.all_commands}
			end

			def stabilize_commands!(commands)
				commands_through(stable_timestamp, commands).each do |command|
					command.mark_as_run!
					command.mark_as_persisted!
				end
			end

			def persistent?
				@persist_commands || false
			end

			def check_reconciliation!
				@reconciled = true
				clients.each {|client| @reconciled = false unless has_checked_in? client.id}
			end

		end
		
	end
end