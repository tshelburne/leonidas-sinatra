describe Leonidas::Commands::Aggregator do
	
	subject do
		TestClasses::TestAggregator.new
	end

	describe '#add_command!' do 
		
		it "will reject arguments not of type Leonidas::Commands::Command" do 
			'but it is not'.should eq 'this to be done'
		end

		it "will add a command to the list of commands" do
			'but it is not'.should eq 'this to be done'
		end
	
	end

	describe '#add_commands!' do 
	
		it "will add each in the list of commands to the list of active commands" do
			'but it is not'.should eq 'this to be done'
		end

	end

	describe '#commands_through' do 
	
		it "will return a list of commands before the given timestamp" do
			'but it is not'.should eq 'this to be done'
		end

		it "will include commands at the given timestamp" do 
			'but it is not'.should eq 'this to be done'
		end
	
	end

	describe '#commands_since' do 
	
		it "will return a list of commands after the given timestamp" do
			'but it is not'.should eq 'this to be done'
		end

		it "will exclude commands at the given timestamp" do
			'but it is not'.should eq 'this to be done'
		end
	
	end

	describe '#deactivate_commands!' do 

		it "will add the requested commands to the inactive commands" do
			'but it is not'.should eq 'this to be done'
		end

		it "will not add any command which isn't a current member of the active commands" do 
			'but it is not'.should eq 'this to be done'
		end
	
		it "will remove the requested commands from the active commands" do
			'but it is not'.should eq 'this to be done'
		end
	
	end

end