module Leonidas
	module Routes

		class SyncApp < Sinatra::Base
			include Keystone::Server::Helpers

			get '/:app_id' do
		    content_type "application/json"

		    app = Leonidas::App::AppRepository.find params[:app_id]

		    new_commands = params[:sources].reduce([ ]) {|commands, source| commands.concat app.connection(source[:id]).commands_since(source[:lastUpdate])}

				{
					success: true,
					message: 'commands retrieved',
					data: {
						commands: new_commands.map {|command| command.to_hash},
						currentSources: app.connections.map {|connection| { id: connection.id, lastUpdate: connection.last_update }},
						stableTimestamp: app.stable_timestamp
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