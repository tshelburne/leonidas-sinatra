class TestApp < Sinatra::Base
	include Keystone::Server::Helpers

	get '/commander' do
		@app = nil
		if Leonidas::MemoryLayer::MemoryRegistry.has_app_registered?("app 1") 
			@app = Leonidas::MemoryLayer::MemoryRegistry.retrieve_app("app 1")
		else	
			@app = Leonidas::App::App.new({ integer: 1, string: "test" }, "app 1")
			Leonidas::MemoryLayer::register_app!(app)
		end
		
		@connection = @app.create_connection!
		haml :test
	end

end