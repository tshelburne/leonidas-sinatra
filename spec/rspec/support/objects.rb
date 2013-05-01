module TestObjects

	def build_command(connection, timestamp, name="increment", data={ increment_by: 1 })
		::Leonidas::Commands::Command.new(name, data, timestamp, connection)
	end

	def build_connection
		::Leonidas::App::Connection.new
	end

end