Organizer = require 'leonidas/commands/organizer'

describe "Organizer", ->
	command1 = command2 = command3 = command4 = null
	organizer = null

	beforeEach ->
		command1 = buildCommand(1)
		command2 = buildCommand(2, "pop-char")
		command3 = buildCommand(3, "pop-char")
		command4 = buildCommand(4)
		organizer = new Organizer()

	describe "#addCommand", ->

		it "will add unsynced commands", ->
			organizer.addCommand command1
			expect(organizer.unsyncedCommands).toEqual [ command1 ]

		it "will add synced commands", ->
			organizer.addCommand command1, false
			expect(organizer.syncedCommands).toEqual [ command1 ]

	describe "#addCommands", ->

		it "will add multiple unsynced commands", ->
			organizer.addCommands [ command1, command2 ]
			expect(organizer.unsyncedCommands).toEqual [ command1, command2 ]

		it "will add multiple synced commands", ->
			organizer.addCommands [ command1, command2 ], false
			expect(organizer.syncedCommands).toEqual [ command1, command2 ]

	describe "#markAsSynced", ->

		it "will add the requested commands to the syncedCommands list", ->
			organizer.addCommands [ command1, command2, command3 ]
			organizer.markAsSynced [ command1, command2 ]
			expect(organizer.syncedCommands).toEqual [ command1, command2 ]

		it "will remove the requested commands from the unsyncedCommands list", ->
			organizer.addCommands [ command1, command2, command3 ]
			organizer.markAsSynced [ command1, command2 ]
			expect(organizer.unsyncedCommands).toEqual [ command3 ]

	describe "#lockCommands", ->

		it "will add the requested commands to the lockedCommands list", ->
			organizer.addCommands [ command1, command2, command3 ]
			organizer.lockCommands [ command1, command2 ]
			expect(organizer.lockedCommands).toEqual [ command1, command2 ]

		it "will remove requested commands from the syncedCommands list", ->
			organizer.addCommands [ command1, command2, command3 ], false
			organizer.lockCommands [ command1, command2 ]
			expect(organizer.syncedCommands).toEqual [ command3 ]

	describe "#activeCommands", ->

		it "will return a concatenated list of synced and unsynced commands", ->
			organizer.addCommands [ command2, command4 ]
			organizer.addCommands [ command1, command3 ], false
			expect(organizer.activeCommands().length).toEqual 4
			expect(command in organizer.activeCommands()).toBeTruthy() for command in organizer.unsyncedCommands
			expect(command in organizer.activeCommands()).toBeTruthy() for command in organizer.syncedCommands

		it "will sort the list of commands by timestamp", ->
			organizer.addCommands [ command2, command4 ]
			organizer.addCommands [ command1, command3 ], false
			expect(organizer.activeCommands()).toEqual [ command1, command2, command3, command4 ]