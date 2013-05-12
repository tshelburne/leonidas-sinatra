module Leonidas
	module App

		class Connection
			include ::Leonidas::Commands::Aggregator
			
			attr_reader :id, :commands

			def initialize
				@id = SecureRandom.uuid
				@commands = [ ]
			end

			def last_update
				latest_command = @commands.max_by {|command| command.timestamp} 
				latest_command.nil? ? Time.at(0) : latest_command.timestamp
			end

		end
		
	end
end