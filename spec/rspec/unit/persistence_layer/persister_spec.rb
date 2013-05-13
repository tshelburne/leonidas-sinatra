describe Leonidas::PersistenceLayer::Persister do
	include TestObjects

	def clear_persistence_layer
		Leonidas::PersistenceLayer::Persister.class_variable_set(:@@persister, nil)
		Leonidas::PersistenceLayer::Persister.class_variable_get(:@@state_loader).instance_variable_set(:@builders, [])
	end

	subject do
		described_class
	end

	before :each do
		@app = TestClasses::TestApp.new
		id1 = @app.create_client!
		id2 = @app.create_client!
		@app.add_commands! id1, [ build_command(Time.now) ]
		@persister = TestClasses::TestAppPersister.new([ @app ])
	end

	after :each do
		clear_persistence_layer
	end

	describe '::set_app_persister' do 

		it "will reject any argument that doesn't include AppPersister" do
			persister = { fake_persister: "maybe it'll work this time" }
			expect { subject.set_app_persister! persister }.to raise_error(TypeError, "Argument must include Leonidas::PersistenceLayer::AppPersister")
			subject.class_variable_get(:@@persister).should be_nil
		end

		it "will set the persister to use for saving an app" do
			persister = TestClasses::TestAppPersister.new
			subject.set_app_persister! persister
			subject.class_variable_get(:@@persister).should eq persister
		end

	end

	describe '::load' do 

		before :each do 
			described_class.set_app_persister! @persister
			described_class.add_state_builder! TestClasses::TestAppStateBuilder.new
		end
	
		it "will load an app with the given name" do
			subject.load("app-1").should eq @app
		end

		it "will return nil if no app with the given name exists" do
			subject.load("badname").should be_nil
		end

		it "will set the app current state to the active state" do 
			subject.load("app-1").current_state[:value].should eq 1
		end
	
	end

	describe '::persist' do 
	
		it "will persist the app" do
			described_class.set_app_persister! @persister
			@persister.clear_apps!
			subject.load("app-1").should be_nil
			subject.persist @app
			subject.load("app-1").should eq @app
		end
	
	end

	describe '::delete' do 
	
		it "will delete the app" do
			described_class.set_app_persister! @persister
			subject.delete @app
			subject.load("app-1").should be_nil
		end
	
	end

end