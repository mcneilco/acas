exports.setupAPIRoutes = (app) ->
	app.post '/api/testedEntities/properties', exports.testedEntityProperties

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/testedEntities/properties', loginRoutes.ensureAuthenticated, exports.testedEntityProperties

exports.testedEntityProperties = (req, resp) ->
	csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'

	if global.specRunnerTestmode
		if req.body.properties.indexOf('ERROR') > -1
			resp.statusCode = 500
			resp.end "problem with propery request, check log"


		ents = req.body.entityIdStringLines.split '\n'
		console.log ents
		out = "id,"
		for prop in req.body.properties
			out += prop+","
		out = out.slice(0,-1) + '\n'
		for i in [0..ents.length-2]
			out += ents[i]+","
			j=0
			for prop2 in req.body.properties
				if ents[i].indexOf('ERROR') < 0 then out += i + j++
				else out += ""
				out += ','
			out = out.slice(0,-1) + '\n'

		resp.json resultCSV:out
	else
		csUtilities.getTestedEntityProperties req.body.properties, req.body.entityIdStringLines, (properties) ->
			if properties?
				resp.json resultCSV: properties
			else
				resp.statusCode = 500
				resp.end "problem with propery request, check log"
