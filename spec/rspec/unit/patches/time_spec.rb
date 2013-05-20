describe Time do
	
	describe '#as_milliseconds' do
		
		it "will return the current milliseconds since the Epoch" do
			Time.at(0).as_milliseconds.should eq 0
			Time.at(1.5).as_milliseconds.should eq 1500
		end

		it "will round down to the nearest millisecond" do
			Time.at(234.65442).as_milliseconds.should eq 234654
			Time.at(234.65499).as_milliseconds.should eq 234654
		end

	end

end