Organizer = require 'leonidas/commands/organizer'
Processor = require 'leonidas/commands/processor'
Synchronizer = require 'leonidas/commands/synchronizer'

describe "Synchronizer", ->
	state = null
	command1 = command2 = command4 = command5 = command6 = command7 = command8 = null
	client = null
	organizer = null
	synchronizer = null
	processor = null

	beforeEach ->
		state = { value: 1 }
		client = buildClient()
		organizer = new Organizer()
		command1 = buildCommand(new Date(2013, 4, 1), { number: 1 }, "increment", "client-1", "11")
		command2 = buildCommand(new Date(2013, 4, 2), { number: 2 }, "multiply",  "client-2", "22")
		command4 = buildCommand(new Date(2013, 4, 4), { number: 2 }, "multiply",  "client-1", "14")
		command5 = buildCommand(new Date(2013, 4, 5), { number: 3 }, "multiply",  "client-1", "15")
		command6 = buildCommand(new Date(2013, 4, 6), { number: 1 }, "increment", "client-3", "36")
		command7 = buildCommand(new Date(2013, 4, 7), { number: 4 }, "increment", "client-1", "17")
		command8 = buildCommand(new Date(2013, 4, 8), { number: 3 }, "increment", "client-3", "38")
		processor = new Processor([ new IncrementHandler(state), new MultiplyHandler(state)])
		synchronizer = new Synchronizer("http://mydomain.com/sync", client, organizer, processor)

	describe "#push", ->

		it "will not run if there are no commands to sync", ->
			spyOn(window, "reqwest")
			synchronizer.push()
			expect(window.reqwest).not.toHaveBeenCalled()

		describe "when making the request, will send", ->

			beforeEach -> 
				organizer.local.addCommands [ command1, command4 ]
				spyOn(window, "reqwest")

			it "an app name", ->
				synchronizer.push()
				expect(window.reqwest.mostRecentCall.args[0].data.appName).toEqual client.appName

			it "an app type", ->
				synchronizer.push()
				expect(window.reqwest.mostRecentCall.args[0].data.appType).toEqual client.appType

			it "a client id", ->
				synchronizer.push()
				expect(window.reqwest.mostRecentCall.args[0].data.clientId).toEqual client.id

			it "the time the push was initialized", ->
				synchronizer.push()
				expect(window.reqwest.mostRecentCall.args[0].data.pushedAt).toEqual synchronizer.lastPushAttempt

			it "the list of unsynced commands", ->
				synchronizer.push()
				expect(window.reqwest.mostRecentCall.args[0].data.commands["11"]).toEqual command1.toHash()
				expect(window.reqwest.mostRecentCall.args[0].data.commands["14"]).toEqual command4.toHash()

		describe "when successful", ->

			beforeEach ->
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncPushResponse))
				organizer.local.addCommands [ command1, command4 ]

			it "will set the client's lastUpdate to the time the push was attempted", ->
				synchronizer.push()
				expect(client.lastUpdate).toEqual synchronizer.lastPushAttempt

		describe "when unsuccessful", ->

			beforeEach ->
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.reconcileRequiredResponse))
				spyOn(synchronizer, "reconcile")
				jasmine.Clock.useMock()
				organizer.local.addCommands [ command1, command4 ]

			it "will begin reconciling if reconciliation is required", ->
				synchronizer.push()
				jasmine.Clock.tick(2000)
				expect(synchronizer.reconcile).toHaveBeenCalled()