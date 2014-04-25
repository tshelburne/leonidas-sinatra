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

	describe 'when filtering' do

		it "will reject a call when #all_commands isn't implemented on the includee class" do
			temp_subject = TestClasses::InvalidTestCommandContainer.new
			expect { temp_subject.commands_through(3) }.to raise_error(StandardError, "Includee class must include #all_commands")
			expect { temp_subject.commands_to(3)      }.to raise_error(StandardError, "Includee class must include #all_commands")
			expect { temp_subject.commands_from(3)    }.to raise_error(StandardError, "Includee class must include #all_commands")
			expect { temp_subject.commands_since(3)   }.to raise_error(StandardError, "Includee class must include #all_commands")
		end

		it "will not affect the result of #all_commands" do
			subject.commands_through(3)
			subject.all_commands.should eq [ @command1, @command2, @command3, @command4 ]
			subject.commands_to(3)
			subject.all_commands.should eq [ @command1, @command2, @command3, @command4 ]
			subject.commands_from(2)
			subject.all_commands.should eq [ @command1, @command2, @command3, @command4 ]
			subject.commands_since(2)
			subject.all_commands.should eq [ @command1, @command2, @command3, @command4 ]
		end

		context 'by timestamp' do

			it "will handle a Time representing the timestamp" do
				subject.commands_through(Time.at(3)).should eq [ @command1, @command2, @command3 ]
				subject.commands_to(Time.at(3)).should eq [ @command1, @command2 ]
				subject.commands_from(Time.at(2)).should eq [ @command2, @command3, @command4 ]
				subject.commands_since(Time.at(2)).should eq [ @command3, @command4 ]
			end
			
			it "will handle a Command representing the timestamp" do
				subject.commands_through(@command3).should eq [ @command1, @command2, @command3 ]
				subject.commands_to(@command3).should eq [ @command1, @command2 ]
				subject.commands_from(@command2).should eq [ @command2, @command3, @command4 ]
				subject.commands_since(@command2).should eq [ @command3, @command4 ]
			end

			it "will handle a Fixnum representing the timestamp" do
				subject.commands_through(3).should eq [ @command1, @command2, @command3 ]
				subject.commands_to(3).should eq [ @command1, @command2 ]
				subject.commands_from(2).should eq [ @command2, @command3, @command4 ]
				subject.commands_since(2).should eq [ @command3, @command4 ]
			end

			it "will handle a Float representing the timestamp" do
				subject.commands_through(3.4).should eq [ @command1, @command2, @command3 ]
				subject.commands_to(2.4).should eq [ @command1, @command2 ]
				subject.commands_from(1.5).should eq [ @command2, @command3, @command4 ]
				subject.commands_since(2.5).should eq [ @command3, @command4 ]
			end

			it "will reject a non-Fixnum, non-Float, non-Command, or non-Time argument" do
				expect { subject.commands_through("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
				expect { subject.commands_to("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
				expect { subject.commands_from("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
				expect { subject.commands_since("three") }.to raise_error(TypeError, "Argument must be more 'timestampy'")
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

		context "when a list of commands is passed in as the second argument" do
			
			it "will run the function against the specified commands" do
				subject.commands_from(2, [ @command1, @command2, @command3 ]).should eq [ @command2, @command3 ]
			end

			it "will not affect the list of commands passed in" do
				commands = [ @command1, @command2, @command3 ]
				subject.commands_from(2, commands)
				commands.should eq [ @command1, @command2, @command3 ]
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

		context "when a list of commands is passed in as the second argument" do
			
			it "will run the function against the specified commands" do
				subject.commands_since(2, [ @command1, @command2, @command3 ]).should eq [ @command3 ]
			end

			it "will not affect the list of commands passed in" do
				commands = [ @command1, @command2, @command3 ]
				subject.commands_since(2, commands)
				commands.should eq [ @command1, @command2, @command3 ]
			end

		end
	
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

		context "when a list of commands is passed in as the second argument" do
			
			it "will run the function against the specified commands" do
				subject.commands_through(3, [ @command2, @command3, @command4 ]).should eq [ @command2, @command3 ]
			end

			it "will not affect the list of commands passed in" do
				commands = [ @command2, @command3, @command4 ]
				subject.commands_through(3, commands)
				commands.should eq [ @command2, @command3, @command4 ]
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

		context "when a list of commands is passed in as the second argument" do
			
			it "will run the function against the specified commands" do
				subject.commands_to(3, [ @command2, @command3, @command4 ]).should eq [ @command2 ]
			end

			it "will not affect the list of commands passed in" do
				commands = [ @command2, @command3, @command4 ]
				subject.commands_to(3, commands)
				commands.should eq [ @command2, @command3, @command4 ]
			end

		end

	end

	describe '#commands_between' do 

		it "will return a list of commands between the given from and through timestamps" do
			subject.commands_between(@command2.timestamp, @command4.timestamp).should include @command3
			subject.commands_between(@command2.timestamp, @command4.timestamp).should_not include @command1
		end

		it "will include commands at the given timestamps" do
			subject.commands_between(@command2.timestamp, @command4.timestamp).should include @command2
			subject.commands_between(@command2.timestamp, @command4.timestamp).should include @command4
		end

		context "when a list of commands is passed in as the second argument" do
			
			it "will run the function against the specified commands" do
				subject.commands_between(2, 3, [ @command1, @command2, @command3 ]).should eq [ @command2, @command3 ]
			end

			it "will not affect the list of commands passed in" do
				commands = [ @command1, @command2, @command3 ]
				subject.commands_between(2, 3, commands)
				commands.should eq [ @command1, @command2, @command3 ]
			end

		end
	
	end

	describe '#commands_inside' do 

		it "will return a list of commands inside the given since and to timestamps" do
			subject.commands_inside(@command2.timestamp, @command4.timestamp).should include @command3
			subject.commands_inside(@command2.timestamp, @command4.timestamp).should_not include @command1
		end

		it "will exclude commands at the given timestamps" do
			subject.commands_inside(@command2.timestamp, @command4.timestamp).should_not include @command2
			subject.commands_inside(@command2.timestamp, @command4.timestamp).should_not include @command4
		end

		context "when a list of commands is passed in as the second argument" do
			
			it "will run the function against the specified commands" do
				subject.commands_inside(1, 3, [ @command1, @command2, @command3 ]).should eq [ @command2 ]
			end

			it "will not affect the list of commands passed in" do
				commands = [ @command1, @command2, @command3 ]
				subject.commands_inside(1, 3, commands)
				commands.should eq [ @command1, @command2, @command3 ]
			end

		end
	
	end

end