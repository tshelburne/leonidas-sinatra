module Leonidas
	module Commands

		class Command
			
			attr_reader :name, :data, :timestamp

			def initialize(name, data, timestamp)
				@name = name
				@data = data
				@timestamp = timestamp
			end

			def to_hash
				{ name: @name, data: @data, timestamp: @timestamp.to_i }
			end

		end
		
	end
end