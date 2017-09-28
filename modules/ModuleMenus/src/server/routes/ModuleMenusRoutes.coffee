_ = require 'underscore'

exports.setupChannels = (io, sessionStore, loginRoutes) ->
	nsp = io.of('/user:loggedin')
	connectedUsers = {}
	nsp.on('connection', (socket) =>
		userName = getUserNameFromSession(socket)
		sessionID = getSessionID(socket)
		unless connectedUsers[sessionID]?
			connectedUsers[sessionID] = []
		connectedUsers[sessionID].push socket.id
		totalNumberOfConnectionsForUser = _.size(connectedUsers[sessionID])
		broadcastMessageToSpecificClients(connectedUsers[sessionID], 'loggedOn', totalNumberOfConnectionsForUser, socket)
		socket.emit('loggedOn', totalNumberOfConnectionsForUser)

		socket.on('disconnect', =>
			parsedCookie = JSON.parse(sessionStore.sessions[sessionID])

			clientConnections = connectedUsers[sessionID]
			connectedUsers[sessionID] = _.without(clientConnections, socket.id)
			totalNumberOfConnectionsForUser = _.size(connectedUsers[sessionID])
			if parsedCookie.passport.user?
				console.log "got disconnect"
				broadcastMessageToSpecificClients(connectedUsers[sessionID], 'tabClosed', totalNumberOfConnectionsForUser, socket)
			else
				console.log "got logoff"
				broadcastMessageToSpecificClients(connectedUsers[sessionID], 'loggedOff', totalNumberOfConnectionsForUser, socket)
		)

		socket.on('changeUserName', (updatedUsername) =>
			sessionID = getSessionID(socket)
			updateUserNameInSession updatedUsername, sessionStore, sessionID, (newUser) ->
				broadcastMessageToSpecificClients(connectedUsers[sessionID], 'usernameUpdated', newUser, socket)
				socket.emit('usernameUpdated', newUser)
		)
	)

getUserNameFromSession = (socket) ->
	unless socket.request.user.originalLoginUserName?
		console.log "using original login name"
		return socket.request.user.originalLoginUserName
	else
		return socket.request.user.username

updateUserNameInSession = (updatedUserName, sessionStore, sessionId, callback) ->
	parsedCookie = JSON.parse(sessionStore.sessions[sessionId])
	if updatedUserName == parsedCookie.passport.user.username
		return #nothing to change

	unless parsedCookie.passport.user.originalLoginUserName?
		parsedCookie.passport.user.originalLoginUserName = parsedCookie.passport.user.username

	config = require '../conf/compiled/conf.js'
	csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
	csUtilities.getUser updatedUserName, (messgage, user) ->
		newUser =
			id: user.id
			username: user.username
			email: user.email
			firstName: user.firstName
			lastName: user.lastName
		if config.all.client.moduleMenus.fastUserSwitchingChangeUserRoles
			newUser.roles = user.roles
		else
			newUser.roles = parsedCookie.passport.user.roles

		parsedCookie.passport.user = newUser
		sessionStore.sessions[sessionId] = JSON.stringify(parsedCookie)
		callback newUser

broadcastMessageToSpecificClients = (socketIds, messageName, payload, socket) ->
	_.each(socketIds, (socketId) ->
		socket.broadcast.to(socketId).emit(messageName, payload)
	)

getSessionID = (socket) ->
	socket.request.sessionID