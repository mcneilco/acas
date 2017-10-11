exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/authorByUsername/:username', exports.getAuthorByUsername
	app.get '/api/authorModulePreferences/:userName/:moduleName', exports.getAuthorModulePreferences
	app.put '/api/authorModulePreferences/:userName/:moduleName', exports.updateAuthorModulePreferences
	app.post '/api/genericSearch/authors', exports.genericAuthorSearch
	app.delete '/api/authors/:id', exports.deleteAuthor
	app.post '/api/author', exports.saveAuthor
	app.put '/api/author/:id', exports.updateAuthor

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/authorByUsername/:username', loginRoutes.ensureAuthenticated, exports.getAuthorByUsername
	app.get '/api/authorModulePreferences/:userName/:moduleName', loginRoutes.ensureAuthenticated, exports.getAuthorModulePreferences
	app.put '/api/authorModulePreferences/:userName/:moduleName', loginRoutes.ensureAuthenticated, exports.updateAuthorModulePreferences
	app.post '/api/genericSearch/authors', loginRoutes.ensureAuthenticated, exports.genericAuthorSearch
	app.delete '/api/authors/:id', loginRoutes.ensureAuthenticated, exports.deleteAuthor
	app.post '/api/author', loginRoutes.ensureAuthenticated, exports.saveAuthor
	app.put '/api/author/:id', loginRoutes.ensureAuthenticated, exports.updateAuthor
	app.get '/activateUser', exports.activateUserAndRedirectToChangePassword

serverUtilityFunctions = require './ServerUtilityFunctions.js'
_ = require 'underscore'
Backbone = require 'backbone'
$ = require 'jquery'
request = require 'request'
config = require '../conf/compiled/conf.js'
Label = serverUtilityFunctions.Label
LabelList = serverUtilityFunctions.LabelList
Value = serverUtilityFunctions.Value
ValueList = serverUtilityFunctions.ValueList
State = serverUtilityFunctions.State
StateList = serverUtilityFunctions.StateList
Thing = serverUtilityFunctions.Thing
ThingItx = serverUtilityFunctions.ThingItx
FirstThingItx = serverUtilityFunctions.FirstThingItx
SecondThingItx = serverUtilityFunctions.SecondThingItx
FirstThingItx = serverUtilityFunctions.FirstThingItx
LsThingItxList = serverUtilityFunctions.LsThingItxList
FirstLsThingItxList = serverUtilityFunctions.FirstLsThingItxList
SecondLsThingItxList = serverUtilityFunctions.SecondLsThingItxList


exports.getAuthorByUsername = (req, resp) ->
	exports.getAuthorByUsernameInternal req.params.username, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getAuthorByUsernameInternal = (username, callback) ->
	if global.specRunnerTestmode
		authorServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/AuthorServiceTestJSON.js'
		resp.json authorServiceTestJSON.getAuthorByUsernameInternalResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"authors?find=ByUserName&userName="+username
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json, 200
			else
				console.error 'got ajax error trying to get getContainersInLocation'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify("getContainersInLocation failed"), 500
		)

exports.getAuthorModulePreferences = (req, resp) ->
	exports.getAuthorModulePreferencesInternal req.params.userName, req.params.moduleName, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getAuthorModulePreferencesInternal = (userName, moduleName, callback) ->
	if global.specRunnerTestmode
		authorServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/AuthorServiceTestJSON.js'
		resp.json authorServiceTestJSON.getAuthorByUsernameInternalResponse
	else
		exports.getAuthorByUsernameInternal userName, (json, statusCode) ->

			author = new Author json
			settings = author.get('lsStates').getStateValueByTypeAndKind('metadata', 'module preferences', 'clobValue', moduleName)?.get("clobValue")
			if settings?
				console.debug 'here are settings', settings
				callback JSON.parse(settings), statusCode
			else
				callback null, 204

