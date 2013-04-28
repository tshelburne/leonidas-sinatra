Client = require 'leonidas/client'

describe "Client", ->
	client = null

	beforeEach ->
		client = new Client("app 1", { test: "test" })
		client.activeState = { test: "different" }

	describe "#revertState", ->

		it "will revert the active state to the locked state", ->
			client.revertState()
			expect(client.activeState).toEqual { test: "test" }

	describe "#lockState", ->

		it "will lock the state to the active state", ->
			client.lockState()
			expect(client.lockedState).toEqual { test: "different" }