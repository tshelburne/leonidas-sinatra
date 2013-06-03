Command = require 'leonidas/commands/command'
Client = require 'leonidas/client'

buildCommand = (timestamp, data={}, name="increment", clientId="client-1", commandId=null)->
	new Command(name, data, clientId, timestamp, commandId)

buildClient = ->
	new Client("client-1", "app-1", 'TestClasses::TestApp', null)

globalize(buildCommand, "buildCommand")
globalize(buildClient, "buildClient")