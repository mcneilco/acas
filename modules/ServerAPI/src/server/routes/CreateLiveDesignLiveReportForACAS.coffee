exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/redirectToNewLiveDesignLiveReportForExperiment/:experimentCode', exports.redirectToNewLiveDesignLiveReportForExperiment
	app.get '/api/getUrlForNewLiveDesignLiveReportForExperiment/:experimentCode', exports.getUrlForNewLiveDesignLiveReportForExperiment
	app.get '/api/getLiveDesignReportContent/:liveDesignReportID', exports.getLiveDesignReportContent
	app.get '/api/getResultViewerURLByExperimentName/:experimentName', exports.getResultViewerURLByExperimentName
	app.get '/api/getLiveReportIDByExperimentName/:experimentName', exports.getLiveReportIDByExperimentName
	app.get '/api/getLiveReportContentByExperimentName/:experimentName', exports.getLiveReportContentByExperimentName
	app.get '/api/writeLiveReportContentToCSVByExperimentName/:experimentName', exports.writeLiveReportContentToCSVByExperimentName
	app.get '/api/installLiveDesignPythonClient', exports.installLiveDesignPythonClient
	app.post '/api/compareLiveReportCsv', exports.compareLiveReportCsv
	app.get '/api/deleteLiveDesignReport/:liveDesignReportID', exports.deleteLiveDesignReport

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/redirectToNewLiveDesignLiveReportForExperiment/:experimentCode', loginRoutes.ensureAuthenticated, exports.redirectToNewLiveDesignLiveReportForExperiment
	app.get '/api/getUrlForNewLiveDesignLiveReportForExperiment/:experimentCode', loginRoutes.ensureAuthenticated, exports.getUrlForNewLiveDesignLiveReportForExperiment
	app.get '/api/getLiveDesignReportContent/:liveDesignReportID', loginRoutes.ensureAuthenticated, exports.getLiveDesignReportContent
	app.get '/api/getResultViewerURLByExperimentName/:experimentName', loginRoutes.ensureAuthenticated, exports.getResultViewerURLByExperimentName
	app.get '/api/getLiveReportIDByExperimentName/:experimentName', loginRoutes.ensureAuthenticated, exports.getLiveReportIDByExperimentName
	app.get '/api/getLiveReportContentByExperimentName/:experimentName', loginRoutes.ensureAuthenticated, exports.getLiveReportContentByExperimentName

config = require '../conf/compiled/conf.js'
request = require 'request'
_ = require 'underscore'

exports.redirectToNewLiveDesignLiveReportForExperiment = (req, resp) ->
  exptCode = req.params.experimentCode
  username = req.user.username
  exports.getUrlForNewLiveDesignLiveReportForExperimentInternal exptCode, username, (url) ->
	  resp.redirect url

exports.getUrlForNewLiveDesignLiveReportForExperiment = (req, resp) ->
  exptCode = req.params.experimentCode
  username = req.user.username
  exports.getUrlForNewLiveDesignLiveReportForExperimentInternal exptCode, (url) ->
	  resp.json {url: url}

exports.getUrlForNewLiveDesignLiveReportForExperimentInternal = (exptCode, username, callback) ->
  exec = require('child_process').exec
  config = require '../conf/compiled/conf.js'
  request = require 'request'

  request.get
    url: config.all.client.service.rapache.fullpath+"ServerAPI/getCmpdAndResultType?experiment="+exptCode
    json: true
  , (error, response, body) =>

    serverError = error
    exptInfo = body
    exptInfo.experimentCode = exptCode
    exptInfo.username = username
    console.log @responseJSON
    #install fresh ldclient
    exports.installLiveDesignPythonClientInternal (statusCode, output) ->
        console.log 'Updated LDClient'
    command = "python ./src/python/ServerAPI/createLiveDesignLiveReportForACAS/create_lr_for_acas.py -e "
    command += "'"+config.all.client.service.result.viewer.liveDesign.baseUrl+"' -u '"+config.all.client.service.result.viewer.liveDesign.username+"' -p '"+config.all.client.service.result.viewer.liveDesign.password+"' -d '"+config.all.client.service.result.viewer.liveDesign.database+"' -i '"
    #		data = {"compounds":["V035000","CMPD-0000002"],"assays":[{"protocolName":"Target Y binding","resultType":"curve id"}]}
    #		command += (JSON.stringify data)+"'"
    command += (JSON.stringify exptInfo)+"'"
    console.log "About to call python using command: "+command

    child = exec command,  (error, stdout, stderr) ->
      reportURLPos = stdout.indexOf config.all.client.service.result.viewer.liveDesign.baseUrl
      reportURL = stdout.substr reportURLPos
      console.log "stderr: " + stderr
      console.log "stdout: " + stdout

      callback reportURL

