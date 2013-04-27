module Leonidas
	module Commands

		class Command
			
			attr_reader :name, :data, :timestamp, :connection

			def initialize(name, data, timestamp, connection)
				@name = name
				@data = data
				@timestamp = timestamp

				raise TypeError, "Argument must be a Leonidas::App::Connection" unless connection.is_a? Leonidas::App::Connection
				@connection = connection
			end

			def to_hash
				{ name: @name, data: @data, timestamp: @timestamp, connection: @connection.id }
			end

		end
		
	end
end