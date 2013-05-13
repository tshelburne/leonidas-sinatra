describe Leonidas::Commands::Aggregator do
	include TestObjects
	
	subject do
		TestClasses::TestAggregator.new
	end

	describe '#add_command!' do 
		
		it "will reject arguments not of type Leonidas::Commands::Command" do 
			expect { subject.add_command!({ name: "increment" }) }.to raise_error(TypeError, "Argument must be a Leonidas::Commands::Command")
		end

		it "will add a command to the list of commands" do
			command = build_command(Time.at(1))
			subject.add_command! command
			subject.commands_since(Time.at(0)).should eq [ command ]
		end

		it "will not add a command if a command with an identical id already exists" do
			command1 = build_command(Time.at(1))
			command2 = build_command(Time.at(1))
			subject.add_command! command1
			subject.add_command! command2
			subject.commands_since(Time.at(0)).should eq [ command1 ]
		end
	
	end

	describe '#add_commands!' do 
	
		it "will add each in the list of commands to the list of active commands" do
			command1 = build_command(Time.at(1))
			command2 = build_command(Time.at(2))
			subject.add_commands! [ command1, command2 ]
			subject.commands_since(Time.at(0)).should eq [ command1, command2 ]
		end

	end

	describe '#commands_through' do 

		before :each do
			@command1 = build_command(Time.at(1))
			@command2 = build_command(Time.at(2))
			@command3 = build_command(Time.at(3))
			@command4 = build_command(Time.at(4))
			subject.add_commands! [ @command1, @command2, @command3, @command4 ]
		end
	
		it "will return a list of active commands before the given timestamp" do
			subject.commands_through(Time.at(3)).should include @command1
			subject.commands_through(Time.at(3)).should include @command2
			subject.commands_through(Time.at(3)).should_not include @command4
		end

		it "will include active commands at the given timestamp" do 
			subject.commands_through(Time.at(3)).should include @command3
		end
	
	end

	describe '#commands_since' do 
	
		before :each do
			@command1 = build_command(Time.at(1))
			@command2 = build_command(Time.at(2))
			@command3 = build_command(Time.at(3))
			@command4 = build_command(Time.at(4))
			subject.add_commands! [ @command1, @command2, @command3, @command4 ]
		end

		it "will return a list of active commands after the given timestamp" do
			subject.commands_since(Time.at(2)).should include @command3
			subject.commands_since(Time.at(2)).should include @command4
			subject.commands_since(Time.at(2)).should_not include @command1
		end

		it "will exclude commands at the given timestamp" do
			subject.commands_since(Time.at(2)).should_not include @command2
		end
	
	end

end