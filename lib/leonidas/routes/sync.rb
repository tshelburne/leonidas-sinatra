module Leonidas
	module Routes

		class SyncApp < Sinatra::Base
			include ::Leonidas::App::AppRepository

			get '/:app_name' do
		    content_type "application/json"

		    app = app_repository.find params[:app_name]

		    new_commands = params[:clients].reduce([ ]) {|commands, client| commands.concat app.connection(client[:id]).commands_since(client[:lastUpdate])}
		    additional_clients = app.connections.select {|connection| connection.id != params[:clientId]}

				{
					success: true,
					message: 'commands retrieved',
					data: {
						commands: new_commands.map {|command| command.to_hash},
						currentClients: additional_clients.map {|connection| { id: connection.id, lastUpdate: connection.last_update }},
						stableTimestamp: app.stable_timestamp
					}
				}.to_json
			end

			post '/:app_name' do
		    content_type "application/json"

		    app = app_repository.find params[:app_name]
		    connection = app.connection params[:clientId]

		    commands = params[:commands].map {|command| ::Leonidas::Commands::Command.new(command.name, command.data, command.timestamp, connection)}
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