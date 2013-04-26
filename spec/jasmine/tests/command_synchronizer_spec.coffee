CommandOrganizer = require 'leonidas/command_organizer'
CommandProcessor = require 'leonidas/command_processor'
CommandStabilizer = require 'leonidas/command_stabilizer'
CommandSynchronizer = require 'leonidas/command_synchronizer'

describe "CommandSynchronizer", ->
	command1 = command4 = command5 = command7 = null
	source = null
	organizer = null
	synchronizer = null

	beforeEach ->
		source = buildSource()
		organizer = new CommandOrganizer()
		command1 = buildCommand(1)
		command4 = buildCommand(4, "pop-char")
		command5 = buildCommand(5, "pop-char")
		command7 = buildCommand(7)
		processor = new CommandProcessor([ new IncrementHandler(source.activeState), new PopCharHandler(source.activeState)])
		stabilizer = new CommandStabilizer(source, organizer, processor)
		synchronizer = new CommandSynchronizer("http://mydomain.com/sync", source, organizer, stabilizer)

	describe "#push", ->

		beforeEach ->
			organizer.addCommands [ command1, command4 ]

		describe "when successful", ->

			it "will mark the commands pushed as synced", ->
				spyOn($,"ajax").andCallFake( (params)-> params.success(mocks.syncPushResponse))
				synchronizer.push()
				expect(organizer.syncedCommands).toEqual [ command1, command4 ]
				expect(organizer.unsyncedCommands).toEqual [ ]

			it "will not mark unsynced commands added since push was called as synced", ->
				spyOn($,"ajax").andCallFake( (params)-> 
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
				spyOn($,"ajax").andCallFake( (params)-> params.success(mocks.syncPullResponse))

			it "will update the list of external sources and their latest timestamps", ->
				synchronizer.pull()
				expect(synchronizer.externalSources).toEqual [ { id: "2345", lastUpdate: 2 }, { id: "3456", lastUpdate: 8 } ]

			it "will add the list of received commands as synced commands", ->
				synchronizer.pull()
				expect(organizer.syncedCommands.length).toEqual 3
				expect(organizer.syncedCommands[0].toHash()).toEqual { name: 'pop-char',  data: { }, timestamp: 4 },
				expect(organizer.syncedCommands[1].toHash()).toEqual { name: 'increment', data: { }, timestamp: 6 },
				expect(organizer.syncedCommands[2].toHash()).toEqual { name: 'increment', data: { }, timestamp: 8 }

			it "will lock to a new stable state", ->
				synchronizer.pull()
				expect(source.lockedState).toEqual { integer: 2, string: "tes" }

			it "will deactivate stable commands", ->
				synchronizer.pull()
				expect(organizer.inactiveCommands.length).toEqual 2
				expect(organizer.inactiveCommands[0].toHash()).toEqual { name: 'increment',  data: { }, timestamp: 1 },
				expect(organizer.inactiveCommands[1].toHash()).toEqual { name: 'pop-char', data: { }, timestamp: 2 },