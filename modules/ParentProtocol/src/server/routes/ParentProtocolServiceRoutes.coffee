exports.setupAPIRoutes = (app) ->
	app.get '/api/protocols/codetable', exports.getProtocolCodeTableValues
	app.get '/api/getItxProtProtsByFirstProt/:getItxProtProtsByFirstProt', exports.getItxProtProtsByFirstProt
	app.post '/api/postProtProtItxs', exports.postProtProtItxs
	app.put '/api/putProtProtItxs', exports.putProtProtItxs
	app.post '/api/protocols/getByCodeNamesArray', exports.protocolsByCodeNamesArray

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/protocols/codetable', loginRoutes.ensureAuthenticated, exports.getProtocolCodeTableValues
	app.get '/api/protocols/parentProtocol/:id', loginRoutes.ensureAuthenticated, exports.getParentProtocolById
	app.get '/api/protocols/parentProtocol/codename/:codename', loginRoutes.ensureAuthenticated, exports.getParentProtocolByCodeName
	app.post '/api/protocols/parentProtocol', loginRoutes.ensureAuthenticated, exports.postParentProtocol
	app.put '/api/protocols/parentProtocol/:id', loginRoutes.ensureAuthenticated, exports.putParentProtocol
	app.get '/api/getItxProtProtsByFirstProt/:getItxProtProtsByFirstProt', loginRoutes.ensureAuthenticated, exports.getItxProtProtsByFirstProt
	app.post '/api/postProtProtItxs', loginRoutes.ensureAuthenticated, exports.postProtProtItxs
	app.put '/api/putProtProtItxs', loginRoutes.ensureAuthenticated, exports.putProtProtItxs
	app.post '/api/protocols/getByCodeNamesArray', loginRoutes.ensureAuthenticated, exports.protocolsByCodeNamesArray

_ = require 'underscore'

exports.getProtocolCodeTableValues = (req, resp) ->
	if global.specRunnerTestmode
		console.debug process.cwd()
		codeTableServiceTestJSON = require '../public/javascripts/spec/ParentProtocol/testFixtures/ProtocolListCodeTableTestJSON.js'
		resp.end JSON.stringify codeTableServiceTestJSON['protocolCodes']
	else
		config = require '../conf/compiled/conf.js'
		baseurl = "#{config.all.client.service.persistence.fullpath}protocols/codetable"
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.error 'got ajax error trying to get all protocol code tables'
				console.error error
				console.error json
				console.error response
				resp.status(500).send "got ajax error"
		)

exports.getParentProtocolById = (req, resp) ->
	if global.specRunnerTestmode
		ParentProtocol = require '../public/javascripts/spec/ParentProtocol/testFixtures/ParentProtocolServiceTestJSON.js'
		resp.end JSON.stringify ParentProtocol['savedParentProtocol']
	else
		config = require '../conf/compiled/conf.js'
		url = config.all.client.service.persistence.fullpath+"protocols/"+req.params.id
		if req.query.childProtocols? and req.query.childProtocols=="fullObject" #ie has '?childProtocols=fullObject' appended to end of api route
			childProtocolFormat = "fullObject"
		else
			childProtocolFormat = "stub"
		getProtocolByIdOrCodename url, childProtocolFormat, resp

exports.getParentProtocolByCodeName = (req, resp) ->
	if global.specRunnerTestmode
		parentProtocol = require '../public/javascripts/spec/ParentProtocol/testFixtures/ParentProtocolServiceTestJSON.js'
		resp.end JSON.stringify parentProtocol['savedParentProtocol']
	else
		config = require '../conf/compiled/conf.js'
		url = config.all.client.service.persistence.fullpath+"protocols/codename/"+req.params.codename
		if req.query.childProtocols? and req.query.childProtocols=="fullObject" #ie has '?childProtocols=fullObject' appended to end of api route
			childProtocolFormat = "fullObject"
		else
			childProtocolFormat = "stub"
		getProtocolByIdOrCodename url, childProtocolFormat, resp

