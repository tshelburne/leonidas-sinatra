describe Leonidas::Commands::Command do
	
	subject do
		described_class.new("id", "test", { test: "testdata" }, "clientid", Time.at(0))
	end

	describe '#to_hash' do 

		it "will return the command as a hash" do
			subject.to_hash.should eq({ id: "id", name: "test", data: { test: "testdata" }, clientId: "clientid", timestamp: Time.at(0).to_i })
		end

	end

end