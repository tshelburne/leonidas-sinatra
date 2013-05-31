Organizer = require 'leonidas/commands/organizer'
Processor = require 'leonidas/commands/processor'
Synchronizer = require 'leonidas/commands/synchronizer'

describe "Synchronizer", ->
	command1 = command2 = command4 = command5 = command6 = command7 = command8 = null
	client = null
	organizer = null
	synchronizer = null
	processor = null

	beforeEach ->
		client = buildClient()
		organizer = new Organizer()
		command1 = buildCommand(new Date(2013, 4, 1), { number: 1 }, "increment", "client-1", "11")
		command2 = buildCommand(new Date(2013, 4, 2), { number: 2 }, "multiply",  "client-2", "22")
		command4 = buildCommand(new Date(2013, 4, 4), { number: 2 }, "multiply",  "client-1", "14")
		command5 = buildCommand(new Date(2013, 4, 5), { number: 3 }, "multiply",  "client-1", "15")
		command6 = buildCommand(new Date(2013, 4, 6), { number: 1 }, "increment", "client-3", "36")
		command7 = buildCommand(new Date(2013, 4, 7), { number: 4 }, "increment", "client-1", "17")
		command8 = buildCommand(new Date(2013, 4, 8), { number: 3 }, "increment", "client-3", "38")
		processor = new Processor([ new IncrementHandler(client.state), new MultiplyHandler(client.state)])
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
				expect(client.state.integer).toEqual 32

		describe "when unsuccessful", ->

			beforeEach ->
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.reconcileRequiredResponse))
				spyOn(synchronizer, "reconcile")
				jasmine.Clock.useMock()

			it "will begin reconciling if reconciliation is required", ->
				synchronizer.pull()
				jasmine.Clock.tick(2000)
				expect(synchronizer.reconcile).toHaveBeenCalled()



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
				jasmine.log commandList
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