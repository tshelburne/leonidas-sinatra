require 'rack/test'
require 'json'

describe Leonidas::Routes::SyncApp do
	include Rack::Test::Methods
	include TestObjects
	include TestMocks
	
	def app
		subject
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

	def reload_app
		@app = memory_layer.retrieve_app @app.name
	end

	def command_time(command)
		command.timestamp.as_milliseconds
	end

	def add_stable_commands
		@app.add_commands! 'client-1', [ @command1, @command4 ]
		@app.add_commands! 'client-2', [ @command2 ]
		@app.add_commands! 'client-3', [ @command3 ]
	end

	def set_unreconciled!
		memory_layer.clear_registry!
		get "/", pull_request
		reload_app
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

	describe "get /" do

		before :each do
			add_stable_commands
		end

		it "can handle an empty client list" do
			get "/", { appName: 'app-1', clientId: 'client-1', clients: [ ] }
			response_code.should eq 200
		end

		context "when the app id is invalid" do
		
			it "will fail" do
				get "/", { appName: 'bad-name' }
				response_code.should eq 404
			end

			context "and an app type is supplied" do

				it "will return a reconcile required response" do
					get "/", { appName: 'bad-name', appType: 'TestClasses::TestApp' }
					response_body["success"].should be_false
					response_body["message"].should eq "reconcile required"
					response_body["data"].should eq({ })
				end

				it "will create the app and set it to reconcile required" do
					get "/", { appName: 'bad-name', appType: 'TestClasses::TestApp' }
					memory_layer.should have_app 'bad-name'
					memory_layer.retrieve_app('bad-name').should_not be_reconciled
				end

			end

		end

		context "when the app isn't fully reconciled" do

			it "will return a reconcile required response" do
				set_unreconciled!
				get "/", pull_request
				response_body["success"].should be_false
				response_body["message"].should eq "reconcile required"
				response_body["data"].should eq({ })
			end

			it "will not return the reconcile required response if the client has already checked in" do
				set_unreconciled!
				post "/reconcile", client1_reconcile_request
				get "/", pull_request
				response_body["message"].should_not eq "reconcile required"
			end

		end

		context "when successful" do

			before :each do
				@app.add_commands! 'client-3', [ @command6, @command7 ]
				@app.add_commands! 'client-2', [ @command8 ]
			end

			it "will return a list of new commands from all external clients" do
				get "/", pull_request
				response_body["data"]["commands"].should eq [ 
					{ "id" => "28", "name" => "increment", "data" => { "number" => "3" }, "clientId" => 'client-2', "timestamp" => command_time(@command8) },
					{ "id" => "37", "name" => "multiply",  "data" => { "number" => "3" }, "clientId" => 'client-3', "timestamp" => command_time(@command7) }
				]
			end

			it "will return a list of clients and their last update" do
				get "/", pull_request
				response_body["data"]["externalClients"].should eq [
					{ "id" => 'client-2', "lastUpdate" => command_time(@command8) }, 
					{ "id" => 'client-3', "lastUpdate" => command_time(@command7) } 
				]
			end

			it "will return a stable timestamp" do
				get "/", pull_request
				response_body["data"]["stableTimestamp"].should eq command_time(@command4)
			end
			
		end

	end

end