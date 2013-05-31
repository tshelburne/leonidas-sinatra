class CommandList

	constructor: ->
		@commands = [ ]

	addCommand: (command)-> 
		command.id = generateUniqueId(@commands) unless command.id?
		@commands.push command
		
	addCommands: (commands)-> @addCommand(command) for command in commands

	commandsThrough: (timestamp)-> (command for command in @commands when command.timestamp <= timestamp)

	commandsSince: (timestamp)-> (command for command in @commands when command.timestamp > timestamp)

	# private

	generateUniqueId = (commands)-> 
		candidate = "#{new Date().getTime()}-#{commands.length}"
		until candidate not in (command.id for command in commands)
			candidate = "#{new Date().getTime()}-#{commands.length}"
		candidate

return CommandList