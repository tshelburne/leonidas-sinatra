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

	describe '#name=' do
		
		it "will reset the name of the app" do
			subject.name = "app-2"
			subject.name.should eq "app-2"
		end

	end

	describe '#app_type' do
		
		it "will return a string representing the class name" do
			subject.app_type.should eq "TestClasses::TestApp"
		end

	end

	describe '#current_state' do 
		
		it "will return the current state of the application" do
			subject.current_state.should eq({ value: 0 })
		end
	
	end
	
	describe '#create_client!' do
		
		it "will return a client id" do 
			id = subject.create_client!
			subject.send(:client, id).should_not be_nil
		end

		it "will add the new client the the app's list of clients" do 
			id = subject.create_client!
			subject.send(:has_client?, id).should be_true
		end

	end

	describe '#close_client!' do

		it "will remove the client" do 
			id = subject.create_client!
			subject.close_client! id
			subject.send(:has_client?, id).should be_false
		end

	end

	describe '#client_list' do 
	
		it "will create a list of hashes of clients" do
			id1 = subject.create_client!
			subject.add_commands! id1, [ build_command(Time.at(5), id1) ]
			id2 = subject.create_client!
			subject.add_commands! id2, [ build_command(Time.at(10), id2) ]
			id3 = subject.create_client!
			subject.add_commands! id3, [ build_command(Time.at(15), id3) ]

			subject.client_list.should eq [ { id: id1, lastUpdate: 5 }, { id: id2, lastUpdate: 10 }, { id: id3, lastUpdate: 15 } ]
		end
	
	end

	describe '#stable_timestamp' do 
		
		it "will default to a 0 timestamp if there are no clients" do 
			subject.stable_timestamp.should eq Time.at(0)
		end

		it "will return the current minimum timestamp between all clients" do
			id1 = subject.create_client!
			subject.add_commands! id1, [ build_command(Time.at(5)) ]
			id2 = subject.create_client!
			subject.add_commands! id2, [ build_command(Time.at(10)) ]
			id3 = subject.create_client!
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
			@id1 = subject.create_client!
			@id2 = subject.create_client!
			@command1 = build_command Time.now
			@command2 = build_command @command1.timestamp + 1, "clientid", "multiply", { number: 3 }
			@command3 = build_command @command1.timestamp + 2
		end

		it "will reject any commands that aren't of type Leonidas::Commands::Command" do
			expect { subject.add_commands!(@id1, [ { command: "sort of?" } ]) }.to raise_error(TypeError, "Argument must be a Leonidas::Commands::Command")
		end

		it "will reject a client id that doesn't exist in the application" do 
			expect { subject.add_commands!("bad-id", [ @command1 ]) }.to raise_error(TypeError, "Argument must be a valid client id")
		end

		it "will add the commands to the given client" do
			subject.add_commands! @id1, [ @command1, @command3 ]
			subject.commands_from_client(@id1).should eq [ @command1, @command3 ]
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

	describe '#commands_from_client' do 

		before :each do
			@id = subject.create_client!
			@command1 = build_command Time.at(10)
			@command2 = build_command Time.at(15), "clientid", "multiply", { number: 3 }
			@command3 = build_command Time.at(20)
			subject.add_commands! @id, [ @command1, @command2, @command3 ]
		end
	
		it "will return all commands from the requested client when no timestamp is given" do
			subject.commands_from_client(@id).should eq [ @command1, @command2, @command3 ]
		end

		it "will return only those commands that occurred since the given timestamp" do 
			subject.commands_from_client(@id, Time.at(12)).should eq [ @command2, @command3 ]
		end

		it "will not return commands that happened at exactly the requested timestamp" do
			subject.commands_from_client(@id, Time.at(15)).should_not include @command2
		end

		it "will return nil if the client doesn't exist in the app" do
			subject.commands_from_client("bad-id").should be_nil
		end
	
	end

	describe '#process_commands!' do 

		before :each do
			id1 = subject.create_client!
			id2 = subject.create_client!
			@command3 = build_command(Time.at(10))
			subject.send(:client, id1).add_commands! [ build_command(Time.at(0)), @command3 ]
			subject.send(:client, id2).add_command! build_command(Time.at(1))
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

	describe '#require_reconciliation!' do
		
		it "will mark the app as unreconciled" do
			subject.require_reconciliation!
			subject.should_not be_reconciled
		end

	end

	describe '#check_in!' do
		
		before :each do
			subject.require_reconciliation!
		end

		it "will mark the app as reconciled when no other clients are passed in" do
			id = ::Leonidas::App::Client.new.id
			subject.check_in! id, []
			subject.should be_reconciled
		end

		it "will mark the app as reconciled when the client checking in is the last one not yet checked in" do
			id1 = ::Leonidas::App::Client.new.id
			id2 = ::Leonidas::App::Client.new.id
			subject.check_in! id1, [ id2 ]
			subject.should_not be_reconciled
			subject.check_in! id2, [ id1 ]
			subject.should be_reconciled
		end

	end

	describe '#reconciled?' do
		
		it "will default to true" do
			subject.should be_reconciled
		end

		it "will return false when the app is marked as unreconciled" do
			subject.require_reconciliation!
			subject.should_not be_reconciled
		end

	end

end