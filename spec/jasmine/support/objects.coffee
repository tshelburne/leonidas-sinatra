Command = require 'leonidas/commands/command'
Client = require 'leonidas/client'

buildCommand = (timestamp, name="increment", data={}, clientId="id")->
	new Command(name, data, clientId, timestamp)

buildClient = ->
	new Client("app 1", { integer: 1, string: "test" })

globalize(buildCommand, "buildCommand")
globalize(buildClient, "buildClient")