module Leonidas
	module Dsl
		
		class ConfigurationExpression

			def persister_class_is(persister)
				Leonidas::PersistenceLayer::Persister.set_app_persister! persister
			end

			def add_app_state_builder(builder)
				Leonidas::PersistenceLayer::Persister.add_state_builder! builder
			end

		end

	end
end