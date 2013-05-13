class CommandList

	constructor: ->
		@commands = [ ]

	addCommand: (command)-> @commands.push command
		
	addCommands: (commands)-> @addCommand(command) for command in commands

	commandsThrough: (timestamp)-> (command for command in @commands when command.timestamp <= timestamp)

	commandsSince: (timestamp)-> (command for command in @commands when command.timestamp > timestamp)

return CommandList