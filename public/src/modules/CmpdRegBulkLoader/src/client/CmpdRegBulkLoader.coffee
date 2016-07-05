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

#	validate: (attrs) =>
#		errors = []
#		if attrs.required and attrs.dbProperty != "corporate id" and attrs.dbProperty != "Project" and attrs.defaultVal == ""
#			errors.push
#				attribute: 'defaultVal'
#				message: 'A default value must be assigned'
#		if errors.length > 0
#			return errors
#		else
#			return null

	validateProject: ->
		projectError = []
		if @get('required') and @get('dbProperty') == "Project" and @get('defaultVal') == "unassigned"
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
				unless currentDbProp is "none" or currentDbProp is "Parent Common Name" or currentDbProp is "Parent LiveDesign Corp Name" or currentDbProp is "Parent Alias" or currentDbProp is "Lot Alias"
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
		if saltEquiv?
			if saltId?
				if saltId.get('defaultVal') is ""
					errors.push
						attribute: 'defaultVal:eq('+@indexOf(saltId)+')'
						message: "Salt equivalent requires default value for salt type/id property"
			if saltType?
				if saltType.get('defaultVal') is ""
					errors.push
						attribute: 'defaultVal:eq('+@indexOf(saltType)+')'
						message: "Salt equivalent requires default value for salt type/id property"
		errors

class window.BulkLoadFile extends Backbone.Model

class window.BulkLoadFileList extends Backbone.Collection
	model: BulkLoadFile

class window.DetectSdfPropertiesController extends Backbone.View
	template: _.template($("#DetectSdfPropertiesView").html())

	events: ->
		"click .bv_readMore": "readMoreRecords"
		"click .bv_readAll": "readAllRecords"

	initialize: ->
		@numRecords = 100
		@tempName = "none"
		@mappings = new AssignedPropertiesList()
		@fileName = null

	render: ->
		$(@el).empty()
		$(@el).html @template()
		@disableInputs()
		@setupBrowseFileController()

	setupBrowseFileController: =>
		@browseFileController = new LSFileChooserController
			el: @$('.bv_browseSdfFile')
			formId: 'fieldBlah',
			maxNumberOfFiles: 1,
			requiresValidation: false
			url: UtilityFunctions::getFileServiceURL()
			allowedFileTypes: ['sdf']
		@browseFileController.on 'amDirty', =>
			@trigger 'amDirty'
		@browseFileController.on 'amClean', =>
			@trigger 'amClean'
		@browseFileController.render()
		@browseFileController.on('fileUploader:uploadComplete', @handleFileUploaded)
		@browseFileController.on('fileDeleted', @handleFileRemoved)

	handleFileUploaded: (fileName) =>
		@fileName = fileName
		@trigger 'fileChanged', @fileName
		@getProperties()

	getProperties: =>
		@$('.bv_detectedSdfPropertiesList').html "Loading..."
		@disableInputs()
		@$('.bv_deleteFile').attr 'disabled','disabled'
		if @mappings instanceof Backbone.Collection
			mappings = @mappings.toJSON()
		else
			mappings = @mappings

		if @tempName is "none"
			templateName = null
		else
			templateName = @tempName
		sdfInfo =
			fileName: @fileName
			numRecords: @numRecords
			templateName: templateName
			mappings: mappings
			userName: window.AppLaunchParams.loginUser.username
		$.ajax
			type: 'POST'
			url: "/api/cmpdRegBulkLoader/readSDF"
			data: sdfInfo
			success: (response) =>
				@handlePropertiesDetected(response)
				@$('.bv_deleteFile').removeAttr 'disabled'
			error: (err) =>
				@handleReadError(err)
				@serviceReturn = null
			dataType: 'json'

	handlePropertiesDetected: (response) ->
		if response is "Error"
			@handleReadError(response)
		else
			@trigger 'propsDetected', response

	handleReadError: (err) ->
		@$('.bv_detectedSdfPropertiesList').addClass 'readError'
		@$('.bv_detectedSdfPropertiesList').html "An error occurred reading the SD file. Please retry upload or contact an administrator."

	handleFileRemoved: =>
		@disableInputs()
		@$('.bv_detectedSdfPropertiesList').html ""
		@fileName = null
		@numRecords = 100
		@$('.bv_recordsRead').html 0
		@trigger 'resetAssignProps'
		@trigger 'fileChanged', @fileName

	updatePropertiesRead: (sdfPropsList, numRecordsRead) ->
		@$('.bv_detectedSdfPropertiesList').removeClass 'readError'

		if @numRecords == -1 or (@numRecords > numRecordsRead)
			@numRecords = numRecordsRead
		else
			@$('.bv_readMore').removeAttr('disabled')
			@$('.bv_readAll').removeAttr('disabled')
		@$('.bv_recordsRead').html @numRecords
		newLine = "&#13;&#10;"
		props = ""
		sdfPropsList.each (prop) ->
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
		if @model.get('dbProperty') is "none"
			@$('.bv_defaultVal').attr 'disabled', 'disabled'

		@

	setupDbPropertiesSelect: ->
		formattedDbProperties = @formatDbSelectOptions()
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
			if code.toLowerCase().indexOf("date") > -1
				name += " (YYYY-MM-DD or MM-DD-YYYY)"
			newOption = new PickList
				code: code
				name: name
			formattedOptions.add newOption
		formattedOptions

	handleDbPropertyChanged: ->
		dbProp = @dbPropertiesListController.getSelectedCode()
		if dbProp is "none" or dbProp is "corporate id"
			@$('.bv_defaultVal').attr('disabled', 'disabled')
		else
			@$('.bv_defaultVal').removeAttr('disabled')
		propInfo = @dbPropertiesList.findWhere({name: dbProp})
		if propInfo?
			if propInfo.get('required')
				@model.set required: true
			else
				@model.set required: false
		else
			@model.set required: false
		@model.set dbProperty: dbProp

		@trigger 'assignedDbPropChanged'

	handleDefaultValChanged: ->
		@model.set defaultVal: UtilityFunctions::getTrimmedInput @$('.bv_defaultVal')

	clear: =>
		@model.destroy()
		@trigger 'modelRemoved'

