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
				{ id: @id2, lastUpdate: Time.new(2013, 4, 4).to_i }, 
				{ id: @id3, lastUpdate: Time.new(2013, 4, 6).to_i }
			]
		}
	end

	def push_request
		{ 
			appName: "app-1", 
			clientId: @id1,
			clients: [ 
				{ id: @id2, lastUpdate: Time.new(2013, 4, 4).to_i }, 
				{ id: @id3, lastUpdate: Time.new(2013, 4, 6).to_i } 
			],
			commands: [ 
				{ id: "15", name: "increment", data: { number: 1 }, clientId: @id1, timestamp: Time.new(2013, 4, 5).to_i }
			]
		}
	end

	def reconcile_request
		# this is the environment when get /, push / fails, and then post /reconcile
		{
			appName: "app-1",
			clientId: @id1,
			clients: [ 
				{ id: @id2, lastUpdate: Time.new(2013, 4, 8).to_i }, 
				{ id: @id3, lastUpdate: Time.new(2013, 4, 7).to_i } 
			],
			commandList: [
				{ id: "11", name: "increment", data: { number: 1 }, clientId: @id1, timestamp: Time.new(2013, 4, 1).to_i },
				{ id: "22", name: "increment", data: { number: 2 }, clientId: @id2, timestamp: Time.new(2013, 4, 2).to_i },
				{ id: "33", name: "increment", data: { number: 2 }, clientId: @id3, timestamp: Time.new(2013, 4, 3).to_i },
				{ id: "14", name: "multiply",  data: { number: 3 }, clientId: @id1, timestamp: Time.new(2013, 4, 4).to_i },
				{ id: "15", name: "increment", data: { number: 1 }, clientId: @id1, timestamp: Time.new(2013, 4, 5).to_i },
				{ id: "36", name: "multiply",  data: { number: 2 }, clientId: @id3, timestamp: Time.new(2013, 4, 6).to_i },
				{ id: "37", name: "multiply",  data: { number: 3 }, clientId: @id3, timestamp: Time.new(2013, 4, 7).to_i },
				{ id: "28", name: "increment", data: { number: 3 }, clientId: @id2, timestamp: Time.new(2013, 4, 8).to_i }
			],
			stableTimestamp: Time.new(2013, 4, 4).to_i 
		}
	end

	before :each do
		@app = TestClasses::TestApp.new
		@id1 = @app.create_client!
		@id2 = @app.create_client!
		@id3 = @app.create_client!
		@app.add_commands! @id1, [ build_command(Time.new(2013, 4, 1), @id1, "increment", { number: 1 }, "11"), build_command(Time.new(2013, 4, 4), @id1, "multiply", { number: 3 }, "14") ]
		@app.add_commands! @id2, [ build_command(Time.new(2013, 4, 2), @id2, "increment", { number: 2 }, "22") ]
		@app.add_commands! @id3, [ build_command(Time.new(2013, 4, 3), @id3, "increment", { number: 2 }, "33") ]
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
				@app.add_commands! @id3, [ build_command(Time.new(2013, 4, 6), @id3, "multiply",  { number: 2 }, "36"), build_command(Time.new(2013, 4, 7), @id3, "multiply", { number: 3 }, "37") ]
				@app.add_commands! @id2, [ build_command(Time.new(2013, 4, 8), @id2, "increment", { number: 3 }, "28") ]
			end

			it "will return a list of new commands from all external clients" do
				get "/", pull_request
				response_body["data"]["commands"].should eq [ 
					{ "id" => "36", "name" => "multiply",  "data" => { "number" => 2 }, "clientId" => @id3, "timestamp" => Time.new(2013, 4, 6).to_i },
					{ "id" => "37", "name" => "multiply",  "data" => { "number" => 3 }, "clientId" => @id3, "timestamp" => Time.new(2013, 4, 7).to_i },
					{ "id" => "28", "name" => "increment", "data" => { "number" => 3 }, "clientId" => @id2, "timestamp" => Time.new(2013, 4, 8).to_i } 
				]
			end

			it "will return a list of clients and their last update" do
				get "/", pull_request
				response_body["data"]["currentClients"].should eq [
					{ "id" => @id2, "lastUpdate" => Time.new(2013, 4, 8).to_i }, 
					{ "id" => @id3, "lastUpdate" => Time.new(2013, 4, 7).to_i } 
				]
			end

			it "will return a stable timestamp" do
				get "/", pull_request
				response_body["data"]["stableTimestamp"].should eq Time.new(2013, 4, 4).to_i
			end
			
		end

	end

	describe 'post /' do
		
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

			it "will return a success message" do
				
			end
			
		end

	end

end