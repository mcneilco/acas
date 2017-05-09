exports.setupRoutes = (app, loginRoutes) ->
	app.get '/components/ACASFormChemicalRegStructure', loginRoutes.ensureAuthenticated, exports.aCASFormChemicalRegStructureIndex
	app.get '/components/ACASFormChemicalSearchStructure', loginRoutes.ensureAuthenticated, exports.aCASFormChemicalSearchStructureIndex


exports.aCASFormChemicalRegStructureIndex = (req, res) ->
	return res.render 'ACASFormChemicalRegStructure',
		title: "ACASFormChemicalRegStructure.jade"

exports.aCASFormChemicalSearchStructureIndex = (req, res) ->
	return res.render 'ACASFormChemicalSearchStructure',
		title: "ACASFormChemicalSearchStructure.jade"