exports.updateAuthorModulePreferences = (req, resp) ->
	exports.updateAuthorModulePreferencesInternal req.params.userName, req.params.moduleName, req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.updateAuthorModulePreferencesInternal = (userName, moduleName, settings, callback) ->
	if global.specRunnerTestmode
		authorServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/AuthorServiceTestJSON.js'
		resp.json authorServiceTestJSON.updateAuthorApplicationSettingsResponse
	else
		exports.getAuthorByUsernameInternal userName, (json, statusCode) ->
			author = new Author json
			newValue = JSON.stringify(settings)
			value = author.get('lsStates').getOrCreateValueByTypeAndKind('metadata', 'module preferences', 'clobValue', moduleName)
			if value.isNew()
				author.get('lsStates').getOrCreateValueByTypeAndKind('metadata', 'module preferences', 'clobValue', moduleName).set('clobValue', newValue)
			else
				if value.get('clobValue') != newValue
					author.get('lsStates').getOrCreateValueByTypeAndKind('metadata', 'module preferences', 'clobValue', moduleName).set('ignored', true)
					author.get('lsStates').getOrCreateValueByTypeAndKind('metadata', 'module preferences', 'clobValue', moduleName).set('clobValue', newValue)
				else
					author.get('lsStates').getOrCreateValueByTypeAndKind('metadata', 'module preferences', 'clobValue', moduleName).set('clobValue', newValue)
			author.prepareToSave userName
			author.reformatBeforeSaving()
			exports.updateAuthorInternal author, (json, status) ->
				author = new Author json
				settings = author.get('lsStates').getStateValueByTypeAndKind('metadata', 'module preferences', 'clobValue', moduleName)?.get("clobValue")
				if settings?
					callback JSON.parse(settings), statusCode
				else
					callback null, 500

exports.updateAuthorInternal = (author, callback) ->
	if global.specRunnerTestmode
		authorServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/AuthorServiceTestJSON.js'
		callback authorServiceTestJSON.updateAuthor
	else
		config = require '../conf/compiled/conf.js'
		# if author.has('transactionOptions')
		# 	transactionOptions = author.get('transactionOptions')
		# 	delete author.transactionOptions
		# else
		# 	transactionOptions = {
		# 		comments: "author update"
		# 	}
		# transactionOptions.status = "COMPLETED"
		# transactionOptions.type = "CHANGE"
		# lsTransactionRecordedDate = new Date().getTime()
		# serverUtilityFunctions.createLSTransaction2 lsTransactionRecordedDate, transactionOptions, (transaction) ->
		# 	authorToSave = serverUtilityFunctions.insertTransactionIntoBackboneModel transaction.id, author
		baseurl = config.all.client.service.persistence.fullpath+"authors/"
		request = require 'request'

		request(
			method: 'PUT'
			url: baseurl
			body: author
			json: true
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && response.statusCode == 200 && json[0] != "<"
				callback json, 200
			else
				console.error 'got ajax error trying to update author'
				console.error error
				console.error json
				console.error "request #{JSON.stringify(author, null, ' ')}"
				console.error response
				callback JSON.stringify("updateAuthor failed"), 500
		)

exports.createNewAuthorInternal = (author, cb) ->
	config = require '../conf/compiled/conf.js'
	request = require 'request'
	request(
		method: 'POST'
		url: config.all.client.service.persistence.fullpath + "authors"
		body: author
		json: true
		timeout: 6000000
	, (err, response, json) =>
		if err?
			cb err, null
		else if response.statusCode != 201
			cb json, null
		else
			cb null, json
	)

exports.genericAuthorSearch = (req, resp) ->
	if req.query.testMode is true or global.specRunnerTestmode is true
		resp.end JSON.stringify "Stubs mode not implemented yet for author search"
	else
		config = require '../conf/compiled/conf.js'
		console.log "search req - generic author"
		console.log req
		unless req.body.queryDTO?
			req.body.queryDTO = {}
		# req.body needs queryString and queryDTO
		baseurl = config.all.client.service.persistence.fullpath+"authors/genericBrowserSearch"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				#filter out ignored authors
				if json.numberOfResults > 0
					nonIgnoredAuthors = _.filter json.results, (auth) =>
						!auth.ignored
					resp.json nonIgnoredAuthors
				else
					resp.json []
			else
				console.log 'got ajax error trying to search for authors'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end json
		)

