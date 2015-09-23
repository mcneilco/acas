exports.setupAPIRoutes = (app) ->
	app.post '/api/testedEntities/properties', exports.testedEntityPropertiesRoute
	app.get '/api/:entityType/:entityKind/property/descriptors', exports.entityPropertyDescriptors
	app.post '/api/:entityType/:entityKind/properties/:format?', exports.entityPropertiesRoute

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/testedEntities/properties', loginRoutes.ensureAuthenticated, exports.testedEntityProperties
	app.get '/api/:entityType/:entityKind/property/descriptors', loginRoutes.ensureAuthenticated, exports.entityPropertyDescriptors
	app.post '/api/:entityType/:entityKind/properties/:format?', loginRoutes.ensureAuthenticated, exports.entityPropertiesRoute

exports.entityPropertiesRoute = (req, resp) ->
	exports.entityProperties req.params.entityType, req.params.entityKind, req.body.entityCodeList, req.body.propertyNameList, req.params.format, (json) ->
		if json.indexOf('problem with property request') > -1
			resp.statusCode = 500
		else
			resp.json json

exports.entityProperties = (entityType, entityKind, entityCodeList, propertyNameList, format, callback) ->
	#Default format if not provided is json
	if !format?
		format = "json"

	csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
	if global.specRunnerTestmode
		if JSON.stringify(propertyNameList).indexOf('ERROR') > -1
			callback "problem with property request, check log"

		response = []
		for entityCode,index in entityCodeList
			entityResponse = {}
			entityResponse.id = entityCode
			for propertyName in propertyNameList
				if entityCode.indexOf("ERROR")
					entityResponse[propertyName] = ""
				else
				entityResponse[propertyName] = 1
			response.push entityResponse

		if format == "csv"
			response =  exports.objectToCSV(response, withHeader = true)
		callback response

	else
		csUtilities.getEntityProperties entityType, entityKind, entityCodeList, propertyNameList, format, callback, (json) ->
			if properties?
				callback properties
			else
				callback "problem with property request, check log"


exports.objectToCSV = (objArray, withHeader) ->
	array = if typeof objArray != 'object' then JSON.parse(objArray) else objArray
	str = ''
	if withHeader
		str += Object.keys(array[0]).join(',') + '\n'
	i = 0
	while i < array.length
		line = ''
		for index of array[i]
			if line != ''
				line += ','
			line += array[i][index]
		str += line + '\n'
		i++
	str

exports.testedEntityPropertiesRoute = (req, resp) ->
	exports.getEntityProperties req.body.properties, req.body.entityIdStringLines, (json) ->
		if JSON.stringify(json).indexOf('problem with property request') > -1
			resp.statusCode = 500
			resp.end "problem with property request, check log"
		else
			resp.json json

exports.getEntityProperties = (properties, entityIdStringLines, callback) ->
	csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
	if global.specRunnerTestmode
		if properties.indexOf('ERROR') > -1
			callback "problem with property request, check log"


		ents = entityIdStringLines.split '\n'
		out = "id,"
		for prop in properties
			out += prop+","
		out = out.slice(0,-1) + '\n'
		for i in [0..ents.length-2]
			out += ents[i]+","
			j=0
			for prop2 in properties
				if ents[i].indexOf('ERROR') < 0 then out += i + j++
				else out += ""
				out += ','
			out = out.slice(0,-1) + '\n'
		callback resultCSV:out
	else
		csUtilities.getTestedEntityProperties properties, entityIdStringLines, (properties) ->
			if properties?
				callback resultCSV: properties
			else
				callback "problem with property request, check log"



exports.entityPropertyDescriptors = (req, resp) ->
	csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
	if global.specRunnerTestmode
		entityDescriptorServiceTestJSON = require "../public/javascripts/spec/testFixtures/EntityPropertyDescriptorsServiceTestJSON.js"
		resp.json entityDescriptorServiceTestJSON.propertyDescriptors[req.params.entityType][req.params.entityKind]
	else
		csUtilities.getEntityPropertyDescriptors req.params.entityType, req.params.entityKind, (descriptorsJSON)->
			resp.json JSON.parse(descriptorsJSON)