exports.getLiveDesignReportContent = (req, resp) ->
  liveDesignReportID = req.params.liveDesignReportID
  stripHTML  = req.query.stripHTML != "0"
  exports.getLiveDesignReportContentInternal liveDesignReportID, stripHTML, (content) ->
    resp.header "Content-Disposition", "attachment;filename=#{liveDesignReportID}.csv"
    resp.type "text/csv"
    resp.send(200, content);

exports.getLiveDesignReportContentInternal = (liveDesignReportID, stripHTML, callback) ->
  exec = require('child_process').exec
  config = require '../conf/compiled/conf.js'
  request = require 'request'

  command = "python ./src/python/ServerAPI/export_live_report.py -i #{liveDesignReportID} -e #{config.all.client.service.result.viewer.liveDesign.baseUrl} -u #{config.all.client.service.result.viewer.liveDesign.username} -p #{config.all.client.service.result.viewer.liveDesign.password}"
  console.log "About to call python using command: "+command

  child = exec command,  (error, stdout, stderr) ->
    console.log "stderr: " + stderr
    console.log "stdout: " + stdout
    content = stdout
    if stripHTML? & stripHTML
      regex = /(<([^>]+)>)/ig
      content = content.replace(regex, "")
    content = content.replace(/\r/g, '')
    callback content

exports.installLiveDesignPythonClient = (req, resp) ->
  exports.installLiveDesignPythonClientInternal (statusCode, output) ->
    resp.send statusCode, output

exports.installLiveDesignPythonClientInternal = (callback) ->
  exec = require('child_process').exec
  config = require '../conf/compiled/conf.js'
  request = require 'request'

  command = "pip install --upgrade --force-reinstall --user #{config.all.client.service.result.viewer.liveDesign.baseUrl}/ldclient.tar.gz csvdiff"
  console.log "About to call pip using command: "+command

  child = exec command,  (error, stdout, stderr) ->
    console.log "stderr: " + stderr
    console.log "stdout: " + stdout
    if error?
      statusCode = 500
      output = stderr
    else
      statusCode = 200
      output = stdout
    callback statusCode, output

exports.getExperimentByName = (experimentName, callback) ->
  options =
    method: 'GET'
    url: "#{config.all.server.nodeapi.path}/api/experiments/experimentName/#{encodeURIComponent(experimentName)}"
    json: true
  request options, (error, response, body) ->
    if error
      console.error options
      throw new Error(error)
    out = _.filter body, (experiment) ->
      !experiment.deleted & !experiment.ignored
    if out?[0]?
      callback out[0]
    else
      callback null

exports.getResultViewerURLByExperimentName = (req, resp) ->
  experimentName = req.params.experimentName
  exports.getResultViewerURLByExperimentNameInternal experimentName, (url) ->
    resp.json {url: url}

exports.getResultViewerURLByExperimentNameInternal = (experimentName, callback) ->
  exports.getExperimentByName experimentName, (experiment) ->
    if experiment?
      experimentCode = experiment.codeName
      options =
        method: 'GET'
        url: "#{config.all.server.nodeapi.path}/api/getUrlForNewLiveDesignLiveReportForExperiment/#{experimentCode}"
        json: true
      request options, (error, response, body) ->
        if error
          throw new Error(error)
        body.url = body.url.replace("\n","")
        callback body
    else
      console.error "could not find experiment"
      callback null

exports.getLiveReportIDByExperimentName = (req, resp) ->
  experimentName = req.params.experimentName
  exports.getLiveReportIDByExperimentNameInternal experimentName, (json) ->
    resp.json json