exports.deleteAuthor = (req, resp) ->
	if global.specRunnerTestmode
		res.end JSON.stringify "stubs mode for deleting author not implemented"
	else
		config = require '../conf/compiled/conf.js'
		authorId = req.params.id
		baseurl = config.all.client.service.persistence.fullpath+"authors/"+authorId
		console.log baseurl
		request = require 'request'

		request(
			method: 'DELETE'
			url: baseurl
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			if !error && response.statusCode == 200
				console.log "deleted author"
				resp.json json
			else
				console.log 'got ajax error trying to delete author'
				console.log error
				console.log response
				resp.statusCode = 500
				resp.end json
		)


class Author extends Backbone.Model
	lsProperties: {}
	className: "Author"

	defaults: () =>
#attrs =
		@set lsType: "default"
		@set lsKind: "default"
		#		@set lsKind: this.className #TODO figure out instance classname and replace --- here's a hack that does it-ish
		@set corpName: ""
		@set recordedBy: AppLaunchParams.loginUser.username
		@set recordedDate: new Date().getTime()
		@set shortDescription: " "
		@set lsLabels: new LabelList()
		@set lsStates: new StateList()
#		@set firstLsThings: new FirstLsThingItxList()
#		@set secondLsThings: new SecondLsThingItxList()

	initialize: ->
		@.set @parse(@.attributes)

	parse: (resp) =>
		if resp?
			if resp == 'not unique lsContainer name'
				@createDefaultLabels()
				@createDefaultStates()
				@trigger 'saveFailed'
				return
			else
				if resp.lsLabels?
					if resp.lsLabels not instanceof LabelList
						resp.lsLabels = new LabelList(resp.lsLabels)
					resp.lsLabels.on 'change', =>
						@trigger 'change'

				if resp.lsStates?
					if resp.lsStates not instanceof StateList
						resp.lsStates = new StateList(resp.lsStates)
					resp.lsStates.on 'change', =>
						@trigger 'change'
				@.set resp
				@createDefaultLabels()
				@createDefaultStates()
#				@createDefaultFirstLsThingItx()
#				@createDefaultSecondLsThingItx()
		else
			@createDefaultLabels()
			@createDefaultStates()
		#			@createDefaultFirstLsThingItx()
		#			@createDefaultSecondLsThingItx()
		resp

	createDefaultLabels: =>
# loop over defaultLabels
# getorCreateLabel
# add key as attribute of model
		if @lsProperties.defaultLabels?
			for dLabel in @lsProperties.defaultLabels
				newLabel = @get('lsLabels').getOrCreateLabelByTypeAndKind dLabel.type, dLabel.kind
				@set dLabel.key, newLabel
				#			if newLabel.get('preferred') is undefined
				newLabel.set preferred: dLabel.preferred


	createDefaultStates: =>
		if @lsProperties.defaultValues?
			for dValue in @lsProperties.defaultValues
