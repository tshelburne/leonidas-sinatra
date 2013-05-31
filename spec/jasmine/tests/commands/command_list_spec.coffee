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

		it "will generate and add a unique id to the command if the command id is null or undefined", ->
			commandList.addCommand command1
			commandList.addCommand command2
			commandList.addCommand command3
			commandList.addCommand command4
			expect(command1.id).toBeDefined()
			expect(command2.id).toBeDefined()
			expect(command3.id).toBeDefined()
			expect(command4.id).toBeDefined()
			expect(command1.id).not.toBeNull()
			expect(command2.id).not.toBeNull()
			expect(command3.id).not.toBeNull()
			expect(command4.id).not.toBeNull()
			expect([ command1.id, command2.id, command3.id ]).not.toContain command4.id
			expect([ command1.id, command2.id ]).not.toContain command3.id 
			expect(command1.id).not.toEqual command2.id

	describe "#addCommands", ->

		it "will add multiple local commands", ->
			commandList.addCommands [ command1, command2 ]
			expect(commandList.commands).toContain command for command in [ command1, command2 ]

		it "will generate and add a unique id to each command if the command id is null or undefined", ->
			commandList.addCommands [ command1, command2 ]
			expect(command1.id).toBeDefined()
			expect(command2.id).toBeDefined()
			expect(command1.id).not.toBeNull()
			expect(command2.id).not.toBeNull()

	describe "#commandsThrough", ->

		beforeEach ->
			commandList.addCommands [ command1, command2, command3, command4 ]

		it "will return a list of the commands before the given timestamp", ->
			expect(commandList.commandsThrough new Date(2013, 4, 3)).toContain command for command in [ command1, command2 ]

		it "will include any commands that happened at exactly the given timestamp", ->
			expect(commandList.commandsThrough new Date(2013, 4, 3)).toContain command3

		it "will not return any commands after the given timestamp", ->
			expect(commandList.commandsThrough new Date(2013, 4, 3)).not.toContain command4

	describe "#commandsSince", ->

		beforeEach ->
			commandList.addCommands [ command1, command2, command3, command4 ]

		it "will return a list of the commands after the given timestamp", ->
			expect(commandList.commandsSince new Date(2013, 4, 2)).toContain command for command in [ command3, command4 ]

		it "will exclude any commands that happened at exactly the given timestamp", ->
			expect(commandList.commandsSince new Date(2013, 4, 2)).not.toContain command2

		it "will not return any commands after the given timestamp", ->
			expect(commandList.commandsSince new Date(2013, 4, 2)).not.toContain command1