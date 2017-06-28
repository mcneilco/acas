exports.setupRoutes = (app, loginRoutes) ->
	app.get '/components/ACASFormChemicalRegStructure', loginRoutes.ensureAuthenticated, exports.aCASFormChemicalRegStructureIndex
	app.get '/components/ACASFormChemicalSearchStructure', loginRoutes.ensureAuthenticated, exports.aCASFormChemicalSearchStructureIndex
	app.get '/components/ACASFormChemicalRegStructureJSME', loginRoutes.ensureAuthenticated, exports.aCASFormChemicalRegStructureJSMEIndex
	app.get '/components/ACASFormChemicalSearchStructureJSME', loginRoutes.ensureAuthenticated, exports.aCASFormChemicalSearchStructureJSMEIndex


exports.aCASFormChemicalRegStructureIndex = (req, res) ->
	return res.render 'ACASFormChemicalRegStructure',
		title: "ACASFormChemicalRegStructure.jade"

exports.aCASFormChemicalSearchStructureIndex = (req, res) ->
	return res.render 'ACASFormChemicalSearchStructure',
		title: "ACASFormChemicalSearchStructure.jade"

exports.aCASFormChemicalRegStructureJSMEIndex = (req, res) ->
	return res.render 'ACASFormChemicalRegStructureJSME',
		title: "ACASFormChemicalRegStructureJSME.jade"

exports.aCASFormChemicalSearchStructureJSMEIndex = (req, res) ->
	return res.render 'ACASFormChemicalSearchStructureJSME',
		title: "ACASFormChemicalSearchStructureJSME.jade"

