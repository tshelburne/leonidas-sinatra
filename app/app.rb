class SyncApp < Sinatra::Base
	include Keystone::Server::Helpers

	get '/test' do
		@command_source = Commands::CommandSource.new("1234")
		haml :test
	end

	get '/sync' do
    content_type "application/json"

		{
			success: true,
			message: 'commands retrieved',
			data: {
				commands: [
					{ name: 'log', data: { message: 'received command'}, timestamp: 2 },
					{ name: 'increment', data: { }, timestamp: 1 },
					{ name: 'increment', data: { }, timestamp: 3 }
				],
				currentSources: [
					{ id: "2345", lastUpdate: 2 },
					{ id: "3456", lastUpdate: 6 }
				],
				stableTimestamp: 1
			}
		}.to_json
	end

	post '/sync' do
    content_type "application/json"

    {
    	success: true,
    	message: 'commands received',
    	data: { }
    }.to_json
	end 

end