#Adding the new state and value to @
				newValue = @get('lsStates').getOrCreateValueByTypeAndKind dValue.stateType, dValue.stateKind, dValue.type, dValue.kind
				@listenTo newValue, 'createNewValue', @createNewValue
				#setting unitType and unitKind in the state, if units are given
				if dValue.unitKind? and newValue.get('unitKind') is undefined
					newValue.set unitKind: dValue.unitKind
				if dValue.unitType? and newValue.get('unitType') is undefined
					newValue.set unitType: dValue.unitType
				if dValue.codeKind? and newValue.get('codeKind') is undefined
					newValue.set codeKind: dValue.codeKind
				if dValue.codeType? and newValue.get('codeType') is undefined
					newValue.set codeType: dValue.codeType
				if dValue.codeOrigin? and newValue.get('codeOrigin') is undefined
					newValue.set codeOrigin: dValue.codeOrigin

				#Setting dValue.key attribute in @ to point to the newValue
				@set dValue.key, newValue

				if dValue.value? and (newValue.get(dValue.type) is undefined)
					newValue.set dValue.type, dValue.value
				#setting top level model attribute's value to equal valueType's value
				# (ie set "value" to equal value in "stringValue")
				@get(dValue.key).set("value", newValue.get(dValue.type))
				newValue.set("key", dValue.key)

	updateValuesByKeyValue: (keyValues) =>
		if @lsProperties.defaultValues?
			defaultKeys =  _.pluck(@lsProperties.defaultValues, "key")
			matchedKeyValues = _.pick keyValues, defaultKeys
			for key of matchedKeyValues
				type = @.get(key).get("lsType")
				value = matchedKeyValues[key]
				unit = keyValues["#{key}Unit"]
				if type == "dateValue"
					value = parseInt value
				else if type == "numericValue"
					value = Number value
				@.get(key).set "value", value
				if unit?
					@.get(key).set "unitKind", String(unit)

	getValues: =>
		response = {}
		if @lsProperties.defaultValues?
			defaultKeys = _.pluck(@lsProperties.defaultValues, "key")
			for key in defaultKeys
				response[key] = @.get(key).get("value")
				if @.get(key).get("unitKind")?
					response["#{key}Unit"] = @.get(key).get("unitKind")
		response

	getValuesByKey: (keys) =>
		if @lsProperties.defaultValues?
			defaultKeys =  _.pluck(@lsProperties.defaultValues, "key")
			matchedKeyValues = _.intersection(keys, defaultKeys)
			outObject = {}
			for key in matchedKeyValues
				outObject[key] = @.get(key).get("value")
			outObject

	createNewValue: (key, newVal) =>
		valInfo = _.where(@lsProperties.defaultValues, {key: key})[0]
		@unset(key)
		newValue = @get('lsStates').getOrCreateValueByTypeAndKind valInfo['stateType'], valInfo['stateKind'], valInfo['type'], valInfo['kind']
		newValue.set valInfo['type'], newVal
		newValue.set
			unitKind: valInfo['unitKind']
			unitType: valInfo['unitType']
			codeKind: valInfo['codeKind']
			codeType: valInfo['codeType']
			codeOrigin: valInfo['codeOrigin']
			value: newVal
		@set key, newValue

	createDefaultFirstLsThingItx: =>
# loop over defaultFirstLsThingItx
# add key as attribute of model
		if @lsProperties.defaultFirstLsThingItx?
			for itx in @lsProperties.defaultFirstLsThingItx
				thingItx = @get('firstLsThings').getItxByTypeAndKind itx.itxType, itx.itxKind
				unless thingItx?
					thingItx = @get('firstLsThings').createItxByTypeAndKind itx.itxType, itx.itxKind
				@set itx.key, thingItx

	createDefaultSecondLsThingItx: =>