# TODO: fill in childProtocols
# TODO: add option to return childProtocols in full object (with states) format or with just min info for ParentProtocol View (ACASDEV-771)

getProtocolByIdOrCodename = (getUrl, childProtocolFormat, resp) ->
	request = require 'request'
	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		stubSavedProtocol = JSON.parse(JSON.stringify(protocolServiceTestJSON.stubSavedProtocol))
		return stubSavedProtocol
	else
		request
			url: getUrl
			json: true
		, (error, response, json) =>
				if !error
					if response?.statusCode is 200
#						callback null, json
						mainProtocol = json
						getItxProtProtsByFirstProt json.id, (protProtItxs) ->
							if protProtItxs.indexOf("Failed") > -1
								resp.statusCode = 500
								resp.end protProtItxs
							else
								#filter out the ignored
								console.log "protProtItxs"
								console.log protProtItxs
								protProtItxs = _.filter JSON.parse(protProtItxs), (itx) ->
									!itx.ignored
								console.log "filteredProtProtItxs"
								console.log protProtItxs
								if childProtocolFormat is "fullObject"
									childProtocols = _.map protProtItxs, (interaction) ->
										console.log "child protocol itx"
										console.log interaction
										itxId: interaction.id
										secondProtId: interaction.secondProtocol.id
										secondProtCodeName: interaction.secondProtocol.codeName
										ignored: interaction.ignored
#										secondProtocol: interaction.secondProtocol
										recordedBy: interaction.recordedBy
										recordedDate: interaction.recordedDate

									#get states and labels for childProtocols
									childProtocolCodeNames = _.map protProtItxs, (interaction) ->
										interaction.secondProtocol.codeName
									console.log "childProtocolCodeNames"
									console.log childProtocolCodeNames
									protocolsByCodeNamesArray childProtocolCodeNames, "fullobject", false, (returnedProts) ->
										_.each childProtocols, (protItx) ->
											secondProtInfo = _.where(returnedProts, protocolCodeName: protItx.secondProtCodeName)[0]
											protItx.secondProtocol = secondProtInfo.protocol
											console.log returnedProts
											console.log "secondProtInfo"
											console.log secondProtInfo
											console.log "protItx"
											console.log protItx
										mainProtocol.childProtocols = childProtocols
										resp.json mainProtocol

								else
									childProtocols = _.map protProtItxs, (interaction) ->
										console.log "child protocol itx"
										console.log interaction
										itxId: interaction.id
										secondProtId: interaction.secondProtocol.id
										secondProtCodeName: interaction.secondProtocol.codeName
										ignored: interaction.ignored
										recordedBy: interaction.recordedBy
										recordedDate: interaction.recordedDate
									mainProtocol.childProtocols = childProtocols
									resp.json mainProtocol

					else
						resp.statusCode = 500
						resp.end "got ajax error on " + getUrl
				else
					resp.statusCode = 500
					resp.end error

exports.postParentProtocol = (req, resp) ->
	if global.specRunnerTestmode
		ParentProtocol = require '../public/javascripts/spec/ParentProtocol/testFixtures/ParentProtocolServiceTestJSON.js'
		resp.end JSON.stringify ParentProtocol['savedParentProtocol']
	else
		config = require '../conf/compiled/conf.js'
		request = require 'request'
		async = require 'async'
		_ = require 'underscore'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'

		firstProtocol = req.body
		serverUtilityFunctions.createLSTransaction firstProtocol.recordedDate, "new protocol", (transaction) ->
			firstProtocol = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, firstProtocol
			url = config.all.client.service.persistence.fullpath+"protocols/"
