describe ::Leonidas::App::Client do
	include TestObjects

	describe '#initialize' do
		
		it "will set a default id if no id is passed in" do
			client = ::Leonidas::App::Client.new
			client.id.should_not be_nil
		end

		it "will set the id of the client if it is passed in" do
			client = ::Leonidas::App::Client.new("test-id")
			client.id.should eq "test-id"
		end

	end

	describe '#last_update' do 

		it "will return a timestamp from when the client was created if no commands exist on the client" do
			subject.last_update.should eq subject.instance_variable_get(:@time_created)
		end

		it "will return the maximum timestamp available from all commands" do 
			command1 = build_command Time.now + 20
			command2 = build_command Time.now + 25
			subject.add_commands! [ command1, command2 ]
			subject.last_update.should eq command2.timestamp
		end

	end

	describe '#to_hash' do 
	
		it "will return a hash of the client" do
			subject.to_hash.should eq({ id: subject.id, lastUpdate: subject.last_update.as_milliseconds })
		end
	
	end

end