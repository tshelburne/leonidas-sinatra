module Leonidas
	module Routes

		class SyncApp < Sinatra::Base
			include ::Leonidas::App::AppRepository

			def current_client_id
				params[:clientId]
			end

			def check_if_reconciled
				halt({ success: false, message: 'reconcile required', data: {} }.to_json) unless @app.reconciled? or @app.has_checked_in? current_client_id
			end

			def map_command_hashes(command_hashes)
				command_hashes.map {|command_hash| ::Leonidas::Commands::Command.new(command_hash[:id], command_hash[:name], command_hash[:data], command_hash[:clientId], Time.at(command_hash[:timestamp].to_f/1000)) }
			end

			def all_external_clients
				@all_external_clients ||= @app.client_list.select {|client| client[:id] != current_client_id}
			end

			def timestamp_from_params(timestamp)
				Time.at(timestamp.to_f/1000)
			end

			before do
				content_type "application/json"
				
				@app ||= app_repository.find params[:appName], params[:appType]
				raise Sinatra::NotFound if @app.nil?
			end

			get '/' do
				check_if_reconciled

				new_commands = all_external_clients.reduce([ ]) do |commands, client|
					client_hash = params[:clients].select {|client_hash| client_hash[:id] == client[:id]}.first
					min_timestamp = client_hash.nil? ? nil : timestamp_from_params(client_hash[:lastUpdate])
					commands.concat @app.commands_from_client(client[:id], min_timestamp)
				end

				{
					success: true,
					message: 'commands retrieved',
					data: {
						commands: new_commands.map {|command| command.to_hash},
						currentClients: all_external_clients,
						stableTimestamp: @app.stable_timestamp.as_milliseconds
					}
				}.to_json
			end

			post '/' do
				check_if_reconciled
				
				commands = map_command_hashes params[:commands]
				@app.add_commands! current_client_id, commands

				{
					success: true,
					message: 'commands received',
					data: { }
				}.to_json
			end 

			post '/reconcile' do
				@app.check_in! current_client_id, params[:clients].map {|client_hash| client_hash[:id]}, timestamp_from_params(params[:stableTimestamp])
				
				params[:commandList].each do |client_id, command_hashes|
					commands = map_command_hashes command_hashes
					@app.add_commands! client_id, commands
				end

				{ 
					success: true,
					message: @app.reconciled? ? 'app fully reconciled' : 'app partially reconciled',
					data: { }
				}.to_json
			end

		end

	end
end