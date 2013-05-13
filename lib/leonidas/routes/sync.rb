module Leonidas
	module Routes

		class SyncApp < Sinatra::Base
			include ::Leonidas::App::AppRepository

			def app
				@app ||= app_repository.find params[:appName]
			end

			def get_client_record(client_id)
				params[:clients].select {|client| client[:id] == client_id}.first
			end

			before { content_type "application/json" }

			get '/' do
				all_external_clients = app.client_list.select {|client| client[:id] != params[:clientId]}
				new_commands = all_external_clients.reduce([ ]) do |commands, client|
					client_record = get_client_record client[:id] 
					commands << client_record.nil? ? app.commands_from(client[:id]) : app.commands_from(client[:id], client_record[:lastUpdate])
				end

				{
					success: true,
					message: 'commands retrieved',
					data: {
						commands: new_commands.map {|command| command.to_hash},
						currentClients: all_external_clients,
						stableTimestamp: app.stable_timestamp
					}
				}.to_json
			end

			post '/' do
				commands = params[:commands].map {|command| ::Leonidas::Commands::Command.new(command.name, command.data, Time.at(command.timestamp.to_i))}
				app.add_commands! params[:clientId], commands

				{
					success: true,
					message: 'commands received',
					data: { }
				}.to_json
			end 

		end

	end
end