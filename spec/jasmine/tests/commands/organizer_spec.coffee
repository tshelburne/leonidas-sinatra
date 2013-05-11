Organizer = require 'leonidas/commands/organizer'

describe "Organizer", ->
	command1 = command2 = command3 = command4 = null
	organizer = null

	beforeEach ->
		command1 = buildCommand(new Date(2013, 4, 1), { number: 1 })
		command2 = buildCommand(new Date(2013, 4, 2), { number: 2 }, "multiply")
		command3 = buildCommand(new Date(2013, 4, 3), { number: 3 }, "multiply")
		command4 = buildCommand(new Date(2013, 4, 4), { number: 4 })
		organizer = new Organizer()
		organizer.local.addCommands [ command2, command4 ]
		organizer.external.addCommands [ command1, command3 ]

	describe "#commandsUntil", ->

		it "will return a list of the commands before the given timestamp", ->
			expect(organizer.commandsUntil new Date(2013, 4, 3)).toContain command for command in [ command1, command2 ]

		it "will include any commands that happened at exactly the given timestamp", ->
			expect(organizer.commandsUntil new Date(2013, 4, 3)).toContain command3

		it "will not return any commands after the given timestamp", ->
			expect(organizer.commandsUntil new Date(2013, 4, 3)).not.toContain command4

		it "will return a sorted list", ->
			expect(organizer.commandsUntil new Date(2013, 4, 3)).toEqual [ command1, command2, command3 ]

	describe "#commandsAfter", ->

		it "will return a list of the commands after the given timestamp", ->
			expect(organizer.commandsAfter new Date(2013, 4, 2)).toContain command for command in [ command3, command4 ]

		it "will exclude any commands that happened at exactly the given timestamp", ->
			expect(organizer.commandsAfter new Date(2013, 4, 2)).not.toContain command2

		it "will not return any commands after the given timestamp", ->
			expect(organizer.commandsAfter new Date(2013, 4, 2)).not.toContain command1

		it "will return a sorted list", ->
			expect(organizer.commandsAfter new Date(2013, 4, 2)).toEqual [ command3, command4 ]

	describe "#allCommands", ->

		it "will return a concatenated list of external and local commands", ->
			expect(organizer.allCommands().length).toEqual 4
			expect(organizer.allCommands()).toContain command for command in organizer.local.commands
			expect(organizer.allCommands()).toContain command for command in organizer.external.commands

		it "will sort the list of commands by timestamp", ->
			expect(organizer.allCommands()).toEqual [ command1, command2, command3, command4 ]