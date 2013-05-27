require 'rack/test'
require 'json'

describe Leonidas::Routes::SyncApp do
	include Rack::Test::Methods
	include TestObjects
	include TestMocks
	
	def app
		subject
	end

	def reload_app
		@app = memory_layer.retrieve_app @app.name
	end

	def response_code
		last_response.status
	end

	def response_body
		JSON.parse(last_response.body)
	end

	def memory_layer
		Leonidas::MemoryLayer::MemoryRegistry
	end

	def add_stable_commands
		@app.add_commands! @id1, [ @command1, @command4 ]
		@app.add_commands! @id2, [ @command2 ]
		@app.add_commands! @id3, [ @command3 ]
	end

	def set_persistent!
		@app.instance_variable_set(:@persist_state, true)
	end

	def set_unreconciled!
		memory_layer.clear_registry!
		get "/", pull_request
		reload_app
	end

	def reconcile!
		post "/reconcile", client1_reconcile_request
		post "/reconcile", client2_reconcile_request
		post "/reconcile", client3_reconcile_request
	end


	before :each do
		@app = TestClasses::TestApp.new
		@app.create_client! 'client-1'
		@app.create_client! 'client-2'
		@app.create_client! 'client-3'
		now_milliseconds = Time.now.as_milliseconds
		set_base_milliseconds(now_milliseconds)
		now_seconds = now_milliseconds.to_f / 1000 # this rounds to a flat millisecond
		@command1 = build_command(Time.at(now_seconds) + 1, 'client-1', "increment", { number: "1" }, "11")
		@command2 = build_command(Time.at(now_seconds) + 2, 'client-2', "increment", { number: "2" }, "22")
		@command3 = build_command(Time.at(now_seconds) + 3, 'client-3', "increment", { number: "2" }, "33")
		@command4 = build_command(Time.at(now_seconds) + 4, 'client-1', "multiply",  { number: "3" }, "14")
		@command5 = build_command(Time.at(now_seconds) + 5, 'client-1', "increment", { number: "1" }, "15")
		@command6 = build_command(Time.at(now_seconds) + 6, 'client-3', "multiply",  { number: "2" }, "36") 
		@command7 = build_command(Time.at(now_seconds) + 7, 'client-3', "multiply",  { number: "3" }, "37")
		@command8 = build_command(Time.at(now_seconds) + 8, 'client-2', "increment", { number: "3" }, "28")
		memory_layer.register_app! @app
	end

	after :each do
		memory_layer.clear_registry!
	end

	describe "post /reconcile" do

		before :each do
			set_unreconciled!
		end

		it "will fail with an invalid app id" do
			get "/reconcile", { appName: 'bad-name' }
			response_code.should eq 404
		end

		it "will not return a reconcile required response when the app isn't fully reconciled" do
			post "/reconcile", client1_reconcile_request
			response_body["message"].should_not eq "reconcile required"
		end

		it "will mark the client as checked in" do
			post "/reconcile", client1_reconcile_request
			@app.should have_checked_in(@id1)
		end

		context "when a single client has a list of all commands" do
			
			context "and stable commands have been persisted" do
				
				before :each do
					set_persistent!
					@app.state = { value: 15 }
				end

				it "will run all the new commands passed in" do
					post "/reconcile", all_knowing_client_reconcile_request
					@app.current_state[:value].should eq 99
				end

				it "will return a success message" do
					post "/reconcile", all_knowing_client_reconcile_request
					response_body["success"].should be_true
					response_body["message"].should eq "app partially reconciled"
				end
				
			end

			context "and stable commands haven't been persisted" do
				
				it "will run all commands passed in" do
					post "/reconcile", all_knowing_client_reconcile_request
					@app.current_state[:value].should eq 99
				end

				it "will return a success message" do
					post "/reconcile", all_knowing_client_reconcile_request
					response_body["success"].should be_true
					response_body["message"].should eq "app partially reconciled"
				end

			end

		end
		
		context "when multiple clients are required to get all commands" do
			
			context "and stable commands have been persisted" do
				
				before :each do
					set_persistent!
					@app.state = { value: 15 }
				end

				it "will run all the new commands passed in" do
					post "/reconcile", client1_reconcile_request
					@app.current_state[:value].should eq 32
					post "/reconcile", client2_reconcile_request
					@app.current_state[:value].should eq 35
					post "/reconcile", client3_reconcile_request
					@app.current_state[:value].should eq 99
				end 

				it "will return a success message" do
					post "/reconcile", client1_reconcile_request
					response_body["success"].should be_true
					response_body["message"].should eq "app partially reconciled"
					post "/reconcile", client2_reconcile_request
					response_body["success"].should be_true
					response_body["message"].should eq "app partially reconciled"
					post "/reconcile", client3_reconcile_request
					response_body["success"].should be_true
					response_body["message"].should eq "app fully reconciled"
				end

				context "and the last client checks in" do

					it "will be fully reconciled" do
						post "/reconcile", client1_reconcile_request
						post "/reconcile", client2_reconcile_request
						post "/reconcile", client3_reconcile_request
						@app.should be_reconciled
					end

					context "and an unregistered client appears after false reconciliation" do
				
						before :each do
							reconcile!
							post "/", orphaned_client_push_request
						end

						it "will be fully reconciled when the last client checks in" do
							post "/reconcile", orphaned_client_reconcile_request
							@app.should_not be_reconciled	
							post "/reconcile", client2_reconcile_request
							@app.should_not be_reconciled
							post "/reconcile", client1_reconcile_request
							@app.should_not be_reconciled
							post "/reconcile", client3_reconcile_request
							@app.should be_reconciled
						end

						it "will run all the new commands passed in" do
							post "/reconcile", orphaned_client_reconcile_request
							@app.current_state[:value].should eq 129
							post "/reconcile", client1_reconcile_request
							@app.current_state[:value].should eq 129
							post "/reconcile", client2_reconcile_request
							@app.current_state[:value].should eq 129
							post "/reconcile", client3_reconcile_request
							@app.current_state[:value].should eq 129
						end

					end

				end

			end

			context "and stable commands haven't been persisted" do

				it "will run all the new commands passed in" do
					post "/reconcile", client2_reconcile_request
					@app.current_state[:value].should eq 8
					post "/reconcile", client1_reconcile_request
					@app.current_state[:value].should eq 35
					post "/reconcile", client3_reconcile_request
					@app.current_state[:value].should eq 99
				end

				it "will return a success message" do
					post "/reconcile", client2_reconcile_request
					response_body["success"].should be_true
					response_body["message"].should eq "app partially reconciled"
					post "/reconcile", client1_reconcile_request
					response_body["success"].should be_true
					response_body["message"].should eq "app partially reconciled"
					post "/reconcile", client3_reconcile_request
					response_body["success"].should be_true
					response_body["message"].should eq "app fully reconciled"
				end

				context "and the last client checks in" do

					it "will be fully reconciled" do
						post "/reconcile", client2_reconcile_request
						@app.should_not be_reconciled
						post "/reconcile", client1_reconcile_request
						@app.should_not be_reconciled
						post "/reconcile", client3_reconcile_request
						@app.should be_reconciled
					end

					context "and an unregistered client appears after false reconciliation" do
				
						before :each do
							reconcile!
							post "/", orphaned_client_push_request
						end

						it "will be fully reconciled when the last client checks in" do
							post "/reconcile", orphaned_client_reconcile_request
							@app.should_not be_reconciled	
							post "/reconcile", client2_reconcile_request
							@app.should_not be_reconciled
							post "/reconcile", client1_reconcile_request
							@app.should_not be_reconciled
							post "/reconcile", client3_reconcile_request
							@app.should be_reconciled
						end

						it "will run all the new commands passed in" do
							post "/reconcile", orphaned_client_reconcile_request
							@app.current_state[:value].should eq 129
						end

					end

				end

			end

		end

	end

end