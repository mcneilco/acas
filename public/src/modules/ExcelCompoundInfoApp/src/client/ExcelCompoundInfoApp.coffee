
window.Office.initialize = (reason) ->
	$(document).ready ->
		window.logger = new ExcelAppLogger
			el: $('.bv_log')
		logger.render()
		window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController
			el: $('.bv_excelInsertCompoundPropertiesView')
		insertCompoundPropertiesController.render()


class window.ExcelInsertCompoundPropertiesController extends Backbone.View
	events:
		'click .bv_getProperties': 'handleGetPropertiesClicked'
		'click .bv_insertProperties': 'handleInsertPropertiesClicked'

	initialize: ->
		@template = _.template($("#ExcelInsertCompoundPropertiesView").html())

	render: =>
		@$el.empty()
		@$el.html @template()

	handleGetPropertiesClicked: =>
		#TODO make sure input is a single column or error
		logger.log "got Get Properties Clicked"
		Office.context.document.getSelectedDataAsync 'matrix', (result) =>
			if result.status == 'succeeded'
				logger.log "Fetched data"
#				logger.log result.value
				@fetchPreferred result.value
			else
				logger.log result.error.name + ': ' + result.error.name

	handleInsertPropertiesClicked: =>
		@insertTable @outputArray

	insertTable: (dataArray) ->
		logger.log dataArray
		Office.context.document.setSelectedDataAsync dataArray, coercionType: 'matrix', (result) =>
			if result.status != 'succeeded'
				logger.log result.error.name + ':' + result.error.message

	fetchPreferred: (inputArray) ->
		logger.log "starting addPreferred"
		logger.log inputArray
		request = requests: []
		for req in inputArray
			request.requests.push requestName: req[0]
		$.ajax
			type: 'POST'
			url: "/api/preferredBatchId"
			data: request
			dataType: 'json'
			success: (json) =>
				logger.log "got preferred id response"
				@fetchPreferredRetun json
			error: (err) =>
				console.log 'got ajax error fetching preferred ids'

	fetchPreferredRetun: (json) ->
#		@outputArray = [["Input ID", "Preferred ID"]]
		@preferredIds = []
		for res in json.results
			prefName = if res.preferredName == "" then "not found" else res.preferredName
#			@outputArray.push [res.requestName, prefName]
			@preferredIds.push prefName
		@fetchCompoundProperties()

	fetchCompoundProperties: ->
		request =
			properties: ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"]
			entityIdStringLines: @preferredIds.join '\n'

		$.ajax
			type: 'POST'
			url: "/api/testedEntities/properties"
			data: request
			dataType: 'json'
			success: (json) =>
				logger.log "got compound property response"
				@fetchCompoundPropertiesReturn json
			error: (err) =>
				console.log 'got ajax error fetching compound properties'

	fetchCompoundPropertiesReturn: (json) ->
		logger.log json.resultCSV
		@outputArray = @convertCSVToMatrix json.resultCSV

	convertCSVToMatrix: (csv) ->
		outMatrix = []
		lines = csv.split('\n')[0..-2] #trim trailing blank line
		logger.log lines.length
		for row in lines
			outMatrix.push row.split(',')
		return outMatrix

class window.ExcelAppLogger extends Backbone.View
	events:
		'click .bv_clearLog': 'handleClearLogClicked'

	initialize: ->
		@template= _.template($("#ExcelAppLoggerView").html())

	render: =>
		@$el.empty()
		@$el.html @template()

	log: (logstr) ->
		@$('.bv_logEntries').append "<div>#{logstr}</div>"

	handleClearLogClicked: =>
		@$('.bv_logEntries').empty()

#TODO maybe add cell coloring for preferred id results
#TODO Preferred ID service seems to break of the last request is empty
#TODO better error trapping and display. alert() doesn't work
#TODO move logger to its own file
#TODO is there a service with the list of available calc properties?
#http://imapp01-d.dart.corp:8080/compserv-rest/api/Compounds/CalculatedProperties/v2/Descriptors
#TODO add properties from http://imapp01-d:8080/DNS/ligands/v1/Batches/BatchProperties
#TODO disable insert button until fetch is returned
#TODO don't send bad ids to compound properties (it fails), but do leave blank lines in results