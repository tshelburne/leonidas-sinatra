addMock "command1",
	name: "increment"
	data: { }
	timestamp: 1

addMock "command2",
	name: "pop-char"
	data: { }
	timestamp: 2

addMock "command3",
	name: "pop-char"
	data: { }
	timestamp: 3

addMock "command4",
	name: "increment"
	data: { }
	timestamp: 4

addMock "commandOrganizer",
	deactivatedCommands: [ mocks.command1 ]
	syncedCommands: [ mocks.command2 ]
	unsyncedCommands: [ mocks.command3, mocks.command4 ]
	addCommand: (command, unsynced=true)->
	addCommands: (commands, unsynced=true)->
	deactivateCommands: (commands)->
	markAsSynced: (commands)-> 
	activeCommands: -> [ mocks.command2, mocks.command3, mocks.command4 ]

