module Leonidas
	module App

		module App

			def id
				@id
			end

			def revert_state!
				@active_state = @locked_state.dup
			end

			def lock_state!
				@locked_state = @active_state.dup
			end

			def create_connection!
				connection = Leonidas::App::Connection.new
				@connections << connection
			end

			def remove_connection!(id)
				@connections.delete connection(id)
			end

			def connection(id)
				@connections.select {|connection| connection.id == id}.first
			end

			def connections
				@connections
			end

			def stable_timestamp
				now = Time.now.to_i
				stable_time = @connections.reduce(now) {|min, connection| connection.last_update < min ? connection.last_update : min }
				stable_time == now ? nil : stable_time
			end

			def process_commands!
				stabilizer.stabilize
				@processor.process active_commands
			end

			def active_commands
				@connections.reduce([ ]) {|commands, connection| commands.concat! connection.active_commands}
			end

			private 

			def stabilizer
				@stabilizer ||= Leonidas::Commands::Stabilizer.new(self, @processor)
			end

		end
		
	end
end