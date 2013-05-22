describe Leonidas::Commands::Command do
	
	subject do
		described_class.new("id", "test", { test: "testdata" }, "clientid", @now)
	end

	before :each do
		@now = Time.now
	end

	describe '#to_hash' do 

		it "will return the command as a hash" do
			subject.to_hash.should eq({ id: "id", name: "test", data: { test: "testdata" }, clientId: "clientid", timestamp: @now.as_milliseconds })
		end

	end

end