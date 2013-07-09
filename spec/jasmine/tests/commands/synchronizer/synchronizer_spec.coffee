Synchronizer = require 'leonidas/commands/synchronizer'
Organizer = require 'leonidas/commands/organizer'
Processor = require 'leonidas/commands/processor'
Client = require 'leonidas/client'

describe "Synchronizer", ->
	organizer = synchronizer = null

	beforeEach ->
		state = { value: 1 }
		organizer = new Organizer()
		client = new Client("1234", "app1", "TestClasses::TestApp")
		synchronizer = new Synchronizer("http://my.test.url", client, organizer, new Processor([ new IncrementHandler(state), new MultiplyHandler(state)]))

	describe "#isOnline", ->

		it "will return true by default", ->
			expect(synchronizer.isOnline()).toBeTruthy()

		it "will return false when @pull() produces a sync error", ->
			spyOn(window, "reqwest").andCallFake( (params)-> params.error())
			synchronizer.pull()
			expect(synchronizer.isOnline()).toBeFalsy()

		it "will return false when @push() produces a sync error", ->
			organizer.local.addCommand buildCommand(new Date())
			spyOn(window, "reqwest").andCallFake( (params)-> params.error())
			synchronizer.push()
			expect(synchronizer.isOnline()).toBeFalsy()

		it "will return false when @reconcile() produces a sync error", ->
			spyOn(window, "reqwest").andCallFake( (params)-> params.error())
			synchronizer.reconcile()
			expect(synchronizer.isOnline()).toBeFalsy()

		describe "after having been false", ->

			it "will return true when @pull() successfully connects to the server", ->
				synchronizer.connectionSuccessful = false # not crazy about this, but you can't redefine faked spies
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncPullResponse))
				synchronizer.pull()
				expect(synchronizer.isOnline()).toBeTruthy()

			it "will return true when @push() successfully connects to the server", ->
				organizer.local.addCommand buildCommand(new Date())
				synchronizer.connectionSuccessful = false # not crazy about this, but you can't redefine faked spies
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncPushResponse))
				synchronizer.push()
				expect(synchronizer.isOnline()).toBeTruthy()

			it "will return true when @reconcile() successfully connects to the server", ->
				synchronizer.connectionSuccessful = false # not crazy about this, but you can't redefine faked spies
				spyOn(window, "reqwest").andCallFake( (params)-> params.success(mocks.syncReconcileResponse))
				synchronizer.reconcile()
				expect(synchronizer.isOnline()).toBeTruthy()