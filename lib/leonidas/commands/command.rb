module Leonidas
	module Commands

		class Command
			
			attr_reader :id, :name, :data, :timestamp

			def initialize(id, name, data, timestamp)
				@id = id
				@name = name
				@data = data
				@timestamp = timestamp
			end

			def to_hash
				{ id: @id, name: @name, data: @data, timestamp: @timestamp.to_i }
			end

		end
		
	end
end