#			interactionUrl = config.all.client.service.persistence.fullpath+"itxprotocolprotocols/jsonArray"

			secondProtocolList = req.body.childProtocols
			delete firstProtocol.subclass
			delete firstProtocol.childProtocols

			request.post
				url: url
				json: firstProtocol
			, (error, response, json) =>
				if !error && response.statusCode == 201
					mainProtocol = json
					interactionList = _.map secondProtocolList, (sProtocol) ->
						firstProtocol: {'id': mainProtocol.id},
						secondProtocol: {'id': sProtocol.secondProtId},
						lsType: "has member",
						lsKind: "collection member"
						recordedBy: sProtocol.recordedBy
						recordedDate: sProtocol.recordedDate

					postProtProtItxs interactionList, req.query.testMode, (newProtProtItxs) ->
						if newProtProtItxs.indexOf("saveFailed") > -1
							resp.statusCode = 500
							resp.json newProtProtItxs
						else
							childProtocols = _.filter newProtProtItxs, (interaction) ->
								!interaction.ignored
							childProtocols = _.map childProtocols, (interaction) ->
								itxId: interaction.id,
								secondProtId: interaction.secondProtocol.id
								secondProtCodeName: interaction.secondProtocol.codeName
								ignored: interaction.ignored
								recordedBy: interaction.recordedBy
								recordedDate: interaction.recordedDate
							mainProtocol.childProtocols = childProtocols
							resp.json mainProtocol
				else
					console.error 'got ajax error with ' + url
					console.error "posted: " + JSON.stringify firstProtocol
					console.error "status code: " + response.statusCode
					console.error "error message: " + error
					console.error json
					resp.status(500).send "got ajax error"


exports.putParentProtocol = (req, resp) ->
	if global.specRunnerTestmode
		ParentProtocol = require '../public/javascripts/spec/ParentProtocol/testFixtures/ParentProtocolServiceTestJSON.js'
		resp.end JSON.stringify ParentProtocol['savedParentProtocol']
	else
		config = require '../conf/compiled/conf.js'
		request = require 'request'
		async = require 'async'
		_ = require 'underscore'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'

		firstProtocol = req.body
		serverUtilityFunctions.createLSTransaction firstProtocol.recordedDate, "updated protocol", (transaction) ->
			firstProtocol = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, firstProtocol
			url = config.all.client.service.persistence.fullpath+"protocols/"
#			interactionUrl = config.all.client.service.persistence.fullpath+"itxprotocolprotocols/jsonArray"

			secondProtocolItxList = req.body.childProtocols
			delete firstProtocol.subclass
			delete firstProtocol.childProtocols
			itxsToPost = []
			itxsToPut = []
			_.each secondProtocolItxList, (secondProtItx) =>
				if secondProtItx.itxId?
					itxsToPut.push
						firstProtocol: {'id': firstProtocol.id},
						secondProtocol: {'id': secondProtItx.secondProtId},
						id: secondProtItx.itxId
						lsType: "has member"
						lsKind: "collection member"
						ignored: secondProtItx.ignored
						recordedBy: secondProtItx.recordedBy
						recordedDate: secondProtItx.recordedDate

				else
					itxsToPost.push
						firstProtocol: {'id': firstProtocol.id},
						secondProtocol: {'id': secondProtItx.secondProtId},
						lsType: "has member",
						lsKind: "collection member"
						recordedBy: secondProtItx.recordedBy
						recordedDate: secondProtItx.recordedDate


			request.put
				url: url
				json: firstProtocol
			, (error, response, json) =>
				console.log "put first protocol"
				console.log json
				console.log response.statusCode
				if !error && response.statusCode == 200
					console.log "itxsToPost"
					console.log itxsToPost
					console.log "itxsToPut"
					console.log itxsToPut
					mainProtocol = json
					putProtProtItxs itxsToPut, req.query.testMode, (updatedProtProtItxs) ->
						if updatedProtProtItxs.indexOf("saveFailed") > -1
							resp.statusCode = 500
							resp.json updatedProtProtItxs
						else
							updatedChildProtocols = _.map updatedProtProtItxs, (interaction) ->
								itxId: interaction.id,
								secondProtId: interaction.secondProtocol.id
								secondProtCodeName: interaction.secondProtocol.codeName
								ignored: interaction.ignored
							mainProtocol.childProtocols = updatedChildProtocols

							postProtProtItxs itxsToPost, req.query.testMode, (newProtProtItxs) ->
								if newProtProtItxs.indexOf("saveFailed") > -1
									resp.statusCode = 500
									resp.json newProtProtItxs
								else
									newChildProtocols = _.map newProtProtItxs, (interaction) ->
										itxId: interaction.id,
										secondProtId: interaction.secondProtocol.id
										secondProtCodeName: interaction.secondProtocol.codeName
										ignored: interaction.ignored
									console.log "newChildProtocols"
									console.log newChildProtocols
									mainProtocol.childProtocols.push newChildProtocols...
									console.log "mainProtocol.childProtocols after concat"
									console.log mainProtocol.childProtocols
									resp.json mainProtocol

