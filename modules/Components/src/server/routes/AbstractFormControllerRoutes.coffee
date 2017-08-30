_ = require 'underscore'

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/formController/clearAllLocks', exports.clearAllLocks

global.editLockedEntities = {}

exports.setupChannels = (io, sessionStore, loginRoutes) ->
	nsp = io.of('/formController:connected')
	connectedUsers = {}
	nsp.on('connection', (socket) =>
		console.log "Opened new connection #{socket.id}"

		socket.on('disconnect', =>
			console.log "got disconnect"
			sessionLocks = _.where global.editLockedEntities, socketID: socket.id
			for lockKey, lock of global.editLockedEntities
				if lock.socketID==socket.id
					console.log "clearing lock on #{lock}"
					for quid in lock.rejectedRequestSocketIDs
						socket.broadcast.to(quid).emit('editLockAvailable')
					delete global.editLockedEntities[lockKey]
		)

		socket.on('editLockEntity', (entityType, codeName) =>
			console.log "got editLockEntity request #{entityType}, #{codeName}"

			parsedCookie = JSON.parse(sessionStore.sessions[socket.request.sessionID])
			lockKey = entityType+"_"+codeName
			console.log "trying to lock #{lockKey} for session #{socket.id}"

			lockedEntity = global.editLockedEntities[lockKey]
			if lockedEntity? and lockedEntity.socketID!=socket.id
				lockedEntity.rejectedRequestSocketIDs.push socket.id
				result =
					okToEdit: false
					currentEditor: lockedEntity.currentEditor
					lastActivityDate: lockedEntity.lastActivityDate
					lockCreatedDate: lockedEntity.lockCreatedDate
			else if lockedEntity? and lockedEntity.socketID==socket.id
				result =
					okToEdit: true
					currentEditor: lockedEntity.currentEditor
					lastActivityDate: lockedEntity.lastActivityDate
					lockCreatedDate: lockedEntity.lockCreatedDate
			else
				now = new Date().getTime()
				global.editLockedEntities[lockKey] =
					currentEditor: parsedCookie.passport.user.username
					lastActivityDate: now
					lockCreatedDate: now
					socketID: socket.id
					entityType: entityType
					codeName: codeName
					rejectedRequestSocketIDs: []
				result =
					okToEdit: true
					currentEditor: parsedCookie.passport.user.username
					lastActivityDate: now
					lockCreatedDate: now

			socket.emit('editLockRequestResult', result)
		)
		socket.on('updateEditLock', (entityType, codeName) =>
#			console.log "got updateEditLock #{entityType}, #{codeName}"
			lockKey = entityType+"_"+codeName
			lockedEntity = global.editLockedEntities[lockKey]
			if lockedEntity? and lockedEntity.socketID==socket.id
				now = new Date().getTime()
				lockedEntity.lastActivityDate = now
		)
	)

exports.clearAllLocks = (req, resp) ->
	console.log "clearing edit locks. Users will have to reload to get access"
	console.dir global.editLockedEntities, depth: 3
	global.editLockedEntities = {}
	console.dir global.editLockedEntities, depth: 3
	resp.end()
