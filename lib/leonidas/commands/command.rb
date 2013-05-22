module Leonidas
	module Commands

		class Command
			
			attr_reader :id, :name, :data, :client_id, :timestamp

			def initialize(id, name, data, client_id, timestamp)
				@id = id
				@name = name
				@data = data
				@client_id = client_id
				@timestamp = timestamp
			end

			def to_hash
				{ id: @id, name: @name, data: @data, clientId: @client_id, timestamp: @timestamp.as_milliseconds }
			end

		end
		
	end
end