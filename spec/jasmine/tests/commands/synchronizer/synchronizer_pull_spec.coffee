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

	describe "#pull", ->

		beforeEach ->
			organizer.local.addCommands [ command1, command4, command5, command7 ]
			processor.runCommands [ command1, command4, command5, command7 ]

		describe "when making the request, will send", ->

			beforeEach -> spyOn(window, "reqwest")

			it "an app name", ->
				synchronizer.pull()
				expect(window.reqwest.mostRecentCall.args[0].data.appName).toEqual client.appName

			it "an app type", ->
				synchronizer.pull()
				expect(window.reqwest.mostRecentCall.args[0].data.appType).toEqual client.appType

			it "a client id", ->
				synchronizer.pull()
				expect(window.reqwest.mostRecentCall.args[0].data.clientId).toEqual client.id

			it "a list of external clients", ->
				synchronizer.externalClients = { "client-2": new Date(2013, 4, 2).getTime(), "client-3": new Date(2013, 4, 8).getTime() }
				synchronizer.pull()
				expect(window.reqwest.mostRecentCall.args[0].data.externalClients).toEqual synchronizer.externalClients

		describe "when successful", ->

			beforeEach -> spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncPullResponse))

			it "will update the list of external clients and their latest timestamps", ->
				synchronizer.pull()
				expect(synchronizer.externalClients).toEqual 
					"client-2": new Date(2013, 4, 2).getTime()
					"client-3": new Date(2013, 4, 8).getTime()
					
			it "will update the stable timestamp", ->
				synchronizer.pull()
				expect(synchronizer.stableTimestamp).toEqual new Date(2013, 4, 2).getTime()

			it "will add the list of received commands to external commands", ->
				synchronizer.pull()
				expect(organizer.external.commands.length).toEqual 3
				expect(organizer.external.commands[0].toHash()).toEqual { id: '22', name: 'multiply',  data: { number: 2 }, clientId: "client-2", timestamp: new Date(2013, 4, 2).getTime() }
				expect(organizer.external.commands[1].toHash()).toEqual { id: '36', name: 'increment', data: { number: 1 }, clientId: "client-3", timestamp: new Date(2013, 4, 6).getTime() }
				expect(organizer.external.commands[2].toHash()).toEqual { id: '38', name: 'increment', data: { number: 3 }, clientId: "client-3", timestamp: new Date(2013, 4, 8).getTime() }

			it "will update to the most current state", ->
				synchronizer.pull()
				expect(state.value).toEqual 32

		describe "when unsuccessful", ->

			beforeEach ->
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.reconcileRequiredResponse))
				spyOn(synchronizer, "reconcile")
				jasmine.Clock.useMock()

			it "will begin reconciling if reconciliation is required", ->
				synchronizer.pull()
				jasmine.Clock.tick(2000)
				expect(synchronizer.reconcile).toHaveBeenCalled()