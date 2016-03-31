_ = require 'underscore'
Backbone = require 'backbone'
$ = require 'jquery'

basicRScriptPreValidation = (payload) ->
	result =
		hasError: false
		hasWarning: false
		errorMessages: []
		transactionId: null
		experimentId: null
		results: null

	if not payload.user?
		result.hasError = true
		result.errorMessages.push
			errorLevel: "error"
			message: "Username is required"

	return result

exports.runRFunction_HIDDEN = (request, rScript, rFunction, returnFunction, preValidationFunction) ->
	config = require '../conf/compiled/conf.js'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	rScriptCommand = config.all.server.rscript
	if config.all.server.rscript?
		rScriptCommand = config.all.server.rscript
	else
		rScriptCommand = "Rscript"

	csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
	csUtilities.logUsage "About to call R function: "+rFunction, JSON.stringify(request.body), request.body.user
	if preValidationFunction?
		preValErrors = preValidationFunction.call @, request.body
	else
		preValErrors = basicRScriptPreValidation request.body

	if preValErrors.hasError
		console.log preValErrors
		returnFunction.call @, JSON.stringify(preValErrors)

		return

	exec = require('child_process').exec
	Tempfile = require 'temporary/lib/file'

	rCommandFile = new Tempfile
	requestJSONFile = new Tempfile
	stdoutFile =  new Tempfile
	requestJSONFile.writeFile JSON.stringify(request.body), =>

		rCommand = 'tryCatch({ '
		rCommand += '	out <- capture.output(.libPaths("r_libs")); '
		rCommand += '	out <- capture.output(require("rjson")); '
		rCommand += '	out <- capture.output(source("'+rScript+'")); '
		rCommand += '	out <- capture.output(request <- fromJSON(file='+JSON.stringify(requestJSONFile.path)+'));'
		rCommand += '	out <- capture.output(returnValues <- '+rFunction+'(request));'
		rCommand += '	cat(toJSON(returnValues));'
		rCommand += '},error = function(ex) {cat(paste("R Execution Error:",ex));})'
		rCommandFile.writeFile rCommand, =>
			console.log rCommand
			console.log stdoutFile.path
			command = rScriptCommand + " " + rCommandFile.path + " > "+stdoutFile.path+" 2> /dev/null"

			child = exec command,  (error, stdout, stderr) ->
				console.log "stderr: " + stderr
				console.log "stdout: " + stdout
				stdoutFile.readFile encoding: 'utf8', (err, stdoutFileText) =>
					if stdoutFileText.indexOf("R Execution Error") is 0
						message =
							errorLevel: "error"
							message: stdoutFileText
						result =
							hasError: true
							hasWarning: false
							errorMessages: [message]
							transactionId: null
							experimentId: null
							results: null
						returnFunction.call JSON.stringify(result)
						csUtilities.logUsage "Returned R execution error R function: "+rFunction, JSON.stringify(result.errorMessages), request.body.user
					else
						returnFunction.call @, stdoutFileText
						try
							if stdoutFileText.indexOf '"hasError":true' > -1
								csUtilities.logUsage "Returned success from R function with trapped errors: "+rFunction, stdoutFileText, request.body.user
							else
								csUtilities.logUsage "Returned success from R function: "+rFunction, "NA", request.body.user
						catch error
							console.log error

exports.runRFunction = (req, rScript, rFunction, returnFunction, preValidationFunction) ->
	testMode = req.query.testMode
	exports.runRFunctionOutsideRequest req.body.user, req.body, rScript, rFunction, returnFunction, preValidationFunction, testMode

