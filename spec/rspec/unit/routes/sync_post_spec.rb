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
		@app.add_commands! 'client-1', [ @command1, @command4 ]
		@app.add_commands! 'client-2', [ @command2 ]
		@app.add_commands! 'client-3', [ @command3 ]
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

	describe 'post /' do
		
		before :each do
			add_stable_commands
			@app.add_commands! 'client-3', [ @command6 ]
		end

		it "will fail with an invalid client id" do
			post "/", { appName: 'app-1', clientId: 'bad-id', commands: [ build_command(Time.now).to_hash ] }
			response_body["success"].should be_false
			response_body["message"].should eq "Argument 'bad-id' is not a valid client id"
			response_body["data"].should eq({ })
		end

		context "when the app id is invalid" do
		
			it "will fail" do
				post "/", { appName: 'bad-name' }
				response_code.should eq 404
			end

			context "and an app type is supplied" do

				it "will return a reconcile required response" do
					post "/", { appName: 'bad-name', appType: 'TestClasses::TestApp' }
					response_body["success"].should be_false
					response_body["message"].should eq "reconcile required"
					response_body["data"].should eq({ })
				end

				it "will create the app and set it to reconcile required" do
					post "/", { appName: 'bad-name', appType: 'TestClasses::TestApp' }
					memory_layer.should have_app 'bad-name'
					memory_layer.retrieve_app('bad-name').should_not be_reconciled
				end

			end

		end

		context "when the app isn't fully reconciled" do

			before :each do
				set_unreconciled!
			end

			it "will return a reconcile required response" do
				post "/", push_request
				response_body["success"].should be_false
				response_body["message"].should eq "reconcile required"
				response_body["data"].should eq({ })
			end

			it "will not return the reconcile required response if the client has already checked in" do
				post "/reconcile", client1_reconcile_request
				post "/", push_request
				response_body["message"].should_not eq "reconcile required"
			end

		end

		context "when the app was previously unreconciled and the request comes from an unregistered client" do

			before :each do
				set_unreconciled!
				reconcile!
			end

			it "will return a reconcile required response" do
				post "/", orphaned_client_push_request
				response_body['success'].should be_false
				response_body['message'].should eq 'reconcile required'
				response_body['data'].should eq({ })
			end

			it "will mark the app as unreconciled" do
				post "/", orphaned_client_push_request
				@app.should_not be_reconciled
			end

		end

		context "when successful" do

			it "will run the list of commands" do
				post "/", push_request
				@app.current_state[:value].should eq 32
			end
			
		end
		
	end

end