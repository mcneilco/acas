class window.SdfProperty extends Backbone.Model

class window.SdfPropertiesList extends Backbone.Collection
	model: SdfProperty

class window.DbProperty extends Backbone.Model

class window.DbPropertiesList extends Backbone.Collection
	model: DbProperty

	getRequired: ->
		@filter (prop) ->
			prop.get('required')

class window.AssignedProperty extends Backbone.Model
	defaults:
		sdfProperty: null
		dbProperty: "none"
		defaultVal: ""
		required: false

	validate: (attrs) =>
		errors = []
		if attrs.required and attrs.dbProperty != "corporate id" and attrs.defaultVal == ""
			errors.push
				attribute: 'defaultVal'
				message: 'A default value must be assigned'
		if errors.length > 0
			return errors
		else
			return null


class window.AssignedPropertiesList extends Backbone.Collection
	model: AssignedProperty

	checkDuplicates: =>
		console.log "check duplicates"
		duplicates = []
		assignedDbProps = {}
		if @.length != 0
			for index in [0..@.length-1]
				model = @.at(index)
				currentDbProp = model.get('dbProperty')
				console.log currentDbProp
				unless currentDbProp is "none"
					if currentDbProp of assignedDbProps
						duplicates.push
							attribute: 'dbProperty:eq('+index+')'
							message: "Database property can not be assigned more than once"
						duplicates.push
							attribute: 'dbProperty:eq('+assignedDbProps[currentDbProp]+')'
							message: "Database property can not be assigned more than once"
					else
						assignedDbProps[currentDbProp] = index
		console.log assignedDbProps
		console.log duplicates
		duplicates



class window.DetectSdfPropertiesController extends Backbone.View
	template: _.template($("#DetectSdfPropertiesView").html())

	events: ->
		"click .bv_readMore": "readMoreRecords"
		"click .bv_readAll": "readAllRecords"

	initialize: ->
		@numRecords = 100
		@temp = "none"

	render: ->
		$(@el).empty()
		$(@el).html @template()
		@disableInputs()
		@setupBrowseFileController()

	setupBrowseFileController: =>
		@browseFileController = new LSFileChooserController
			el: @$('.bv_browseFile')
			formId: 'fieldBlah',
			maxNumberOfFiles: 1,
			requiresValidation: false
			url: UtilityFunctions::getFileServiceURL()
			allowedFileTypes: ['sdf']
		#			hideDelete: false
		@browseFileController.on 'amDirty', =>
			@trigger 'amDirty'
		@browseFileController.on 'amClean', =>
			@trigger 'amClean'
		@browseFileController.render()
		@browseFileController.on('fileUploader:uploadComplete', @handleFileUploaded)
		@browseFileController.on('fileDeleted', @handleFileRemoved)

	handleFileUploaded: (fileName) =>
		console.log "file uploaded"
		@fileName = fileName
		@getProperties()

	getProperties: =>
		#TODO: need to call service to read the first 100 records
		@$('.bv_detectedSdfPropertiesList').html "Loading..."
		@disableInputs()
		@$('.bv_deleteFile').attr 'disabled','disabled'
		sdfInfo =
			fileName: @fileName
			numRecords: @numRecords
			template: @temp
		$.ajax
			type: 'POST'
			url: "/api/cmpdRegBulkLoader/readSDF"
			data: sdfInfo
			success: (response) =>
				console.log "successful read of SDF"
				@handlePropertiesDetected(response)
				@$('.bv_deleteFile').removeAttr 'disabled'
			error: (err) =>
				@serviceReturn = null
			dataType: 'json'