exports.runRFunctionOutsideRequest = (username, argumentsJSON, rScript, rFunction, returnFunction, preValidationFunction, testMode) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'

	csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
	csUtilities.logUsage "About to call RApache function: "+rFunction, JSON.stringify(argumentsJSON), username
	if preValidationFunction?
		preValErrors = preValidationFunction.call @, argumentsJSON
	else
		preValErrors = basicRScriptPreValidation argumentsJSON

	if preValErrors.hasError
		console.log preValErrors
		returnFunction.call @, JSON.stringify(preValErrors)

		return

	requestBody =
		rScript:rScript
		rFunction:rFunction
		request: JSON.stringify(argumentsJSON)

	if testMode or global.specRunnerTestmode
		runRFunctionServiceTestJSON = require '../public/javascripts/spec/testFixtures/runRFunctionServiceTestJSON.js'
		console.log 'test'
		console.log JSON.stringify(runRFunctionServiceTestJSON.runRFunctionResponse.hasError)
		returnFunction.call @, JSON.stringify(runRFunctionServiceTestJSON.runRFunctionResponse)
	else
		request.post
			timeout: 6000000
			url: config.all.client.service.rapache.fullpath + "runfunction"
			json: true
			body: JSON.stringify(requestBody)
		, (error, response, body) =>
			@serverError = error
			@responseJSON = body
			if response.statusCode != 200 or (@responseJSON? && @responseJSON["RExecutionError"]?) or @serverError?
				if response.statusCode !=200
					messageText = "Internal error please contact administrator"
				else if (@responseJSON? && @responseJSON["RExecutionError"]?)
					messageText = @responseJSON["RExecutionError"]
				else
					messageText = @serverError
				message =
					errorLevel: "error"
					message: messageText
				result =
					hasError: true
					hasWarning: false
					errorMessages: [message]
					transactionId: null
					experimentId: null
					results:
						htmlSummary: messageText
				returnFunction.call @, JSON.stringify(result)
				csUtilities.logUsage "Returned R execution error R function: "+rFunction, JSON.stringify(result.errorMessages), username
			else
				returnFunction.call @, JSON.stringify(@responseJSON)
				try
					if @responseJSON.hasError
						csUtilities.logUsage "Returned success from R function with trapped errors: "+rFunction, JSON.stringify(@responseJSON), username
					else
						csUtilities.logUsage "Returned success from R function: "+rFunction, "NA", username
				catch error
					console.log error


exports.runRScript = (rScript) ->
	config = require '../conf/compiled/conf.js'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	rScriptCommand = config.all.server.rscript
	if config.all.server.rscript?
		rScriptCommand = config.all.server.rscript
	else
		rScriptCommand = "Rscript"

	exec = require('child_process').exec
	command = "export R_LIBS=r_libs && "+ rScriptCommand + " " + rScript + " 2> /dev/null"
	console.log "About to call R script using command: "+command
	child = exec command,  (error, stdout, stderr) ->
		console.log "stderr: " + stderr
		console.log "stdout: " + stdout


### To allow following test routes to work, install this Module
	# ServerUtility function testing routes
	serverUtilityFunctions = require './public/src/modules/02_serverAPI/src/server/routes/ServerUtilityFunctions.js'
	serverUtilityFunctions.setupRoutes(app)

###
exports.setupRoutes = (app) ->
	app.post '/api/runRFunctionTest', exports.runRFunctionTest
	app.post '/api/runRApacheFunctionTest', exports.runRApacheFunctionTest

exports.runRFunctionTest = (request, response)  ->

	response.writeHead(200, {'Content-Type': 'application/json'});

	exports.runRFunction(
		request,
		"public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R",
		"runRFunctionTest",
		(rReturn) ->
			response.end rReturn
	)

exports.runRApacheFunctionTest = (request, response)  ->

	response.writeHead(200, {'Content-Type': 'application/json'});

	exports.runRApacheFunction(
		request,
		"public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R",
		"runRFunctionTest",
		(rReturn) ->
			console.log rReturn
			response.end rReturn
	)

exports.getFromACASServer = (baseurl, resp) ->
	request = require 'request'
	request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else
				console.log 'got ajax error'
				console.log error
				console.log json
				console.log response
	)


exports.ensureExists = (path, mask, cb) ->
	fs = require 'fs'
	fs.mkdir path, mask, (err) ->
		if err
			if err.code is "EEXIST" # ignore the error if the folder already exists
				cb null
			else # something else went wrong
				cb err
		else # successfully created folder
			console.log "Created new directory: "+path
			cb null
		return

	return

