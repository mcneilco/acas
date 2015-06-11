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
		if attrs.required and attrs.dbProperty != "corporate id" and attrs.dbProperty != "project" and attrs.defaultVal == ""
			errors.push
				attribute: 'defaultVal'
				message: 'A default value must be assigned'
		if errors.length > 0
			return errors
		else
			return null

	validateProject: ->
		console.log "validate project"
		console.log @
		projectError = []
		if @get('required') and @get('dbProperty') == "project" and @get('defaultVal') == "unassigned"
			projectError. push
				attribute: 'dbProject'
				message: 'Project must be selected'
		projectError

class window.AssignedPropertiesList extends Backbone.Collection
	model: AssignedProperty

	checkDuplicates: =>
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
		duplicates

	checkSaltProperties: =>
		errors = []
		saltId = @findWhere({dbProperty:'salt id'})
		saltType = @findWhere({dbProperty:'salt type'})
		saltEquiv = @findWhere({dbProperty:'salt equivalents'})
		if (saltId? or saltType?)
			if saltEquiv?
				if saltEquiv.get('defaultVal') is ""
					errors.push
						attribute: 'defaultVal:eq('+@indexOf(saltEquiv)+')'
						message: "Salt type/id requires default value for salt equivalents property"
		errors

class window.DetectSdfPropertiesController extends Backbone.View
	template: _.template($("#DetectSdfPropertiesView").html())

	events: ->
		"click .bv_readMore": "readMoreRecords"
		"click .bv_readAll": "readAllRecords"

	initialize: ->
		@numRecords = 100
		@tempName = "none"
		@mappings = null
		@project = "unassigned"

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
		@$('.bv_detectedSdfPropertiesList').html "Loading..."
		@disableInputs()
		@$('.bv_deleteFile').attr 'disabled','disabled'
		mappings = null
		if @mappings instanceof Backbone.Collection
			console.log "@mappings is backbonecollection"
			console.log @mappings
			mappings = @mappings.toJSON()
		else
			mappings = @mappings
		console.log "mappings"
		console.log mappings
		if window.conf.cmpdReg.showProjectSelect
			#add selected project to mappings
			mappingsCollection = new Backbone.Collection mappings #change to collection to be able to search for project property
			projectProp = mappingsCollection.findWhere({dbProperty:'project'})
			if projectProp?
				projectProp.set defaultVal: @project
				mappings = mappingsCollection.toJSON()
			else
				if mappings == null
					mappings = []
				mappings.push
					dbProperty: 'project'
					sdfProperty: null
					required: true
					defaultVal: @project

		sdfInfo =
			fileName: @fileName
			numRecords: @numRecords
			templateName: @tempName
			mappings: mappings
		console.log "about to read sdf"
		$.ajax
			type: 'POST'
			url: "/api/cmpdRegBulkLoader/readSDF"
			data: sdfInfo
			success: (response) =>
				console.log "successful read of SDF"
				@handlePropertiesDetected(response)
				@$('.bv_deleteFile').removeAttr 'disabled'
			error: (err) =>
				console.log "error reading sdf"
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
		if @numRecords == -1
			@$('.bv_recordsRead').html 'All'
			#TODO: can/should service return with total number of records?
		else
			@$('.bv_recordsRead').html @numRecords
			@$('.bv_readMore').removeAttr('disabled')
			@$('.bv_readAll').removeAttr('disabled')
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

	disableInputs: ->
		@$('.bv_readMore').attr 'disabled', 'disabled'
		@$('.bv_readAll').attr 'disabled', 'disabled'

	readMoreRecords: ->
		@numRecords += 100
		@getProperties()

	readAllRecords: ->
		@numRecords = -1
		@getProperties()

	handleTemplateChanged: (templateName, mappings) =>
		@tempName = templateName
		@mappings = mappings
		if @fileName? and @fileName != null
			@getProperties()

	handleProjectChanged: (projectName) =>
		@project = projectName

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
		console.log @dbPropertiesList
		propInfo = @dbPropertiesList.findWhere({name: dbProp})
		console.log propInfo
		if propInfo?
			if propInfo.get('required')
				@model.set required: true
			else
				@model.set required: false
		else
			#dbProp = none
			@model.set required: false
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
		"change .bv_dbProject": "handleDbProjectChanged"
		"change .bv_useTemplate": "handleTemplateChanged"
		"change .bv_saveTemplate": "handleSaveTemplateCheckboxChanged"
		"keyup .bv_templateName": "handleNameTemplateChanged"
		"change .bv_overwrite": "handleOverwriteRadioSelectChanged"
		"click .bv_regCmpds": "handleRegCmpdsClicked"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@getAndFormatTemplateOptions()
		if window.conf.cmpdReg.showProjectSelect
			@setupProjectSelect()
			@isValid()
		else
			@$('.bv_group_dbProject').hide()
		@setupAssignedPropertiesListController()

	getAndFormatTemplateOptions: ->
		console.log "getting templates"
		console.log window.AppLaunchParams.loginUser.username
		$.ajax
			type: 'GET'
			url: "/api/cmpdRegBulkLoader/templates/"+window.AppLaunchParams.loginUser.username
			dataType: 'json'
			success: (response) =>
				console.log "got templates"
				@templates = new Backbone.Collection response
				console.log @templates
				@translateIntoPicklistFormat()
			error: (err) =>
				@serviceReturn = null

	translateIntoPicklistFormat:  ->
		templatePickList = new PickListList()
		@templates.each (temp) =>
			option = new PickList()
			option.set
				code: temp.get('template')
				name: temp.get('template')
				ignored: temp.get('ignored')
			templatePickList.add(option)
		console.log templatePickList
		@setupTemplateSelect(templatePickList)

	setupTemplateSelect: (templatePickList)->
		@templateList = templatePickList
		@templateListController = new PickListSelectController
			el: @$('.bv_useTemplate')
			collection: @templateList
			insertFirstOption: new PickList
				code: "none"
				name: "None"
			selectedCode: "none"
			autoFetch: false

	setupProjectSelect: ->
		@projectList = new PickListList()
		@projectList.url = "/api/projects"
		@projectListController = new PickListSelectController
			el: @$('.bv_dbProject')
			collection: @projectList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Project"
			selectedCode: "unassigned"

	setupAssignedPropertiesListController: ->
		@assignedPropertiesListController= new AssignedPropertiesListController
			el: @$('.bv_assignedPropertiesList')
			collection: new AssignedPropertiesList()
		@assignedPropertiesListController.on 'assignedDbPropChanged', =>
			@showUnassignedDbProperties()
		@assignedPropertiesListController.render()

	createPropertyCollections: (properties) ->
		console.log "handle props detected in app controller"
		console.log properties
		console.log properties.sdfProperties
		@sdfPropertiesList = new SdfPropertiesList properties.sdfProperties
		@dbPropertiesList = new DbPropertiesList properties.dbProperties
		#TODO: disable browsing for another file while service to read records is still running - perhaps have spinner that says "Reading..." or use modal
		@assignedPropertiesList = new AssignedPropertiesList properties.bulkloadProperties
		@assignedPropertiesList.on 'change', =>
			console.log "assigned props changed, trigger isvalid"
			@isValid()
		@addUnassignedSdfProperties()
		@assignedPropertiesListController.collection = @assignedPropertiesList
		@assignedPropertiesListController.dbPropertiesList = @dbPropertiesList
		@assignedPropertiesListController.render()
		@showUnassignedDbProperties()
		@$('.bv_addDbProperty').removeAttr('disabled')
		if window.conf.cmpdReg.showProjectSelect
			@handleDbProjectChanged()
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

	handleDbProjectChanged: ->
		#this function only gets called if project select is shown in the configuration part of the GUI
		console.log "handle Project changed"
		project = @projectListController.getSelectedCode()
		if @assignedPropertiesList?
			#file has already been read at least once
			assignedProjectProp = @assignedPropertiesList.findWhere({dbProperty: "project"})
			if assignedProjectProp?
				assignedProjectProp.set defaultVal: project
			else
				console.log "adding new assigned property"
				projectProp = new AssignedProperty
					sdfProperty: null
					dbProperty: "project"
					defaultVal: project
					required: true
				@assignedPropertiesList.add projectProp
		@isValid()
		@trigger 'projectChanged', project


	handleTemplateChanged: ->
		templateName = @templateListController.getSelectedCode()
		if templateName is "none"
			mappings = null
		else
			mappings = @templates.findWhere({template: templateName}).get('mappings')
		console.log "handle temp changed"
		console.log mappings
		@trigger 'templateChanged', templateName, mappings

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
			@isValid()

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
		if @assignedPropertiesList.findWhere({dbProperty: 'salt id'}) or @assignedPropertiesList.findWhere({dbProperty: 'salt type'})?
			unless @assignedPropertiesList.findWhere({dbProperty: 'salt equivalents'})?
				unassignedDbProps += newLine + 'salt equivalents (required for salt type/id)'
