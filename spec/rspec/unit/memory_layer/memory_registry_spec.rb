describe Leonidas::MemoryLayer::MemoryRegistry do

	subject do
		described_class
	end

	before :each do
		subject.clear_registry!
	end

	describe '::register_app!' do 

		it "will reject an argument if it doesn't include Leonidas::App::App" do
			app = { convincing_app: "not so much"}
			expect { subject.register_app!(app) }.to raise_error(TypeError, "Argument must include Leonidas::App::App")
			subject.should_not have_app app
		end

		it "will add an app to the list of registered apps" do 
			subject.register_app! TestClasses::TestApp.new
			subject.retrieve_app("app 1").should_not be_nil
		end

		it "will throw an error if an app with the same name is already registered" do
			app1 = TestClasses::TestApp.new
			app2 = TestClasses::TestApp.new
			expect { subject.register_app! app1 }.not_to raise_error
			expect { subject.register_app! app2 }.to raise_error(StandardError, "An app with the name 'app 1' is already registered")
			subject.retrieve_app('app 1').should eq app1
		end

	end

	describe '::retrieve_app' do 
	
		it "will return nil if the requested app isn't registered" do
			subject.retrieve_app("app 1").should be_nil
		end

		it "will return the app if it is registered" do 
			app = TestClasses::TestApp.new
			subject.register_app! app
			subject.retrieve_app("app 1").should eq app
		end
	
	end

	describe '::has_app?' do 
	
		it "will return true if the requested app is registered" do
			subject.register_app! TestClasses::TestApp.new
			subject.should have_app "app 1"
		end
	
		it "will return false if the requested app is not registered" do 
			subject.should_not have_app "badid"
		end

	end

	describe '::close_app!' do 
	
		it "will remove the app from the list of registered apps" do
			subject.register_app! TestClasses::TestApp.new
			subject.close_app! "app 1"
			subject.should_not have_app "app 1"
		end
	
	end

	describe '#clear_registry!' do 
	
		it "removes all apps registered" do
			app1 = TestClasses::TestApp.new
			app2 = TestClasses::TestApp.new("app 2")
			subject.register_app! app1
			subject.register_app! app2
			subject.clear_registry!
			subject.should_not have_app app1.name
			subject.should_not have_app app2.name
		end
	
	end

end