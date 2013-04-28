module Leonidas
	module Routes

		class SyncApp < Sinatra::Base
			include Keystone::Server::Helpers

			get '/:app_id' do
		    content_type "application/json"

		    app = Leonidas::App::AppRepository.find params[:app_id]

				{
					success: true,
					message: 'commands retrieved',
					data: {
						commands: [
							{ name: 'log', data: { message: 'received command'}, timestamp: 2 },
							{ name: 'increment', data: { }, timestamp: 1 },
							{ name: 'increment', data: { }, timestamp: 3 }
						],
						currentSources: app.connections.map {|connection| { id: connection.id, lastUpdate: connection.last_update }},
						stableTimestamp: 1
					}
				}.to_json
			end

			post '/:app_id' do
		    content_type "application/json"

		    app = Leonidas::App::AppRepository.find params[:app_id]
		    connection = app.connection params[:sourceId]

		    commands = params[:commands].map {|command| Leonidas::Commands::Command.new(command.name, command.data, command.timestamp, connection)}
		    connection.add_commands! commands

		    {
		    	success: true,
		    	message: 'commands received',
		    	data: { }
		    }.to_json
			end 

		end

	end
end