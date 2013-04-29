describe Leonidas::Dsl::ConfigurationExpression do

	def set_default_persister
		Leonidas::PersistenceLayer::Persister.class_variable_set(:@@persister, nil)
		Leonidas::PersistenceLayer::Persister.class_variable_get(:@@state_loader).instance_variable_set(:@builders, [])
	end

	after :each do
		set_default_persister
	end

	describe '#persister_class_is' do 

		it "will set the class used to persist apps in Persister" do
			persister_class = TestClasses::TestAppPersister
			subject.persister_class_is persister_class
			Leonidas::PersistenceLayer::Persister.class_variable_get(:@@persister).should_not be_nil
		end

	end

	describe '#add_app_state_builder' do 
	
		it "will add a state builder to the persister's state loader" do
			builder_class = TestClasses::TestAppStateBuilder
			subject.add_app_state_builder builder_class
			Leonidas::PersistenceLayer::Persister.class_variable_get(:@@state_loader).instance_variable_get(:@builders).should_not be_empty
		end
	
	end

end