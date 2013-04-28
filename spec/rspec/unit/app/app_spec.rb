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
			subject.name.should eq "app 1"
		end
	
	end

	describe '#current_state' do 
		
		it "will return the current state of the application" do
			subject.current_state.should eq({ value: 1 })
		end
	
	end
	
	describe '#create_connection!' do
		
		it "will return a Leonidas::App::Connection" do 
			subject.create_connection!.should be_a Leonidas::App::Connection
		end

		it "will add the new connection the the app's list of connections" do 
			conn = subject.create_connection!
			subject.should have_connection(conn.id)
		end

	end

	describe '#close_connection!' do

		it "will remove the connection" do 
			conn = subject.create_connection!
			subject.close_connection! conn.id
			subject.should_not have_connection(conn.id)
		end

	end

	describe '#connection' do
		
		it "will return nil if the requested connection doesn't exist" do
			subject.connection('badid').should be_nil
		end

		it "will retrieve the requested connection" do
			conn = subject.create_connection!
			subject.connection(conn.id).should eq conn
		end

	end

	describe '#has_connection?' do 

		it "will return true if it has the requested connection" do
			conn = subject.create_connection!
			subject.should have_connection(conn.id)
		end

		it "will return false if it doesn't have the requested connection" do
			subject.should_not have_connection("badid")
		end

	end

	describe '#connections' do 
	
		it "will return the full list of connections" do
			conn1 = subject.create_connection!
			conn2 = subject.create_connection!
			subject.connections.should eq [ conn1, conn2 ]
		end
	
	end

	describe '#stable_timestamp' do 
		
		it "will default to 0 if there are no connections" do 
			subject.stable_timestamp.should eq 0
		end

		it "will return the current minimum timestamp between all connections" do
			conn1 = subject.create_connection!
			conn2 = subject.create_connection!
			conn3 = subject.create_connection!
			subject.stable_timestamp.should eq conn1.last_update
			conn3.last_update = Time.now.to_i
			subject.stable_timestamp.should eq conn2.last_update
			conn3.last_update = conn1.last_update - 10
			subject.stable_timestamp.should eq conn3.last_update
		end

	end

	describe '#stabilize!' do 

		before :each do
			conn1 = subject.create_connection!
			conn2 = subject.create_connection!
			@command3 = build_command(conn1, conn1.last_update+5)
			conn1.add_commands! [ build_command(conn1, conn1.last_update-5), @command3 ]
			conn2.add_command! build_command(conn2, conn2.last_update-5)
		end

		context "when the app is set to be persistent" do
			
			it "will persist all commands which occured at or before the stable timestamp" do
				subject.instance_variable_set :@persist_state, true
				subject.stabilize!
				TestClasses::PersistentState.value.should eq 2
			end

		end

		it "will reduce the active commands by the stable commands" do
			subject.stabilize!
			subject.active_commands.should eq [ @command3 ]
		end

		it "will set the current state to the state when all stable commands have been run" do 
			subject.stabilize!
			subject.current_state.should eq({ value: 2 })
		end

	end

	describe '#process_commands!' do 

		before :each do
			conn1 = subject.create_connection!
			conn2 = subject.create_connection!
			@command3 = build_command(conn1, conn1.last_update+5)
			conn1.add_commands! [ build_command(conn1, conn1.last_update-5), @command3 ]
			conn2.add_command! build_command(conn2, conn2.last_update-5)
		end

		context "when the app is set to be persistent" do
			
			it "will persist all commands which occured at or before the stable timestamp" do
				subject.instance_variable_set :@persist_state, true
				subject.process_commands!
				TestClasses::PersistentState.value.should eq 2
			end

		end

		it "will reduce the active commands by the stable commands" do
			subject.stabilize!
			subject.active_commands.should eq [ @command3 ]
		end

		it "will set the current state to the state when all active commands have been run" do
			subject.process_commands!
			subject.current_state.should eq({ value: 3 })
		end

	end

	describe '#active_commands' do 

		it "will return a list of all active commands" do
			conn1 = subject.create_connection!
			conn2 = subject.create_connection!
			command1 = build_command(conn1, 1)
			command2 = build_command(conn2, 2)
			command3 = build_command(conn1, 3)
			conn1.add_commands! [ command1, command3 ]
			conn2.add_command! command2
			subject.active_commands.should eq [ command1, command3, command2 ]
		end

	end

end