exports.setupRoutes = (app, loginRoutes) ->
	app.get '/openExptInQueryTool', loginRoutes.ensureAuthenticated, exports.redirectToQueryToolForExperiment


exports.redirectToQueryToolForExperiment = (req, resp) ->
	config = require '../conf/compiled/conf.js'
	request = require 'request'

# params: {"tool": "Seurat", "experiment": "EXPT-00001", "protocol": "PROT-00001"}
	tool = req.query.tool

	if not tool?
		tool = config.all.client.service.result.viewer.defaultViewer
		if not tool? #default may later change to Simple SAR
			tool = 'Seurat'
	if tool is 'LiveDesign'
		#resp.redirect '/api/redirectToNewLiveDesignLiveReportForExperiment/' + req.query.experiment
		getLdUrl = require './CreateLiveDesignLiveReportForACAS.js'
		getLdUrl.getUrlForNewLiveDesignLiveReportForExperiment req.query.experiment, (url) ->
			resp.redirect url
	else if tool is 'Seurat'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/codename/"+req.query.experiment
		request.get
			url: baseurl
			json: true
		, (error, response, body) =>
			if error or response.statusCode >= 300
				resp.status(500).send('error getting experiment')
			else
				console.log body
				#TODO: this does not work yet
				Experiment = require('')
				expt = new Experiment body
				prefExptName = expt.pickBestName()
				prot = new Protocol expt.protocol
				prefProtName = prot.pickBestName()
				resp.redirect config.all.client.service.result.viewer.seurat.protocolPrefix + prefExptName +
						config.all.client.service.result.viewer.seurat.experimentPrefix + prefProtName
	else
    # Could later add customer specific call here
		resp.status(500).send('Invalid viewer tool')