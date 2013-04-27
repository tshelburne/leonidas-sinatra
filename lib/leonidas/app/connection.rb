module Leonidas
	module App

		class Connection
			include Leonidas::Commands::Aggregator
			
			attr_reader :id, :active_commands
			attr_accessor :last_update

			def initialize
				@id = SecureRandom.uuid
				@last_update = Time.now.to_i
				@active_commands = [ ]
				@inactive_commands = [ ]
			end

		end
		
	end
end