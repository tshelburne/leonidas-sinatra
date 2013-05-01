module Leonidas
	module Dsl
		
		class ConfigurationExpression

			def persister_class_is(persister_class)
				::Leonidas::PersistenceLayer::Persister.set_app_persister! persister_class.new
			end

			def add_app_state_builder(builder_class)
				::Leonidas::PersistenceLayer::Persister.add_state_builder! builder_class.new
			end

		end

	end
end