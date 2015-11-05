exports.setupRoutes = (app, loginRoutes) ->
	app.get '/openExptInQueryTool', loginRoutes.ensureAuthenticated, exports.redirectToQueryToolForExperiment


exports.redirectToQueryToolForExperiment = (req, resp) ->
	config = require '../conf/compiled/conf.js'

# params: {"tool": "Seurat", "experiment": "EXPT-00001", "protocol": "PROT-00001"}
	tool = req.query.tool

	if not tool?
		tool = config.all.client.service.result.viewer.defaultViewer
		if not tool? #default may later change to Simple SAR
			tool = 'DataViewer'
	if tool is 'LiveDesign'
		#resp.redirect '/api/redirectToNewLiveDesignLiveReportForExperiment/' + req.query.experiment
		getLdUrl = require './CreateLiveDesignLiveReportForACAS.js'
		getLdUrl.getUrlForNewLiveDesignLiveReportForExperiment req.query.experiment, (url) ->
			resp.redirect url
	else if tool is 'Seurat'
		expRoutes = require './ExperimentServiceRoutes.js'
		expRoutes.resultViewerURLFromExperimentCodeName req.query.experiment, (err, res) ->
			if err? or not res.resultViewerURL?
				resp.status(404).send "Could not get Seurat link"
			else
				resp.redirect res.resultViewerURL
	else if tool is 'DataViewer'
		resp.redirect '/dataViewer/filterByExpt/'+req.query.experiment
	else
    # Could later add customer specific call here
		resp.status(500).send('Invalid viewer tool')