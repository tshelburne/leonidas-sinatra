module Leonidas
	module App

		class App
			include Leonidas::Commands::Aggregator
			
			attr_reader :id, :state, :connections

			def initialize(id, state)
				@locked_state = state.dup
				@active_state = state.dup
				@id = id
				@connections = [ ]
			end

			def revert_state!
				@active_state = @locked_state.dup
			end

			def lock_state!
				@locked_state = @active_state.dup
			end

			def create_connection!(id)
				connection = Leonidas::App::Connection.new()
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

		end
		
	end
end