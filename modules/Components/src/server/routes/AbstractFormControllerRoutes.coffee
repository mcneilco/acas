_ = require 'underscore'

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/formController/clearAllLocks', loginRoutes.ensureAuthenticated, exports.clearAllLocks

global.editLockedEntities = {}
global.newFormEntities = {}

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

			for lockKey, lock of global.newFormEntities
				if lock.savingLockSocketID==socket.id
					console.log "clearing save lock on #{lock}"
					lock.savingLockSocketID = null
					for quid in lock.savingNotificationRequestSocketIDs
						socket.broadcast.to(quid).emit('newEntitySavingComplete')

				index = lock.savingNotificationRequestSocketIDs.indexOf socket.id
				if index > -1
					lock.savingNotificationRequestSocketIDs.splice(index, 1)

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
		socket.on('clearEditLock', (entityType, codeName) =>
			console.log "got clearEditLock #{entityType}, #{codeName}"
			lockKey = entityType+"_"+codeName
			lockedEntity = global.editLockedEntities[lockKey]
			if lockedEntity? and lockedEntity.socketID==socket.id
				for quid in lockedEntity.rejectedRequestSocketIDs
					socket.broadcast.to(quid).emit('editLockAvailable')
				delete global.editLockedEntities[lockKey]
		)

		socket.on('registerForSavingNewLockNotification', (entityType) =>
			lockKey = entityType+"_savingNewLock"
			nfEntity = global.newFormEntities[lockKey]
			if nfEntity?
				nfEntity.savingNotificationRequestSocketIDs.push socket.id
			else
				global.newFormEntities[lockKey] =
					savingLockSocketID: null
					savingNotificationRequestSocketIDs: [socket.id]
		)
		socket.on('savingNewLock', (entityType) =>
			lockKey = entityType+"_savingNewLock"
			nfEntity = global.newFormEntities[lockKey]
			if nfEntity?
				nfEntity.savingLockSocketID = socket.id
				for quid in nfEntity.savingNotificationRequestSocketIDs
					socket.broadcast.to(quid).emit('newEntitySaveActive')
		)
		socket.on('savingNewConplete', (entityType) =>
			lockKey = entityType+"_savingNewLock"
			nfEntity = global.newFormEntities[lockKey]
			if nfEntity? and nfEntity.savingLockSocketID==socket.id
				nfEntity.savingLockSocketID = null
				for quid in nfEntity.savingNotificationRequestSocketIDs
					socket.broadcast.to(quid).emit('newEntitySavingComplete')
		)
	)

exports.clearAllLocks = (req, resp) ->
	console.log "clearing edit locks. Users will have to reload to get access"
	console.dir global.editLockedEntities, depth: 3
	global.editLockedEntities = {}
	console.dir global.editLockedEntities, depth: 3
	resp.end()

