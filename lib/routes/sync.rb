module Leonidas
	module Routes

		class SyncApp < Sinatra::Base
			include Keystone::Server::Helpers

			get '/:app_id' do
		    content_type "application/json"

		    app = Leonidas::MemoryLayer::AppRegistry.retrieve_app params[:app_id]

				{
					success: true,
					message: 'commands retrieved',
					data: {
						commands: [
							{ name: 'log', data: { message: 'received command'}, timestamp: 2 },
							{ name: 'increment', data: { }, timestamp: 1 },
							{ name: 'increment', data: { }, timestamp: 3 }
						],
						currentSources: app.sources.map {|source| { id: source.id, lastUpdate: source.last_update }},
						stableTimestamp: 1
					}
				}.to_json
			end

			post '/:app_id' do
		    content_type "application/json"

		    app = Leonidas::MemoryLayer::AppRegistry.retrieve_app params[:app_id]
		    source = app.source(params[:sourceId])

		    commands = params[:commands].map {|command| Leonidas::Commands::Command.new(command.name, command.data, command.timestamp, source)}

		    {
		    	success: true,
		    	message: 'commands received',
		    	data: { }
		    }.to_json
			end 

		end

	end
end