class window.AssignedPropertiesListController extends AbstractFormController
	template: _.template($("#AssignedPropertiesListView").html())

	events:
		"click .bv_addDbProperty": "addNewProperty"

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
		apc = new AssignedPropertyController
			model: prop
			dbPropertiesList: @dbPropertiesList
		apc.on 'assignedDbPropChanged', =>
			@trigger 'assignedDbPropChanged'
		apc.on 'modelRemoved', =>
			@collection.trigger 'change'
		unless (window.conf.cmpdReg.showProjectSelect and prop.get('dbProperty') is "Project")
			@$('.bv_propInfo').append apc.render().el
		if canDelete
			apc.$('.bv_deleteProperty').show()



class window.AssignSdfPropertiesController extends Backbone.View
	template: _.template($("#AssignSdfPropertiesView").html())

	events:
		"change .bv_dbProject": "handleDbProjectChanged"
		"keyup .bv_fileDate": "handleFileDateChanged"
		"change .bv_fileDate": "handleFileDateChanged" #have this here too for when you set date using date icon
		"click .bv_fileDateIcon": "handleFileDateIconClicked"
		"change .bv_useTemplate": "handleTemplateChanged"
		"change .bv_saveTemplate": "handleSaveTemplateCheckboxChanged"
		"keyup .bv_templateName": "handleNameTemplateChanged"
		"change .bv_overwrite": "handleOverwriteRadioSelectChanged"
		"click .bv_regCmpds": "handleRegCmpdsClicked"

	initialize: ->
		@fileName = null
		@project = false
		$(@el).empty()
		$(@el).html @template()
		@getAndFormatTemplateOptions()
		if window.conf.cmpdReg.showFileDate
			@$('.bv_group_fileDate').show()
			@fileDate = null
			@$('.bv_fileDate').datepicker();
			@$('.bv_fileDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		else
			@$('.bv_group_fileDate').hide()
		if window.conf.cmpdReg.showProjectSelect
			@setupProjectSelect()
			@isValid()
		else
			@$('.bv_group_dbProject').hide()
		@setupAssignedPropertiesListController()

	getAndFormatTemplateOptions: ->
		$.ajax
			type: 'GET'
			url: "/api/cmpdRegBulkLoader/templates/"+window.AppLaunchParams.loginUser.username
			dataType: 'json'
			success: (response) =>
				@templates = new Backbone.Collection response
				@translateIntoPicklistFormat()
			error: (err) =>
				@serviceReturn = null

	translateIntoPicklistFormat:  ->
		templatePickList = new PickListList()
		@templates.each (temp) =>
			option = new PickList()
			option.set
				code: temp.get('templateName')
				name: temp.get('templateName')
				ignored: temp.get('ignored')
			templatePickList.add(option)
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
		@projectList.url = "/cmpdreg/projects"
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
		@sdfPropertiesList = new SdfPropertiesList properties.sdfProperties
		@dbPropertiesList = new DbPropertiesList properties.dbProperties
		@assignedPropertiesList = new AssignedPropertiesList properties.bulkLoadProperties
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
		@sdfPropertiesList.each (sdfProp) =>
			sdfProperty = sdfProp.get('name')
			unless @assignedPropertiesList.findWhere({sdfProperty: sdfProperty})?
				newAssignedProp = new AssignedProperty
					dbProperty: "none"
					required: false
					sdfProperty: sdfProperty
				@assignedPropertiesList.add newAssignedProp

	handleFileChanged: (newFileName) ->
		@fileName = newFileName

	handleDbProjectChanged: ->
		#this function only gets called if project select is shown in the configuration part of the GUI
		project = @projectListController.getSelectedCode()
		@project = project # set the selected
		@isValid()
		@trigger 'projectChanged', project

	handleFileDateChanged: ->
		if UtilityFunctions::getTrimmedInput(@$('.bv_fileDate')) is ""
			@fileDate = null
		else
			@fileDate = UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_fileDate'))
		@isValid()

	handleFileDateIconClicked: =>
		@$( ".bv_fileDate" ).datepicker( "show" )

	handleTemplateChanged: ->
		templateName = @templateListController.getSelectedCode()
		if templateName is "none"
			mappings = new AssignedPropertiesList()
		else
			mappings = new AssignedPropertiesList (JSON.parse(@templates.findWhere({templateName: templateName}).get('jsonTemplate')))
		@trigger 'templateChanged', templateName, mappings

	handleSaveTemplateCheckboxChanged: ->
		saveTemplateChecked = @$('.bv_saveTemplate').is(":checked")
		if saveTemplateChecked
			@$('.bv_templateName').removeAttr('disabled')
			currentTempName = @templateListController.getSelectedCode()
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
		if @templateList.findWhere({name: tempName})? #and tempName.toLowerCase() != "none"
			@$('.bv_overwriteMessage').html tempName+" already exists. Overwrite?"
			@$('.bv_overwriteWarning').show()
			@$('input[name="bv_overwrite"][value="no"]').prop('checked',true)
			@$('.bv_overwrite').change()
		else
			@$('.bv_overwriteWarning').hide()
			@isValid()

	handleOverwriteRadioSelectChanged: =>
		@isValid()

	showUnassignedDbProperties: ->
		reqDbProp = @dbPropertiesList.getRequired()
		unassignedDbProps = ""
		newLine = "&#13;&#10;"
		for prop in reqDbProp
			name = prop.get('name')
			unless @assignedPropertiesList.findWhere({dbProperty: name})?
				if unassignedDbProps == ""
					unassignedDbProps = name
				else
					unassignedDbProps += newLine + name
		if @assignedPropertiesList.findWhere({dbProperty: 'salt id'})? or @assignedPropertiesList.findWhere({dbProperty: 'salt type'})?
			unless @assignedPropertiesList.findWhere({dbProperty: 'salt equivalents'})?
				unassignedDbProps += newLine + 'salt equivalents (required for salt type/id)'
		if @assignedPropertiesList.findWhere({dbProperty: 'salt equivalents'})?
			unless (@assignedPropertiesList.findWhere({dbProperty: 'salt id'})? or @assignedPropertiesList.findWhere({dbProperty: 'salt type'})?)
				unassignedDbProps += newLine + 'salt id/type (required for salt equivalents)'
		@$('.bv_unassignedProperties').html unassignedDbProps
		@isValid()

	isValid: =>
		@clearValidationErrorStyles()
		validCheck = true
		validAp = @validateAssignedProperties()
		unless validAp
			validCheck = false
		otherErrors = []
		if window.conf.cmpdReg.showProjectSelect
			otherErrors.push @getProjectErrors()...
		if window.conf.cmpdReg.showFileDate
			otherErrors.push @getFileDateErrors()...
		if @assignedPropertiesList?
			otherErrors.push @assignedPropertiesList.checkDuplicates()...
			otherErrors.push @assignedPropertiesList.checkSaltProperties()...
		otherErrors.push @getTemplateErrors()...
		@showValidationErrors(otherErrors)
		unless @$('.bv_unassignedProperties').html() == ""
			validCheck = false
		if otherErrors.length > 0
			validCheck = false

		if validCheck
			@$('.bv_regCmpds').removeAttr('disabled')
		else
			@$('.bv_regCmpds').attr 'disabled','disabled'

		validCheck

	getProjectErrors: ->
		projectError = []
		if @projectListController.getSelectedCode() is "unassigned" or @projectListController.getSelectedCode() is null
			projectError.push
				attribute: 'dbProject'
				message: 'Project must be selected'
		projectError

	validateAssignedProperties: ->
		validCheck = true
		if @assignedPropertiesList?
			@assignedPropertiesList.each (model) =>
				validModel = model.isValid()
				if validModel is false
					validCheck = false
		validCheck

	getFileDateErrors: ->
		fileDateErrors = []
		if _.isNaN(@fileDate) and @fileDate != null
			fileDateErrors.push
				attribute: 'fileDate'
				message: "File date must be a valid date"
		fileDateErrors

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
		@$('.bv_group_templateName').addClass 'input_error error'
		@$('.bv_group_templateName').attr('data-toggle', 'tooltip')
		@$('.bv_group_templateName').attr('data-placement', 'bottom')
		@$('.bv_group_templateName').attr('data-original-title', errMessage)
		@$("[data-toggle=tooltip]").tooltip();

	handleRegCmpdsClicked: ->
		@$('.bv_regCmpds').attr 'disabled', 'disabled'
		@$('.bv_registering').show()
		saveTemplateChecked = @$('.bv_saveTemplate').is(":checked")
		if saveTemplateChecked
			@saveTemplate()
		else
			@registerCompounds()

	saveTemplate: ->
		templateName = UtilityFunctions::getTrimmedInput(@$('.bv_templateName'))
		dataToPost =
			templateName: templateName
			jsonTemplate: JSON.stringify @assignedPropertiesListController.collection.models
			recordedBy: window.AppLaunchParams.loginUser.username
			ignored: false
		$.ajax
			type: 'POST'
			url: "/api/cmpdRegBulkLoader/saveTemplate"
			data: dataToPost
			success: (response) =>
				if response.id?
					@registerCompounds()
				else
					@handleSaveTemplateError()
			error: (err) =>
				@serviceReturn = null
				@handleSaveTemplateError()
			dataType: 'json'

	handleSaveTemplateError: ->
		@$('.bv_registering').hide()
		@$('.bv_saveErrorModal').modal('show')
		@$('.bv_saveErrorTitle').html "Error: Template Not Saved"
		@$('.bv_errorMessage').html "An error occurred while trying to save the template. The compounds have not been registered yet. Please try again or contact an administrator."

	addProjectToMappingsPayLoad: ->
		if @project?
			dbProjectProperty = new AssignedProperty
				dbProperty: "Project"
				required: true
				sdfProperty: null
				defaultVal: @project
			@assignedPropertiesListController.collection.add dbProjectProperty

	registerCompounds: ->
		@addProjectToMappingsPayLoad()
		dataToPost =
			fileName: @fileName
			mappings: JSON.parse(JSON.stringify(@assignedPropertiesListController.collection.models))
			userName: window.AppLaunchParams.loginUser.username
		if window.conf.cmpdReg.showFileDate
			dataToPost.fileDate = @fileDate
		$.ajax
			type: 'POST'
			url: "/api/cmpdRegBulkLoader/registerCmpds"
			data: dataToPost
			timeout: 6000000
			success: (response) =>
				@$('.bv_registering').hide()
				if response is "Error"
					@handleRegisterCmpdsError()
				else
					@trigger 'saveComplete', response
			error: (err) =>
				@serviceReturn = null
				@handleRegisterCmpdsError()
			dataType: 'json'

	handleRegisterCmpdsError: ->
		@$('.bv_registering').hide()
		@$('.bv_saveErrorModal').modal('show')
		@$('.bv_saveErrorTitle').html "Error: Compounds Not Registered"
		@$('.bv_errorMessage').html "An error occurred while trying to register the compounds. Please try again or contact an administrator."

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
		@assignSdfPropertiesController = new AssignSdfPropertiesController
			el: @$('.bv_assignSdfProperties')
		@detectSdfPropertiesController.on 'fileChanged', (newFileName) =>
			@assignSdfPropertiesController.handleFileChanged newFileName
		@assignSdfPropertiesController.on 'templateChanged', (templateName, mappings) =>
			@detectSdfPropertiesController.handleTemplateChanged(templateName, mappings)
		@assignSdfPropertiesController.on 'saveComplete', (saveSummary) =>
			@trigger 'saveComplete', saveSummary

	handleSdfPropertiesDetected: (properties) =>
		@$('.bv_templateWarning').hide()
		@$('.bv_templateWarning').html ""
		for err in properties.errors
			if err["level"] is "warning"
				@$('.bv_templateWarning').append '<div class="alert" style="margin-left: 105px;margin-right: 100px;width: 550px;margin-top: 10px;margin-bottom: 0px;">'+err["message"]+'</div>'
				@$('.bv_templateWarning').show()
		@assignSdfPropertiesController.createPropertyCollections(properties)
		@detectSdfPropertiesController.mappings = @assignSdfPropertiesController.assignedPropertiesList
		@detectSdfPropertiesController.updatePropertiesRead(@assignSdfPropertiesController.sdfPropertiesList, properties.numRecordsRead)
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

class window.FileRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#FileRowSummaryView').html())

	render: =>
		fileDate = @model.get('fileDate')
		if fileDate is null
			fileDate = ""
		else
			fileDate = UtilityFunctions::convertMSToYMDDate(fileDate)
		toDisplay =
			fileName: @model.get('fileName')
			loadDate: fileDate
			loadUser: @model.get('recordedBy')
		$(@el).html(@template(toDisplay))

		@

class window.FileSummaryTableController extends Backbone.View
	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#FileSummaryTableView').html())
		$(@el).html @template
		if @collection.models.length is 0
			$(".bv_noFilesFoundMessage").removeClass "hide"
			# display message indicating no files were found
		else
			$(".bv_noFilesFoundMessage").addClass "hide"
			@collection.each (file) =>
				frsc = new FileRowSummaryController
					model: file
				frsc.on "gotClick", @selectedRowChanged

				@$("tbody").append frsc.render().el
			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar

		@


class window.PurgeFilesController extends Backbone.View
	template: _.template($("#PurgeFilesView").html())

	events:
		"click .bv_purgeFileBtn": "handlePurgeFileBtnClicked"
		"click .bv_cancelPurge": "handleCancelBtnClicked"
		"click .bv_confirmPurgeFileButton": "handleConfirmPurgeFileBtnClicked"
		"click .bv_okay": "handleOkayClicked"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_purgeFileBtn').attr 'disabled', 'disabled'
		@$('.bv_purgeSummaryWrapper').hide()
		@fileInfoToPurge = null
		@fileNameToPurge = null
		@getFiles()

	getFiles: ->
		$.ajax
			type: 'GET'
			url: "/api/cmpdRegBulkLoader/getFilesToPurge"
			dataType: "json"
			success: (response) =>
				@setupFileSummaryTable(response)
			error: (err) =>
				@handleGetFilesError()

	setupFileSummaryTable: (files) ->
		if files.length == 0
			$('.bv_fileTableController').addClass "well"
			$('.bv_fileTableController').html "No files to purge"
			$('.bv_purgeFileBtn').hide()
		else
			@fileSummaryTable = new FileSummaryTableController
				collection: new BulkLoadFileList files

			@fileSummaryTable.on "selectedRowUpdated", @selectedFileUpdated
			$(".bv_fileTableController").html @fileSummaryTable.render().el

	handleGetFilesError: ->
		$('.bv_fileTableController').addClass "well"
		$('.bv_fileTableController').html "An error occurred when getting files to purge. Please try refreshing the page or contact an administrator."
		$('.bv_purgeFileBtn').hide()

	selectedFileUpdated: (file) =>
		@fileInfoToPurge = file
		@fileNameToPurge = file.get('fileName')
#		@$('.bv_requestedPurgeFileName').html @fileNameToPurge
		@$('.bv_purgeFileBtn').removeAttr 'disabled'

	handlePurgeFileBtnClicked: ->
		@$('.bv_purgeFileBtn').attr 'disabled', 'disabled'
		@$('.bv_purgeSummaryWrapper').hide()
		@$('.bv_purging').hide()
		@$('.bv_purgeButtons').show()
		@$('.bv_dependencyCheckModal').modal
			backdrop: 'static'
		fileInfo =
			fileInfo: JSON.parse(JSON.stringify @fileInfoToPurge)
		$.ajax
			type: 'POST'
			url: "/api/cmpdRegBulkLoader/checkFileDependencies"
			data: fileInfo
			dataType: 'json'
			success: (response) =>
				if response.canPurge
					@$('.bv_showDependenciesTitle').html "Confirm Purge"
					@$('.bv_cancelPurge').show()
					@$('.bv_confirmPurgeFileButton').show()
					@$('.bv_okay').hide()
				else
					@$('.bv_showDependenciesTitle').html "Can Not Purge"
					@$('.bv_cancelPurge').hide()
					@$('.bv_confirmPurgeFileButton').hide()
					@$('.bv_okay').show()
				@$('.bv_dependenciesSummary').html response.summary
				@$('.bv_dependencyCheckModal').modal "hide"
				@$('.bv_showDependenciesModal').modal
					backdrop: 'static'

			error: (err) =>
				@serviceReturn = null
				@$('.bv_dependencyCheckModal').modal "hide"
				@$('.bv_dependenciesCheckErrorModal').modal 'show'
#					backdrop: 'static'
				@$('.bv_dependenciesCheckError').html "There has been an error checking the dependencies. Please try again or contact an administrator."

	handleCancelBtnClicked: ->
		@$('.bv_showDependenciesModal').modal "hide"

	handleConfirmPurgeFileBtnClicked: ->
		@$('.bv_purgeButtons').hide()
		@$('.bv_purging').show()
		fileInfo =
			fileInfo: JSON.parse(JSON.stringify @fileInfoToPurge)
		$.ajax
			type: 'POST'
			url: "/api/cmpdRegBulkLoader/purgeFile"
			data: fileInfo
			dataType: 'json'
			success: (response) =>
				@$('.bv_purging').hide()
				if response.success
					@handlePurgeSuccess(response)
				else
					@handlePurgeError()
			error: (err) =>
				@serviceReturn = null
				@handlePurgeError()

	handleOkayClicked: ->
		@$('.bv_showDependenciesModal').modal "hide"

	handlePurgeSuccess: (response) =>
		@$('.bv_showDependenciesModal').modal "hide"
#		@$('.bv_filePurgedSuccessfullyMessage').show()
		@$('.bv_purgeSummary').html response.summary
		downloadUrl = window.conf.datafiles.downloadurl.prefix + "cmpdreg_bulkload/" + response.fileName
		@$('.bv_purgedFileName').attr "href", downloadUrl
		@$('.bv_purgedFileName').html response.fileName
		@$('.bv_purgeSummaryWrapper').show()
		@fileInfoToPurge = null
		@fileNameToPurge = null
		@getFiles()

	handlePurgeError: ->
		@$('.bv_purgeSummary').html "An error occurred purging the file: "+ @fileNameToPurge + " .Please try again or contact an administrator."
		@$('.bv_purgeSummaryWrapper').show()
		@fileInfoToPurge = null
		@fileNameToPurge = null
		@getFiles()

class window.CmpdRegBulkLoaderAppController extends Backbone.View
	template: _.template($("#CmpdRegBulkLoaderAppView").html())

	events:
		"click .bv_bulkRegDropdown": "handleBulkRegDropdownSelected"
		"click .bv_purgeFileDropdown": "handlePurgeFileDropdownSelected"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		$(@el).addClass 'CmpdRegBulkLoaderAppController'
		if window.conf.cmpdReg?.projectName?
			projectName = window.conf.cmpdReg.projectName
			@$('.bv_headerName').html "BULK COMPOUND REGISTRATION: Project "+ projectName
		else
			@$('.bv_headerName').html "BULK COMPOUND REGISTRATION"

		@$('.bv_loginUserFirstName').html window.AppLaunchParams.loginUser.firstName
		@$('.bv_loginUserLastName').html window.AppLaunchParams.loginUser.lastName
		if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, [window.conf.roles.cmpdreg.adminRole]
			@$('.bv_adminDropdownWrapper').show()
		else
			@$('.bv_adminDropdownWrapper').hide()
		@$('.bv_searchNavOption').hide()
		if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, [window.conf.roles.cmpdreg.chemistRole]
			@setupBulkRegCmpdsController()
			@$('.bv_registerDropdown').show()
		else
			@$('.bv_bulkReg').html "You do not have permission to register compounds."
			@$('.bv_registerDropdown').hide()


	handleBulkRegDropdownSelected: ->
		unless @$('.bv_bulkReg').is(':visible')
			@$('.bv_bulkReg').show()
			@setupBulkRegCmpdsController()
			@$('.bv_bulkRegSummary').hide()
			@$('.bv_purgeFiles').hide()
		@$('.bv_registerDropdown').dropdown('toggle')

	handlePurgeFileDropdownSelected: ->
		unless @$('.bv_purgeFiles').is(':visible')
			@$('.bv_bulkReg').hide()
			@$('.bv_bulkRegSummary').hide()
			@$('.bv_purgeFiles').show()
			@setupPurgeFilesController()
		@$('.bv_adminDropdown').dropdown('toggle')

	setupBulkRegCmpdsController: ->
		@regCmpdsController = new BulkRegCmpdsController
			el: @$('.bv_bulkReg')
		@regCmpdsController.on 'saveComplete', (summary) =>
			@$('.bv_bulkReg').hide()
			@$('.bv_bulkRegSummary').show()
			@setupBulkRegCmpdsSummaryController(summary[0])
			downloadUrl = window.conf.datafiles.downloadurl.prefix + "cmpdreg_bulkload/" +summary[1]
			@$('.bv_downloadSummary').attr "href", downloadUrl

	setupBulkRegCmpdsSummaryController: (summary) ->
		if @regCmpdsSummaryController?
			@regCmpdsSummaryController.undelegateEvents()
		@regCmpdsSummaryController = new BulkRegCmpdsSummaryController
			el: @$('.bv_bulkRegSummary')
			summaryHTML: summary['summary']
		@regCmpdsSummaryController.render()
		@regCmpdsSummaryController.on 'loadAnother', =>
			if @regCmpdsController?
				@regCmpdsController.undelegateEvents()
			@setupBulkRegCmpdsController()
			@$('.bv_bulkRegSummary').hide()
			@$('.bv_bulkReg').show()

	setupPurgeFilesController: ->
		if @purgeFilesController?
			@purgeFilesController.undelegateEvents()
		@purgeFilesController = new PurgeFilesController
			el: @$('.bv_purgeFiles')