#
#		#TODO: disable browsing for another file while service to read records is still running - perhaps have spinner that says "Reading..." or use modal

	handlePropertiesDetected: (response) ->
		console.log "handle properties detected"
		console.log response
		console.log @numRecords
		@trigger 'propsDetected', response

	handleFileRemoved: =>
		console.log "sdf file removed"
		@disableInputs()
		@$('.bv_detectedSdfPropertiesList').html ""
		@fileName = null
		@numRecords = 100
		@$('.bv_recordsRead').html 0
		@trigger 'resetAssignProps'

	showSdfProperties: (sdfPropsList) ->
		@$('.bv_recordsRead').html @numRecords
		console.log "show SDF props"
		console.log sdfPropsList
		newLine = "&#13;&#10;"
		props = ""
		sdfPropsList.each (prop) ->
			console.log prop.get('name')
			if props == ""
				props = prop.get('name')
			else
				props += newLine + prop.get('name')
		if props == ""
			props = "No SDF Properties Detected"
		@$('.bv_detectedSdfPropertiesList').html props
		@$('.bv_readMore').removeAttr('disabled')
		@$('.bv_readAll').removeAttr('disabled')

	disableInputs: ->
		@$('.bv_readMore').attr 'disabled', 'disabled'
		@$('.bv_readAll').attr 'disabled', 'disabled'
#		@$('select').attr 'disabled', 'disabled'
#		@$("textarea").attr 'disabled', 'disabled'

	readMoreRecords: ->
		@numRecords += 100
		@getProperties()

	readAllRecords: ->
		#TODO: what to send in for numRecords?
		@getProperties()

	handleTemplateChanged: (template) =>
		@temp = template
		if @fileName? and @fileName != null
			@getProperties()


class window.AssignedPropertyController extends AbstractFormController
	template: _.template($("#AssignedPropertyView").html())
	className: "form-inline"

	events:
		"change .bv_dbProperty": "handleDbPropertyChanged"
		"keyup .bv_defaultVal": "handleDefaultValChanged"
		"click .bv_deleteProperty": "clear"

	initialize: ->
		unless @model?
			@model = new AssignedProperty()
		@errorOwnerName = 'AssignedPropertyController'
		@setBindings()
		@model.on "destroy", @remove, @
		if @options.dbPropertiesList?
			@dbPropertiesList = @options.dbPropertiesList
		else
			@dbPropertiesList = new DbPropertiesList()

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@$('.bv_sdfProperty').html(@model.get('sdfProperty'))
		@setupDbPropertiesSelect()
		@$('.bv_defaultVal').val @model.get('defaultVal')
		console.log "dbProp"
		console.log @model.get('dbProperty')
		if @model.get('dbProperty') is "none"
			console.log "disabling"
			@$('.bv_defaultVal').attr 'disabled', 'disabled'

		@

	setupDbPropertiesSelect: ->
		formattedDbProperties = @formatDbSelectOptions()
#		@dbPropertiesList = new PickListList()
#		@dbPropertiesList.url = "/api/codetables/properties/database"
		@dbPropertiesListController = new PickListSelectController
			el: @$('.bv_dbProperty')
			collection: formattedDbProperties
			insertFirstOption: new PickList
				code: "none"
				name: "None"
			selectedCode: @model.get('dbProperty')
			autoFetch: false

	formatDbSelectOptions: ->
		formattedOptions = new PickListList()
		@dbPropertiesList.each (dbProp) ->
			code = dbProp.get('name')
			if dbProp.get('required')
				name = code+"*"
			else
				name = code
			newOption = new PickList
				code: code
				name: name
			formattedOptions.add newOption
		formattedOptions

	handleDbPropertyChanged: ->
		console.log "handle db prop changed"
		dbProp = @dbPropertiesListController.getSelectedCode()
		console.log dbProp
		if dbProp is "none" or dbProp is "corporate id"
			@$('.bv_defaultVal').attr('disabled', 'disabled')
		else
			@$('.bv_defaultVal').removeAttr('disabled')
		propInfo = @dbPropertiesList.findWhere({name: dbProp})
		if propInfo.get('required')
			@model.set required: true

		@model.set dbProperty: dbProp

		@trigger 'assignedDbPropChanged'

	handleDefaultValChanged: ->
		@model.set defaultVal: UtilityFunctions::getTrimmedInput @$('.bv_defaultVal')
#		@trigger 'assignedDbPropChanged'

	clear: =>
#		@model.trigger 'amDirty'
		@model.destroy()
#		@attributeChanged()

class window.AssignedPropertiesListController extends AbstractFormController
	template: _.template($("#AssignedPropertiesListView").html())

	events:
		"click .bv_addDbProperty": "addNewProperty"

