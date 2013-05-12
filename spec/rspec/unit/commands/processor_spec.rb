describe Leonidas::Commands::Processor do
	include TestObjects

	subject do
		@app = TestMocks::MockApp.new
		described_class.new([ TestClasses::IncrementHandler.new(@app), TestClasses::MultiplyHandler.new(@app) ])
	end

	before :each do
		TestClasses::PersistentState.reset
		@command1 = build_command(Time.at(1))
		@command2 = build_command(Time.at(2), "multiply", { number: 3 })
		@command3 = build_command(Time.at(3), "increment", { number: 4 })
	end

	describe '#process' do 

		it "will run a list of commands in order by timestamp" do
			subject.process([ @command3, @command1, @command2 ])
			@app.current_state.should eq({ value: 7 })
		end

		it "will persist the list of commands when persist is true" do 
			subject.process([ @command3, @command1, @command2 ], true)
			TestClasses::PersistentState.value.should eq 7
		end

	end

end