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

	describe '#has_run?' do
		
		it "will default to false" do
			subject.should_not have_run
		end

		it "will return true when the command is marked as run" do
			subject.mark_as_run!
			subject.should have_run
		end

		it "will return false when the command is marked as not run" do
			subject.mark_as_run!
			subject.mark_as_not_run!
			subject.should_not have_run
		end

	end

	describe '#mark_as_run!' do 
	
		it "will mark the command as having been run" do
			subject.mark_as_run!
			subject.should have_run
		end
	
	end

	describe '#mark_as_not_run!' do 
	
		it "will mark the command as not having been run" do
			subject.mark_as_run!
			subject.mark_as_not_run!
			subject.should_not have_run
		end
	
	end

end