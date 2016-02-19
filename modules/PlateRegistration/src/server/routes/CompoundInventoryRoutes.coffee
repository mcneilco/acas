_ = require('lodash')

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/compoundInventory', loginRoutes.ensureAuthenticated, exports.compoundInventoryIndex
	app.get '/compoundInventorySpecRunner', loginRoutes.ensureAuthenticated, exports.compoundInventorySpecRunner
	app.post '/api/validateIdentifiers', loginRoutes.ensureAuthenticated, exports.validateIdentifiers

exports.compoundInventoryIndex = (req, resp) ->
	return resp.render 'PlateRegistration',
		title: 'Plate Registration'

exports.compoundInventorySpecRunner = (req, resp) ->
	return resp.render 'PlateRegistrationSpecRunner',
		title: 'Plate Registration SpecRunner'

exports.validateIdentifiers = (req, resp) ->
	if global.specRunnerTestmode
		resp.end JSON.stringify {}
	else
		identifiers = req.body.identifiers.split(",")
		validatedIdentifiers = []
		throwServerError = false
		_.each(identifiers, (identifier) ->
			unless identifier is ""
				if identifier.indexOf('alias') > -1
					validatedIdentifiers.push
						requestName: identifier
						preferredName: identifier + "---aliased"
				else if identifier.indexOf('error') > -1
					validatedIdentifiers.push
						requestName: identifier
						preferredName: ""
				else
					validatedIdentifiers.push
						requestName: identifier
						preferredName: identifier
				if identifier is "barf"
					throwServerError = true
		)

		if throwServerError
			resp.status(500).send('Something broke!')

		else
			resp.setHeader 'Content-Type', 'application/json'
			resp.end JSON.stringify validatedIdentifiers