Client = require "leonidas/client"

describe "Client", ->
	
	describe "when constructing a new Client instance", ->

		it "will reject a null client id", ->
			expect(-> new Client()).toThrow()

		it "will reject a null app name", ->
			expect(-> new Client("client-id")).toThrow()