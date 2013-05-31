addMock "syncPullResponse",
	success: true
	message: 'commands retrieved'
	data:
		commands: [
			{ id: '22', name: 'multiply',  data: { number: 2 }, clientId: "client-2", timestamp: new Date(2013, 4, 2).getTime() },
			{ id: '36', name: 'increment', data: { number: 1 }, clientId: "client-3", timestamp: new Date(2013, 4, 6).getTime() },
			{ id: '38', name: 'increment', data: { number: 3 }, clientId: "client-3", timestamp: new Date(2013, 4, 8).getTime() }
		]
		externalClients: [
			{ id: "client-2", lastUpdate: new Date(2013, 4, 2).getTime() },
			{ id: "client-3", lastUpdate: new Date(2013, 4, 8).getTime() }
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