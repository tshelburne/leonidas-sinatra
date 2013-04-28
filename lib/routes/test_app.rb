class TestApp < Sinatra::Base
	include Keystone::Server::Helpers

	get '/commander' do
		@app = Leonidas::App::AppRepository.find("app 1") 
		if @app.nil?	
			@app = Leonidas::App::App.new({ integer: 1, string: "test" }, "app 1")
			Leonidas::App::AppRepository.save app
		end
		
		@connection = @app.create_connection!
		haml :test
	end

end