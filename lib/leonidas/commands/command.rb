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
				@has_been_persisted = false
			end

			def to_hash
				{ id: @id, name: @name, data: @data, clientId: @client_id, timestamp: @timestamp.as_milliseconds }
			end

			def has_run?
				@has_run
			end

			def has_been_persisted?
				@has_been_persisted
			end

			def mark_as_run!
				@has_run = true
			end

			def mark_as_not_run!
				@has_run = false
			end

			def mark_as_persisted!
				@has_been_persisted = true
			end

			def mark_as_not_persisted!
				@has_been_persisted = false
			end

		end
		
	end
end