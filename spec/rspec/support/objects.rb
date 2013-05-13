module TestObjects

	def build_command(timestamp, name="increment", data={ number: 1 })
		::Leonidas::Commands::Command.new(name, data, timestamp)
	end

	def build_client
		::Leonidas::App::Client.new
	end

end