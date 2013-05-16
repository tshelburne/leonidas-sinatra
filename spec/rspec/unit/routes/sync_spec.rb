require 'rack/test'
require 'json'

describe Leonidas::Routes::SyncApp do
	include Rack::Test::Methods
	include TestObjects
	
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

	def pull_request
		{ 
			appName: "app-1", 
			clientId: @id1,
			clients: [ 
				{ id: @id2, lastUpdate: @command4.timestamp.to_i.to_s }, 
				{ id: @id3, lastUpdate: @command6.timestamp.to_i.to_s }
			]
		}
	end

	def push_request
		{ 
			appName: "app-1", 
			clientId: @id1,
			clients: [ 
				{ id: @id2, lastUpdate: @command4.timestamp.to_i.to_s }, 
				{ id: @id3, lastUpdate: @command6.timestamp.to_i.to_s } 
			],
			commands: [ 
				{ id: "15", name: "increment", data: { number: "1" }, clientId: @id1, timestamp: @command5.timestamp.to_i.to_s }
			]
		}
	end

	def client1_reconcile_request
		# this is the environment when get /, push / fails, and then post /reconcile
		{
			appName: "app-1",
			clientId: @id1,
			clients: [ 
				{ id: @id2, lastUpdate: @command8.timestamp.to_i.to_s }, 
				{ id: @id3, lastUpdate: @command7.timestamp.to_i.to_s } 
			],
			commandList: [
				{ id: "11", name: "increment", data: { number: "1" }, clientId: @id1, timestamp: @command1.timestamp.to_i.to_s },
				{ id: "22", name: "increment", data: { number: "2" }, clientId: @id2, timestamp: @command2.timestamp.to_i.to_s },
				{ id: "33", name: "increment", data: { number: "2" }, clientId: @id3, timestamp: @command3.timestamp.to_i.to_s },
				{ id: "14", name: "multiply",  data: { number: "3" }, clientId: @id1, timestamp: @command4.timestamp.to_i.to_s },
				{ id: "15", name: "increment", data: { number: "1" }, clientId: @id1, timestamp: @command5.timestamp.to_i.to_s },
				{ id: "36", name: "multiply",  data: { number: "2" }, clientId: @id3, timestamp: @command6.timestamp.to_i.to_s },
				{ id: "37", name: "multiply",  data: { number: "3" }, clientId: @id3, timestamp: @command7.timestamp.to_i.to_s },
				{ id: "28", name: "increment", data: { number: "3" }, clientId: @id2, timestamp: @command8.timestamp.to_i.to_s }
			],
			stableTimestamp: @command4.timestamp.to_i.to_s
		}
	end

	before :each do
		@app = TestClasses::TestApp.new
		@id1 = @app.create_client!
		@id2 = @app.create_client!
		@id3 = @app.create_client!
		@command1 = build_command(Time.now + 1, @id1, "increment", { number: "1" }, "11")
		@command2 = build_command(Time.now + 2, @id2, "increment", { number: "2" }, "22")
		@command3 = build_command(Time.now + 3, @id3, "increment", { number: "2" }, "33")
		@command4 = build_command(Time.now + 4, @id1, "multiply",  { number: "3" }, "14")
		@command5 = build_command(Time.now + 5, @id1, "increment", { number: "1" }, "15")
		@command6 = build_command(Time.now + 6, @id3, "multiply",  { number: "2" }, "36") 
		@command7 = build_command(Time.now + 7, @id3, "multiply",  { number: "3" }, "37")
		@command8 = build_command(Time.now + 8, @id2, "increment", { number: "3" }, "28")
		@app.add_commands! @id1, [ @command1, @command4 ]
		@app.add_commands! @id2, [ @command2 ]
		@app.add_commands! @id3, [ @command3 ]
		memory_layer.register_app! @app
	end

	after :each do
		memory_layer.clear_registry!
	end

	describe "get /" do
		
		it "will fail with an invalid app id" do
			get "/", { appName: 'bad-name' }
			response_code.should eq 404
		end

		it "will return a reconcile required response when the app isn't fully reconciled" do
			get "/", { appName: 'bad-name', appType: 'TestClasses::TestApp' }
			response_body["success"].should be_false
			response_body["message"].should eq "reconcile required"
			response_body["data"].should eq({ })
		end

		context "when successful" do

			before :each do
				@app.add_commands! @id3, [ @command6, @command7 ]
				@app.add_commands! @id2, [ @command8 ]
			end

			it "will return a list of new commands from all external clients" do
				get "/", pull_request
				response_body["data"]["commands"].should eq [ 
					{ "id" => "28", "name" => "increment", "data" => { "number" => "3" }, "clientId" => @id2, "timestamp" => @command8.timestamp.to_i },
					{ "id" => "37", "name" => "multiply",  "data" => { "number" => "3" }, "clientId" => @id3, "timestamp" => @command7.timestamp.to_i }
				]
			end

			it "will return a list of clients and their last update" do
				get "/", pull_request
				response_body["data"]["currentClients"].should eq [
					{ "id" => @id2, "lastUpdate" => @command8.timestamp.to_i }, 
					{ "id" => @id3, "lastUpdate" => @command7.timestamp.to_i } 
				]
			end

			it "will return a stable timestamp" do
				get "/", pull_request
				response_body["data"]["stableTimestamp"].should eq @command4.timestamp.to_i
			end
			
		end

	end

	describe 'post /' do
		
		before :each do
			@app.add_commands! @id3, [ @command6 ]
		end

		it "will fail with an invalid app id" do
			post "/", { appName: 'bad-name'}
			response_code.should eq 404
		end

		it "will return a reconcile required response when the app isn't fully reconciled" do
			get "/", { appName: 'bad-name', appType: 'TestClasses::TestApp' }
			response_body["success"].should be_false
			response_body["message"].should eq "reconcile required"
			response_body["data"].should eq({ })
		end

		context "when successful" do

			it "will run the list of commands" do
				post "/", push_request
				@app.current_state[:value].should eq 32
			end
			
		end
		
	end

	describe "post /reconcile" do

		it "will fail with an invalid app id" do
			get "/reconcile", { appName: 'bad-name' }
			response_code.should eq 404
		end

		it "will not return a reconcile required response when the app isn't fully reconciled" do
			post "/reconcile", { appName: 'bad-name', appType: 'TestClasses::TestApp' }
			# response_body["message"].should_not eq "reconcile required"
		end

		context "when successful" do

			it "will run all the new commands passed in" do
				
			end

			it "will return a success message" do
				
			end
			
		end

	end

end