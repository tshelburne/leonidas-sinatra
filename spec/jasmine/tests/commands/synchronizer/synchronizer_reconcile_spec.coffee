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

	describe "#reconcile", ->

		beforeEach ->
			spyOn(synchronizer, 'reconcile').andCallThrough()
			jasmine.Clock.useMock()

		describe "when making the request, will send", ->

			beforeEach -> 
				synchronizer.externalClients = { "client-2": new Date(2013, 4, 2).getTime(), "client-3": new Date(2013, 4, 8).getTime() }
				organizer.local.addCommands [ command1, command4 ]
				organizer.external.addCommands [ command2, command6, command8 ]
				spyOn(window, "reqwest")

			it "an app name", ->
				synchronizer.reconcile()
				expect(window.reqwest.mostRecentCall.args[0].data.appName).toEqual client.appName

			it "an app type", ->
				synchronizer.reconcile()
				expect(window.reqwest.mostRecentCall.args[0].data.appType).toEqual client.appType

			it "a client id", ->
				synchronizer.reconcile()
				expect(window.reqwest.mostRecentCall.args[0].data.clientId).toEqual client.id

			it "a list of external clients", ->
				synchronizer.reconcile()
				expect(window.reqwest.mostRecentCall.args[0].data.externalClients).toEqual synchronizer.externalClients

			it "a list of all commands", ->
				synchronizer.reconcile()
				commandList = window.reqwest.mostRecentCall.args[0].data.commandList
				expect(commandList['client-1']["11"]).toEqual command1.toHash()
				expect(commandList['client-1']["14"]).toEqual command4.toHash()
				expect(commandList['client-2']["22"]).toEqual command2.toHash()
				expect(commandList['client-3']["36"]).toEqual command6.toHash()
				expect(commandList['client-3']["38"]).toEqual command8.toHash()

			it "the latest stable timestamp", ->
				synchronizer.stableTimestamp = 10
				synchronizer.reconcile()
				expect(window.reqwest.mostRecentCall.args[0].data.stableTimestamp).toEqual synchronizer.stableTimestamp

		describe "when successful", ->

			beforeEach ->
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncReconcileResponse))

			it "stops calling reconcile", ->
				synchronizer.reconcile()
				jasmine.Clock.tick(5000)
				expect(synchronizer.reconcile.calls.length).toEqual 1

		describe "when unsuccessful", ->

			beforeEach ->
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.reconcileRequiredResponse))

			it "will continue to call reconcile", ->
				synchronizer.reconcile()
				jasmine.Clock.tick(5500)
				expect(synchronizer.reconcile.calls.length).toEqual 6