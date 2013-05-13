module Leonidas
	module App

		class Client
			include ::Leonidas::Commands::Aggregator
			
			attr_reader :id, :commands

			def initialize(id=nil)
				@id = id || SecureRandom.uuid
				@commands = [ ]
				@time_created = Time.now
			end

			def last_update
				latest_command = @commands.max_by {|command| command.timestamp} 
				latest_command.nil? ? @time_created : latest_command.timestamp
			end

			def to_hash
				{ id: @id, lastUpdate: last_update.to_i }
			end

		end
		
	end
end