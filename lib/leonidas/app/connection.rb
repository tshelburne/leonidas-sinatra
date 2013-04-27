module Leonidas
	module App

		class Connection
			include Leonidas::Commands::Aggregator
			
			attr_accessor :id, :last_update

			def initialize(id)
				@id = id
				@last_update = Time.now.to_i
				@commands = [ ]
			end

		end
		
	end
end