Organizer = require "leonidas/commands/organizer"
Processor = require "leonidas/commands/processor"
Synchronizer = require "leonidas/commands/synchronizer"
Commander = require 'leonidas/commander'

describe "Commander", ->
	state = null
	commander = null
	client = null
	organizer = null
	synchronizer = null

	beforeEach ->
		state = { value: 1 }
		client = buildClient()
		organizer = new Organizer()
		processor = new Processor([ new MultiplyHandler(state) ])
		synchronizer = new Synchronizer("http://mydomain.com/sync", client, organizer, processor)
		spyOn(synchronizer, "push")
		spyOn(synchronizer, "pull")
		commander = new Commander(client, organizer, processor, synchronizer)

	describe "::create", ->

		it "will create a Commander instance using the included classes", ->
			commander = Commander.create(client, [ new MultiplyHandler(state) ], "http://mydomain.com/sync")
			expect(commander.constructor).toEqual Commander

	describe "#startSync", ->

		beforeEach -> 
      jasmine.Clock.useMock()

		it "will set the synchronizer to begin pushing updates", ->
     	commander.startSync()
     	jasmine.Clock.tick(5500)
     	expect(synchronizer.push.calls.length).toEqual 5

		it "will set the synchronizer to begin pulling updates", ->
     	commander.startSync()
     	jasmine.Clock.tick(11000)
     	expect(synchronizer.pull.calls.length).toEqual 2

	describe "#stopSync", ->

		beforeEach -> 
      jasmine.Clock.useMock()

		it "will stop the synchronizer from pushing updates", ->
			commander.startSync()
			commander.stopSync()
			jasmine.Clock.tick(10000)
			expect(synchronizer.push).not.toHaveBeenCalled()

		it "will stop the synchronizer from pulling updates", ->
			commander.startSync()
			commander.stopSync()
			jasmine.Clock.tick(10000)
			expect(synchronizer.pull).not.toHaveBeenCalled()

	describe "#forceSync", ->

		it "will immediately push any updates", ->
			commander.forceSync()
			expect(synchronizer.push).toHaveBeenCalled()

		it "will immediately pull any updates", ->
			commander.forceSync()
			expect(synchronizer.pull).toHaveBeenCalled()

	describe "#issueCommand", ->

		it "will generate a local command", ->
			commander.issueCommand "multiply", { number: 3 }
			expect(organizer.local.commands.length).toEqual 1

		it "will run the command to update the local client state", ->
			commander.issueCommand "multiply", { number: 3 }
			expect(state.value).toEqual 3