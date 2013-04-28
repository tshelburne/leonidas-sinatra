Command = require 'leonidas/command'
Client = require 'leonidas/client'

buildCommand = (timestamp, name="increment", data={})->
	new Command(name, data, timestamp)

buildClient = ->
	new Client("app 1", { integer: 1, string: "test" })

globalize(buildCommand, "buildCommand")
globalize(buildClient, "buildClient")