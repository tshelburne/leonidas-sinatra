Command = require 'leonidas/command'
CommandSource = require 'leonidas/command_source'

buildCommand = (timestamp, name="increment", data={})->
	new Command(name, data, timestamp)

buildSource = ->
	new CommandSource("app 1", { integer: 1, string: "test" })

globalize(buildCommand, "buildCommand")
globalize(buildSource, "buildSource")