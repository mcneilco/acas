exports.setupRoutes = (app, loginRoutes) ->
	app.get '/compoundInventory', loginRoutes.ensureAuthenticated, exports.compoundInventoryIndex
	app.get '/compoundInventorySpecRunner', loginRoutes.ensureAuthenticated, exports.compoundInventorySpecRunner

exports.compoundInventoryIndex = (req, resp) ->
	return resp.render 'PlateRegistration',
		title: 'Plate Registration'

exports.compoundInventorySpecRunner = (req, resp) ->
	return resp.render 'PlateRegistrationSpecRunner',
		title: 'Plate Registration SpecRunner'