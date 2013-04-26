class TestApp < Sinatra::Base
	include Keystone::Server::Helpers

	get '/commander' do
		@app = nil
		if Leonidas::MemoryLayer::AppRegistry.app_is_registered?("1234") 
			@app = Leonidas::MemoryLayer::AppRegistry.retrieve_app("1234")
		else	
			@app = Leonidas::MemoryLayer::App.new({ integer: 1, string: "test" }, "1234")
			Leonidas::MemoryLayer::register_app!(app)
		end
		
		@command_source = Commands::CommandSource.new("1234")
		haml :test
	end

end