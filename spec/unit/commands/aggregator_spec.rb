describe Leonidas::Commands::Aggregator do
	include TestObjects
	
	subject do
		TestClasses::TestCommandContainer.new
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

		it "will not add any command which already has it's id represented in the list" do
			command1 = build_command(Time.at(1))
			command2 = build_command(Time.at(2))
			command3 = build_command(Time.at(3))
			command4 = build_command(Time.at(3))
			command5 = build_command(Time.at(4))
			command6 = build_command(Time.at(1))
			subject.add_commands! [ command1, command2, command3 ]
			subject.add_commands! [ command4, command5, command6 ]
			subject.commands_since(Time.at(0)).should eq [ command1, command2, command3, command5 ]
		end

	end

end