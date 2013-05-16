describe Leonidas::Commands::Handler do
	include TestObjects

	before :each do
		@command = build_command Time.now
	end

	describe '#handles?' do 
	
		it "will return true if the command name matches the handler name" do
			subject.instance_variable_set(:@name, "increment")
			subject.handles?(@command).should be_true
		end
	
		it "will return false if the command name doesn't match the handler name" do
			subject.instance_variable_set(:@name, "multiply")
			subject.handles?(@command).should be_false
		end

	end

	describe '#run' do 

		it "will throw an exception if not overridden" do
			expect { subject.run(@command) }.to raise_error(NoMethodError, "Class must implement a #run method")
		end

	end

	describe '#persist' do 
	
		it "will throw an exception if not overridden" do
			expect { subject.persist(@command) }.to raise_error(NoMethodError, "Class must implement a #persist method")
		end

	end

	describe '#rollback' do 
	
		it "will throw an exception if not overridden" do
			expect { subject.rollback(@command) }.to raise_error(NoMethodError, "Class must implement a #rollback method")
		end

	end

	describe '#rollback_persist' do 
	
		it "will throw an exception if not overridden" do
			expect { subject.rollback_persist(@command) }.to raise_error(NoMethodError, "Class must implement a #rollback_persist method")
		end

	end

end