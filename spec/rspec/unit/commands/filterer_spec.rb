describe Leonidas::Commands::Filterer do
	include TestObjects
	
	subject do
		TestClasses::TestCommandContainer.new
	end

	describe '#commands_through' do 

		before :each do
			@command1 = build_command(Time.at(1))
			@command2 = build_command(Time.at(2))
			@command3 = build_command(Time.at(3))
			@command4 = build_command(Time.at(4))
			subject.add_commands! [ @command1, @command2, @command3, @command4 ]
		end
	
		it "will return a list of commands before the given timestamp" do
			subject.commands_through(Time.at(3)).should include @command1
			subject.commands_through(Time.at(3)).should include @command2
			subject.commands_through(Time.at(3)).should_not include @command4
		end

		it "will include commands at the given timestamp" do 
			subject.commands_through(Time.at(3)).should include @command3
		end

		it "will handle a Fixnum representing the timestamp" do
			subject.commands_through(3).should eq [ @command1, @command2, @command3 ]
		end

		it "will reject any non-Fixnum or non-Time arguments" do
			expect { subject.commands_through("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
		end
	
	end

	describe '#commands_to' do
		
		before :each do
			@command1 = build_command(Time.at(1))
			@command2 = build_command(Time.at(2))
			@command3 = build_command(Time.at(3))
			@command4 = build_command(Time.at(4))
			subject.add_commands! [ @command1, @command2, @command3, @command4 ]
		end
	
		it "will return a list of commands before the given timestamp" do
			subject.commands_to(Time.at(3)).should include @command1
			subject.commands_to(Time.at(3)).should include @command2
			subject.commands_to(Time.at(3)).should_not include @command4
		end

		it "will exclude commands at the given timestamp" do 
			subject.commands_to(Time.at(3)).should_not include @command3
		end

		it "will handle a Fixnum representing the timestamp" do
			subject.commands_to(3).should eq [ @command1, @command2 ]
		end

		it "will reject any non-Fixnum or non-Time arguments" do
			expect { subject.commands_to("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
		end

	end

	describe '#commands_from' do 
	
		before :each do
			@command1 = build_command(Time.at(1))
			@command2 = build_command(Time.at(2))
			@command3 = build_command(Time.at(3))
			@command4 = build_command(Time.at(4))
			subject.add_commands! [ @command1, @command2, @command3, @command4 ]
		end

		it "will return a list of commands after the given timestamp" do
			subject.commands_from(Time.at(2)).should include @command3
			subject.commands_from(Time.at(2)).should include @command4
			subject.commands_from(Time.at(2)).should_not include @command1
		end

		it "will include commands at the given timestamp" do
			subject.commands_from(Time.at(2)).should include @command2
		end

		it "will handle a Fixnum representing the timestamp" do
			subject.commands_from(2).should eq [ @command2, @command3, @command4 ]
		end

		it "will reject any non-Fixnum or non-Time arguments" do
			expect { subject.commands_from("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
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

		it "will return a list of commands after the given timestamp" do
			subject.commands_since(Time.at(2)).should include @command3
			subject.commands_since(Time.at(2)).should include @command4
			subject.commands_since(Time.at(2)).should_not include @command1
		end

		it "will exclude commands at the given timestamp" do
			subject.commands_since(Time.at(2)).should_not include @command2
		end

		it "will handle a Fixnum representing the timestamp" do
			subject.commands_since(2).should eq [ @command3, @command4 ]
		end

		it "will reject any non-Fixnum or non-Time arguments" do
			expect { subject.commands_since("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
		end
	
	end

end