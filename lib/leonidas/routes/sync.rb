module Leonidas
	module Routes

		class SyncApp < Sinatra::Base
			include ::Leonidas::App::AppRepository

			get '/:app_name' do
		    content_type "application/json"

		    app = app_repository.find params[:app_name]
		    current_client = app.connection(params[:clientId])

		    all_other_clients = app.connections.select {|connection| connection != current_client}
		    new_commands = all_other_clients.reduce([]) do |commands, client|
		    	last_update = params[:clients][:"#{client.id}"]
		    	commands << last_update.nil? ? client.commands : client.commands_since(last_update)
		    end

				{
					success: true,
					message: 'commands retrieved',
					data: {
						commands: new_commands.map {|command| command.to_hash},
						currentClients: all_other_clients.reduce({}) {|current_clients, connection| current_clients[connection.id] = connection.last_update },
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