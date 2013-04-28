describe Leonidas::Commands::Command do
	include TestObjects

	subject do
		@connection = build_connection
		Leonidas::Commands::Command.new("test", { test: "testdata" }, 123, @connection)
	end

	describe '#to_hash' do 

		it "will return the command as a hash" do
			subject.to_hash.should eq({ name: "test", data: { test: "testdata" }, timestamp: 123, @connection.id })
		end

	end

end