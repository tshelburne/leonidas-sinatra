Command = require 'leonidas/command'
CommandSource = require 'leonidas/command_source'

buildSource = ->
	new CommandSource("1234", { integer: 1, string: "test" })

buildCommand = (timestamp, name="increment", data={})->
	new Command(name, data, timestamp)

globalize(buildCommand, "buildCommand")
globalize(buildSource, "buildSource")