#	initialize: ->
#		@collection.on 'change', => @trigger 'checkIfCan

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (prop) =>
			@addOneProperty(prop, false)

		@

	addNewProperty: =>
		newModel = new AssignedProperty()
		@collection.add newModel
		@addOneProperty(newModel, true)
		newModel.trigger 'amDirty'

	addOneProperty: (prop, canDelete) ->
		console.log "add one prop"
		console.log @dbPropertiesList
		apc = new AssignedPropertyController
			model: prop
			dbPropertiesList: @dbPropertiesList
		apc.on 'assignedDbPropChanged', =>
			@trigger 'assignedDbPropChanged'
		@$('.bv_propInfo').append apc.render().el
		if canDelete
			apc.$('.bv_deleteProperty').show()
#		apc.on 'updateState', =>
#			@trigger 'updateState'



class window.AssignSdfPropertiesController extends Backbone.View
	template: _.template($("#AssignSdfPropertiesView").html())

	events:
		"change .bv_useTemplate": "handleTemplateChanged"
		"change .bv_saveTemplate": "handleSaveTemplateCheckboxChanged"
		"keyup .bv_templateName": "handleNameTemplateChanged"
		"change .bv_overwrite": "handleOverwriteRadioSelectChanged"
		"click .bv_regCmpds": "handleRegCmpdsClicked"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@setupTemplateSelect()
		@setupAssignedPropertiesListController()

	setupTemplateSelect: ->
		@templateList = new PickListList()
		@templateList.url = "/api/codetables/properties/templates"
		@templateListController = new PickListSelectController
			el: @$('.bv_useTemplate')
			collection: @templateList
			insertFirstOption: new PickList
				code: "none"
				name: "None"
			selectedCode: "none"

	setupAssignedPropertiesListController: ->
		@assignedPropertiesListController= new AssignedPropertiesListController
			el: @$('.bv_assignedPropertiesList')
			collection: new AssignedPropertiesList()
		@assignedPropertiesListController.on 'assignedDbPropChanged', =>
#			@isValid()
			@showUnassignedDbProperties()
		@assignedPropertiesListController.render()

	createPropertyCollections: (properties) ->
		console.log "handle props detected in app controller"
		console.log properties
		console.log properties.sdfProperties
		@sdfPropertiesList = new SdfPropertiesList properties.sdfProperties
		@dbPropertiesList = new DbPropertiesList properties.dbProperties
		#TODO: disable browsing for another file while service to read records is still running - perhaps have spinner that says "Reading..." or use modal
		@assignedPropertiesList = new AssignedPropertiesList properties.autoMagicProperties
		@assignedPropertiesList.on 'change', =>
			@isValid()
		@addUnassignedSdfProperties()
		@assignedPropertiesListController.collection = @assignedPropertiesList
		@assignedPropertiesListController.dbPropertiesList = @dbPropertiesList
		@assignedPropertiesListController.render()
		@showUnassignedDbProperties()
		@$('.bv_addDbProperty').removeAttr('disabled')
		@isValid()

	addUnassignedSdfProperties: ->
		console.log "add unassigned sdf props"
		console.log @sdfPropertiesList
		console.log @assignedPropertiesList
		@sdfPropertiesList.each (sdfProp) =>
			sdfProperty = sdfProp.get('name')
			unless @assignedPropertiesList.findWhere({sdfProperty: sdfProperty})?
				newAssignedProp = new AssignedProperty
					dbProperty: "none"
					required: false
					sdfProperty: sdfProperty
				@assignedPropertiesList.add newAssignedProp

	handleTemplateChanged: ->
		template = @templateListController.getSelectedCode()
		@trigger 'templateChanged', template

	handleSaveTemplateCheckboxChanged: ->
		console.log "checkbox changed"
		saveTemplateChecked = @$('.bv_saveTemplate').is(":checked")
		console.log saveTemplateChecked
		if saveTemplateChecked
			@$('.bv_templateName').removeAttr('disabled')
			currentTempName = @templateListController.getSelectedCode()
			console.log currentTempName
			if currentTempName is "none"
				@$('.bv_templateName').val ""
			else
				@$('.bv_templateName').val currentTempName
		else
			@$('.bv_templateName').val ""
			@$('.bv_templateName').attr 'disabled', 'disabled'
		@$('.bv_templateName').keyup()
		@isValid()

	handleNameTemplateChanged: ->
		tempName = UtilityFunctions::getTrimmedInput @$('.bv_templateName')
		console.log "new TempName"
		console.log tempName
		if @templateList.findWhere({name: tempName})? #and tempName.toLowerCase() != "none"
			@$('.bv_overwriteMessage').html tempName+" already exists. Overwrite?"
			@$('.bv_overwriteWarning').show()
			@$('input[name="bv_overwrite"][value="no"]').prop('checked',true)
			@$('.bv_overwrite').change()
		else
			@$('.bv_overwriteWarning').hide()
			@hideNameTemplateError()

	handleOverwriteRadioSelectChanged: =>
		console.log "radio select changed"
		@isValid()

	showUnassignedDbProperties: ->
		console.log "show unassigned db props"
		reqDbProp = @dbPropertiesList.getRequired()
