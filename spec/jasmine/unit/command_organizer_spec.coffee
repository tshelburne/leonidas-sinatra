CommandOrganizer = require 'leonidas/command_organizer'

describe "CommandOrganizer", ->
	organizer = null

	beforeEach ->
		organizer = new CommandOrganizer()

	describe "#addCommand", ->

		it "will add unsynced commands", ->
			organizer.addCommand mocks.command1
			expect(organizer.unsyncedCommands).toEqual [ mocks.command1 ]

		it "will add synced commands", ->
			organizer.addCommand mocks.command1, false
			expect(organizer.syncedCommands).toEqual [ mocks.command1 ]

	describe "#addCommands", ->

		it "will add multiple unsynced commands", ->
			organizer.addCommands [ mocks.command1, mocks.command2 ]
			expect(organizer.unsyncedCommands).toEqual [ mocks.command1, mocks.command2 ]

		it "will add multiple synced commands", ->
			organizer.addCommands [ mocks.command1, mocks.command2 ], false
			expect(organizer.syncedCommands).toEqual [ mocks.command1, mocks.command2 ]

	describe "#markAsSynced", ->

		it "will add the requested commands to the syncedCommands list", ->
			organizer.addCommands [ mocks.command1, mocks.command2, mocks.command3 ]
			organizer.markAsSynced [ mocks.command1, mocks.command2 ]
			expect(organizer.syncedCommands).toEqual [ mocks.command1, mocks.command2 ]

		it "will remove the requested commands from the unsyncedCommands list", ->
			organizer.addCommands [ mocks.command1, mocks.command2, mocks.command3 ]
			organizer.markAsSynced [ mocks.command1, mocks.command2 ]
			expect(organizer.unsyncedCommands).toEqual [ mocks.command3 ]

	describe "#deactivateCommands", ->

		it "will add the requested commands to the deactivatedCommands list", ->
			organizer.addCommands [ mocks.command1, mocks.command2, mocks.command3 ]
			organizer.deactivateCommands [ mocks.command1, mocks.command2 ]
			expect(organizer.deactivatedCommands).toEqual [ mocks.command1, mocks.command2 ]

		it "will remove requested commands from the syncedCommands list", ->
			organizer.addCommands [ mocks.command1, mocks.command2, mocks.command3 ], false
			organizer.deactivateCommands [ mocks.command1, mocks.command2 ]
			expect(organizer.syncedCommands).toEqual [ mocks.command3 ]

	describe "#activeCommands", ->

		it "will return a concatenated list of synced and unsynced commands", ->
			organizer.addCommands [ mocks.command2, mocks.command4 ]
			organizer.addCommands [ mocks.command1, mocks.command3 ], false
			expect(organizer.activeCommands().length).toEqual 4
			expect(command in organizer.activeCommands()).toBeTruthy() for command in organizer.unsyncedCommands
			expect(command in organizer.activeCommands()).toBeTruthy() for command in organizer.syncedCommands

		it "will sort the list of commands by timestamp", ->
			organizer.addCommands [ mocks.command2, mocks.command4 ]
			organizer.addCommands [ mocks.command1, mocks.command3 ], false
			expect(organizer.activeCommands()).toEqual [ mocks.command1, mocks.command2, mocks.command3, mocks.command4 ]