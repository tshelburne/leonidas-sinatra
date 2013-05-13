describe Leonidas::App::App do
	include TestObjects
	
	subject do
		TestClasses::TestApp.new
	end

	before :each do
		TestClasses::PersistentState.reset
	end

	describe '#name' do 
	
		it "will return the name defined in the includer class" do
			subject.name.should eq "app-1"
		end
	
	end

	describe '#current_state' do 
		
		it "will return the current state of the application" do
			subject.current_state.should eq({ value: 0 })
		end
	
	end
	
	describe '#create_connection!' do
		
		it "will return a connection id" do 
			id = subject.create_connection!
			subject.send(:connection, id).should_not be_nil
		end

		it "will add the new connection the the app's list of connections" do 
			id = subject.create_connection!
			subject.send(:has_connection?, id).should be_true
		end

	end

	describe '#close_connection!' do

		it "will remove the connection" do 
			id = subject.create_connection!
			subject.close_connection! id
			subject.send(:has_connection?, id).should be_false
		end

	end

	describe '#connection_list' do 
	
		it "will create a list of hashes of connections" do
			id1 = subject.create_connection!
			subject.add_commands! id1, [ build_command(Time.at(5)) ]
			id2 = subject.create_connection!
			subject.add_commands! id2, [ build_command(Time.at(10)) ]

			subject.connection_list.should eq [ { id: id1, lastUpdate: Time.at(5).to_i }, { id: id2, lastUpdate: Time.at(10).to_i } ]
		end
	
	end

	describe '#stable_timestamp' do 
		
		it "will default to a 0 timestamp if there are no connections" do 
			subject.stable_timestamp.should eq Time.at(0)
		end

		it "will return the current minimum timestamp between all connections" do
			id1 = subject.create_connection!
			subject.add_commands! id1, [ build_command(Time.at(5)) ]
			id2 = subject.create_connection!
			subject.add_commands! id2, [ build_command(Time.at(10)) ]
			id3 = subject.create_connection!
			subject.add_commands! id3, [ build_command(Time.at(15)) ]

			subject.stable_timestamp.should eq Time.at(5)
			
			subject.add_commands! id1, [ build_command(Time.at(20)) ]
			subject.stable_timestamp.should eq Time.at(10)

			subject.add_commands! id2, [ build_command(Time.at(25)) ]
			subject.stable_timestamp.should eq Time.at(15)
		end

	end

	describe '#add_commands!' do 

		before :each do
			@id1 = subject.create_connection!
			@id2 = subject.create_connection!
			@command1 = build_command Time.now
			@command2 = build_command Time.now, "multiply", { number: 3 }
			@command3 = build_command Time.now
		end

		it "will reject any commands that aren't of type Leonidas::Commands::Command" do
			expect { subject.add_commands!(@id1, [ { command: "sort of?" } ]) }.to raise_error(TypeError, "Argument must be a Leonidas::Commands::Command")
		end

		it "will reject a connection id that doesn't exist in the application" do 
			expect { subject.add_commands!("bad-id", [ @command1 ]) }.to raise_error(TypeError, "Argument must be a valid connection id")
		end

		it "will add the commands to the given connection" do
			subject.add_commands! @id1, [ @command1, @command3 ]
			subject.commands_from(@id1).should eq [ @command1, @command3 ]
		end

		it "will update the current state to have run all active commands" do 
			subject.add_commands! @id1, [ @command1, @command3 ]
			subject.add_commands! @id2, [ @command2 ]
			subject.current_state[:value].should eq 4
		end

		context "when the app is set to be persistent" do

			it "will persist all commands which occured at or before the stable timestamp" do
				subject.instance_variable_set :@persist_state, true
				subject.add_commands! @id1, [ @command1, @command3 ]
				subject.add_commands! @id2, [ @command2 ]
				TestClasses::PersistentState.value.should eq 3
			end

		end

	end

	describe '#commands_from' do 

		before :each do
			@id = subject.create_connection!
			@command1 = build_command Time.at(10)
			@command2 = build_command Time.at(15), "multiply", { number: 3 }
			@command3 = build_command Time.at(20)
			subject.add_commands! @id, [ @command1, @command2, @command3 ]
		end
	
		it "will return all commands from the requested connection when no timestamp is given" do
			subject.commands_from(@id).should eq [ @command1, @command2, @command3 ]
		end

		it "will return only those commands that occurred since the given timestamp" do 
			subject.commands_from(@id, Time.at(12)).should eq [ @command2, @command3 ]
		end
	
	end

	describe '#process_commands!' do 

		before :each do
			id1 = subject.create_connection!
			id2 = subject.create_connection!
			@command3 = build_command(Time.at(10))
			subject.send(:connection, id1).add_commands! [ build_command(Time.at(0)), @command3 ]
			subject.send(:connection, id2).add_command! build_command(Time.at(0))
		end

		it "will set the current state to the state when all active commands have been run" do
			subject.process_commands!
			subject.current_state[:value].should eq 3
		end

		it "will run idempotently" do
			4.times { subject.process_commands! }
			subject.current_state[:value].should eq 3
		end

		context "when the app is set to be persistent" do

			it "will persist all commands which occured at or before the stable timestamp" do
				subject.instance_variable_set :@persist_state, true
				subject.process_commands!
				TestClasses::PersistentState.value.should eq 2
			end

		end

	end

end