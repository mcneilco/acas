
# The following is needed when running specs and live
#if navigator.appVersion.indexOf("Microsoft") != -1 && window.Office?
if true
	window.Office.initialize = (reason) ->
		$(document).ready ->
			window.logger = new ExcelAppLogger
				el: $('.bv_log')
#		logger.render()
		window.getAuthorModulePreferences window.AppLaunchParams.loginUser.username, 'CIExcelCompoundPropertiesApp', (preferences, statusCode) ->
			if statusCode == 200
				window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController
					el: $('.bv_excelInsertCompoundPropertiesView')
					selectedBatchPropertyDescriptors: preferences.selectedBatchPropertyDescriptors
					selectedParentPropertyDescriptors: preferences.selectedParentPropertyDescriptors
					includeRequestedID: preferences.includeRequestedID
					insertColumnHeaders: preferences.insertColumnHeaders
			else
				window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController
					el: $('.bv_excelInsertCompoundPropertiesView')
			insertCompoundPropertiesController.render()
else
	#The following is used for debugging the app in chrome
	window.onload = ->
		window.logger = new ExcelAppLogger
			el: $('.bv_log')
		logger.render()
		window.getAuthorModulePreferences window.AppLaunchParams.loginUser.username, 'CIExcelCompoundPropertiesApp', (preferences, statusCode) ->
			if statusCode == 200
				logger.log preferences.includeRequestedName
				window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController
					el: $('.bv_excelInsertCompoundPropertiesView')
					selectedBatchPropertyDescriptors: preferences.selectedBatchPropertyDescriptors
					selectedParentPropertyDescriptors: preferences.selectedParentPropertyDescriptors
					includeRequestedID: preferences.includeRequestedID
					insertColumnHeaders: preferences.insertColumnHeaders
			else
				window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController
					el: $('.bv_excelInsertCompoundPropertiesView')
			insertCompoundPropertiesController.render()

class window.Attributes extends Backbone.Model
	defaults:
		insertColumnHeaders: true
		includeRequestedID: false

class window.AttributesController extends Backbone.View
	initialize: ->
		@template = _.template($("#AttributesControllerView").html())

	events: ->
		'change .bv_insertColumnHeaders': 'handleInsertColumnHeaders'
		'click .bv_insertColumnHeadersClickZone': 'handleInsertColumnHeadersClickZone'
		'change .bv_includeRequestedID': 'handleIncludeRequestedID'
		'click .bv_includeRequestedIDClickZone': 'handleIncludeRequestedIDClickZone'

	render: =>
		@$el.empty()
		@model = new Attributes
			insertColumnHeaders: @options.insertColumnHeaders
			includeRequestedID: @options.includeRequestedID

		@$el.html @template @model.attributes

	handleInsertColumnHeaders: =>
		@model.set 'insertColumnHeaders', @$('.bv_insertColumnHeaders').is(":checked")

	handleInsertColumnHeadersClickZone: =>
		@$('.bv_insertColumnHeaders').click()

	handleIncludeRequestedID: =>
		@model.set 'includeRequestedID', @$('.bv_includeRequestedID').is(":checked")

	handleIncludeRequestedIDClickZone: =>
		@$('.bv_includeRequestedID').click()

	getInsertColumnHeaders: =>
		@model.get 'insertColumnHeaders'

	getIncludeRequestedID: =>
		@model.get 'includeRequestedID'


class window.PropertyDescriptor extends Backbone.Model

class window.PropertyDescriptorController extends Backbone.View
	initialize: ->
		@template =  _.template($("#PropertyDescriptorControllerView").html())

	events: ->
		'change .bv_propertyDescriptorCheckbox': 'handleDescriptorCheckboxChanged'
		'click .bv_propertyDescriptorCheckboxClickZone': 'handleDescriptorCheckboxZoneClicked'

	render: ->
		@$el.empty()
		@model.set 'isChecked', @options.isChecked
		@$el.html @template(@model.attributes)
		@$('.bv_descriptorLabel').text(@model.get('valueDescriptor').prettyName)
		if @model.get('valueDescriptor').description?
			@$('.bv_descriptorLabel').attr 'title', @model.get('valueDescriptor').description
		else
			@$('.bv_descriptorLabel').attr 'title', @model.get('valueDescriptor').prettyName
		@

	handleDescriptorCheckboxZoneClicked: ->
		@$('.bv_propertyDescriptorCheckbox').click()

	handleDescriptorCheckboxChanged: ->
		checked = @$('.bv_propertyDescriptorCheckbox').is(":checked")
		@model.set 'isChecked', checked
		if checked
			@trigger 'checked'
		else
			@trigger 'unchecked'

