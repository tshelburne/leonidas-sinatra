module Leonidas
	module App

		class Connection
			include ::Leonidas::Commands::Aggregator
			
			attr_reader :id, :commands

			def initialize
				@id = SecureRandom.uuid
				@commands = [ ]
				@time_created = Time.now
			end

			def last_update
				latest_command = @commands.max_by {|command| command.timestamp} 
				latest_command.nil? ? @time_created : latest_command.timestamp
			end

		end
		
	end
end