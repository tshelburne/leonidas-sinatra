describe Leonidas::Commands::Filterer do
	include TestObjects
	
	subject do
		TestClasses::TestCommandContainer.new
	end

	before :each do
		@command1 = build_command(Time.at(1))
		@command2 = build_command(Time.at(2))
		@command3 = build_command(Time.at(3))
		@command4 = build_command(Time.at(4))
		subject.add_commands! [ @command1, @command2, @command3, @command4 ]
	end

	describe '#commands_through' do 
	
		it "will return a list of commands before the given timestamp" do
			subject.commands_through(@command3.timestamp).should include @command1
			subject.commands_through(@command3.timestamp).should include @command2
			subject.commands_through(@command3.timestamp).should_not include @command4
		end

		it "will include commands at the given timestamp" do 
			subject.commands_through(@command3.timestamp).should include @command3
		end

		it "will handle a Command representing the timestamp" do
			subject.commands_through(@command3).should eq [ @command1, @command2, @command3 ]
		end

		it "will handle a Fixnum representing the timestamp" do
			subject.commands_through(3).should eq [ @command1, @command2, @command3 ]
		end

		it "will handle a Float representing the timestamp" do
			subject.commands_through(3.4).should eq [ @command1, @command2, @command3 ]
		end

		it "will reject a non-Fixnum, non-Float, non-Command, or non-Time argument" do
			expect { subject.commands_through("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
		end

		context "when a list of commands is passed in as the second argument" do
			
			it "will run the function against the specified commands" do
				subject.commands_through(3, [ @command2, @command3, @command4 ]).should eq [ @command2, @command3 ]
			end

		end
	
	end

	describe '#commands_to' do
	
		it "will return a list of commands before the given timestamp" do
			subject.commands_to(@command3.timestamp).should include @command1
			subject.commands_to(@command3.timestamp).should include @command2
			subject.commands_to(@command3.timestamp).should_not include @command4
		end

		it "will exclude commands at the given timestamp" do 
			subject.commands_to(@command3.timestamp).should_not include @command3
		end

		it "will handle a Command representing the timestamp" do
			subject.commands_to(@command3).should eq [ @command1, @command2 ]
		end

		it "will handle a Fixnum representing the timestamp" do
			subject.commands_to(3).should eq [ @command1, @command2 ]
		end

		it "will handle a Float representing the timestamp" do
			subject.commands_to(2.4).should eq [ @command1, @command2 ]
		end

		it "will reject a non-Fixnum, non-Float, non-Command, or non-Time argument" do
			expect { subject.commands_to("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
		end

		context "when a list of commands is passed in as the second argument" do
			
			it "will run the function against the specified commands" do
				subject.commands_to(3, [ @command2, @command3, @command4 ]).should eq [ @command2 ]
			end

		end

	end

	describe '#commands_from' do 

		it "will return a list of commands after the given timestamp" do
			subject.commands_from(@command2.timestamp).should include @command3
			subject.commands_from(@command2.timestamp).should include @command4
			subject.commands_from(@command2.timestamp).should_not include @command1
		end

		it "will include commands at the given timestamp" do
			subject.commands_from(@command2.timestamp).should include @command2
		end

		it "will handle a Command representing the timestamp" do
			subject.commands_from(@command2).should eq [ @command2, @command3, @command4 ]
		end

		it "will handle a Fixnum representing the timestamp" do
			subject.commands_from(2).should eq [ @command2, @command3, @command4 ]
		end

		it "will handle a Float representing the timestamp" do
			subject.commands_from(1.5).should eq [ @command2, @command3, @command4 ]
		end

		it "will reject a non-Fixnum, non-Float, non-Command, or non-Time argument" do
			expect { subject.commands_from("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
		end

		context "when a list of commands is passed in as the second argument" do
			
			it "will run the function against the specified commands" do
				subject.commands_from(2, [ @command1, @command2, @command3 ]).should eq [ @command2, @command3 ]
			end

		end
	
	end

	describe '#commands_since' do 

		it "will return a list of commands after the given timestamp" do
			subject.commands_since(@command2.timestamp).should include @command3
			subject.commands_since(@command2.timestamp).should include @command4
			subject.commands_since(@command2.timestamp).should_not include @command1
		end

		it "will exclude commands at the given timestamp" do
			subject.commands_since(@command2.timestamp).should_not include @command2
		end

		it "will handle a Command representing the timestamp" do
			subject.commands_since(@command2).should eq [ @command3, @command4 ]
		end

		it "will handle a Fixnum representing the timestamp" do
			subject.commands_since(2).should eq [ @command3, @command4 ]
		end

		it "will handle a Float representing the timestamp" do
			subject.commands_since(2.5).should eq [ @command3, @command4 ]
		end

		it "will reject a non-Fixnum, non-Float, non-Command, or non-Time argument" do
			expect { subject.commands_since("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
		end

		context "when a list of commands is passed in as the second argument" do
			
			it "will run the function against the specified commands" do
				subject.commands_since(2, [ @command1, @command2, @command3 ]).should eq [ @command3 ]
			end

		end
	
	end

end