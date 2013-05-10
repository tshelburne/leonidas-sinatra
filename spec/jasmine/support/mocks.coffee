addMock "syncPushResponse",
	success: true
	message: 'commands received'
	data: { }

addMock "syncPullResponse",
	success: true
	message: 'commands retrieved'
	data:
		commands: [
			{ name: 'pop-char',  data: { }, connection: "2345", timestamp: new Date(4, 2, 2013).getTime() },
			{ name: 'increment', data: { }, connection: "3456", timestamp: new Date(4, 6, 2013).getTime() },
			{ name: 'increment', data: { }, connection: "3456", timestamp: new Date(4, 8, 2013).getTime() }
		]
		currentClients: [
			{ id: "2345", lastUpdate: new Date(4, 2, 2013).getTime() },
			{ id: "3456", lastUpdate: new Date(4, 8, 2013).getTime() }
		]
		stableTimestamp: new Date(4, 2, 2013).getTime()