# loop over defaultSecondLsThingItx
# add key as attribute of model
		if @lsProperties.defaultSecondLsThingItx?
			for itx in @lsProperties.defaultSecondLsThingItx
				thingItx = @get('secondLsThings').getOrCreateItxByTypeAndKind itx.itxType, itx.itxKind
				@set itx.key, thingItx

	reformatBeforeSaving: =>
		if @lsProperties.defaultLabels?
			for dLabel in @lsProperties.defaultLabels
				@unset(dLabel.key)

		#		if @lsProperties.defaultFirstLsThingItx?
		#			for itx in @lsProperties.defaultFirstLsThingItx
		#				@unset(itx.key)
		#
		#		if @get('firstLsThings')? and @get('firstLsThings') instanceof FirstLsThingItxList
		#			@get('firstLsThings').reformatBeforeSaving()
		#
		#		if @lsProperties.defaultSecondLsThingItx?
		#			for itx in @lsProperties.defaultSecondLsThingItx
		#				@unset(itx.key)
		#
		#		if @get('secondLsThings')? and @get('secondLsThings') instanceof SecondLsThingItxList
		#			@get('secondLsThings').reformatBeforeSaving()

		if @lsProperties.defaultValues?
			for dValue in @lsProperties.defaultValues
				if @get(dValue.key)?
					if @get(dValue.key).get('value') is undefined
						lsStates = @get('lsStates').getStatesByTypeAndKind dValue.stateType, dValue.stateKind
						value = lsStates[0].getValuesByTypeAndKind dValue.type, dValue.kind
						lsStates[0].get('lsValues').remove value
					@unset(dValue.key)

		if @attributes.attributes?
			delete @attributes.attributes
		if @attributes.collection?
			delete @attributes.collection
		for i of @attributes
			if _.isFunction(@attributes[i])
				delete @attributes[i]
			else if !isNaN(i)
				delete @attributes[i]

#	deleteInteractions : =>
#		delete @attributes.firstLsThings
#		delete @attributes.secondLsThings

	duplicate: =>
		copiedContainer = @.clone()
		copiedContainer.unset 'codeName'
		labels = copiedContainer.get('lsLabels')
		labels.each (label) =>
			@resetClonedAttrs label
		states = copiedContainer.get('lsStates')
		@resetStatesAndVals states
		copiedContainer.set
			version: 0
		@resetClonedAttrs(copiedContainer)
		copiedContainer.get('notebook').set value: ""
		copiedContainer.get('scientist').set value: "unassigned"
		copiedContainer.get('completion date').set value: null

		#		delete copiedContainer.attributes.firstLsThings

		#		secondItxs = copiedThing.get('secondLsThings')
		#		secondItxs.each (itx) =>
		#			@resetClonedAttrs(itx)
		#			itxStates = itx.get('lsStates')
		#			@resetStatesAndVals itxStates
		copiedContainer

	resetStatesAndVals: (states) =>
		states.each (st) =>
			@resetClonedAttrs(st)
			values = st.get('lsValues')
			if values?
				ignoredVals = values.filter (val) ->
					val.get('ignored')
				for val in ignoredVals
					igVal = st.getValueById(val.get('id'))[0]
					values.remove igVal
				values.each (sv) =>
					@resetClonedAttrs(sv)

	resetClonedAttrs: (clone) =>
		clone.unset 'id'
		clone.unset 'lsTransaction'
		clone.unset 'modifiedDate'
		clone.set
			recordedBy: AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
			version: 0

	getStateValueHistory: (vKind) =>
		valInfo = _.where(@lsProperties.defaultValues, {key: vKind})[0]
		@get('lsStates').getStateValueHistory valInfo['stateType'], valInfo['stateKind'], valInfo['type'], valInfo['kind']

	prepareToSave: (recordedBy)->
		if !recordedBy?
			recordedBy = @get('recordedBy')
		rBy = recordedBy
		rDate = new Date().getTime()
		@set recordedDate: rDate
		@get('lsLabels').each (lab) ->
			unless lab.get('recordedBy') != ""
				lab.set recordedBy: rBy
			unless lab.get('recordedDate') != null
				lab.set recordedDate: rDate
		@get('lsStates').each (state) ->
			unless state.get('recordedBy') != ""
				state.set recordedBy: rBy
			unless state.get('recordedDate') != null
				state.set recordedDate: rDate
			state.get('lsValues').each (val) ->
				unless val.get('recordedBy') != ""
					val.set recordedBy: rBy
				unless val.get('recordedDate') != null
					val.set recordedDate: rDate

exports.Author = Author
AppLaunchParams = loginUser:username:"acas"

exports.saveAuthor = (req, resp) ->
	if req.session?.passport?.user?
		user = req.session.passport.user
	else
		user =
			username: 'anonymous'
			roles: []
	exports.saveAuthorInternal req.body, user, (err, response) ->
		if err?
			resp.statusCode = 500
			resp.json err
		else
			resp.json response

