module TestObjects

	def build_command(timestamp, client_id="clientid", name="increment", data={ number: 1 }, id=nil)
		id ||= timestamp.to_i
		::Leonidas::Commands::Command.new(id, name, data, client_id, timestamp)
	end

	def build_client
		::Leonidas::App::Client.new
	end

end