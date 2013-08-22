module Leonidas
	module Routes

		class ConsoleApp < Sinatra::Base

			set :views, "#{settings.root}/../views"
			set :public_folder, "#{settings.views}/public"
			set :layout, :layout

			helpers do
				
				def close_app_link app
					close_form url("/app/#{app.name}/close"), "app"
				end

				def close_client_link app, client
					close_form url("/app/#{app.name}/client/#{client.id}/close"), "client"
				end

				def close_form action, type
					haml :'partials/close_form', layout: false, locals: { action: action, type: type }
				end

			end

			def app_registry
				::Leonidas::MemoryLayer::MemoryRegistry
			end
			
			def ensure_app!
				raise Sinatra::NotFound if app.nil?
			end

			def app
				@app ||= app_registry.retrieve_app params[:app_name]
			end

			def ensure_client!
				raise Sinatra::NotFound if client.nil?
			end

			def client
				@client ||= app.client params[:client_id]
			end

			get '/' do
				redirect to('/dashboard')
			end

			get '/dashboard' do
				@apps_by_type = {}

				app_registry.all_apps.each do |app|
					@apps_by_type[app.app_type] = [] unless @apps_by_type[app.app_type]
					@apps_by_type[app.app_type] << app
				end

				haml :dashboard
			end

			get '/app/:app_name' do
				ensure_app!

				haml :application
			end

			post '/app/:app_name/close' do
				app_registry.close_app! params[:app_name]

				redirect to('/dashboard')
			end

			get '/app/:app_name/client/:client_id' do
				ensure_app!
				ensure_client!

				haml :client
			end

			post '/app/:app_name/client/:client_id/close' do
				ensure_app!

				app.close_client! params[:client_id]

				redirect to("/app/#{app.name}")
			end

		end

	end
end