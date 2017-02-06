exports.setupAPIRoutes = (app) ->
	app.post '/api/entityReviewRequestNotification', exports.exptReadyForReviewNotification

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/authors', loginRoutes.ensureAuthenticated, exports.getAuthors
	app.post '/api/entityReviewRequestNotification', loginRoutes.ensureAuthenticated, exports.exptReadyForReviewNotification

exports.getAuthors = (req, resp) ->
	console.log "getting authors"
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		baseEntityServiceTestJSON = require '../public/javascripts/spec/testFixtures/BaseEntityServiceTestJSON.js'
		resp.end JSON.stringify baseEntityServiceTestJSON.authorsList
	else
		csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
		csUtilities.getAuthors req, resp

exports.exptReadyForReviewNotification = (request, response)  ->
	request.connection.setTimeout 600000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});
	if global.specRunnerTestmode
		console.log "test mode: "+global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"src/r/ELN/ExptReadyForReviewNotification.R",
			"deleteComponentRequestNotification",
			(rReturn) ->
				response.end rReturn
		)
	else
		authorRoutes = require './AuthorRoutes.js'
		console.log "getting username in exptReadyForReviewNotification"
		console.log request.body.userName
		authorRoutes.getAuthorByUsernameInternal request.body.reviewer, (json, statusCode) =>
			console.log "author"
			console.log json
			console.log request.body
			request.body.reviewerEmail = json.emailAddress
			console.log request.body
			serverUtilityFunctions.runRFunction(
				request,
				"src/r/ELN/ExptReadyForReviewNotification.R",
				"exptReadyForReviewNotification",
				(rReturn) ->
					response.end rReturn
			)