exports.updateAuthor = (req, resp) ->
	if req.session?.passport?.user?
		user = req.session.passport.user
	else
		user =
			username: 'anonymous'
			roles: []
	exports.updateAuthorAndRolesInternal req.body, user, (err, response) ->
		if err?
			resp.statusCode = 500
			resp.json err
		else
			resp.json response

exports.saveAuthorInternal = (author, user, callback) ->
	validateAuthorAttributes author, (authorValidationErrors) ->
		if authorValidationErrors?
			callback authorValidationErrors
		else
			checkUserCanCreateOrEditAuthor user, (err, userCanCreate) ->
				if err?
					callback err
				else if !userCanCreate
					console.error "ALERT: User #{user.username} attempted to create an author without having the proper roles."
					callback 'You do not have permissions to create authors! This incident will be reported to your system administrator.'
				else
					checkUserNameAndEmailAreUnique author, (userNameEmailUniqueError) ->
						if userNameEmailUniqueError?
							callback userNameEmailUniqueError
						else
							parseSystemRoles author, (err, author, systemRoles) ->
								if err?
									callback err
								else
									author.recordedBy = user.username
									createOrSignupAuthorInternal author, (err, savedAuthor) ->
										if err?
											callback err
										else
											fetchSystemRoles systemRoles, (err, systemRoles) ->
												flatAuthorRoles = []
												_.each systemRoles, (role) ->
													flatAuthorRole =
														roleType: role.lsType
														roleKind: role.lsKind
														roleName: role.roleName
														userName: author.userName
													flatAuthorRoles.push flatAuthorRole
												saveAuthorRoles flatAuthorRoles, (err, savedRoles) ->
													if err?
														callback err
													else
														exports.getAuthorByUsernameInternal author.userName, (response, statusCode) ->
															if statusCode != 200
																callback err
															else
																callback null, response

exports.updateAuthorAndRolesInternal = (author, user, callback) ->
	validateAuthorAttributes author, (authorValidationErrors) ->
		if authorValidationErrors?
			callback authorValidationErrors
		else
			checkUserCanCreateOrEditAuthor user, (err, userCanEdit) ->
				if err?
					callback err
				else if !userCanEdit
					console.error "ALERT: User #{user.username} attempted to edit an author without having the proper roles."
					callback 'You do not have permissions to edit authors! This incident will be reported to your system administrator.'
				else
					parseSystemRoles author, (err, author, systemRoles) ->
						if err?
							callback err
						else
							exports.getAuthorByUsernameInternal author.userName, (savedAuthor, statusCode) ->
								if statusCode != 200
									callback savedAuthor
								else
									checkIfEmailHasChangedAndIsUnique author, savedAuthor, (err) ->
										if err?
											callback err
										else
											parseSystemRoles savedAuthor, (err, savedAuthor, savedSystemRoles) ->
												diffSystemRolesWithSaved author.userName, systemRoles, savedSystemRoles, (err, rolesToAdd, rolesToDelete) ->
													if rolesToAdd.length > 0 or rolesToDelete.length > 0
														checkUserCanEditSystemRoles user, (err, userCanEditRoles) ->
															if err?
																callback err
															else if !userCanEditRoles
																console.error "ALERT: User #{user.username} attempted to edit system roles without having the proper authorities."
																callback 'You do not have permissions to edit system roles! This incident will be reported to your system administrator.'
															else
																exports.updateAuthorInternal author, (updatedAuthor, statusCode) ->
																	if statusCode != 200
																		callback updatedAuthor
																	else
																		saveAuthorRoles rolesToAdd, (err, savedRoles) ->
																			if err?
																				callback err
																			else
																				deleteAuthorRoles rolesToDelete, (err, deletedRoles) ->
																					if err?
																						callback err
																					else
																						#save successful. Fetch the new author and return.
																						exports.getAuthorByUsernameInternal author.userName, (response, statusCode) ->
																							if statusCode != 200
																								callback err
																							else
																								callback null, response
													else
														#roles have not changed, just update the author
														exports.updateAuthorInternal author, (updatedAuthor, statusCode) ->
															if statusCode != 200
																callback updatedAuthor
															else
																#save successful. Fetch the new author and return.
																exports.getAuthorByUsernameInternal author.userName, (response, statusCode) ->
																	if statusCode != 200
																		callback err
																	else
																		callback null, response

