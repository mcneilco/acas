exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/redirectToNewLiveDesignLiveReportForExperiment/:experimentCode', loginRoutes.ensureAuthenticated, exports.redirectToNewLiveDesignLiveReportForExperiment


exports.redirectToNewLiveDesignLiveReportForExperiment = (req, resp) ->
  exptCode = req.params.experimentCode
  exports.getUrlForNewLiveDesignLiveReportForExperiment exptCode, (url) ->
	  resp.redirect url



exports.getUrlForNewLiveDesignLiveReportForExperiment = (exptCode, callback) ->
  exec = require('child_process').exec
  config = require '../conf/compiled/conf.js'
  request = require 'request'

  request.get
    url: config.all.client.service.rapache.fullpath+"ServerAPI/getCmpdAndResultType?experiment="+exptCode
    json: true
  , (error, response, body) =>

    serverError = error
    exptInfo = body
    console.log @responseJSON


    command = "./public/src/modules/ServerAPI/src/server/createLiveDesignLiveReportForACAS/create_lr_for_acas.py -e "
    command += "'"+config.all.client.service.result.viewer.liveDesign.baseUrl+"' -u '"+config.all.client.service.result.viewer.liveDesign.username+"' -p '"+config.all.client.service.result.viewer.liveDesign.password+"' -i '"
    #		data = {"compounds":["V035000","CMPD-0000002"],"assays":[{"protocolName":"Target Y binding","resultType":"curve id"}]}
    #		command += (JSON.stringify data)+"'"
    command += (JSON.stringify exptInfo)+"'"
    console.log "About to call python using command: "+command

    child = exec command,  (error, stdout, stderr) ->
      reportURLPos = stdout.indexOf "https://"
      reportURL = stdout.substr reportURLPos
      console.log "stderr: " + stderr
      console.log "stdout: " + stdout

      callback reportURL



