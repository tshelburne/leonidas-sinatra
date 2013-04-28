class TestApp < Sinatra::Base
	include Keystone::Server::Helpers

	get '/commander' do
		
		
		@app = nil
		if Leonidas::MemoryLayer::MemoryRegistry.app_is_registered?("1234") 
			@app = Leonidas::MemoryLayer::MemoryRegistry.retrieve_app("1234")
		else	
			@app = Leonidas::App::App.new({ integer: 1, string: "test" }, "1234")
			Leonidas::MemoryLayer::register_app!(app)
		end
		
		@connection = @app.create_connection!
		haml :test
	end

end