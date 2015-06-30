
# The following is needed when running specs and live
window.Office.initialize = (reason) ->
	$(document).ready ->
		window.logger = new ExcelAppLogger
			el: $('.bv_log')
		logger.render()
		window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController
			el: $('.bv_excelInsertCompoundPropertiesView')
		insertCompoundPropertiesController.render()

# The following is used for debugging the app in chrome
#window.onload = ->
#	window.logger = new ExcelAppLogger
#		el: $('.bv_log')
#	logger.render()
#	window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController
#		el: $('.bv_excelInsertCompoundPropertiesView')
#	insertCompoundPropertiesController.render()


class window.Attributes extends Backbone.Model
	defaults:
		insertColumnHeaders: true
		includeRequestedID: true

class window.AttributesController extends Backbone.View
	initialize: ->
		@template = _.template($("#AttributesControllerView").html())

	render: =>
		@$el.empty()
		@attributes = new Attributes()
		@$el.html @template @attributes.attributes


class window.PropertyDescriptor extends Backbone.Model

class window.PropertyDescriptorController extends Backbone.View
	initialize: ->
		@template =  _.template($("#PropertyDescriptorControllerView").html())

	events: ->
		'change .bv_propertyDescriptorCheckbox': 'handleDescriptorCheckboxChanged'

	render: ->
		@$el.empty()
		@model.set 'isChecked', false
		@$el.html @template(@model.attributes)
		@$('.bv_descriptorLabel').text(@model.get('valueDescriptor').prettyName)
		@$('.bv_descriptorLabel').attr 'title', @model.get('valueDescriptor').description
		@

	handleDescriptorCheckboxChanged: ->
		@model.set 'isChecked', @$('.bv_propertyDescriptorCheckbox').is(":checked")

class window.PropertyDescriptorList extends Backbone.Collection
	model: PropertyDescriptor

class window.PropertyDescriptorListController extends Backbone.View
	initialize: ->
		@title = @options.title
		@template = _.template($("#PropertyDescriptorListControllerView").html())
		@collection = new PropertyDescriptorList()
		@propertyControllersList = []
		@collection.url = @options.url
		@collection.fetch
			success: =>
				@collection.each (propertyDescriptor) =>
					@addPropertyDescriptor(propertyDescriptor)
				@trigger 'ready'
			error: =>
				console.log 'error fetching property descriptors from route: ' + @collection.url

	render:->
		@$el.empty()
		@$el.html @template()
		@$('.propertyDescriptorListControllerTitle').html @title
		@propertyControllersList.forEach (pdc) =>
			@$('.bv_propertyDescriptorList').append pdc.render().el
		@

	getSelectedProperties: ->
		selectedProperties = @collection.where({isChecked: true})
		selectedPropertyNames = []
		selectedProperties.forEach (selectedProperty) ->
			selectedPropertyNames.push(selectedProperty.get('valueDescriptor').name)
		return(selectedPropertyNames)

	addPropertyDescriptor: (propertyDescriptor) ->
		pdc = new PropertyDescriptorController
			model: propertyDescriptor
		@propertyControllersList.push pdc



class window.ExcelInsertCompoundPropertiesController extends Backbone.View
	events:
		'click .bv_getProperties': 'handleGetPropertiesClicked'
		'click .bv_insertProperties': 'handleInsertPropertiesClicked'

	initialize: ->
		@template = _.template($("#ExcelInsertCompoundPropertiesView").html())

	render: =>
		@$el.empty()
		@$el.html @template()
		@attributesController = new AttributesController
			el: $('.bv_attributes')
		@attributesController.render()
		@batchPropertyDescriptorListController = new PropertyDescriptorListController
			el: $('.bv_batchProperties')
			title: 'Batch Properties'
			url: '/api/compound/batch/property/descriptors'
		@batchPropertyDescriptorListController.on 'ready', @batchPropertyDescriptorListController.render
		@parentPropertyDescriptorListController = new PropertyDescriptorListController
			el: $('.bv_parentProperties')
			title: 'Parent Properties'
			url: '/api/compound/parent/property/descriptors'
		@parentPropertyDescriptorListController.on 'ready', @parentPropertyDescriptorListController.render
		@$("[data-toggle=popover]").popover
			html: true
			content: '1. Choose Properties to look up.<br />
								2. Select input IDs in workbook.<br />
								3. Click <button class="btn btn-xs btn-primary">Get Properties</button><br />
								4. Select a cell at the upper-left corner where you want the Properties to be inserted.<br />
								5. Click <button class="btn btn-xs btn-primary">Insert Properties</button>'


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
				@fetchPreferredReturn json
			error: (err) =>
				console.log 'got ajax error fetching preferred ids'

	fetchPreferredReturn: (json) ->
#		@outputArray = [["Input ID", "Preferred ID"]]
		@preferredIds = []
		for res in json.results
			prefName = if res.preferredName == "" then "not found" else res.preferredName
#			@outputArray.push [res.requestName, prefName]
			@preferredIds.push prefName
		@fetchCompoundProperties()

	getSelectedProperties: ->
		selectedParentProperties = []
		selectedParentProperties.parent = @parentPropertyDescriptorListController.getSelectedProperties()
		selectedParentProperties.batch = @batchPropertyDescriptorListController.getSelectedProperties()
		return selectedParentProperties

	fetchCompoundProperties: ->
		selectedProperties = @getSelectedProperties()
		request =
			properties: selectedProperties.parent
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