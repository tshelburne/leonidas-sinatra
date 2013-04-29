describe Leonidas::PersistenceLayer::StateLoader do

	describe '#add_builder!' do 

		it "will reject any argument that isn't a StateBuilder" do
			builder = { pretty_good: "but not good enough" }
			expect { subject.add_builder! builder }.to raise_error(TypeError, "Argument must include Leonidas::PersistenceLayer::StateBuilder")
			subject.instance_variable_get(:@builders).should be_empty
		end

		it "will add a builder to the state loader" do
			builder = TestClasses::TestAppStateBuilder.new
			subject.add_builder! builder
			subject.instance_variable_get(:@builders).should eq [ builder ]
		end

	end

	describe '#load_state' do 
	
		it "will load the state for a given app" do
			subject.add_builder! TestClasses::TestAppStateBuilder.new
			state = subject.load_state TestClasses::TestApp.new
			state.should eq({ value: 0 })
		end
	
	end

end