Organizer = require 'leonidas/commands/organizer'
Processor = require 'leonidas/commands/processor'
Synchronizer = require 'leonidas/commands/synchronizer'

describe "Synchronizer", ->
	command1 = command4 = command5 = command7 = null
	client = null
	organizer = null
	synchronizer = null
	processor = null

	beforeEach ->
		client = buildClient()
		organizer = new Organizer()
		command1 = buildCommand(new Date(2013, 4, 1), { number: 1 })
		command4 = buildCommand(new Date(2013, 4, 4), { number: 2 }, "multiply")
		command5 = buildCommand(new Date(2013, 4, 5), { number: 3 }, "multiply")
		command7 = buildCommand(new Date(2013, 4, 7), { number: 4 })
		processor = new Processor([ new IncrementHandler(client.state), new MultiplyHandler(client.state)])
		synchronizer = new Synchronizer("http://mydomain.com/sync", client, organizer, processor)

	describe "#push", ->

		beforeEach ->
			spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncPushResponse))

		it "will not run if there are no commands to sync", ->
			synchronizer.push()
			expect(window.reqwest).not.toHaveBeenCalled()

		describe "when successful", ->

			beforeEach ->
				organizer.local.addCommands [ command1, command4 ]

			it "will set the client's lastUpdate to the timestamp of the latest command passed down", ->
				synchronizer.push()
				expect(client.lastUpdate).toEqual command4.timestamp

	describe "#pull", ->

		beforeEach ->
			organizer.local.addCommands [ command1, command4, command5, command7 ]
			processor.runCommands [ command1, command4, command5, command7 ]

		describe "when successful", ->

			beforeEach ->
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncPullResponse))

			it "will update the list of external clients and their latest timestamps", ->
				synchronizer.pull()
				expect(synchronizer.externalClients).toEqual [ { id: "2345", lastUpdate: new Date(2013, 4, 2).getTime() }, { id: "3456", lastUpdate: new Date(2013, 4, 8).getTime() } ]

			it "will update the stable timestamp", ->
				synchronizer.pull()
				expect(synchronizer.stableTimestamp).toEqual new Date(2013, 4, 2).getTime()

			it "will add the list of received commands to external commands", ->
				synchronizer.pull()
				expect(organizer.external.commands.length).toEqual 3
				expect(organizer.external.commands[0].toHash()).toEqual { id: 'command2', name: 'multiply',  data: { number: 2 }, clientId: "2345", timestamp: new Date(2013, 4, 2).getTime() }
				expect(organizer.external.commands[1].toHash()).toEqual { id: 'command6', name: 'increment', data: { number: 1 }, clientId: "3456", timestamp: new Date(2013, 4, 6).getTime() }
				expect(organizer.external.commands[2].toHash()).toEqual { id: 'command8', name: 'increment', data: { number: 3 }, clientId: "3456", timestamp: new Date(2013, 4, 8).getTime() }

			it "will update to the most current state", ->
				synchronizer.pull()
				expect(client.state.integer).toEqual 32

	describe "#reconcile", ->

		beforeEach ->
			spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncReconcileResponse))

		it "fails", ->
			expect(false).toBeTruthy()