class window.PropertyDescriptorList extends Backbone.Collection
	model: PropertyDescriptor

class window.PropertyDescriptorListController extends Backbone.View
	events:
		'click .bv_checkAll': 'handleCheckAllClicked'
		'click .bv_invert': 'handleInvertSelectionClicked'
		'click .bv_uncheckAll': 'handleUncheckAllClicked'
		'click .bv_propertyDescriptorListControllerCollapser': 'togglePropertyDescriptorListCollapse'

	initialize: ->
		@numberChecked=0
		@valid = false
		@title = @options.title
		@template = _.template($("#PropertyDescriptorListControllerView").html())
		@collection = new PropertyDescriptorList()
		@propertyControllersList = []
		@collection.url = @options.url
		@collection.fetch
			success: =>
				@collection.each (propertyDescriptor) =>
					if @options.selectedPropertyDescriptors?
						check =  propertyDescriptor.get('valueDescriptor').name in @options.selectedPropertyDescriptors
					@addPropertyDescriptor(propertyDescriptor, check)
				@trigger 'ready'
			error: =>
				logger.log 'error fetching property descriptors from route: ' + @collection.url

	render:->
		@$el.empty()
		@$el.html @template()
		@$('.propertyDescriptorListControllerTitle').html @title
		@propertyControllersList.forEach (pdc) =>
			@$('.bv_propertyDescriptorList').append pdc.render().el
		@$('.bv_propertyDescriptorList').collapse
			toggle: true
		@$('.bv_propertyDescriptorList').on 'shown.bs.collapse', =>
			@$('.bv_collapseExpand').addClass('hide')
			@$('.bv_collapseDown').removeClass('hide')
		@$('.bv_propertyDescriptorList').on 'hidden.bs.collapse', =>
			@$('.bv_collapseExpand').removeClass('hide')
			@$('.bv_collapseDown').addClass('hide')
		@validate()
		@

	handleCheckAllClicked: ->
		anyClicked = false
		@propertyControllersList.forEach (pdc) ->
			if !pdc.model.get ('isChecked')
				anyClicked = true
				pdc.$('.bv_propertyDescriptorCheckbox').click()

	handleInvertSelectionClicked: ->
		@propertyControllersList.forEach (pdc) ->
			pdc.$('.bv_propertyDescriptorCheckbox').click()

	handleUncheckAllClicked: ->
		@propertyControllersList.forEach (pdc) ->
			if pdc.model.get ('isChecked')
					pdc.$('.bv_propertyDescriptorCheckbox').click()

	getSelectedProperties: (callback)->
		selectedProperties = @collection.where({isChecked: true})
		selectedProps =
			names: []
			prettyNames: []
		selectedProperties.forEach (selectedProperty) ->
			selectedProps.names.push(selectedProperty.get('valueDescriptor').name)
			selectedProps.prettyNames.push(selectedProperty.get('valueDescriptor').prettyName)
		callback selectedProps

	addPropertyDescriptor: (propertyDescriptor, isChecked) ->
		pdc = new PropertyDescriptorController
			model: propertyDescriptor
			isChecked: isChecked
		if isChecked
			@numberChecked = @numberChecked + 1
		pdc.on 'checked', =>
			@numberChecked = @numberChecked + 1
			@validate()
		pdc.on 'unchecked', =>
			@numberChecked = @numberChecked - 1
			@validate()
		@propertyControllersList.push pdc

	validate: ->
		if @numberChecked == 0
			if @valid == true
				@valid = false
				@trigger 'invalid'
		else
			if @valid == false
				@valid = true
				@trigger 'valid'

	togglePropertyDescriptorListCollapse: ->
		@$('.bv_propertyDescriptorList').collapse('toggle')

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
			includeRequestedID: @options.includeRequestedID
			insertColumnHeaders: @options.insertColumnHeaders
		@attributesController.render()
		@batchPropertyDescriptorListController = new PropertyDescriptorListController
			el: $('.bv_batchProperties')
			title: 'Batch Properties'
			url: '/api/compound/batch/property/descriptors'
			selectedPropertyDescriptors: @options.selectedBatchPropertyDescriptors
		@batchPropertyDescriptorValid = false
		@batchPropertyDescriptorListController.on 'valid', =>
			@batchPropertyDescriptorValid = true
			@validate()
		@batchPropertyDescriptorListController.on 'invalid', =>
			@batchPropertyDescriptorValid = false
			@validate()
		@batchPropertyDescriptorListController.on 'ready', @batchPropertyDescriptorListController.render
		@parentPropertyDescriptorValid = false
		@parentPropertyDescriptorListController = new PropertyDescriptorListController
			el: $('.bv_parentProperties')
			title: 'Parent Properties'
			url: '/api/compound/parent/property/descriptors'
			selectedPropertyDescriptors: @options.selectedParentPropertyDescriptors
		@parentPropertyDescriptorListController.on 'valid', =>
			@parentPropertyDescriptorValid = true
			@validate()
		@parentPropertyDescriptorListController.on 'invalid', =>
			logger.log 'should be invalid'
			@parentPropertyDescriptorValid = false
			@validate()
		@parentPropertyDescriptorListController.on 'ready', @parentPropertyDescriptorListController.render
		@$("[data-toggle=instructions]").popover
			html: true
			content: '1. Choose Properties to look up.<br />
								2. Select input IDs in workbook.<br />
								3. Click <button class="btn btn-xs btn-primary">Get Properties</button><br />
								4. Select a cell at the upper-left corner where you want the Properties to be inserted.<br />
								5. Click <button class="btn btn-xs btn-primary">Insert Properties</button>'
		@$("[data-toggle=options]").popover
			html: true
			content: '<a class="btn btn-xs btn-primary" href="/logout/excelApps">Logout</a><br /><a class="btn btn-xs btn-primary">Show Log'
		Office.context.document.addHandlerAsync Office.EventType.DocumentSelectionChanged, =>
			@validate()
		@validate()

	handleGetPropertiesClicked: =>
		Office.context.document.getSelectedDataAsync 'matrix', (result) =>
			if result.status == 'succeeded'
				@parseInputArray result.value
			else
				logger.log result.error.name + ': ' + result.error.name

	validate: =>
		if @parentPropertyDescriptorValid == false && @batchPropertyDescriptorValid == false
			@$('.bv_getProperties').attr 'disabled', 'disabled'
			@setErrorStatus 'Please check atleast one property'
		else
			Office.context.document.getSelectedDataAsync 'matrix', (result) =>
				if result.status == 'succeeded'
					inputArray = result.value
					error = false
					if inputArray?
						request = []
						for req in inputArray
							if req.length > 1
								error = true
								errorMessage =  'Select a single column'
								break
							else
								request.push req[0]
						if !error && request.join("") == ""
							error = true
							errorMessage =  'Please select non-empty cells'