validateAuthorAttributes = (author, callback) ->
	requiredAttrs = ['firstName', 'lastName', 'userName', 'emailAddress']
	missingAttrs = []
	for attr in requiredAttrs
		if !author[attr]? or author[attr].length < 1
			missingAttrs.push attr
	if missingAttrs.length > 0
		callback missingAttrs
	else
		callback null

parseUserRoles = (user) ->
	userRoles = []
	if user.roles?
		_.each user.roles, (authorRole) ->
			userRoles.push authorRole.roleEntry.roleName
	return userRoles

checkUserCanCreateOrEditAuthor = (user, callback) ->
	userRoles = parseUserRoles user
	authStrategy = config.all.server.security.authstrategy
	adminRole = config.all.client.roles.acas.adminRole
	if !config.all.client.author.editingRoles?
		editingRoles = []
	else
		editingRoles = config.all.client.author.editingRoles.split(",")
	if !adminRole? or adminRole.length < 1
		callback null, true
	else
		if authStrategy == 'database' and (userRoles.indexOf(adminRole) > -1)
			callback null, true
		else if authStrategy == 'database'
			callback null, false
		else if editingRoles? and editingRoles.length > 1
			hasEditingRole = ((_.intersection userRoles, editingRoles).length > 0)
			callback null, hasEditingRole
		else
			callback null, true

checkUserCanEditSystemRoles = (user, callback) ->
	userRoles = parseUserRoles user
	authStrategy = config.all.server.security.authstrategy
	adminRole = config.all.client.roles.acas.adminRole
	if !adminRole? or adminRole.length < 1
		callback null, true
	else
		if (userRoles.indexOf(adminRole) > -1)
			callback null, true
		else
			callback null, false

checkUserNameAndEmailAreUnique = (author, callback) ->
	checkUserNameIsUnique author, (err, userNameUnique) ->
		if err?
			callback err
		else
			checkEmailIsUnique author, (err, emailIsUnique) ->
				if err?
					callback err
				else
					if !userNameUnique and !emailIsUnique
						callback 'That username and email address are both already in use.'
					else if !userNameUnique
						callback 'That username is already in use.'
					else if !emailIsUnique
						callback 'That email address is already in use.'
					else
						callback null

checkUserNameIsUnique = (author, callback) ->
	baseurl = config.all.client.service.persistence.fullpath+"authors?find=ByUserName&userName="+author.userName
	request(
		method: 'GET'
		url: baseurl
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			if json.length < 1
				callback null, true
			else
				console.debug json
				callback null, false
		else
			console.error 'got error checking if author username exists'
			console.error error
			console.error json
			console.error response
			callback JSON.stringify("failed checking author username")
	)

checkEmailIsUnique = (author, callback) ->
	baseurl = config.all.client.service.persistence.fullpath+"authors?find=ByEmailAddress&emailAddress="+author.emailAddress
	request(
		method: 'GET'
		url: baseurl
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			if json.length < 1
				callback null, true
			else
				console.debug json
				callback null, false
		else
			console.error 'got error checking if author emailAddress exists'
			console.error error
			console.error json
			console.error response
			callback JSON.stringify("failed checking author emailAddress")
	)

checkIfEmailHasChangedAndIsUnique = (author, savedAuthor, callback) ->
	if author.emailAddress == savedAuthor.emailAddress
		callback null
	else
		checkEmailIsUnique author (err, isUnique) ->
			if err?
				callback err
			else if isUnique
				callback null
			else
				callback 'That email address is already in use.'

