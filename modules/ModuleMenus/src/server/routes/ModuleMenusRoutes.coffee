_ = require 'underscore'

exports.setupChannels = (io, loginRoutes) ->
	nsp = io.of('/user:loggedin')
	connectedUsers = {}
	nsp.on('connection', (socket) =>
		userName = getUserNameFromSession(socket)
		unless connectedUsers[userName]?
			connectedUsers[userName] = []
		connectedUsers[userName].push socket.id
		totalNumberOfConnectionsForUser = _.size(connectedUsers[userName])
		broadcastMessageToSpecificClients(connectedUsers[userName], 'loggedOn', totalNumberOfConnectionsForUser, socket)
		socket.emit('loggedOn', totalNumberOfConnectionsForUser)
		socket.on('disconnect', =>
			userName = getUserNameFromSession(socket)
			clientConnections = connectedUsers[userName]
			connectedUsers[userName] = _.without(clientConnections, socket.id)
			totalNumberOfConnectionsForUser = _.size(connectedUsers[userName])
			broadcastMessageToSpecificClients(connectedUsers[userName], 'loggedOff', totalNumberOfConnectionsForUser, socket)
		)

		socket.on('changeUserName', (updatedUsername) =>
			userName = getUserNameFromSession(socket)
			updateUserFirstNameInSession(updatedUsername, socket)
			broadcastMessageToSpecificClients(connectedUsers[userName], 'usernameUpdated', updatedUsername, socket)
			socket.emit('usernameUpdated', updatedUsername)
		)
	)

getUserNameFromSession = (socket) ->
	return socket.request.user.username

updateUserFirstNameInSession = (updatedFirstName, socket) ->
	socket.request.user.firstName = updatedFirstName

broadcastMessageToSpecificClients = (socketIds, messageName, payload, socket) ->
	console.log "broadcastMessageToSpecificClients"
	_.each(socketIds, (socketId) ->
		socket.broadcast.to(socketId).emit(messageName, payload)
	)