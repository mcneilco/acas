exports.setupAPIRoutes = (app) ->
	app.get '/api/entitymeta/configuredEntityTypes', exports.getConfiguredEntityTypes
	app.post '/api/entitymeta/preferredCodes', exports.preferredCodes

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/entitymeta/configuredEntityTypes', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypes
	app.post '/api/entitymeta/preferredCodes', loginRoutes.ensureAuthenticated, exports.preferredCodes

configuredEntityTypes = require '../conf/ConfiguredEntityTypes.js'

exports.getConfiguredEntityTypes = (req, resp) ->
	if req.query.asCodes?
		codes = for et in configuredEntityTypes.entityTypes
			code: et.type+" "+et.kind #Should we store this explicitly in the config?
			name: et.displayName
			ignored: false
		resp.json codes
	else
		resp.json configuredEntityTypes.entityTypes

exports.preferredCodes = (req, resp) ->
	if req.body.type is "compound"
		if req.body.kind is "batch name"
			preferredBatchService = require "./PreferredBatchIdService.js"
			reqLines = formatCSVRequestAsReqArray(req.body.entityIdStringLines)
			preferredBatchService.getPreferredCompoundBatchIDs reqLines , (prefResp) ->
				preferreds = JSON.parse(prefResp).results
				outStr =  "Requested Name,Preferred Code\n"
				for pref in preferreds
					outStr += pref.requestName + ',' + pref.preferredName + '\n'
				resp.json resultCSV: outStr
			return
#	else
#		entityType = configuredEntityTypes.entityTypes. where type: req.body.type, kind: req.body.kind
#		if entityType.codeOrgin is "ACAS LSThing"
#			preferredThingService = require "./ThingServiceRoutes.js"


	if global.specRunnerTestmode
		if req.body.type.indexOf('ERROR') > -1
			resp.statusCode = 500
			resp.end "problem with propery request, check log"
			return

		out = for name in req.body.entityIdStringLines.split('\n')
			name + "," + if name.indexOf('ERROR') < 0 then name else ""

		outStr =  "Requested Name,Preferred Code\n"+out.join('\n')
		resp.json resultCSV: outStr

	else
		console.log "preferredCodes not implemented"


formatCSVRequestAsReqArray = (csvReq) ->
	requests = []
	for req in csvReq.split '\n'
		requests.push requestName: req

	return requests
