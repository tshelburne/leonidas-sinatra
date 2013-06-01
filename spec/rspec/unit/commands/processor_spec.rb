describe Leonidas::Commands::Processor do
	include TestObjects

	subject do
		@app = TestClasses::TestApp.new
		described_class.new(@app.handlers)
	end

	before :each do
		TestClasses::PersistentState.reset
		@command1 = build_command(Time.at(1))
		@command2 = build_command(Time.at(2), "clientid", "multiply", { number: 3 })
		@command3 = build_command(Time.at(3), "clientid", "increment", { number: 4 })
		@all_commands = [ @command3, @command1, @command2 ]
	end

	describe '#run' do 

		it "will run a list of commands in order by timestamp" do
			subject.run([ @command3, @command1, @command2 ])
			@app.state[:value].should eq 7
		end

		it "will mark the commands as run" do 
			subject.run(@all_commands)
			@all_commands.each {|command| command.should have_run}
		end

		context "when persist is true" do

			it "will persist the list of commands" do 
				subject.run(@all_commands, true)
				TestClasses::PersistentState.value.should eq 7
			end

			it "will mark the commands as persisted" do 
				subject.run(@all_commands, true)
				@all_commands.each {|command| command.should have_been_persisted}
			end

		end

	end

	describe '#rollback' do
		
		it "will rollback the list of commands in reverse order by timestamp" do
			subject.run(@all_commands)
			subject.rollback([ @command3, @command2 ])
			@app.state[:value].should eq 1
		end

		it "will mark the commands as not run" do 
			subject.run(@all_commands)
			subject.rollback([ @command3, @command2 ])
			[ @command3, @command2 ].each {|command| command.should_not have_run}
		end

		context "when persist is true" do

			it "will rollback the persistence of commands if persisted is true" do
				subject.run(@all_commands, true)
				subject.rollback([ @command3, @command2 ], true)
				TestClasses::PersistentState.value.should eq 1
			end

			it "will mark the commands as persisted" do 
			subject.run(@all_commands, true)
			subject.rollback([ @command3, @command2 ], true)
			[ @command3, @command2 ].each {|command| command.should_not have_been_persisted}
			end

		end

	end

end