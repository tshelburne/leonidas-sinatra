Organizer = require 'leonidas/commands/organizer'
Processor = require 'leonidas/commands/processor'
Stabilizer = require 'leonidas/commands/stabilizer'
Synchronizer = require 'leonidas/commands/synchronizer'

describe "Synchronizer", ->
	command1 = command4 = command5 = command7 = null
	client = null
	organizer = null
	synchronizer = null

	beforeEach ->
		client = buildClient()
		organizer = new Organizer()
		command1 = buildCommand(new Date(4, 1, 2013), { number: 1 })
		command4 = buildCommand(new Date(4, 4, 2013), { number: 2 }, "multiply")
		command5 = buildCommand(new Date(4, 5, 2013), { number: 3 }, "multiply")
		command7 = buildCommand(new Date(4, 7, 2013), { number: 4 })
		processor = new Processor([ new IncrementHandler(client.activeState), new MultiplyHandler(client.activeState)])
		stabilizer = new Stabilizer(client, organizer, processor)
		synchronizer = new Synchronizer("http://mydomain.com/sync", client, organizer, stabilizer)

	describe "#push", ->

		beforeEach ->
			organizer.addCommands [ command1, command4 ]

		describe "when successful", ->

			it "will mark the commands pushed as synced", ->
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncPushResponse))
				synchronizer.push()
				expect(organizer.syncedCommands).toEqual [ command1, command4 ]
				expect(organizer.unsyncedCommands).toEqual [ ]

			it "will not mark unsynced commands added since push was called as synced", ->
				spyOn(window, "reqwest").andCallFake( (params)-> 
					organizer.addCommands [ command5, command7 ]
					params.success(mocks.syncPushResponse)
				)
				synchronizer.push()
				expect(organizer.syncedCommands).toEqual [ command1, command4 ]
				expect(organizer.unsyncedCommands).toEqual [ command5, command7 ]

	describe "#pull", ->

		describe "when successful", ->

			beforeEach ->
				organizer.addCommands [ command1, command4 ], false
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncPullResponse))

			it "will update the list of external clients and their latest timestamps", ->
				synchronizer.pull()
				expect(synchronizer.externalClients).toEqual [ { id: "2345", lastUpdate: new Date(4, 2, 2013).getTime() }, { id: "3456", lastUpdate: new Date(4, 8, 2013).getTime() } ]

			it "will update the stable timestamp", ->
				synchronizer.pull()
				expect(synchronizer.stableTimestamp).toEqual new Date(4, 2, 2013).getTime()

			it "will add the list of received commands as synced commands", ->
				synchronizer.pull()
				expect(organizer.syncedCommands.length).toEqual 3
				expect(organizer.syncedCommands[0]).toEqual command4
				expect(organizer.syncedCommands[1].toHash()).toEqual { name: 'increment', data: { number: 1 }, clientId: "3456", timestamp: new Date(4, 6, 2013).getTime() }
				expect(organizer.syncedCommands[2].toHash()).toEqual { name: 'increment', data: { number: 3 }, clientId: "3456", timestamp: new Date(4, 8, 2013).getTime() }

			it "will lock to a new stable state", ->
				synchronizer.pull()
				expect(client.lockedState).toEqual { integer: 4 }

			it "will lock stable commands", ->
				synchronizer.pull()
				expect(organizer.lockedCommands.length).toEqual 2
				expect(organizer.lockedCommands[0]).toEqual command1
				expect(organizer.lockedCommands[1].toHash()).toEqual { name: 'multiply',  data: { number: 2 }, clientId: "2345", timestamp: new Date(4, 2, 2013).getTime() }