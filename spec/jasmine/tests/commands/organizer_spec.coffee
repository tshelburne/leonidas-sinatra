Organizer = require 'leonidas/commands/organizer'

describe "Organizer", ->
	command1 = command2 = command3 = command4 = null
	organizer = null

	beforeEach ->
		command1 = buildCommand(new Date(4, 1, 2013), { number: 1 })
		command2 = buildCommand(new Date(4, 2, 2013), { number: 2 }, "multiply")
		command3 = buildCommand(new Date(4, 3, 2013), { number: 3 }, "multiply")
		command4 = buildCommand(new Date(4, 4, 2013), { number: 4 })
		organizer = new Organizer()

	describe "#addCommand", ->

		describe "when adding a local command", ->

			it "will add the command to the list of local commands", ->
				organizer.addCommand command1
				expect(organizer.localCommands).toEqual [ command1 ]

			it "will set the command id to the current length of the local command list", ->
				organizer.addCommand command1
				expect(command1.id).toEqual 0

		it "will add external commands", ->
			organizer.addCommand command1, false
			expect(organizer.externalCommands).toEqual [ command1 ]

	describe "#addCommands", ->

		describe "when adding local commands", ->

			it "will add multiple local commands", ->
				organizer.addCommands [ command1, command2 ]
				expect(organizer.localCommands).toEqual [ command1, command2 ]

			it "will set each command id to the increasing length of the local command list", ->
				organizer.addCommands [ command1, command2 ]
				expect(command1.id).toEqual 0
				expect(command2.id).toEqual 1

		it "will add multiple external commands", ->
			organizer.addCommands [ command1, command2 ], false
			expect(organizer.externalCommands).toEqual [ command1, command2 ]

	describe "#commandsUntil", ->

		beforeEach ->
			organizer.addCommands [ command2, command4 ]
			organizer.addCommands [ command1, command3 ], false

		it "will return a list of the commands before the given timestamp", ->
			expect(organizer.commandsUntil new Date(4, 3, 2013), false).toContain command for command in [ command1, command2 ]

		it "will include any commands that happened at exactly the given timestamp", ->
			expect(organizer.commandsUntil new Date(4, 3, 2013), false).toContain command3

		it "will not return any commands after the given timestamp", ->
			expect(organizer.commandsUntil new Date(4, 3, 2013), false).not.toContain command4

		it "will return a sorted list", ->
			expect(organizer.commandsUntil new Date(4, 3, 2013), false).toEqual [ command1, command2, command3 ]

		describe "when only local commands are requested", ->

			it "will not return any external commands", ->
				expect(organizer.commandsUntil new Date(4, 3, 2013)).not.toContain command for command in [ command1, command3 ]

	describe "#commandsAfter", ->

		beforeEach ->
			organizer.addCommands [ command2, command4 ]
			organizer.addCommands [ command1, command3 ], false

		it "will return a list of the commands after the given timestamp", ->
			expect(organizer.commandsAfter new Date(4, 2, 2013), false).toContain command for command in [ command3, command4 ]

		it "will exclude any commands that happened at exactly the given timestamp", ->
			expect(organizer.commandsAfter new Date(4, 2, 2013), false).not.toContain command2

		it "will not return any commands after the given timestamp", ->
			expect(organizer.commandsAfter new Date(4, 2, 2013), false).not.toContain command1

		it "will return a sorted list", ->
			expect(organizer.commandsAfter new Date(4, 2, 2013), false).toEqual [ command3, command4 ]

		describe "when only local commands are requested", ->

			it "will not return any external commands", ->
				expect(organizer.commandsUntil new Date(4, 2, 2013)).not.toContain command for command in [ command1, command3 ]

	describe "#allCommands", ->

		beforeEach ->
			organizer.addCommands [ command2, command4 ]
			organizer.addCommands [ command1, command3 ], false

		it "will return a concatenated list of external and local commands", ->
			expect(organizer.allCommands().length).toEqual 4
			expect(command in organizer.allCommands()).toBeTruthy() for command in organizer.localCommands
			expect(command in organizer.allCommands()).toBeTruthy() for command in organizer.externalCommands

		it "will sort the list of commands by timestamp", ->
			expect(organizer.allCommands()).toEqual [ command1, command2, command3, command4 ]