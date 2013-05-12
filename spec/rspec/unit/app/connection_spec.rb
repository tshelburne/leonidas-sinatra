describe ::Leonidas::App::Connection do
	include TestObjects

	describe '#last_update' do 

		it "will return a 0 timestamp if no commands exist on the connection" do
			subject.last_update.should eq Time.at(0)
		end

		it "will return the maximum timestamp available from all commands" do 
			command1 = build_command subject, Time.at(20)
			command2 = build_command subject, Time.at(25)
			subject.add_commands! [ command1, command2 ]
			subject.last_update.should eq command2.timestamp
		end

	end

end