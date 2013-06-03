describe Leonidas::Commands::Handler do
	include TestObjects
	include TestClasses

	def actual_handler
		TestClasses::IncrementHandler.new(@app.state)
	end

	before :each do
		@app = TestClasses::TestApp.new
		@command = build_command Time.now
	end

	after :each do
		TestClasses::PersistentState.reset
	end

	describe '#handles?' do 
	
		it "will return true if the command name matches the handler name" do
			actual_handler.handles?(@command).should be_true
		end
	
		it "will return false if the command name doesn't match the handler name" do
			TestClasses::MultiplyHandler.new(@app.state).handles?(@command).should be_false
		end

	end

	describe '#run_wrapper' do
		
		it "will run the command" do
			actual_handler.run_wrapper @command
			@app.state[:value].should eq 1
		end

		it "will mark the command as having run" do
			actual_handler.run_wrapper @command
			@command.should have_run
		end

	end

	describe '#persist_wrapper' do

		it "will persist the command" do
			actual_handler.persist_wrapper @command
			TestClasses::PersistentState.value.should eq 1
		end

		it "will mark the command as having been persisted" do
			actual_handler.persist_wrapper @command
			@command.should have_been_persisted
		end

	end

	describe '#rollback_wrapper' do
		
		it "will rollback the command" do
			actual_handler.rollback_wrapper @command
			@app.state[:value].should eq -1
		end

		it "will mark the command as not having been run" do
			@command.mark_as_run!
			actual_handler.rollback_wrapper @command
			@command.should_not have_run
		end

	end

	describe '#rollback_persist_wrapper' do
		
		it "will rollback the persistence of the command" do
			actual_handler.rollback_persist_wrapper @command
			TestClasses::PersistentState.value.should eq -1
		end

		it "will mark the command as not having been persisted" do
			@command.mark_as_persisted!
			actual_handler.rollback_persist_wrapper @command
			@command.should_not have_been_persisted
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