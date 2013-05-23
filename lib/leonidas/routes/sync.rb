module Leonidas
	module Routes

		class SyncApp < Sinatra::Base
			include ::Leonidas::App::AppRepository

			def current_client_id
				params[:clientId]
			end

			def ensure_reconciled
				halt(respond false, 'reconcile required', {}) unless @app.reconciled? or @app.has_checked_in? current_client_id
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

			def respond(success, message, data={})
				{
					success: success,
					message: message,
					data: data
				}.to_json
			end


			before do
				content_type "application/json"
				
				@app ||= app_repository.find params[:appName], params[:appType]
				raise Sinatra::NotFound if @app.nil?
			end

			get '/' do
				ensure_reconciled

				new_commands = all_external_clients.reduce([ ]) do |commands, client|
					client_hash = params[:clients].select {|client_hash| client_hash[:id] == client[:id]}.first
					min_timestamp = client_hash.nil? ? nil : timestamp_from_params(client_hash[:lastUpdate])
					commands.concat @app.commands_from_client(client[:id], min_timestamp)
				end

				respond(true, 'commands retrieved',
					{
						commands: new_commands.map {|command| command.to_hash},
						currentClients: all_external_clients,
						stableTimestamp: @app.stable_timestamp.as_milliseconds
					}
				)
			end

			post '/' do
				ensure_reconciled
				
				begin
					commands = map_command_hashes params[:commands]
					@app.add_commands! current_client_id, commands
				rescue => e
					return respond false, e.message
				end

				respond true, 'commands received'
			end 

			post '/reconcile' do
				@app.check_in! current_client_id, params[:clients].map {|client_hash| client_hash[:id]}, timestamp_from_params(params[:stableTimestamp])
				
				params[:commandList].each do |client_id, command_hashes|
					commands = map_command_hashes command_hashes
					@app.add_commands! client_id, commands
				end

				respond true, @app.reconciled? ? 'app fully reconciled' : 'app partially reconciled'
			end

		end

	end
end