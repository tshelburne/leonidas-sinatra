Command = require 'leonidas/commands/command'
Client = require 'leonidas/client'

buildCommand = (timestamp, data={}, name="increment", clientId="id")->
	new Command(name, data, clientId, timestamp)

buildClient = ->
	new Client("app-1", { integer: 1 })

globalize(buildCommand, "buildCommand")
globalize(buildClient, "buildClient")