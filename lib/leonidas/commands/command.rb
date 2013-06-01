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
				@has_run = false
			end

			def to_hash
				{ id: @id, name: @name, data: @data, clientId: @client_id, timestamp: @timestamp.as_milliseconds }
			end

			def has_run?
				@has_run
			end

			def mark_as_run!
				@has_run = true
			end

			def mark_as_not_run!
				@has_run = false
			end

		end
		
	end
end