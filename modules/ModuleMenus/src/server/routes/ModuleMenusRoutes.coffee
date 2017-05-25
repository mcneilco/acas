_ = require 'underscore'

exports.setupChannels = (io, sessionStore, loginRoutes) ->
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
			clientConnections = connectedUsers[userName]
			connectedUsers[userName] = _.without(clientConnections, socket.id)
			totalNumberOfConnectionsForUser = _.size(connectedUsers[userName])
			broadcastMessageToSpecificClients(connectedUsers[userName], 'loggedOff', totalNumberOfConnectionsForUser, socket)
		)

		socket.on('changeUserName', (updatedUsername) =>
			sessionID = getSessionID(socket)
			updateUserNameInSession(updatedUsername, sessionStore, sessionID)
			broadcastMessageToSpecificClients(connectedUsers[userName], 'usernameUpdated', updatedUsername, socket)
			socket.emit('usernameUpdated', updatedUsername)
		)
	)

getUserNameFromSession = (socket) ->
	unless socket.request.user.originalLoginUserName?
		console.log "using original login name"
		return socket.request.user.originalLoginUserName
	else
		return socket.request.user.username

updateUserNameInSession = (updatedUserName, sessionStore, sessionId) ->
	parsedCookie = JSON.parse(sessionStore.sessions[sessionId])
	unless parsedCookie.passport.user.originalLoginUserName?
		parsedCookie.passport.user.originalLoginUserName = parsedCookie.passport.user.username
	parsedCookie.passport.user.username = updatedUserName
	parsedCookie.passport.user.firstName = updatedUserName
	sessionStore.sessions[sessionId] = JSON.stringify(parsedCookie)

broadcastMessageToSpecificClients = (socketIds, messageName, payload, socket) ->
	_.each(socketIds, (socketId) ->
		socket.broadcast.to(socketId).emit(messageName, payload)
	)

getSessionID = (socket) ->
	socket.request.sessionID