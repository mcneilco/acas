
request = require 'request'
_ = require 'underscore'

Promise = require 'promise'


class BalanceAccess
	constructor: (balanceName, balanceUrl, room) ->
		@balanceName = balanceName
		@balanceUrl = balanceUrl
		@isAvailable = true
		@currentConnectedUser = null
		@status = "idle"
		@balanceConnectQueue = []
		@room = room
		@heartBeat = null

	###
	get the current status of the balance from the node server connected to the balance
	###
	getBalanceStatus: =>
		balanceStatusURL = @balanceUrl + "api/getBalanceStatus?balanceId=#{@balanceName}"
		return new Promise((resolve, reject) =>
			request(
				method: 'GET'
				url: balanceStatusURL
				json: true
			, (error, response, json) =>
				if error?
					reject error
				else
					resolve json.message
			)
		)

	startHeartBeat: =>
		unless @heartBeat?
			@heartBeat = setInterval( =>
				@getBalanceStatus().then((balanceStatus) =>
					unless balanceStatus is @status
						@status = balanceStatus
						switch @status
							when "idle"
								@room.emit('youShouldTryConnecting')
							when "in_use"
								@room.emit('in_use')
				).catch((err) =>
					@room.emit("device_server_offline")
				)
			, 1000)

	clearHeartBeat: =>
		clearInterval(@heartBeat)
		@heartBeat = null

	removeUserFromQueue: (clientId) =>
		if @currentConnectedUser.clientId is clientId
			@disconnectCurrentUser()
		else
			@balanceConnectQueue = _.filter(@balanceConnectQueue, (qu) ->
				qu.clientId isnt clientId
			)

	disconnectCurrentUser: =>
		@balanceConnectQueue.shift()
		@isAvailable = true
		@currentConnectedUser = null

	getNextUser: =>
		return _.first(@balanceConnectQueue)

	###
	Attempt to connect the supplied client.
	If client can connect, return null.
	If client can't connect, return the ID of the currently connected user
	###
	connectClient: (clientId, userName, socket) =>
		clientInQueue = _.findWhere(@balanceConnectQueue, {clientId: clientId})
		unless clientInQueue
			@balanceConnectQueue.push {clientId: clientId, userName: userName, socket: socket}
		return new Promise((resolve, reject) =>
			@getBalanceStatus().then((balanceStatus) =>
				@status = balanceStatus
				@startHeartBeat()
				switch @status
					when "idle"
						if @isAvailable
							@currentConnectedUser = {clientId: clientId, userName: userName, socket: socket}
							@isAvailable = false
							resolve null
						else
							if _.first(@balanceConnectQueue).clientId is clientId
								@currentConnectedUser = {clientId: clientId, userName: userName, socket: socket}
								@isAvailable = false
								resolve null
							else
								reject {status: 'not_available', connectedUser: @currentConnectedUser}
					when "device_not_connected"
						reject {status: "device_not_connected"}
					when "in_use"
						reject {status: "in_use"}
			).catch((err) =>
				reject {status: "device_server_offline"}
			)
		)

	swapCurrentUser: (userToAdd, socket) =>
		clientInQueue = _.findWhere(@balanceConnectQueue, {clientId: userToAdd.clientId})
		if clientInQueue
			@removeUserToAddFromQueue(userToAdd.clientId)

		@removeCurrentUser()
		@balanceConnectQueue.push {clientId: userToAdd.clientId, userName: userToAdd.userName, socket: socket}
		@currentConnectedUser = {clientId: userToAdd.clientId, userName: userToAdd.userName, socket: socket}
		@isAvailable = false


	removeUserToAddFromQueue: (clientId) =>
		@balanceConnectQueue = _.reject(@balanceConnectQueue, (user) ->
			return user.clientId is clientId
		)

	clearAllUsers: =>
		@balanceConnectQueue = []
		@isAvailable = true
		@currentConnectedUser = null

	removeCurrentUser: =>
		@balanceConnectQueue.shift()
		@currentConnectedUser = null