parseSystemRoles = (author, callback) ->
	roleEntries = _.pluck author.authorRoles, 'roleEntry'
	systemRoles = _.where roleEntries, {lsType: 'System'}
	delete author['authorRoles']
	callback null, author, systemRoles


diffSystemRolesWithSaved = (userName, systemRoles, savedSystemRoles, callback) ->
	rolesToAdd = _.filter systemRoles, (sysRole) ->
		!(_.findWhere savedSystemRoles, (id: sysRole.id))?
	rolesToDelete = _.filter savedSystemRoles, (savedSysRole) ->
		!(_.findWhere systemRoles, (id: savedSysRole.id))?
	fetchSystemRoles rolesToAdd, (err, rolesToAdd) ->
		if err?
			callback err
		else
			flatAuthRolesToAdd = []
			_.each rolesToAdd, (role) ->
				flatAuthorRole =
					roleType: role.lsType
					roleKind: role.lsKind
					roleName: role.roleName
					userName: userName
				flatAuthRolesToAdd.push flatAuthorRole
			flatAuthRolesToDelete = []
			_.each rolesToDelete, (role) ->
				flatAuthorRole =
					roleType: role.lsType
					roleKind: role.lsKind
					roleName: role.roleName
					userName: userName
				flatAuthRolesToDelete.push flatAuthorRole
			callback null, flatAuthRolesToAdd, flatAuthRolesToDelete

saveAuthorRoles = (rolesToCreate, cb) ->
	request(
		method: 'POST'
		url: config.all.client.service.persistence.fullpath + "authorroles/saveRoles"
		body: rolesToCreate
		json: true
		timeout: 6000000
	, (err, response, json) =>
		if err?
			cb err, null
		else
			cb null, json
	)

deleteAuthorRoles = (rolesToDelete, cb) ->
	request(
		method: 'POST'
		url: config.all.client.service.persistence.fullpath + "authorroles/deleteRoles"
		body: rolesToDelete
		json: true
		timeout: 6000000
	, (err, response, json) =>
		if err?
			cb err, null
		else
			cb null, json
	)

fetchSystemRoles = (incompleteSystemRoles, callback) ->
	request(
		method: 'GET'
		url: config.all.client.service.persistence.fullpath + 'lsRoles?lsType=System'
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			allSystemRoles = json
			ids = {}
			_.each incompleteSystemRoles, (partialRole) ->
				ids[partialRole.id] = true
			filteredSystemRoles = _.filter allSystemRoles, (val) ->
				return ids[val.id]
			callback null, filteredSystemRoles
		else
			console.error 'got error trying to get fetch system roles'
			console.error error
			console.error json
			callback 'failed to fetch system roles'
	)

exports.activateUserAndRedirectToChangePassword = (req, resp) ->
	request(
		method: 'GET'
		url: config.all.client.service.persistence.fullpath + "authorization/activateUser?emailAddress=#{req.query.emailAddress}&activate=#{req.query.activate}"
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			resp.redirect '/passwordChange'
		else
			#redirect to error page
	)

createOrSignupAuthorInternal = (author, cb) ->
	authStrategy = config.all.server.security.authstrategy
	if authStrategy == 'database'
		exports.signupNewAuthorInternal author, (err, savedAuthor) ->
			cb err, savedAuthor
	else
		exports.createNewAuthorInternal author, (err, savedAuthor) ->
			cb err, savedAuthor

exports.signupNewAuthorInternal = (author, cb) ->
	config = require '../conf/compiled/conf.js'
	request = require 'request'
	request(
		method: 'POST'
		url: config.all.client.service.persistence.fullpath + "authors/signupAuthor"
		body: author
		json: true
		timeout: 6000000
	, (err, response, json) =>
		if err?
			cb err, null
		else if response.statusCode != 201
			cb json, null
		else
			cb null, json
	)