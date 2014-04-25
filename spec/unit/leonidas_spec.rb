describe Leonidas do

	def clear_persistence_layer
		Leonidas::PersistenceLayer::Persister.class_variable_set(:@@persister, nil)
		Leonidas::PersistenceLayer::Persister.class_variable_get(:@@state_loader).instance_variable_set(:@builders, [])
	end

	subject do
		Leonidas
	end

	after :each do
		clear_persistence_layer
	end

	describe '::bootstrap' do 

		it "will load and execute a config" do
			subject.bootstrap(File.expand_path("#{File.dirname(__FILE__)}/../support/config.rb"))
			Leonidas::PersistenceLayer::Persister.class_variable_get(:@@persister).should_not be_nil
			Leonidas::PersistenceLayer::Persister.class_variable_get(:@@state_loader).instance_variable_get(:@builders).should_not be_empty
		end

	end

end