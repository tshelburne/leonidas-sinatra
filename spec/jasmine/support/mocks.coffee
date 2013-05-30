addMock "syncPullResponse",
	success: true
	message: 'commands retrieved'
	data:
		commands: [
			{ id: 'command2', name: 'multiply',  data: { number: 2 }, connection: "2345", timestamp: new Date(2013, 4, 2).getTime() },
			{ id: 'command6', name: 'increment', data: { number: 1 }, connection: "3456", timestamp: new Date(2013, 4, 6).getTime() },
			{ id: 'command8', name: 'increment', data: { number: 3 }, connection: "3456", timestamp: new Date(2013, 4, 8).getTime() }
		]
		externalClients: [
			{ id: "2345", lastUpdate: new Date(2013, 4, 2).getTime() },
			{ id: "3456", lastUpdate: new Date(2013, 4, 8).getTime() }
		]
		stableTimestamp: new Date(2013, 4, 2).getTime()


addMock "syncPushResponse",
	success: true
	message: 'commands received'
	data: { }


addMock "reconcileRequiredResponse",
	success: false
	message: 'reconcile required'
	data: { }


addMock "syncReconcileResponse",
	success: true
	message: "app partially reconciled"
	data: { }