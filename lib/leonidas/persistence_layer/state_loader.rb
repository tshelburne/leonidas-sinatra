module Leonidas
	module PersistenceLayer
		
		class StateLoader
			
			def initialize
				@builders = [ ]
			end

			def add_builder(builder)
				raise TypeError, "Argument must include Leonidas::PersistenceLayer::StateBuilder" unless builder.class < Leonidas::PersistenceLayer::StateBuilder
				@builders << builder
			end

			def load_state(app)
				@builders.each {|builder| return builder.build_state app if builder.handles? app}
			end

		end

	end
end