Client = require 'leonidas/client'
Organizer = require 'leonidas/commands/organizer'
Processor = require 'leonidas/commands/processor'
Stabilizer = require 'leonidas/commands/stabilizer'

describe "Stabilizer", ->
	stabilizer = null
	client = null
	organizer = null

	beforeEach ->
		client = buildClient()
		organizer = new Organizer()
		organizer.addCommands [ buildCommand(1), buildCommand(2, "pop-char"), buildCommand(3, "pop-char"), buildCommand(4) ], false
		processor = new Processor([ new IncrementHandler(client.activeState), new PopCharHandler(client.activeState)])
		stabilizer = new Stabilizer(client, organizer, processor)

	describe "#stabilize", ->

		it "will update the locked state to the state at the given timestamp", ->
			stabilizer.stabilize 2
			expect(client.lockedState).toEqual { integer: 2, string: "tes" }

		it "will deactivate the stable commands in the command organizer", ->
			stabilizer.stabilize 2
			expect(organizer.activeCommands()).toEqual [ buildCommand(3, "pop-char"), buildCommand(4) ]

		it "will process the remaining active commands to leave the active state entirely current", ->
			stabilizer.stabilize 2
			expect(client.activeState).toEqual { integer: 3, string: "te" }