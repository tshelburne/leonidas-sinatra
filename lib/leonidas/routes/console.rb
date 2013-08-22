module Leonidas
	module Routes

		class ConsoleApp < Sinatra::Base

			set :views, "#{settings.root}/../views"
			set :public_folder, "#{settings.views}/public"

			def app_registry
				::Leonidas::MemoryLayer::MemoryRegistry
			end
			
			def ensure_app!
				raise Sinatra::NotFound if app.nil?
			end

			def app
				@app ||= app_registry.retrieve_app params[:app_name]
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

			end

		end

	end
end