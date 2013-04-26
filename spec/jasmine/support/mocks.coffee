addMock "syncPushResponse",
	success: true
	message: 'commands received'
	data: { }

addMock "syncPullResponse",
	success: true
	message: 'commands retrieved'
	data:
		commands: [
			{ name: 'pop-char',  data: { }, timestamp: 2 },
			{ name: 'increment', data: { }, timestamp: 6 },
			{ name: 'increment', data: { }, timestamp: 8 }
		]
		currentSources: [
			{ id: "2345", lastUpdate: 2 },
			{ id: "3456", lastUpdate: 8 }
		]
		stableTimestamp: 2