exports.getLiveReportIDByExperimentNameInternal = (experimentName, callback) ->
  exports.getResultViewerURLByExperimentNameInternal experimentName, (url) ->
    if url?.url?
      urlArray = url.url.split "/"
      liveReportID = urlArray[urlArray.length - 1]
      callback {id: liveReportID}
    else
      callback {id: null}

exports.getLiveReportContentByExperimentName = (req, resp) ->
  experimentName = req.params.experimentName
  stripHTML  = req.query.stripHTML != "0"
  deleteLiveReport  = req.query.deleteLiveReport == "1"
  exports.getLiveReportContentByExperimentNameInternal experimentName, stripHTML, deleteLiveReport, (content) ->
    resp.header "Content-Disposition", "attachment;filename=#{experimentName}.csv"
    resp.type "text/csv"
    resp.send(200, content);

exports.getLiveReportContentByExperimentNameInternal = (experimentName, stripHTML, deleteLiveReport, callback) ->
  exports.getLiveReportIDByExperimentNameInternal experimentName, (id) ->
    if id?.id?
      exports.getLiveDesignReportContentInternal id.id, stripHTML, (content) ->
        callback content
      if deleteLiveReport
        exports.deleteLiveDesignReportInternal id.id, (response) ->
          console.log "returned from deleting live report id #{id.id}"
    else
      callback null

exports.writeLiveReportContentToCSVByExperimentName = (req, resp) ->
  experimentName = req.params.experimentName
  stripHTML  = req.query.stripHTML != "0"
  deleteLiveReport  = req.query.deleteLiveReport == "1"
  exports.writeLiveReportContentToCSVByExperimentNameInternal experimentName, stripHTML, deleteLiveReport, (statusCode, filePath) ->
    resp.statusCode = statusCode
    resp.json {filePath: filePath}

exports.writeLiveReportContentToCSVByExperimentNameInternal = (experimentName, stripHTML, deleteLiveReport, callback) ->
  exports.getLiveReportContentByExperimentNameInternal experimentName, stripHTML, deleteLiveReport, (content) =>
    if content?
      fs = require 'fs'
      Tempfile = require 'temporary/lib/file'
      tempFile =  new Tempfile
      tempFile.writeFile content, (err) =>
        if err?
          console.error err
          statusCode = 500
          output = null
        else
          statusCode = 200
          output = tempFile.path
        callback statusCode, tempFile.path
    else
      callback 500, null

exports.compareLiveReportCsv = (req, resp) ->
  csv1 = req.body.csv1
  csv2  = req.body.csv2
  exports.compareLiveReportCsvInternal csv1, csv2, (statusCode, output) ->
    resp.send statusCode, output

exports.compareLiveReportCsvInternal = (csv1, csv2, callback) ->
  exec = require('child_process').exec
  config = require '../conf/compiled/conf.js'
  request = require 'request'

  command = "python ./src/python/ServerAPI/compare_single_csv.py -b #{csv1} -a #{csv2}"
  console.log "About to call python using command: "+command

  child = exec command,  (error, stdout, stderr) ->
    console.log "stderr: " + stderr
    console.log "stdout: " + stdout
    if error?
      statusCode = 500
      output = stderr
    else
      statusCode = 200
      output = stdout
    callback statusCode, output

exports.deleteLiveDesignReport = (req, resp) ->
  liveDesignReportID  = req.params.liveDesignReportID
  exports.deleteLiveDesignReportInternal liveDesignReportID, (statusCode, output) ->
    resp.send statusCode, output

exports.deleteLiveDesignReportInternal = (liveDesignReportID, callback) ->
  exec = require('child_process').exec
  config = require '../conf/compiled/conf.js'
  request = require 'request'

  command = "python ./src/python/ServerAPI/delete_live_report.py  -i #{liveDesignReportID} -e #{config.all.client.service.result.viewer.liveDesign.baseUrl} -u #{config.all.client.service.result.viewer.liveDesign.username} -p #{config.all.client.service.result.viewer.liveDesign.password}"
  console.log "About to call python using command: "+command

  child = exec command,  (error, stdout, stderr) ->
    console.log "stderr: " + stderr
    console.log "stdout: " + stdout
    if error?
      statusCode = 500
      output = stderr
    else
      statusCode = 200
      output = stdout
    callback statusCode, output
