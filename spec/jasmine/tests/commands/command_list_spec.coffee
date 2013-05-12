CommandList = require 'leonidas/commands/command_list'

describe "CommandList", ->
	command1 = command2 = command3 = command4 = null
	commandList = null

	beforeEach ->
		command1 = buildCommand(new Date(2013, 4, 1), { number: 1 })
		command2 = buildCommand(new Date(2013, 4, 2), { number: 2 }, "multiply")
		command3 = buildCommand(new Date(2013, 4, 3), { number: 3 }, "multiply")
		command4 = buildCommand(new Date(2013, 4, 4), { number: 4 })
		commandList = new CommandList()

	describe "#addCommand", ->

		it "will add the command to the list of commands", ->
			commandList.addCommand command1
			expect(commandList.commands).toEqual [ command1 ]

		it "will sort the list of commands", ->
			commandList.addCommand command2
			commandList.addCommand command1
			expect(commandList.commands).toEqual [ command1, command2 ]

	describe "#addCommands", ->

		it "will add multiple local commands", ->
			commandList.addCommands [ command1, command2 ]
			expect(commandList.commands).toEqual [ command1, command2 ]

		it "will sort the list of commands", ->
			commandList.addCommands [ command2, command4, command3, command1 ]
			expect(commandList.commands).toEqual [ command1, command2, command3, command4 ]

	describe "#commandsThrough", ->

		beforeEach ->
			commandList.addCommands [ command1, command2, command3, command4 ]

		it "will return a list of the commands before the given timestamp", ->
			expect(commandList.commandsThrough new Date(2013, 4, 3)).toContain command for command in [ command1, command2 ]

		it "will include any commands that happened at exactly the given timestamp", ->
			expect(commandList.commandsThrough new Date(2013, 4, 3)).toContain command3

		it "will not return any commands after the given timestamp", ->
			expect(commandList.commandsThrough new Date(2013, 4, 3)).not.toContain command4

		it "will return a sorted list", ->
			expect(commandList.commandsThrough new Date(2013, 4, 3)).toEqual [ command1, command2, command3 ]

	describe "#commandsSince", ->

		beforeEach ->
			commandList.addCommands [ command1, command2, command3, command4 ]

		it "will return a list of the commands after the given timestamp", ->
			expect(commandList.commandsSince new Date(2013, 4, 2)).toContain command for command in [ command3, command4 ]

		it "will exclude any commands that happened at exactly the given timestamp", ->
			expect(commandList.commandsSince new Date(2013, 4, 2)).not.toContain command2

		it "will not return any commands after the given timestamp", ->
			expect(commandList.commandsSince new Date(2013, 4, 2)).not.toContain command1

		it "will return a sorted list", ->
			expect(commandList.commandsSince new Date(2013, 4, 2)).toEqual [ command3, command4 ]