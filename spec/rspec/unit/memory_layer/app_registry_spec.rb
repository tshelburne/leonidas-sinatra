describe Leonidas::MemoryLayer::AppRegistry do

	subject do
		described_class
	end

	before :each do
		subject.class_variable_set(:@@apps, { })
	end

	describe '::register_app!' do 

		it "will reject an argument if it doesn't include Leonidas::App::App" do
			expect { subject.register_app!({ convincing_app: "not so much"}) }.to raise_error(TypeError, "Argument must include Leonidas::App::App")
		end

		it "will add an app to the list of registered apps" do 
			subject.register_app! TestClasses::TestApp.new
			subject.retrieve_app("1234").should_not be_nil
		end

	end

	describe '::retrieve_app' do 
	
		it "will return nil if the requested app isn't registered" do
			subject.retrieve_app("1234").should be_nil
		end

		it "will return the app if it is registered" do 
			app = TestClasses::TestApp.new
			subject.register_app! app
			subject.retrieve_app("1234").should eq app
		end
	
	end

	describe '::has_app_registered?' do 
	
		it "will return true if the requested app is registered" do
			subject.register_app! TestClasses::TestApp.new
			subject.should have_app_registered "1234"
		end
	
		it "will return false if the requested app is not registered" do 
			subject.should_not have_app_registered "badid"
		end

	end

	describe '::close_app!' do 
	
		it "will remove the app from the list of registered apps" do
			subject.register_app! TestClasses::TestApp.new
			subject.close_app! "1234"
			subject.should_not have_app_registered "1234"
		end
	
	end

end