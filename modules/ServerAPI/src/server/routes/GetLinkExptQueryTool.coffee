exports.setupRoutes = (app, loginRoutes) ->
	app.get '/getLinkExptQueryTool', loginRoutes.ensureAuthenticated, exports.getLinkQueryToolForExperiment


exports.getLinkQueryToolForExperiment = (req, resp) ->
	config = require '../conf/compiled/conf.js'
	tool = req.query.tool
	if not tool?
		tool = config.all.client.service.result.viewer.defaultViewer
		if not tool? 
			tool = 'LiveDesign'
	if tool is 'LiveDesign'
		getLdUrl = require './CreateLiveDesignLiveReportForACAS.js'
		username = req.session.passport.user.username
		getLdUrl.getUrlForNewLiveDesignLiveReportForExperimentInternal req.query.experiment, username, (url) ->
			url = url.replace /(\r\n|\n|\r)/gm,""
			console.log "generating link: #{url}"
			resp.status(200).send url
			# Need to Send This Link Back to UI To Add to Link
	else if tool is 'Seurat'
		expRoutes = require './ExperimentServiceRoutes.js'
		expRoutes.resultViewerURLFromExperimentCodeName req.query.experiment, (err, res) ->
			if err? or not res.resultViewerURL?
				resp.status(404).send "Could not get Seurat link"
			else
				resp.status(200).send res.resultViewerURL
	else if tool is 'DataViewer'
		url = '/dataViewer/filterByExpt/'+req.query.experiment
		url = url.replace /(\r\n|\n|\r)/gm,""
		console.log "generating link:  #{url}"
		resp.status(200).send '/dataViewer/filterByExpt/'+req.query.experiment
	else if tool is 'CurveCurator'
		url = '/curveCurator/'+encodeURIComponent(req.query.experiment)
		resp.status(200).send url
	else
		resp.status(500).send('Could not generate any valid links')