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
				timeout: 2000
			, (error, response, json) =>
#				console.log "error", error
#				console.log "json", json
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
					if balanceStatus is "device_server_offline" and @status is "idle"
						@status = balanceStatus
						if @currentConnectedUser?
							@currentConnectedUser.socket.emit	'youShouldTryConnecting'
					else
						unless balanceStatus is @status
							@status = balanceStatus
							switch @status
								when "idle"
									@room.emit('youShouldTryConnecting')
								when "in_use"
									@room.emit('in_use')
				).catch((err) =>
					@status = "device_server_offline"
					@room.emit("device_server_offline")
				)
			, 1000)

	clearHeartBeat: =>
		clearInterval(@heartBeat)
		@heartBeat = null

	disconnectFromBalance: =>
		disconnectFromBalanceURL = @balanceUrl + "api/disconnectFromBalance"
		return new Promise((resolve, reject) =>
			request(
				method: 'GET'
				url: disconnectFromBalanceURL
			, (error, response, json) ->
				if error?
					reject error
				else
					resolve json.message
			)
		)

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
							unless @currentConnectedUser?
								@currentConnectedUser = _.first(@balanceConnectQueue)
							reject {status: 'not_available', connectedUser: @currentConnectedUser}
					when "device_not_connected"
						reject {status: "device_not_connected"}
					when "in_use"
						reject {status: "in_use"}
			).catch((err) =>
				@isAvailable = false
				reject {status: "device_server_offline"}
			)
		)

	swapCurrentUser: (userToAdd, socket) =>
		clientInQueue = _.findWhere(@balanceConnectQueue, {clientId: userToAdd.clientId})
		if clientInQueue
			@removeUserToAddFromQueue(userToAdd.clientId)
		@removeCurrentUser()
		@currentConnectedUser = {clientId: userToAdd.clientId, userName: userToAdd.userName, socket: socket}
		@balanceConnectQueue.push @currentConnectedUser
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
		currentUser = @balanceConnectQueue.shift()
		@balanceConnectQueue.push currentUser
		@currentConnectedUser = null

	zeroBalance: =>
		zeroBalanceURL = @balanceUrl + "api/zeroBalance"
		return new Promise((resolve, reject) =>
			request(
				method: 'POST'
				url: zeroBalanceURL
				json: true
				body: {'callbackURL': global.app.get('port') + '/api/tareSingleVial/zeroBalanceComplete'}
			, (error, response, json) ->
				resolve json
			)
		)


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
			socket.on('zeroBalance', (payload) =>
				@handleZeroBalance(socket, payload)
			)
		)

	handleConnectToDevice: (socket, payload, callback) ->
		unless @balances[payload.deviceUrl]
			@balances[payload.deviceUrl] = new BalanceAccess(payload.deviceName, payload.deviceUrl, @nameSpacedRoom)
		socket.join(payload.deviceUrl)
		@usersInRoom[socket.id] = payload.deviceUrl
		balanceAccess = @balances[payload.deviceUrl]
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
		if balanceAccess?
			if balanceAccess.getNextUser().clientId is socket.id
				balanceAccess.disconnectCurrentUser()
			else
				balanceAccess.removeUserToAddFromQueue(socket.id)
			nextUserInQueue = balanceAccess.getNextUser()
			if nextUserInQueue?
				socket.broadcast.to(nextUserInQueue.clientId).emit('youShouldTryConnecting')
			else
				socket.broadcast.emit('alertAllDisconnectedFromDevice')
				balanceAccess.clearHeartBeat()
				balanceAccess.disconnectFromBalance()
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
			balanceAccess.disconnectFromBalance()

	handleBootUser: (socket, payload, callback) ->
		balanceAccess = @balances[@usersInRoom[socket.id]]
		balanceAccess.swapCurrentUser({userName: payload.userNameToAdd, clientId: socket.id}, socket)
		@currentlyConnectedSocket = socket
		socket.broadcast.to(@usersInRoom[socket.id]).emit('balance_reserved', {status: "not_available", userName: payload.userNameToAdd, clientId: socket.id})
		socket.broadcast.to(payload.userToBootClientId).emit('disconnectedByAnotherUser', {username: payload.userNameToAdd, socketId: socket.id})
		callback(null, 'did this connect? ')

	handleDisconnectAllUsers: (socket, callback) ->
		balanceAccess = @balances[@usersInRoom[socket.id]]
		balanceAccess.disconnectCurrentUser()
		balanceAccess.clearAllUsers()
		socket.broadcast.emit('alertAllDisconnectedFromDevice')
		callback()

	broadCastToAllUsers: (eventName) ->
		@nameSpacedRoom.emit(eventName)

	handleZeroBalance: (socket) ->
		balanceAccess = @balances[@usersInRoom[socket.id]]
		balanceAccessPromise = balanceAccess.zeroBalance()
		balanceAccessPromise.then(() =>
			console.log "balanceAccessPromise.then"
		)
		balanceAccessPromise.catch((err) =>
			console.log "balanceAccessPromise.catch err"
		)
		socket.broadcast.emit('in_use')


exports.DeviceSocketController = DeviceSocketController
