module Leonidas
	module App
		
		class AppRepository

			def find(app_name)
				Leonidas::MemoryLayer::MemoryRegistry.retrieve_app app_name
			end

			def watch(app)
				Leonidas::MemoryLayer::MemoryRegistry.register_app! app
			end

			def archive(app)
				Leonidas::MemoryLayer::MemoryRegistry.close_app! app.name
			end

		end

	end
end