addMock "command1",
	name: "command1"
	data: { }
	timestamp: 1

addMock "command2",
	name: "command2"
	data: { }
	timestamp: 2

addMock "command3",
	name: "command3"
	data: { }
	timestamp: 3

addMock "command4",
	name: "command4"
	data: { }
	timestamp: 4

addMock "commandSource",
	id: "1234"
	originalState: { test: true }
	currentState: { test: true }

addMock "commandOrganizer",
	deactivatedCommands: [ mocks.command1 ]
	syncedCommands: [ mocks.command2 ]
	unsyncedCommands: [ mocks.command3, mocks.command4 ]
	addCommand: (command, unsynced=true)->
	addCommands: (commands, unsynced=true)->
	deactivateCommands: (commands)->
	markAsSynced: (commands)-> 
	activeCommands: -> [ mocks.command2, mocks.command3, mocks.command4 ]