#		@unassignedDbProps = unassignedDbProps
		@$('.bv_unassignedProperties').html unassignedDbProps
		@isValid()

	isValid: =>
		@clearValidationErrorStyles()
		validCheck = true
		validAp = @validateAssignedProperties()
		unless validAp
			console.log "valid check false"
			validCheck = false
		otherErrors = []
		#Todo: use config to see if validateProp needs to be called
		if window.conf.cmpdReg.showProjectSelect
			otherErrors.push @getProjectErrors()...
		if @assignedPropertiesList?
			otherErrors.push @assignedPropertiesList.checkDuplicates()...
			otherErrors.push @assignedPropertiesList.checkSaltProperties()...
		otherErrors.push @getTemplateErrors()...
		@showValidationErrors(otherErrors)
		unless @$('.bv_unassignedProperties').html() == ""
			console.log "has unassigned db props"
			console.log "valid check false"
			validCheck = false
		if otherErrors.length > 0
			console.log "valid check false"
			validCheck = false

		if validCheck
			@$('.bv_regCmpds').removeAttr('disabled')
		else
			@$('.bv_regCmpds').attr 'disabled','disabled'

	getProjectErrors: ->
		projectError = []
		if @assignedPropertiesList?
			projectProp = @assignedPropertiesList.findWhere({dbProperty:'project'})
			if projectProp?
				projectError = projectProp.validateProject()
		else if window.conf.cmpdReg.showProjectSelect
			console.log @projectListController.getSelectedCode()
			if @projectListController.getSelectedCode() is "unassigned" or @projectListController.getSelectedCode() is null
				projectError.push
					attribute: 'dbProject'
					message: 'Project must be selected'
		projectError

	validateAssignedProperties: ->
		validCheck = true
		if @assignedPropertiesList?
			@assignedPropertiesList.each (model) =>
				console.log "isValid"
				console.log model
				validModel = model.isValid()
				if validModel is false
					validCheck = false
		validCheck

	getTemplateErrors: ->
		templateErrors = []
		saveTemplateChecked = @$('.bv_saveTemplate').is(":checked")
		if saveTemplateChecked
			if UtilityFunctions::getTrimmedInput(@$('.bv_templateName')) is ""
				templateErrors. push
					attribute: 'templateName'
					message: 'The template name must be set'

			else if @$('.bv_overwriteWarning').is(":visible") and @$('input[name="bv_overwrite"]:checked').val() is "no"
				templateErrors. push
					attribute: 'templateName'
					message: 'The template name should be unique'
		templateErrors

	showValidationErrors: (errors) =>
		console.log errors
		for err in errors
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

	handleRegCmpdsClicked: ->
		console.log "register compounds"
		console.log @assignedPropertiesListController.collection.models
		templateName = null
		saveTemplateChecked = @$('.bv_saveTemplate').is(":checked")
		if saveTemplateChecked
			templateName = UtilityFunctions::getTrimmedInput(@$('.bv_templateName'))
		dataToPost =
			templateName: templateName
			mappings: JSON.stringify @assignedPropertiesListController.collection.models
			recordedBy: window.AppLaunchParams.loginUser.username
			ignored: false
		$.ajax
			type: 'POST'
			url: "/api/cmpdRegBulkLoader"
			data: dataToPost
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
			@handleSdfPropertiesDetected(properties)
		@detectSdfPropertiesController.on 'resetAssignProps', =>
			if @assignSdfPropertiesController?
				@assignSdfPropertiesController.undelegateEvents()
			@setupAssignSdfPropertiesController()
		@detectSdfPropertiesController.render()

	setupAssignSdfPropertiesController: =>
		console.log "setupAssignSdfPropertiesController"
		@assignSdfPropertiesController = new AssignSdfPropertiesController
			el: @$('.bv_assignSdfProperties')
		@assignSdfPropertiesController.on 'templateChanged', (templateName, mappings) =>
			@detectSdfPropertiesController.handleTemplateChanged(templateName, mappings)
		@assignSdfPropertiesController.on 'projectChanged', (projectName) =>
			@detectSdfPropertiesController.handleProjectChanged(projectName)
		@assignSdfPropertiesController.on 'saveComplete', (saveSummary) =>
			@trigger 'saveComplete', saveSummary

	handleSdfPropertiesDetected: (properties) =>
		@assignSdfPropertiesController.createPropertyCollections(properties)
		@detectSdfPropertiesController.mappings = @assignSdfPropertiesController.assignedPropertiesList
		@detectSdfPropertiesController.showSdfProperties(@assignSdfPropertiesController.sdfPropertiesList)
		@$('.bv_assignProperties').show()
		@$('.bv_saveOptions').show()
		@$('.bv_regCmpds').show()

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
		if @options.summaryHTML?
			@summaryHTML = @options.summaryHTML
		else
			@summaryHTML = ""

	render: ->
		@$('.bv_regSummaryHTML').html @summaryHTML

	handleLoadAnotherSDF: ->
		@trigger 'loadAnother'

class window.PurgeFilesController extends Backbone.View
	template: _.template($("#PurgeFilesView").html())

	events:
		"click .bv_purgeFile": "handlePurgeFile"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()

	handlePurgeFile: ->
		#TODO: add implementation

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
		@regCmpdsController.on 'saveComplete', (summary) =>
			console.log "SAVE complete"
			@$('.bv_bulkReg').hide()
			@$('.bv_bulkRegSummary').show()
			@setupBulkRegCmpdsSummaryController(summary)

	setupBulkRegCmpdsSummaryController: (summary) ->
		if @regCmpdsSummaryController?
			@regCmpdsSummaryController.undelegateEvents()
		console.log summary
		@regCmpdsSummaryController = new BulkRegCmpdsSummaryController
			el: @$('.bv_bulkRegSummary')
			summaryHTML: summary
		@regCmpdsSummaryController.render()
		@regCmpdsSummaryController.on 'loadAnother', =>
			if @regCmpdsController?
				@regCmpdsController.undelegateEvents()
			@setupBulkRegCmpdsController()
			@$('.bv_bulkRegSummary').hide()
			@$('.bv_bulkReg').show()