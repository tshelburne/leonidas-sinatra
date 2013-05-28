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
				{ success: success, message: message, data: data }.to_json
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
				
				commands = map_command_hashes params[:commands]
				begin
					@app.add_commands! current_client_id, commands
				rescue ArgumentError => e
					# when the app has been unreconciled, it's possible we may have orphaned clients check in after false reconciliation
					if @app.has_been_unreconciled? && e.message.match('not a valid client id')
						@app.require_reconciliation!
						ensure_reconciled
					else
						halt(respond false, e.message)
					end
				rescue => e
					halt(respond false, e.message)
				end

				respond true, 'commands received'
			end 

			post '/reconcile' do
				external_clients = params[:clients].nil? ? [] : params[:clients].map {|client_hash| client_hash[:id]}
				current_client_stable_timestamp = timestamp_from_params(params[:stableTimestamp])
				all_commands = { }
				params[:commandList].each do |client_id, command_hashes|
					all_commands[client_id] = map_command_hashes(command_hashes) unless command_hashes.nil?
				end

				@app.check_in! current_client_id, external_clients, current_client_stable_timestamp, all_commands
				
				respond true, @app.reconciled? ? 'app fully reconciled' : 'app partially reconciled'
			end

		end

	end
end