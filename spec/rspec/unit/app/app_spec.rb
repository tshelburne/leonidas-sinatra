describe Leonidas::App::App do

	subject do
		Test::TestApp.new
	end
	
	describe '#create_connection!' do
		
		it "will return a new connection" do 
			false.should be_true
		end

		it "will add the new connection the the apps list of connections" do 
			false.should be_true
		end

	end

	describe '#close_connection!' do
		
		it "will do nothing if the connection doesn't exist" do 
			false.should be_true
		end

		it "will remove the connection" do 
			false.should be_true
		end

	end

	describe '#connection' do
		
		it "will return nil if the requested connection doesn't exist" do
			false.should be_true
		end

		it "will retrieve the requested connection" do
			false.should be_true
		end

	end

	describe '#connections' do 
	
		it "will return the list of all connections" do
			false.should be_true
		end
	
	end

	describe '#stable_timestamp' do 
		
		it "will default to nil if there are no connections" do 
			false.should be_true
		end

		it "will return the current minimum timestamp between all connections" do
			false.should be_true
		end
	
	end

	describe '#process_commands!' do 

		it "will update the locked state" do
			false.should be_true
		end

		it "will set the active state to the most up to date" do 
			false.should be_true
		end

	end

	describe '#active_commands' do 
	
		it "will return a list of all active commands" do
			false.should be_true
		end
	
	end

end