class DeviceSocketController
	constructor: (io, nameSpace) ->
		@io = io
		@nameSpace = nameSpace
		@nameSpacedRoom = @io.of(@nameSpace)
		@balances = {}
		@usersInRoom = {}
		@currentlyConnectedSocket = null

	setupEventListeners: =>
		@nameSpacedRoom.on('connection', (socket) =>
			socket.on('connectToDevice', (payload, callback) =>
				@handleConnectToDevice(socket, payload, callback)
			)
			socket.on('disconnected', =>
				@handleDisconnected(socket)
			)
			socket.on('disconnect', =>
				@handleDisconnect(socket)
			)
			socket.on('bootUser', (payload, callback) =>
				@handleBootUser(socket, payload, callback)
			)
			socket.on('disconnectAllUsers', (callback) =>
				@handleDisconnectAllUsers(socket, callback)
			)
		)

	handleConnectToDevice: (socket, payload, callback) ->
		unless @balances[payload.deviceName]
			@balances[payload.deviceName] = new BalanceAccess(payload.deviceName, payload.deviceUrl, @nameSpacedRoom)
		socket.join(payload.deviceName)
		@usersInRoom[socket.id] = payload.deviceName
		balanceAccess = @balances[payload.deviceName]
		balanceAccessPromise = balanceAccess.connectClient(socket.id, payload.userName, socket)
		balanceAccessPromise.then(() =>
			@currentlyConnectedSocket = socket
			return callback(null, 'Connected to device')
		)
		balanceAccessPromise.catch((err) =>
			if err.status is "not_available"
				return callback({status: "not_available", userName: err.connectedUser.userName, clientId: err.connectedUser.clientId}, null)
			else
				return callback({status: err.status}, null)
		)

	emitEventToCurrentlyConnectedClient: (eventName, payload) =>
		if payload?
			@currentlyConnectedSocket.emit(eventName, payload)
		else
			@currentlyConnectedSocket.emit(eventName)

	handleDisconnected: (socket) ->
		balanceAccess = @balances[@usersInRoom[socket.id]]
		balanceAccess.disconnectCurrentUser()
		nextUserInQueue = balanceAccess.getNextUser()
		if nextUserInQueue?
			socket.broadcast.to(nextUserInQueue.clientId).emit('youShouldTryConnecting')
		else
			socket.broadcast.emit('alertAllDisconnectedFromDevice')
			balanceAccess.clearHeartBeat()
		socket.leave(@usersInRoom[socket.id])
		socket.emit('disconnectedFromDevice')

	handleDisconnect: (socket) ->
		balanceAccess = @balances[@usersInRoom[socket.id]]
		balanceAccess.removeUserFromQueue(socket.id)

		nextUserInQueue = balanceAccess.getNextUser()
		if nextUserInQueue?
			socket.broadcast.to(nextUserInQueue.clientId).emit('youShouldTryConnecting')
		else
			socket.broadcast.emit('alertAllDisconnectedFromDevice')
			balanceAccess.clearHeartBeat()

	handleBootUser: (socket, payload, callback) ->
		balanceAccess = @balances[@usersInRoom[socket.id]]
		balanceAccess.disconnectCurrentUser()
		balanceAccess.swapCurrentUser({userName: payload.userNameToAdd, clientId: socket.id})
		@currentlyConnectedSocket = socket
		socket.broadcast.to(payload.userToBootClientId).emit('disconnectedByAnotherUser', payload.userNameToAdd)
		callback(null, 'did this connect? ')

	handleDisconnectAllUsers: (socket, callback) ->
		balanceAccess = @balances[@usersInRoom[socket.id]]
		balanceAccess.disconnectCurrentUser()
		balanceAccess.clearAllUsers()
		socket.broadcast.emit('alertAllDisconnectedFromDevice')
		callback()


exports.DeviceSocketController = DeviceSocketController
