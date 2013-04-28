module Leonidas
	module App

		module App

			def name
				@name
			end

			def current_state
				@active_state
			end

			def create_connection!
				connection = Leonidas::App::Connection.new
				@connections << connection
				connection
			end

			def close_connection!(id)
				@connections.delete connection(id) if has_connection? id
			end

			def connection(id)
				@connections.select {|connection| connection.id == id}.first
			end

			def has_connection?(id)
				not connection(id).nil?
			end

			def connections
				@connections
			end

			def stable_timestamp
				return 0 if @connections.empty?
				now = Time.now.to_i
				@connections.reduce(now) {|min, connection| connection.last_update < min ? connection.last_update : min }
			end

			def stabilize!
				revert_state!
				@processor.process stable_commands, @persistent || false
				lock_state!
				@connections.each {|connection| connection.deactivate_commands!(stable_commands)}
			end

			def process_commands!
				stabilize!
				@processor.process active_commands
			end

			def active_commands
				@connections.reduce([ ]) {|commands, connection| commands.concat connection.active_commands}
			end


			private 

			def stable_commands 
				@connections.reduce([ ]) {|commands, connection| commands.concat connection.commands_through(stable_timestamp)}
			end

			def revert_state!
				@active_state = @locked_state.dup
			end

			def lock_state!
				@locked_state = @active_state.dup
			end

		end
		
	end
end