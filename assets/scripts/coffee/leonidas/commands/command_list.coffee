class CommandList

	constructor: ->
		@commands = [ ]

	addCommand: (command)-> 
		if command.id is null
			command.id = generateUniqueId(@commands)
		@commands.push command
		
	addCommands: (commands)-> @addCommand(command) for command in commands

	commandsThrough: (timestamp)-> (command for command in @commands when command.timestamp <= timestamp)

	commandsSince: (timestamp)-> (command for command in @commands when command.timestamp > timestamp)

	# private

	generateUniqueId = (commands)-> 
		candidate
		until candidate not in (command.id for command in commands)
			candidate = "#{new Date().getTime()}-#{commands.length}"
		candidate

return CommandList