#		console.log reqDbProp
		unassignedDbProps = ""
		newLine = "&#13;&#10;"
		for prop in reqDbProp
			name = prop.get('name')
			unless @assignedPropertiesList.findWhere({dbProperty: name})?
				if unassignedDbProps == ""
					unassignedDbProps = name
				else
					unassignedDbProps += newLine + name
		@$('.bv_unassignedProperties').html unassignedDbProps

	isValid: =>
		@clearValidationErrorStyles()
		validCheck = true
		@assignedPropertiesListController.collection.each (model) ->
			validModel = model.isValid()
			if validModel is false
				validCheck = false
		duplicates = @assignedPropertiesListController.collection.checkDuplicates()
		if duplicates.length > 1
			@showDbPropErrors(duplicates)
			validCheck = false
#		else
#			@removeDbPropErrors()
		saveTemplateChecked = @$('.bv_saveTemplate').is(":checked")
		if saveTemplateChecked and @$('.bv_overwriteWarning').is(":visible") and @$('input[name="bv_overwrite"]:checked').val() is "no"
			console.log "need unique template name"

			overwrite = @$('input[name="bv_overwrite"]:checked').val()
			if overwrite is "yes"
				@hideNameTemplateError()
			else
				@showNameTemplateError('The template name should be unique')
				validCheck = false


		if validCheck
			@$('.bv_regCmpds').removeAttr('disabled')
		else
			@$('.bv_regCmpds').attr 'disabled','disabled'
		validCheck

	showDbPropErrors: (duplicates) ->
		for err in duplicates
			@$('.bv_group_'+err.attribute).addClass 'input_error error'
			@$('.bv_group_'+err.attribute).attr('data-toggle', 'tooltip')
			@$('.bv_group_'+err.attribute).attr('data-placement', 'bottom')
			@$('.bv_group_'+err.attribute).attr('data-original-title', err.message)
			@$("[data-toggle=tooltip]").tooltip();

	clearValidationErrorStyles: =>
		errorElms = @$('.input_error')
		@trigger 'clearErrors', @errorOwnerName
		_.each errorElms, (ee) =>
			$(ee).removeAttr('data-toggle')
			$(ee).removeAttr('data-placement')
			$(ee).removeAttr('title')
			$(ee).removeAttr('data-original-title')
			$(ee).removeClass 'input_error error'

	showNameTemplateError: (errMessage) =>
		console.log "show name template error"
		@$('.bv_group_templateName').addClass 'input_error error'
		@$('.bv_group_templateName').attr('data-toggle', 'tooltip')
		@$('.bv_group_templateName').attr('data-placement', 'bottom')
		@$('.bv_group_templateName').attr('data-original-title', errMessage)
		@$("[data-toggle=tooltip]").tooltip();

	hideNameTemplateError: ->
		console.log "clear name template error"
		@$('.bv_group_templateName').removeAttr('data-toggle')
		@$('.bv_group_templateName').removeAttr('data-placement')
		@$('.bv_group_templateName').removeAttr('title')
		@$('.bv_group_templateName').removeAttr('data-original-title')
		@$('.bv_group_templateName').removeClass 'input_error error'

	handleRegCmpdsClicked: ->
		console.log "register compounds"
		console.log @assignedPropertiesListController.collection.models
		$.ajax
			type: 'POST'
			url: "/api/cmpdRegBulkLoader"
			data:
				properties: JSON.stringify @assignedPropertiesListController.collection.models
			success: (response) =>
				@trigger 'saveComplete', response
			error: (err) =>
				@serviceReturn = null
				#TODO handle save error
			dataType: 'json'


