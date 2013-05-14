describe Leonidas::App::Repository do

	def clear_persistence_layer
		persistence_layer.class_variable_set(:@@persister, nil)
		persistence_layer.class_variable_get(:@@state_loader).instance_variable_set(:@builders, [])
	end

	def persistence_layer
		Leonidas::PersistenceLayer::Persister
	end

	def memory_layer
		Leonidas::MemoryLayer::MemoryRegistry
	end

	before :each do
		@app = TestClasses::TestApp.new
		@persister = TestClasses::TestAppPersister.new
		persistence_layer.set_app_persister! @persister
	end

	after :each do
		memory_layer.clear_registry!
		clear_persistence_layer
		@persister.clear_apps!
	end

	describe '#find' do

		it "will return the app if the app is being watched" do 
			subject.watch @app
			subject.find("app-1").should eq @app
		end

		context "when the app is not being watched" do

			it "will return nil if no app type is passed in" do
				subject.find("app-1").should be_nil
			end

			it "will build the app and set it into reconcile mode" do
				app = subject.find("app-1", 'TestClasses::TestApp')
				app.should be_a TestClasses::TestApp
				app.should_not be_reconciled
				app.name.should eq @app.name
			end

			it "will begin watching the newly created app" do
				app = subject.find("app-1", 'TestClasses::TestApp')
				memory_layer.should have_app 'app-1'
			end

		end

	end

	describe '#load' do
		
		it "will return nil if the app is not persisted" do
			subject.load("app-1").should be_nil
		end
		
		it "will load the app from disk" do 
			subject.save @app
			subject.load("app-1").should eq @app
		end

		it "will begin watching the loaded app" do
			subject.save @app
			subject.load("app-1")
			memory_layer.should have_app "app-1"
		end
	
	end

	describe '#watch' do 
	
		it "will register the app in the memory layer" do
			subject.watch @app
			memory_layer.should have_app 'app-1'
		end
	
	end

	describe '#save' do 
	
		it "will persist the app" do
			subject.save @app
			persistence_layer.load("app-1").should eq @app
		end
	
	end

	describe '#archive' do 
	
		it "will close the app in the memory layer" do
			subject.watch @app
			subject.archive @app
			memory_layer.should_not have_app 'app-1'
		end

		it "will persist the app" do 
			subject.watch @app
			subject.archive @app
			persistence_layer.load("app-1").should eq @app
		end
	
	end

	describe '#delete' do 
	
		it "will close an app in memory" do
			subject.watch @app
			subject.delete @app
			memory_layer.should_not have_app "app-1"
		end

		it "will remove an app from the persistence layer" do
			subject.save @app
			subject.delete @app
			persistence_layer.load("app-1").should be_nil
		end
	
	end

	describe 'AppRepository mixin' do 
	
		it "Leonidas::App::AppRepository can be used as a mixin to provide #app_repository" do
			TestClasses::TestRepositoryContainer.new.app_repository.should be_a Leonidas::App::Repository
		end
	
	end

end