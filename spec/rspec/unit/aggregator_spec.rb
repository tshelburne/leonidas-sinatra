describe Leonidas::Commands::Aggregator do
	
	subject do
		Test::TestAggregator.new
	end

	describe '#add_command!' do 
		
		it "will reject arguments not of type Leonidas::Commands::Command" do 
			false.should be_true
		end

		it "will add a command to the list of commands" do
			false.should be_true
		end

		it "will sort the list of active commands if sort is true" do
			false.should be_true
		end

		it "will not sort the list of active commands if sort is false" do 
			false.should be_true
		end
	
	end

	describe '#add_commands!' do 
	
		it "will add a list to commands to the list of commands" do
			false.should be_true
		end

		it "will sort the list of active commands" do
			false.should be_true
		end
	
	end

	describe '#commands_through' do 
	
		it "will return a list of commands before the given timestamp" do
			false.should be_true
		end

		it "will include commands at the given timestamp" do 
			false.should be_true
		end
	
	end

	describe '#commands_since' do 
	
		it "will return a list of commands after the given timestamp" do
			false.should be_true
		end

		it "will exclude commands at the given timestamp" do
			false.should be_true
		end
	
	end

	describe '#deactivate_commands!' do 

		it "will add the requested commands to the inactive commands" do
			false.should be_true
		end

		it "will not add any command which isn't a current member of the active commands" do 
			false.should be_true
		end
	
		it "will remove the requested commands from the active commands" do
			false.should be_true
		end
	
	end

end