class window.BulkRegCmpdsController extends Backbone.View
	template: _.template($("#BulkRegCmpdsView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@disableAllInputs()
		@setupDetectSdfPropertiesController()
		@setupAssignSdfPropertiesController()

	setupDetectSdfPropertiesController: ->
		@detectSdfPropertiesController = new DetectSdfPropertiesController
			el: @$('.bv_detectSdfProperties')
		@detectSdfPropertiesController.on 'propsDetected', (properties) =>
			@assignSdfPropertiesController.createPropertyCollections(properties)
			@detectSdfPropertiesController.showSdfProperties(@assignSdfPropertiesController.sdfPropertiesList)
			@$('.bv_assignProperties').show()
			@$('.bv_saveOptions').show()
			@$('.bv_regCmpds').show()
		@detectSdfPropertiesController.on 'resetAssignProps', =>
			if @assignSdfPropertiesController?
				@assignSdfPropertiesController.undelegateEvents()
			@setupAssignSdfPropertiesController()
		@detectSdfPropertiesController.render()

	setupAssignSdfPropertiesController: =>
		console.log "setupAssignSdfPropertiesController"
		@assignSdfPropertiesController = new AssignSdfPropertiesController
			el: @$('.bv_assignSdfProperties')
		@assignSdfPropertiesController.on 'templateChanged', (template) =>
			@detectSdfPropertiesController.handleTemplateChanged(template)
		@assignSdfPropertiesController.on 'saveComplete', (saveSummary) =>
			@trigger 'saveComplete', saveSummary

	disableAllInputs: ->
		@$('input').attr 'disabled', 'disabled'
		@$('button').attr 'disabled', 'disabled'
		@$('select').attr 'disabled', 'disabled'
		@$("textarea").attr 'disabled', 'disabled'

class window.BulkRegCmpdsSummaryController extends Backbone.View
	template: _.template($("#BulkRegCmpdsSummaryView").html())

	events:
		"click .bv_loadAnother": "handleLoadAnotherSDF"
		"click .bv_downloadSummary": "handleDownloadSummary"
	initialize: ->
		$(@el).empty()
		$(@el).html @template()

	handleLoadAnotherSDF: ->
		@trigger 'loadAnother'

class window.CmpdRegBulkLoaderAppController extends Backbone.View
	template: _.template($("#CmpdRegBulkLoaderAppView").html())

	events:
		"click .bv_test": "handleTest"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		$(@el).addClass 'CmpdRegBulkLoaderAppController'
		@setupBulkRegCmpdsController()

	handleTest: ->
		console.log "test passed"
#		@$('.bv_drop').dropdown('toggle')

	setupBulkRegCmpdsController: ->
		@regCmpdsController = new BulkRegCmpdsController
			el: @$('.bv_bulkReg')
		@regCmpdsController.on 'saveComplete', =>
			console.log "SAVE complete"
			@$('.bv_bulkReg').hide()
			@setupBulkRegCmpdsSummaryController()

	setupBulkRegCmpdsSummaryController: ->
		@regCmpdsSummaryController = new BulkRegCmpdsSummaryController
			el: @$('.bv_bulkRegSummary')
		@regCmpdsSummaryController.on 'loadAnother', =>
			if @regCmpdsController?
				@regCmpdsController.undelegateEvents()
			@setupBulkRegCmpdsController()
			@$('.bv_bulkRegSummary').hide()
			@$('.bv_bulkReg').show()