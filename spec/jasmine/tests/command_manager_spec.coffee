Organizer = require "leonidas/commands/organizer"
Processor = require "leonidas/commands/processor"
Stabilizer = require "leonidas/commands/stabilizer"
Synchronizer = require "leonidas/commands/synchronizer"
Commander = require 'leonidas/commander'

describe "Commander", ->
	manager = null
	client = null
	organizer = null
	synchronizer = null

	beforeEach ->
		client = buildClient()
		organizer = new Organizer()
		processor = new Processor([ new PopCharHandler(client.activeState) ])
		stabilizer = new Stabilizer(client, organizer, processor)
		synchronizer = new Synchronizer("http://mydomain.com/sync", client, organizer, stabilizer)
		spyOn(synchronizer, "push")
		spyOn(synchronizer, "pull")
		manager = new Commander(organizer, processor, stabilizer, synchronizer)

	describe "::default", ->

		it "will return a default command manager using the built in classes", ->
			manager = Commander.default(client, [ new PopCharHandler("tim") ], "http://mydomain.com/sync")
			expect(manager.constructor.name).toEqual "Commander"

	describe "#startSync", ->

		beforeEach -> 
      jasmine.Clock.useMock()

		it "will set the synchronizer to begin pushing updates", ->
     	manager.startSync()
     	jasmine.Clock.tick(5500)
     	expect(synchronizer.push.calls.length).toEqual 5

		it "will set the synchronizer to begin pulling updates", ->
     	manager.startSync()
     	jasmine.Clock.tick(11000)
     	expect(synchronizer.pull.calls.length).toEqual 2

	describe "#stopSync", ->

		beforeEach -> 
      jasmine.Clock.useMock()

		it "will stop the synchronizer from pushing updates", ->
			manager.startSync()
			manager.stopSync()
			jasmine.Clock.tick(10000)
			expect(synchronizer.push).not.toHaveBeenCalled()

		it "will stop the synchronizer from pulling updates", ->
			manager.startSync()
			manager.stopSync()
			jasmine.Clock.tick(10000)
			expect(synchronizer.pull).not.toHaveBeenCalled()

	describe "#issueCommand", ->

		it "will generate an unsynchronized command", ->
			manager.issueCommand "pop-char", {}
			expect(organizer.unsyncedCommands.length).toEqual 1

		it "will run the command to update the local client state", ->
			manager.issueCommand "pop-char", {}
			expect(client.activeState.string).toEqual "tes"