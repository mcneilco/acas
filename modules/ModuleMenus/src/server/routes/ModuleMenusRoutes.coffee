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

			clientConnections = connectedUsers[sessionID]
			connectedUsers[sessionID] = _.without(clientConnections, socket.id)
			totalNumberOfConnectionsForUser = _.size(connectedUsers[sessionID])
			if socket.request.user?
				console.log "got disconnect"
				broadcastMessageToSpecificClients(connectedUsers[sessionID], 'tabClosed', totalNumberOfConnectionsForUser, socket)
			else
				console.log "got logoff"
				broadcastMessageToSpecificClients(connectedUsers[sessionID], 'loggedOff', totalNumberOfConnectionsForUser, socket)
		)

		socket.on('changeUserName', (updatedUsername) =>
			updateUserNameInSession updatedUsername, sessionStore, socket, (newUser) ->
				broadcastMessageToSpecificClients(connectedUsers[sessionID], 'usernameUpdated', newUser, socket)
				socket.emit('usernameUpdated', newUser)
		)
	)

getUserNameFromSession = (socket) ->
	if 'originalLoginUserName' of socket.request.user && socket.request.user.originalLoginUserName?
		console.log "using original login name"
		return socket.request.user.originalLoginUserName
	else
		return socket.request.user.username

updateUserNameInSession = (updatedUserName, sessionStore, socket, callback) ->
	if updatedUserName == socket.request.user.username
		return #nothing to change

	if !('originalLoginUserName' of socket.request.user) || socket.request.user.originalLoginUserName?
		socket.request.user.originalLoginUserName = socket.request.user.username

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
			newUser.roles = socket.request.user.roles

		socket.request.user = newUser
		sessionID = getSessionID(socket)
		## Get the session from the sessionStore, update the user and then save the session back to the sessionStore
		sessionStore.get sessionID, (err, session) =>
			session.passport.user = newUser
			sessionStore.set sessionID, session, (err, session) =>
				callback newUser


broadcastMessageToSpecificClients = (socketIds, messageName, payload, socket) ->
	_.each(socketIds, (socketId) ->
		socket.broadcast.to(socketId).emit(messageName, payload)
	)

getSessionID = (socket) ->
	socket.request.sessionID