exports.makeAbsolutePath = (relativePath) ->
	acasPath = process.env.PWD
	dotMatches = relativePath.match(/\.\.\//g)
	if dotMatches?
		numDotDots = relativePath.match(/\.\.\//g).length
		relativePath = relativePath.replace /\.\.\//g, ''
		for d in [1..numDotDots]
			acasPath = acasPath.replace /[^\/]+\/?$/, ''
	else
		acasPath+= '/'

	console.log acasPath+relativePath+'/'
	acasPath+relativePath+'/'

exports.getFileValuesFromEntity = (thing, ignoreSaved) ->
	fvs = []
	for state in thing.lsStates
		vals = state.lsValues
		for v in vals
			if (v.lsType == 'fileValue' && !v.ignored && v.fileValue != "" && v.fileValue != undefined)
				unless (ignoreSaved and v.id?)
					fvs.push v
	fvs

exports.getFileValuesFromCollection = (collection, ignoreSaved) ->
	fvs = []
	unless collection.lsStates?
		collection = JSON.parse collection
	for state in collection.lsStates
		vals = state.lsValues
		for v in vals
			if (v.lsType == 'fileValue' && !v.ignored && v.fileValue != "" && v.fileValue != undefined)
				unless (ignoreSaved and v.id?)
					fvs.push v
	if fvs.length > 0
		return fvs
	else
		return null

controllerRedirect= require '../src/javascripts/ServerAPI/ControllerRedirectConf.js'
exports.getRelativeFolderPathForPrefix = (prefix) ->
	if controllerRedirect.controllerRedirectConf[prefix]?
		entityDef = controllerRedirect.controllerRedirectConf[prefix]
		return entityDef.relatedFilesRelativePath + "/"
	else
		return null

exports.getPrefixFromEntityCode = (code) ->
	for pref, redir of controllerRedirect.controllerRedirectConf
		if code.indexOf(pref) > -1
			return pref
	return null

exports.createLSTransaction = (date, comments, callback) ->
	if global.specRunnerTestmode
		console.log "create lsTransaction stubsMode"
		callback
			comments: "test transaction"
			date: 1427414400000
			id: 1234
			version: 0
	else
		config = require '../conf/compiled/conf.js'
		request = require 'request'
		request(
			method: 'POST'
			url: config.all.client.service.persistence.fullpath+"lstransactions"
			json: true
			body:
				recordedDate: date
				comments: comments
		, (error, response, json) ->
			if !error && response.statusCode == 201
				callback json
			else
				console.log 'got connection error trying to create an lsTransaction'
				console.log error
				console.log json
				console.log response
				callback null
		)

exports.insertTransactionIntoEntity = (transactionid, entity) ->
	entity.lsTransaction = transactionid
	if entity.lsLabels?
		for lab in entity.lsLabels
			lab.lsTransaction = transactionid
	if entity.lsStates?
		for state in entity.lsStates
			state.lsTransaction = transactionid
			for val in state.lsValues
				val.lsTransaction = transactionid

	entity

exports.getStatesByTypeAndKind = (acasEntity, type, kind) ->
	_ = require 'underscore'
	_.filter acasEntity.lsStates, (state) ->
		(not state.ignored == true) and (state.lsType == type) and (state.lsKind == kind)

exports.getValuesByTypeAndKind = (state, type, kind) ->
	_ = require 'underscore'
	_.filter state.lsValues, (value) ->
		(not value.ignored == true) and (value.lsType == type) and (value.lsKind == kind)

exports.getStateValueByTypeAndKind = (acasEntity, stype, skind, vtype, vkind) ->
	value = null
	states = exports.getStatesByTypeAndKind acasEntity, stype, skind
	if states.length > 0
#TODO get most recent state and value if more than 1 or throw error
		values = exports.getValuesByTypeAndKind states[0], vtype, vkind
		if values.length > 0
			value = values[0]
	value

exports.getOrCreateStateByTypeAndKind = (acasEntity, sType, sKind) ->
		mStates = getStatesByTypeAndKind acasEntity, sType, sKind
		mState = mStates[0] #TODO should do something smart if there are more than one
		unless mState?
			mState = new State
				lsType: sType
				lsKind: sKind
			acasEntity.lsStates.push mState
		return mState

exports.getOrCreateValueByTypeAndKind = (acasEntity, sType, sKind, vType, vKind) ->
		metaState = getOrCreateStateByTypeAndKind acasEntity, sType, sKind
		descVals = getValuesByTypeAndKind metaState, vType, vKind
		descVal = descVals[0] #TODO should do something smart if there are more than one
		unless descVal?
			descVal = createValueByTypeAndKind metaState, sType, sKind, vType, vKind
		return descVal

exports.createValueByTypeAndKind = (state, sType, sKind, vType, vKind) ->
		descVal = new Value
			lsType: vType
			lsKind: vKind
		metaState = @getOrCreateStateByTypeAndKind sType, sKind
		metaState.get('lsValues').add descVal
		descVal.on 'change', =>
			@trigger('change')
		descVal

#TODO: This was copied and pasted from client Label.coffee and then window was changed to export
class Label extends Backbone.Model
	defaults:
		lsType: "name"
		lsKind: ''
		labelText: ''
		ignored: false
		preferred: false
		recordedDate: null
		recordedBy: ""
		physicallyLabled: false
		imageFile: null

	changeLabelText: (options) ->
		@set labelText: options

class LabelList extends Backbone.Collection
	model: Label

	getCurrent: ->
		@filter (lab) ->
			!(lab.get 'ignored')

	getNames: ->
		_.filter @getCurrent(), (lab) ->
			lab.get('lsType') == "name"

	getPreferred: ->
		_.filter @getCurrent(), (lab) ->
			lab.get 'preferred'

	pickBestLabel: ->
		preferred = @getPreferred()
		if preferred.length > 0
			bestLabel =  _.max preferred, (lab) ->
				rd = lab.get 'recordedDate'
				(if (rd is "") then rd else -1)
		else
			names = @getNames()
			if names.length > 0
				bestLabel = _.max names, (lab) ->
					rd = lab.get 'recordedDate'
					(if (rd is "") then rd else -1)
			else
				current = @getCurrent()
				bestLabel = _.max current, (lab) ->
					rd = lab.get 'recordedDate'
					(if (rd is "") then rd else -1)
		return bestLabel

	pickBestName: ->
		preferredNames = _.filter @getCurrent(), (lab) ->
			lab.get('preferred') && (lab.get('lsType') == "name")
		bestLabel = _.max preferredNames, (lab) ->
			rd = lab.get 'recordedDate'
			(if (rd is "") then Infinity else rd)
		return bestLabel

	getNonPreferredName: (lsKind) ->
		nonPreferredName = _.filter @getCurrent(), (lab) ->
			(lab.get('preferred') is false) && (lab.get('lsType') == "name")
		nonPreferredName[0]


	setName: (label, currentName) ->
		if currentName?
			if currentName.isNew()
				currentName.set
					labelText: label.get 'labelText'
					lsKind: label.get 'lsKind'
					recordedBy: label.get 'recordedBy'
					recordedDate: label.get 'recordedDate'
			else
				currentName.set ignored: true
				@add label
		else
			@add label

	setBestName: (label) ->
		label.set
			lsType: 'name'
			preferred: true
			ignored: false
		currentName = @pickBestName()
		@setName(label, currentName)

	setNonPreferredName: (label) ->
		label.set
			lsType: 'name'
			preferred: false
			ignored: false
		nonPreferredName = @getNonPreferredName()
		@setName(label, nonPreferredName)

	getLabelByTypeAndKind: (type, kind) ->
		@filter (label) ->
			(not label.get('ignored')) and (label.get('lsType')==type) and (label.get('lsKind')==kind)

	getOrCreateLabelByTypeAndKind: (type, kind) ->
		labels = @getLabelByTypeAndKind type, kind
		label = labels[0] #TODO should do something smart if there are more than one
		unless label?
			label = new Label
				lsType: type
				lsKind: kind
			@.add label
			label.on 'change', =>
				@trigger('change')
		return label

	getLabelHistory: (preferredKind) ->
		preferred = @filter (lab) ->
			lab.get 'preferred'
		_.filter preferred, (lab) ->
			lab.get('lsKind') == preferredKind

class Value extends Backbone.Model
	defaults:
		ignored: false
		recordedDate: null
		recordedBy: ""

	initialize: ->
		@.on "change:value": @setValueType

	setValueType: ->
		oldVal = @get(@get('lsType'))
		newVal = @get('value')
		unless oldVal == newVal #or (Number.isNaN(oldVal) and Number.isNaN(newVal))
			if @isNew()
				@.set @get('lsType'), @get('value')
			else
				@set ignored: true
				@trigger 'createNewValue', @get('key'), newVal

class ValueList extends Backbone.Collection
	model: Value

class State extends Backbone.Model
	defaults: ->
		lsValues: new ValueList()
		ignored: false
		recordedDate: null
		recordedBy: ""

	initialize: ->
		if @has('lsValues')
			if @get('lsValues') not instanceof ValueList
				@set lsValues: new ValueList(@get('lsValues'))
		@get('lsValues').on 'change', =>
			@trigger 'change'

	parse: (resp) ->
		if resp.lsValues?
			if resp.lsValues not instanceof ValueList
				resp.lsValues = new ValueList(resp.lsValues)
				resp.lsValues.on 'change', =>
					@trigger 'change'
		resp

	getValuesByTypeAndKind: (type, kind) ->
		@get('lsValues').filter (value) ->
			(!value.get('ignored')) and (value.get('lsType')==type) and (value.get('lsKind')==kind)

	getValueById: (id) ->
		value = @get('lsValues').filter (val) ->
			val.id == id
		value

	getValueHistory: (type, kind) ->
		@get('lsValues').filter (value) ->
			(value.get('lsType')==type) and (value.get('lsKind')==kind)

	getOrCreateValueByTypeAndKind: (vType, vKind) ->
		descVals = @getValuesByTypeAndKind vType, vKind
		descVal = descVals[0] #TODO should do something smart if there are more than one
		unless descVal?
			descVal = @createValueByTypeAndKind(vType, vKind)
		return descVal

	createValueByTypeAndKind: (vType, vKind) ->
		descVal = new Value
			lsType: vType
			lsKind: vKind
		@get('lsValues').add descVal
		descVal.on 'change', =>
			@trigger('change')
		descVal

class StateList extends Backbone.Collection
	model: State

	getStatesByTypeAndKind: (type, kind) ->
		@filter (state) ->
			(not state.get('ignored')) and (state.get('lsType')==type) and (state.get('lsKind')==kind)

	getStateValueByTypeAndKind: (stype, skind, vtype, vkind) ->
		value = null
		states = @getStatesByTypeAndKind stype, skind
		if states.length > 0
#TODO get most recent state and value if more than 1 or throw error
			values = states[0].getValuesByTypeAndKind(vtype, vkind)
			if values.length > 0
				value = values[0]
		value

	getOrCreateStateByTypeAndKind: (sType, sKind) ->
		mStates = @getStatesByTypeAndKind sType, sKind
		mState = mStates[0] #TODO should do something smart if there are more than one
		unless mState?
			mState = new State
				lsType: sType
				lsKind: sKind
			@.add mState
			mState.on 'change', =>
				@trigger('change')
		return mState

	getOrCreateValueByTypeAndKind: (sType, sKind, vType, vKind) ->
		metaState = @getOrCreateStateByTypeAndKind sType, sKind
		descVals = metaState.getValuesByTypeAndKind vType, vKind
		descVal = descVals[0] #TODO should do something smart if there are more than one
		unless descVal?
			descVal = @createValueByTypeAndKind(sType, sKind, vType, vKind)
		return descVal

	createValueByTypeAndKind: (sType, sKind, vType, vKind) ->
		descVal = new Value
			lsType: vType
			lsKind: vKind
		metaState = @getOrCreateStateByTypeAndKind sType, sKind
		metaState.get('lsValues').add descVal
		descVal.on 'change', =>
			@trigger('change')
		descVal

	getValueById: (sType, sKind, id) ->
		state = (@getStatesByTypeAndKind(sType, sKind))[0]
		value = state.get('lsValues').filter (val) ->
			val.id == id
		value

	getStateValueHistory: (sType, sKind, vType, vKind) ->
		valueHistory = []
		states = @getStatesByTypeAndKind sType, sKind
		if states.length > 0
			values = states[0].getValueHistory(vType, vKind)
			if values.length > 0
				valueHistory = values
		valueHistory
##END COPY PASTE

#TODO: This was copied and pasted from client Thing.coffee and then window was changed to export
class Thing extends Backbone.Model
	lsProperties: {}
	className: "Thing"
#	urlRoot: "/api/things"

	defaults: () =>
		#attrs =
		@set lsType: "thing"
		@set lsKind: "thing"
		#		@set lsKind: this.className #TODO figure out instance classname and replace --- here's a hack that does it-ish
		@set corpName: ""
		@set recordedBy: AppLaunchParams.loginUser.username
		@set recordedDate: new Date().getTime()
		@set shortDescription: " "
		@set lsLabels: new LabelList()
		@set lsStates: new StateList()
		@set firstLsThings: new FirstLsThingItxList()
		@set secondLsThings: new SecondLsThingItxList()

	initialize: ->
		@.set @parse(@.attributes)

	parse: (resp) =>
		if resp?
			if resp == 'not unique lsThing name'
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

				if resp.firstLsThings?
					if resp.firstLsThings not instanceof FirstLsThingItxList
						resp.firstLsThings = new FirstLsThingItxList(resp.firstLsThings)
					resp.firstLsThings.on 'change', =>
						@trigger 'change'
				if resp.secondLsThings?
					if resp.secondLsThings not instanceof SecondLsThingItxList
						resp.secondLsThings = new SecondLsThingItxList(resp.secondLsThings)
					resp.secondLsThings.on 'change', =>
						@trigger 'change'
				@.set resp
				@createDefaultLabels()
				@createDefaultStates()
				@createDefaultFirstLsThingItx()
				@createDefaultSecondLsThingItx()
		else
			@createDefaultLabels()
			@createDefaultStates()
			@createDefaultFirstLsThingItx()
			@createDefaultSecondLsThingItx()
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

	createNewValue: (vKind, newVal) =>
		valInfo = _.where(@lsProperties.defaultValues, {key: vKind})[0]
		@unset(vKind)
		newValue = @get('lsStates').getOrCreateValueByTypeAndKind valInfo['stateType'], valInfo['stateKind'], valInfo['type'], valInfo['kind']
		newValue.set valInfo['type'], newVal
		newValue.set
			unitKind: valInfo['unitKind']
			unitType: valInfo['unitType']
			codeKind: valInfo['codeKind']
			codeType: valInfo['codeType']
			codeOrigin: valInfo['codeOrigin']
			value: newVal
		@set vKind, newValue

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

	getAnalyticalFiles: (fileTypes) =>
		#get list of possible kinds of analytical files
		attachFileList = new AttachFileList()
		for type in fileTypes
			analyticalFileState = @get('lsStates').getOrCreateStateByTypeAndKind "metadata", @get('lsKind')+" batch"
			analyticalFileValues = analyticalFileState.getValuesByTypeAndKind "fileValue", type.code
			if analyticalFileValues.length > 0 and type.code != "unassigned"
				#create new attach file model with fileType set to lsKind and fileValue set to fileValue
				#add new afm to attach file list
				for file in analyticalFileValues
					unless file.get('ignored')
						afm = new AttachFile
							fileType: type.code
							fileValue: file.get('fileValue')
							id: file.get('id')
							comments: file.get('comments')
						attachFileList.add afm

		attachFileList

	reformatBeforeSaving: =>
		if @lsProperties.defaultLabels?
			for dLabel in @lsProperties.defaultLabels
				@unset(dLabel.key)

		if @lsProperties.defaultFirstLsThingItx?
			for itx in @lsProperties.defaultFirstLsThingItx
				@unset(itx.key)

		if @get('firstLsThings')? and @get('firstLsThings') instanceof FirstLsThingItxList
			@get('firstLsThings').reformatBeforeSaving()

		if @lsProperties.defaultSecondLsThingItx?
			for itx in @lsProperties.defaultSecondLsThingItx
				@unset(itx.key)

		if @get('secondLsThings')? and @get('secondLsThings') instanceof SecondLsThingItxList
			@get('secondLsThings').reformatBeforeSaving()

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
		for i of @attributes
			if _.isFunction(@attributes[i])
				delete @attributes[i]
			else if !isNaN(i)
				delete @attributes[i]

	deleteInteractions : =>
		delete @attributes.firstLsThings
		delete @attributes.secondLsThings

	duplicate: =>
		copiedThing = @.clone()
		copiedThing.unset 'codeName'
		labels = copiedThing.get('lsLabels')
		labels.each (label) =>
			@resetClonedAttrs label
		states = copiedThing.get('lsStates')
		@resetStatesAndVals states
		copiedThing.set
			version: 0
		@resetClonedAttrs(copiedThing)
		copiedThing.get('notebook').set value: ""
		copiedThing.get('scientist').set value: "unassigned"
		copiedThing.get('completion date').set value: null

		delete copiedThing.attributes.firstLsThings

		secondItxs = copiedThing.get('secondLsThings')
		secondItxs.each (itx) =>
			@resetClonedAttrs(itx)
			itxStates = itx.get('lsStates')
			@resetStatesAndVals itxStates
		copiedThing

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

##END COPY PASTE

#TODO: This was copied and pasted from client ThingInteraction.coffee and then window was changed to export
class ThingItx extends Backbone.Model
	className: "ThingItx"

	defaults: () =>
		@set lsType: "interaction"
		@set lsKind: "interaction"
		@set lsTypeAndKind: @_lsTypeAndKind()
		@set lsStates: new StateList()
		@set recordedBy: AppLaunchParams.loginUser.username
		@set recordedDate: new Date().getTime()

	_lsTypeAndKind: ->
		@get('lsType') + '_' + @get('lsKind')

	initialize: ->
		@set @parse(@attributes)

	parse: (resp) =>
		if resp.lsStates?
			if resp.lsStates not instanceof StateList
				resp.lsStates = new StateList(resp.lsStates)
			resp.lsStates.on 'change', =>
				@trigger 'change'
		resp

	reformatBeforeSaving: =>
		if @attributes.attributes?
			delete @attributes.attributes
		for i of @attributes
			if _.isFunction(@attributes[i])
				delete @attributes[i]
			else if !isNaN(i)
				delete @attributes[i]

		delete @attributes._changing
		delete @attributes._previousAttributes
		delete @attributes.cid
		delete @attributes.changed
		delete @attributes._pending
		delete @attributes.collection

class FirstThingItx extends ThingItx
	className: "FirstThingItx"

	defaults: () =>
		super()
		@set firstLsThing: {}

	setItxThing: (thing) =>
		@set firstLsThing: thing

class SecondThingItx extends ThingItx
	className: "SecondThingItx"

	defaults: () =>
		super()
		@set secondLsThing: {}

	setItxThing: (thing) =>
		@set secondLsThing: thing

class LsThingItxList extends Backbone.Collection
	getItxByTypeAndKind: (type, kind) ->
		@filter (itx) ->
			(not itx.get('ignored')) and (itx.get('lsType')==type) and (itx.get('lsKind')==kind)

	createItxByTypeAndKind: (itxType, itxKind) ->
		itx = new @model
			lsType: itxType
			lsKind: itxKind
			lsTypeAndKind: "#{itxType}_#{itxKind}"
		@.add itx
		itx.on 'change', =>
			@trigger('change')
		return itx

	getItxByItxThingTypeAndKind: (itxType, itxKind, itxThing, itxThingType, itxThingKind) ->
#function for getting first/second lsThing by it's type and kind
#example itxThing: firstLsThing, secondLsThing
		itxArray = @getItxByTypeAndKind(itxType, itxKind)
		itxByItxThing = _.filter itxArray, (itx) ->
			if itx.get(itxThing) instanceof Backbone.Model
				(itx.get(itxThing).get('lsType') == itxThingType) and (itx.get(itxThing).get('lsKind') == itxThingKind)
			else
				(itx.get(itxThing).lsType == itxThingType) and (itx.get(itxThing).lsKind == itxThingKind)
		return itxByItxThing

	getOrderedItxList: (type, kind) ->
		itxs = @getItxByTypeAndKind(type, kind)
		orderedItx = []
		i = 1
		while i <= itxs.length
			nextItx =  _.filter itxs, (itx) ->
				order = itx.get('lsStates').getOrCreateValueByTypeAndKind 'metadata', 'composition', 'numericValue', 'order'
				order.get('numericValue') == i
			orderedItx.push nextItx...
			i++
		orderedItx

	reformatBeforeSaving: =>
		@each((model) ->
			model.reformatBeforeSaving()
		)

class FirstLsThingItxList extends LsThingItxList
	model: FirstThingItx

class SecondLsThingItxList extends LsThingItxList
	model: SecondThingItx


#TODO: This was copied and pasted from client Container.coffee and then window was changed to export
class Container extends Backbone.Model
	lsProperties: {}
	className: "Container"

	defaults: () =>
#attrs =
		@set lsType: "container"
		@set lsKind: "container"
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
				unit = matchedKeyValues["#{key}Unit"]
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

##END COPY PASTE


class ContainerPlate extends Container
	urlRoot: "/api/containers"

	initialize: ->
		@.set
			lsType: "container"
			lsKind: "plate"
		super()

	lsProperties:
		defaultLabels: [
			key: 'barcode'
			type: 'barcode'
			kind: 'barcode'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'description'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'stringValue'
			kind: 'description'
		,
			key: 'status'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'codeValue'
			kind: 'status'
		,
			key: 'createdUser'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'codeValue'
			kind: 'created user'
		,
			key: 'createdDate'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'dateValue'
			kind: 'created date'
		,
			key: 'supplier'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'codeValue'
			kind: 'supplier'
		,
			key: 'type'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'codeValue'
			kind: 'type'
		]

	defaultFirstLsThingItx: []

	defaultSecondLsThingItx: []

class DefinitionContainerPlate extends Container
	urlRoot: "/api/containers"

	initialize: ->
		@.set
			lsType: "definition container"
			lsKind: "plate"
		super()

	lsProperties:
		defaultLabels: [
			key: 'name'
			type: 'name'
			kind: 'model'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'plateSize'
			stateType: 'constants'
			stateKind: 'format'
			type: 'numericValue'
			kind: 'wells'
		,
			key: 'numberOfRows'
			stateType: 'constants'
			stateKind: 'format'
			type: 'numericValue'
			kind: 'rows'
		,
			key: 'numberOfColumns'
			stateType: 'constants'
			stateKind: 'format'
			type: 'numericValue'
			kind: 'columns'
		,
			key: 'subContainerNamingConvention'
			stateType: 'constants'
			stateKind: 'format'
			type: 'codeValue'
			kind: 'A1'
		,
			key: 'maxWellVolume'
			stateType: 'constants'
			stateKind: 'format'
			type: 'numericValue'
			kind: 'max well volume'
		]

	defaultFirstLsThingItx: []

	defaultSecondLsThingItx: []

class ContainerTube extends ContainerPlate
	urlRoot: "/api/containers"

	initialize: ->
		@.set
			lsType: "container"
			lsKind: "tube"
		@.set @parse(@.attributes)

	lsProperties:
		defaultLabels: [
			key: 'barcode'
			type: 'barcode'
			kind: 'barcode'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'description'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'stringValue'
			kind: 'description'
		,
			key: 'status'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'codeValue'
			kind: 'status'
		,
			key: 'createdUser'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'codeValue'
			kind: 'created user'
		,
			key: 'createdDate'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'dateValue'
			kind: 'created date'
		,
			key: 'supplier'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'codeValue'
			kind: 'supplier'
		,
			key: 'type'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'codeValue'
			kind: 'type'
		]

exports.Label = Label
exports.LabelList = LabelList
exports.Value = Value
exports.Value = Value
exports.ValueList = ValueList
exports.State = State
exports.StateList = StateList
exports.Thing = Thing
exports.ThingItx = ThingItx
exports.FirstThingItx = FirstThingItx
exports.SecondThingItx = SecondThingItx
exports.FirstThingItx = FirstThingItx
exports.LsThingItxList = LsThingItxList
exports.FirstLsThingItxList = FirstLsThingItxList
exports.SecondLsThingItxList = SecondLsThingItxList
exports.Container = Container
exports.DefinitionContainerPlate = DefinitionContainerPlate
exports.ContainerPlate = ContainerPlate
exports.ContainerTube = ContainerTube


AppLaunchParams = loginUser:username:"acas"