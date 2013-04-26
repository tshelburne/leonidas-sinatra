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
			{ name: 'increment', data: { }, timestamp: 1 },
			{ name: 'increment', data: { }, timestamp: 3 }
		]
		stableTimestamp: 2
