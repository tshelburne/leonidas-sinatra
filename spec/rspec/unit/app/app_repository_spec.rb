describe Leonidas::App::AppRepository do

	before :each do
		Leonidas::MemoryLayer::MemoryRegistry.clear_registry!
	end

	describe '#find' do 

		it "will return nil if no app with the given name is being watched" do
			subject.find("app 1").should be_nil
		end

		it "will return the app if the app is being watched" do 
			app = TestClasses::TestApp.new
			subject.watch app
			subject.find("app 1").should eq app
		end

	end

	describe '#watch' do 
	
		it "will register the app in the memory layer" do
			subject.watch TestClasses::TestApp.new
			Leonidas::MemoryLayer::MemoryRegistry.should have_app 'app 1'
		end
	
	end

	describe '#save' do 
	
		it "will register the app in the memory layer" do
			subject.save TestClasses::TestApp.new
			Leonidas::MemoryLayer::MemoryRegistry.should have_app 'app 1'
		end
	
	end

	describe '#archive' do 
	
		it "will close the app in the memory layer" do
			app = TestClasses::TestApp.new
			subject.watch app
			subject.archive app
			Leonidas::MemoryLayer::MemoryRegistry.should_not have_app 'app 1'
		end
	
	end

end