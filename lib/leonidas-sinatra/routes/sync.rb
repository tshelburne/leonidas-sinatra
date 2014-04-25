require 'sinatra/base'

module LeonidasSinatra
	module Routes

		class SyncApp < Sinatra::Base
			include ::Leonidas::App::AppRepository

			def ensure_parameters(*parameters)
				parameters.each do |param|
					halt(respond false, "Missing required parameter: #{param}") if params[param].nil?
				end
			end

			def ensure_app
				@app ||= app_repository.find params[:appName], params[:appType]
				raise Sinatra::NotFound if @app.nil?
			end

			def ensure_reconciled
				halt(respond false, 'reconcile required') unless @app.reconciled? or @app.has_checked_in? current_client_id
			end

			def current_client_id
				params[:clientId]
			end

			def map_commands_hash(commands_hash)
				commands = [ ]
				commands_hash.each do |id, details|
					commands << ::Leonidas::Commands::Command.new(id, details[:name], details[:data], details[:clientId], Time.at(details[:timestamp].to_f/1000))
				end
				commands
			end

			def external_clients_from_app
				@external_clients_from_app ||= @app.client_list.select {|client| client[:id] != current_client_id}
			end

			def timestamp_from_params(timestamp)
				Time.at(timestamp.to_f/1000)
			end

			def respond(success, message, data={})
				{ success: success, message: message, data: data }.to_json
			end


			before do
				content_type "application/json"

				ensure_parameters :appName, :clientId
				ensure_app
			end

			get '/' do
				ensure_reconciled

				new_commands = external_clients_from_app.reduce([ ]) do |commands, client|
					client_last_update = params[:externalClients][client[:id]] unless params[:externalClients].nil?
					min_timestamp = client_last_update.nil? ? nil : timestamp_from_params(client_last_update)
					commands.concat @app.commands_from_client(client[:id], min_timestamp)
				end

				respond(true, 'commands retrieved',
					{
						commands: new_commands.map {|command| command.to_hash},
						externalClients: external_clients_from_app,
						stableTimestamp: @app.stable_timestamp.as_milliseconds
					}
				)
			end

			post '/' do
				ensure_reconciled
				
				commands = map_commands_hash params[:commands]
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
				external_clients = params[:externalClients].nil? ? [] : params[:externalClients].keys
				current_client_stable_timestamp = timestamp_from_params(params[:stableTimestamp])
				all_commands = { }
				params[:commandList].each do |client_id, commands_hash|
					all_commands[client_id] = map_commands_hash(commands_hash) unless commands_hash.nil?
				end

				@app.check_in! current_client_id, external_clients, current_client_stable_timestamp, all_commands
				
				respond true, @app.reconciled? ? 'app fully reconciled' : 'app partially reconciled'
			end

		end

	end
end