#						if !error && window.conf.ciExcelCompoundPropertiesApp? && window.conf.ciExcelCompoundPropertiesApp.maxUserRequests? && request.length >= window.conf.ciExcelCompoundPropertiesApp.maxUserRequests
#								error = true
#								errorMessage =  request.length + " selected, please select no more than " + window.conf.ciExcelCompoundPropertiesApp.maxUserRequests
					if error
						@$('.bv_getProperties').attr 'disabled', 'disabled'
						@setErrorStatus errorMessage
					else
						@$('.bv_getProperties').removeAttr 'disabled'
						@setErrorStatus ''

	setPropertyLookUpStatus: (status) =>
	  @.$('.bv_propertyLookUpStatus').html status

	setErrorStatus: (status, force = false) =>
		@.$('.bv_errorStatus').html status
		if status == "" | (force == false && (@.$('.bv_propertyLookUpStatus').html() == "Data ready to insert" | @.$('.bv_propertyLookUpStatus').html() == "Fetching data..."))
			@.$('.bv_errorStatus').addClass('hide')
		else
			@.$('.bv_errorStatus').removeClass('hide')

	parseInputArray: (inputArray) =>
		error = false
		if inputArray?
			request = []
			for req in inputArray
				if req.length > 1
					error = true
					@setErrorStatus 'Select a single column'
					break
				else
					request.push req[0]
		if not error
			@getPropertiesAndRequestData request

	handleInsertPropertiesClicked: =>
		@insertTable @outputArray

	insertTable: (dataArray) =>
		Office.context.document.setSelectedDataAsync dataArray, coercionType: 'matrix', (result) =>
			if result.status != 'succeeded'
				if result.error.message == 'The set operation failed because the supplied data object will overwrite or shift data.'
					@setErrorStatus 'Data overwrite error: cannot overwrite data', true
				else
					logger.log result.error.name + ':' + result.error.message
					@setErrorStatus 'Unknown insert error: see log below', true

	getPropertiesAndRequestData: (request) ->
		@$('.bv_insertProperties').attr 'disabled', 'disabled'
		@$('.bv_getProperties').attr 'disabled', 'disabled'

		@setPropertyLookUpStatus "Fetching data..."

		entityIdStringLines = request.join("\n")

		@getSelectedProperties (selectedProperties) =>
			@getPreferredIDAndProperties entityIdStringLines, selectedProperties

	fetchPreferredReturn: (json) ->
		@preferredIds = []
		for res in json.results
			prefName = if res.preferredName == "" then "not found" else res.preferredName
			@preferredIds.push prefName
		@fetchCompoundProperties()

	getSelectedProperties: (callback)->
		@parentPropertyDescriptorListController.getSelectedProperties (parentProperties) =>
			@batchPropertyDescriptorListController.getSelectedProperties (batchProperties) =>
				selectedProperties = []
				selectedProperties =
					parentNames: parentProperties.names
					parentPrettyNames: parentProperties.prettyNames
					batchNames: batchProperties.names
					batchPrettyNames: batchProperties.prettyNames
				callback selectedProperties

	getPreferredIDAndProperties: (entityIdStringLines, selectedProperties) ->
		req =
			entityIdStringLines: entityIdStringLines
			selectedProperties: selectedProperties
			includeRequestedName: @attributesController.getIncludeRequestedID()
			insertColumnHeaders: @attributesController.getInsertColumnHeaders()
		$.ajax
			type: 'POST'
			url: "/excelApps/getPreferredIDAndProperties"
			timeout: 180000
			data: req
			success: (csv) =>
				@fetchCompoundPropertiesReturn csv
			error: (jqXHR, textStatus)=>
				logger.log textStatus
				logger.log JSON.stringify(jqXHR)
				if jqXHR.status == 401
					@setPropertyLookUpStatus "Unauthorized please login"
				else
					@setPropertyLookUpStatus ("Error fetching data: " + jqXHR.statusText)
				@$('.bv_insertProperties').removeAttr 'disabled'
				@$('.bv_getProperties').removeAttr 'disabled'

		preferences =
			selectedBatchPropertyDescriptors: selectedProperties.batchNames
			selectedParentPropertyDescriptors: selectedProperties.parentNames
			includeRequestedID: @attributesController.getIncludeRequestedID()
			insertColumnHeaders: @attributesController.getInsertColumnHeaders()
		window.updateAuthorModulePreferences window.AppLaunchParams.loginUser.username, 'CIExcelCompoundPropertiesApp', JSON.stringify(preferences), (json, statusCode) =>
			logger.log 'saved preferences'

	fetchCompoundPropertiesReturn: (csv) =>
		@outputArray = @convertCSVToMatrix csv
		@setPropertyLookUpStatus "Data ready to insert"
		@$('.bv_insertProperties').removeAttr 'disabled'
		@$('.bv_getProperties').removeAttr 'disabled'

	convertCSVToMatrix: (csv) ->
		outMatrix = []
		lines = csv.split('\n')[0..-2] #trim trailing blank line
		for row in lines
			outMatrix.push row.split('\t')
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
#TODO better error trapping and display. alert() doesn't work
#TODO move logger to its own file