getItxProtProtsByFirstProt = (firstProtId, callback) ->
	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		callback JSON.stringify [protocolServiceTestJSON.fullSavedProtocol, protocolServiceTestJSON.fullDeletedProtocol]
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxprotocolprotocols/findByFirstProtocol/"+firstProtId
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback JSON.stringify json
			else
				console.log 'got ajax error'
				console.log error
				console.log json
				console.log response
				callback JSON.stringify "Failed: Could not get prot prot itx by first prot from ACAS Server"
		)

exports.getItxProtProtsByFirstProt = (req, resp) ->
	getItxProtProtsByFirstProt req.params.firstProtId, (protProtItxs) ->
		if protProtItxs.indexOf("Failed") > -1
			resp.statusCode = 500
		resp.end protProtItxs

postProtProtItxs = (protProtItxs, testMode, callback) ->
	if testMode or global.specRunnerTestmode
		callback JSON.stringify "stubsMode not implemented"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxprotocolprotocols/jsonArray"
		console.log "post prot prot itx body"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: protProtItxs
			json: true
		, (error, response, json) =>
			console.log "postProtProtItxs json"
			console.log json
			console.log "response.statusCode"
			console.log response.statusCode
			console.log response
			if !error && response.statusCode == 201
				callback json
			else
				console.log "got error posting prot prot itxs"
				callback "posttProtProtItxs saveFailed: " + JSON.stringify error
		)


exports.postProtProtItxs = (req, resp) ->
	postProtProtItxs req.body, req.query.testMode, (newProtProtItxs) ->
		if newProtProtItxs.indexOf("saveFailed") > -1
			resp.statusCode = 500
		resp.json newProtProtItxs

putProtProtItxs = (protProtItxs, testMode, callback) ->
	if testMode or global.specRunnerTestmode
		callback JSON.stringify "stubsMode not implemented"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxprotocolprotocols/jsonArray"
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: protProtItxs
			json: true
		, (error, response, json) =>
			console.log "protProtItxs json"
			console.log json
			console.log "response.statusCode"
			console.log response.statusCode
			console.log response
			if !error && response.statusCode == 200
				callback json
			else
				console.log "got error putting prot prot itxs"
				callback "putProtProtItxs saveFailed: " + JSON.stringify error
		)

exports.putExptExptItxs = (req, resp) ->
	putExptExptItxs req.body, req.query.testMode, (updatedExptExptItxs) ->
		if updatedExptExptItxs.indexOf("saveFailed") > -1
			resp.statusCode = 500
		resp.json updatedExptExptItxs

exports.protocolsByCodeNamesArray = (req, resp) ->
	protocolsByCodeNamesArray req.body.data, req.query.option, req.query.testMode, (returnedProts) ->
		if returnedProts.indexOf("Failed") > -1
			resp.statusCode = 500
		resp.json returnedProts


protocolsByCodeNamesArray = (codeNamesArray, returnOption, testMode, callback) ->
	if testMode or global.specRunnerTestmode
		callback JSON.stringify "stubsMode not implemented"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocols/codename/jsonArray"
		#returnOption are analysisgroups, analysisgroupstates, analysisgroupvalues, fullobject, prettyjson, prettyjsonstub, stubwithprot, and stub
		if returnOption?
			baseurl += "?with=#{returnOption}"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: codeNamesArray
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.log "Failed: got error in bulk get of protocols"
				callback "Bulk get protocols saveFailed: " + JSON.stringify error
		)

