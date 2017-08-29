_ = require 'underscore'

exports.setupChannels = (io, sessionStore, loginRoutes) ->
	nsp = io.of('/formController:connected')
	connectedUsers = {}
	global.editLockedEntities = {}
	nsp.on('connection', (socket) =>

		socket.on('disconnect', =>
			console.log "got disconnect"
			sessionLocks = _.where global.editLockedEntities, socketID: socket.id
			for lockKey, lock of global.editLockedEntities
				if lock.socketID==socket.id
					console.log "clearing lock on #{lock}"
					delete global.editLockedEntities[lockKey]
		)

		socket.on('editLockEntity', (entityType, codeName) =>
			console.log "got editLockEntity #{entityType}, #{codeName}"

			parsedCookie = JSON.parse(sessionStore.sessions[socket.request.sessionID])
			lockKey = entityType+"_"+codeName
			console.log "trying to lock #{lockKey} for session #{socket.id}"

			lockedEntity = global.editLockedEntities[lockKey]
			if lockedEntity? and lockedEntity.socketID!=socket.id
				result =
					okToEdit: false
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
				result =
					okToEdit: true
					currentEditor: parsedCookie.passport.user.username
					lastActivityDate: now
					lockCreatedDate: now

			socket.emit('editLockRequestResult', result)
		)
		socket.on('updateEditLock', (entityType, codeName) =>
			console.log "got updateEditLock #{entityType}, #{codeName}"
			lockKey = entityType+"_"+codeName
			lockedEntity = global.editLockedEntities[lockKey]
			if lockedEntity? and lockedEntity.socketID==socket.id
				now = new Date().getTime()
				lockedEntity.lastActivityDate = now
		)
	)


