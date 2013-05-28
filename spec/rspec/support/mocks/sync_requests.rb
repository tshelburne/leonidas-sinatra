module TestMocks

	def set_base_milliseconds(base_milliseconds)
		@base_milliseconds = base_milliseconds
	end
	
	def pull_request
		{ 
			appName: "app-1", 
			appType: "TestClasses::TestApp",
			clientId: 'client-1',
			clients: [ 
				{ id: 'client-2', lastUpdate: (@base_milliseconds + 4000).to_s }, 
				{ id: 'client-3', lastUpdate: (@base_milliseconds + 6000).to_s }
			]
		}
	end

	def push_request
		# push after all commands have been entered on the client side
		{ 
			appName: "app-1", 
			appType: "TestClasses::TestApp",
			clientId: 'client-1',
			pushedAt: (@base_milliseconds + 10000).to_s,
			commands: [ 
				{ id: "15", name: "increment", data: { number: "1" }, clientId: 'client-1', timestamp: (@base_milliseconds + 5000).to_s }
			]
		}
	end

	def orphaned_client_push_request
		# push after all commands have been entered on the client side
		{ 
			appName: "app-1",
			appType: "TestClasses::TestApp",
			clientId: "orphan",
			pushedAt: (@base_milliseconds + 10000).to_s,
			commands: [
				{ id: "42", name: "increment", data: { number: "1" }, clientId: "orphan", timestamp: (@base_milliseconds + 5000).to_s },
				{ id: "45", name: "increment", data: { number: "2" }, clientId: "orphan", timestamp: (@base_milliseconds + 5000).to_s }
			]
		}
	end

	def single_client_reconcile_request
		@single_client_reconcile_request ||= general_reconcile_request(
			'client-1', 
			%w(11 14 15), 
			{ }, 
			@base_milliseconds + 4000
		)
	end

	def client1_reconcile_request
		@client1_reconcile_request ||= general_reconcile_request(
			'client-1', 
			%w(11 22 33 14 15 36), 
			{ 'client-2' => @base_milliseconds + 4000, 'client-3' => @base_milliseconds + 6000 }, 
			@base_milliseconds + 4000
		)
	end

	def client2_reconcile_request
		@client2_reconcile_request ||= general_reconcile_request(
			'client-2', 
			%w(11 22 33 28), 
			{ 'client-1' => @base_milliseconds + 4000, 'client-3' => @base_milliseconds + 7000 }, 
			@base_milliseconds + 4000
		)
	end

	def client3_reconcile_request
		@client3_reconcile_request ||= general_reconcile_request(
			'client-3', 
			%w(11 22 33 14 36 37), 
			{ 'client-1' => @base_milliseconds + 4000, 'client-2' => @base_milliseconds + 4000 }, 
			@base_milliseconds + 4000
		)
	end

	def orphaned_client_reconcile_request
		@orphaned_client_reconcile_request ||= general_reconcile_request(
			'orphan', 
			%w(11 22 42 33 14 45 36), 
			{ 'client-1' => @base_milliseconds + 4000, 'client-2' => @base_milliseconds + 4000, 'client-3' => @base_milliseconds + 6000 }, 
			@base_milliseconds + 4000
		)
	end

	# SUPPORT #

	def general_reconcile_request(client_id, included_commands, client_updates, stable_timestamp)
		command_list = { }

		{ 'client-1' => %w(11 14 15), 'client-2' => %w(22 28), 'client-3' => %w(33 36 37), 'orphan' => %w(42 45) }.each do |external_client_id, command_ids|
			common_commands = included_commands & command_ids
			unless common_commands.empty?
				command_list[external_client_id] = common_commands.reduce([ ]) {|commands, id| commands << get_command(id) }
			end
		end

		{
			appName: "app-1",
			appType: "TestClasses::TestApp",
			clientId: client_id,
			clients: client_updates.map {|client_id, timestamp| { id: client_id, lastUpdate: timestamp.to_s } },
			commandList: command_list,
			stableTimestamp: stable_timestamp.to_s
		}
	end

	def get_command(id)
		[
			{ id: "11", name: "increment", data: { number: "1" }, clientId: 'client-1', timestamp: (@base_milliseconds + 1000).to_s },
			{ id: "22", name: "increment", data: { number: "2" }, clientId: 'client-2', timestamp: (@base_milliseconds + 2000).to_s },
			{ id: "42", name: "increment", data: { number: "1" }, clientId: "orphan",   timestamp: (@base_milliseconds + 2005).to_s },
			{ id: "33", name: "increment", data: { number: "2" }, clientId: 'client-3', timestamp: (@base_milliseconds + 3000).to_s },
			{ id: "14", name: "multiply",  data: { number: "3" }, clientId: 'client-1', timestamp: (@base_milliseconds + 4000).to_s },
			{ id: "15", name: "increment", data: { number: "1" }, clientId: 'client-1', timestamp: (@base_milliseconds + 5000).to_s },
			{ id: "45", name: "increment", data: { number: "2" }, clientId: "orphan",   timestamp: (@base_milliseconds + 5005).to_s },
			{ id: "36", name: "multiply",  data: { number: "2" }, clientId: 'client-3', timestamp: (@base_milliseconds + 6000).to_s },
			{ id: "37", name: "multiply",  data: { number: "3" }, clientId: 'client-3', timestamp: (@base_milliseconds + 7000).to_s },
			{ id: "28", name: "increment", data: { number: "3" }, clientId: 'client-2', timestamp: (@base_milliseconds + 8000).to_s }
		].select {|command| command[:id] == id}.first
	end

end