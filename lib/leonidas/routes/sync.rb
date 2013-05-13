module Leonidas
	module Routes

		class SyncApp < Sinatra::Base
			include ::Leonidas::App::AppRepository

			def map_command_hashes(command_hashes)
				command_hashes.map {|command_hash| ::Leonidas::Commands::Command.new(command_hash[:id], command_hash[:name], command_hash[:data], Time.at(command_hash[:timestamp]))}
			end

			before do
				content_type "application/json"
				
				@app ||= app_repository.find params[:appName]
        halt({ success: false, message: 'reconcile required', data: {} }.to_json) unless @app.reconciled?
			end

			get '/' do
				all_external_clients = @app.client_list.select {|client| client[:id] != params[:clientId]}
				new_commands = all_external_clients.reduce([ ]) do |commands, client|
					client_hash = params[:clients].select {|client_hash| client_hash[:id] == client[:id]}.first
					commands << client_hash.nil? ? @app.commands_from(client[:id]) : @app.commands_from(client[:id], client_hash[:lastUpdate])
				end

				{
					success: true,
					message: 'commands retrieved',
					data: {
						commands: new_commands.map {|command| command.to_hash},
						currentClients: all_external_clients,
						stableTimestamp: @app.stable_timestamp
					}
				}.to_json
			end

			post '/' do
				commands = map_command_hashes params[:commands]
				@app.add_commands! params[:clientId], commands

				{
					success: true,
					message: 'commands received',
					data: { }
				}.to_json
			end 

			post '/reconcile' do
				@app.check_in! params[:clientId], params[:currentClients]

				params[:commandList].each do |client_id, command_hashes|
					commands = map_command_hashes command_hashes
					@app.add_commands! client_id, commands
				end



				{ 
					success: true,
					message: 'app partially reconciled',
					data: { }
				}
			end

		end

	end
end