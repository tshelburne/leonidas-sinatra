Client = require 'leonidas/client'
Organizer = require 'leonidas/commands/organizer'
Processor = require 'leonidas/commands/processor'
Stabilizer = require 'leonidas/commands/stabilizer'

describe "Stabilizer", ->
	command1 = command2 = command3 = command4 = null
	stabilizer = null
	client = null
	organizer = null

	beforeEach ->
		command1 = buildCommand(new Date(4, 1, 2013), { number: 1 })
		command2 = buildCommand(new Date(4, 2, 2013), { number: 2 }, "multiply")
		command3 = buildCommand(new Date(4, 3, 2013), { number: 3 }, "multiply")
		command4 = buildCommand(new Date(4, 4, 2013), { number: 4 })

		client = buildClient()
		organizer = new Organizer()
		organizer.addCommands [ command1, command2, command3, command4 ], false
		processor = new Processor([ new IncrementHandler(client.activeState), new MultiplyHandler(client.activeState)])
		stabilizer = new Stabilizer(client, organizer, processor)

	describe "#stabilize", ->

		it "will update the locked state to the state at the given timestamp", ->
			stabilizer.stabilize new Date(4, 2, 2013)
			expect(client.lockedState).toEqual { integer: 4 }

		it "will deactivate the stable commands in the command organizer", ->
			stabilizer.stabilize new Date(4, 2, 2013)
			expect(organizer.activeCommands()).toEqual [ command3, command4 ]

		it "will process the remaining active commands to leave the active state entirely current", ->
			stabilizer.stabilize new Date(4, 2, 2013)
			expect(client.activeState).toEqual { integer: 16 }