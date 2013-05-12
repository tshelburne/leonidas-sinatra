Command = require 'leonidas/commands/command'
Client = require 'leonidas/client'

buildCommand = (timestamp, data={}, name="increment", clientId="client-1")->
	new Command(name, data, clientId, timestamp)

buildClient = ->
	new Client("client-1", "app-1", { integer: 1 })

globalize(buildCommand, "buildCommand")
globalize(buildClient, "buildClient")