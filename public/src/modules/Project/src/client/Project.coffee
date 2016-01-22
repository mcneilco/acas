class window.ProjectLeader extends Backbone.Model
	defaults: ->
		scientist: "unassigned"

class window.ProjectLeaderList extends Backbone.Collection
	model: ProjectLeader

	validateCollection: =>
		modelErrors = []
		usedLeaders={}
		if @.length != 0
			for index in [0..@.length-1]
				model = @.at(index)
				currentLeader = model.get('scientist')
				if currentLeader of usedLeaders
					modelErrors.push
						attribute: 'scientist:eq('+index+')'
						message: "The same scientist can not be chosen more than once"
					modelErrors.push
						attribute: 'scientist:eq('+usedLeaders[currentLeader]+')'
						message: "The same scientist can not be chosen more than once"
				else
					usedLeaders[currentLeader] = index
		modelErrors


class window.Project extends Thing
	urlRoot: "/api/things/project/project"
	className: "Project"

	initialize: ->
		@.set
			lsType: "project"
			lsKind: "project"
		super()


	lsProperties:

		defaultLabels: [
			key: 'project name'
			type: 'name'
			kind: 'project name'
			preferred: true
		,
			key: 'project alias'
			type: 'name'
			kind: 'project alias'
			preferred: false
#		,
#			key: 'live design id'
#			type: 'id'
#			kind: 'live design id'
#			preferred: false
		]

		defaultValues: [
			key: 'start date'
			stateType: 'metadata'
			stateKind: 'project metadata'
			type: 'dateValue'
			kind: 'start date'
		,
			key: 'project status'
			stateType: 'metadata'
			stateKind: 'project metadata'
			type: 'codeValue'
			kind: 'project status'
			codeType: 'project'
			codeKind: 'status'
			codeOrigin: 'ACAS DDICT'
			value: 'active'
		,
			key: 'short description'
			stateType: 'metadata'
			stateKind: 'project metadata'
			type: 'stringValue'
			kind: 'short description'
		,
			key: 'project details'
			stateType: 'metadata'
			stateKind: 'project metadata'
			type: 'clobValue'
			kind: 'project details'
		,
			key: 'live design id'
			stateType: 'metadata'
			stateKind: 'project metadata'
			type: 'numericValue'
			kind: 'live design id'
		]

		defaultFirstLsThingItx: [
		]

		defaultSecondLsThingItx: [
		]


	validate: (attrs) ->
		errors = []
		bestName = attrs.lsLabels.pickBestName()
		nameError = true
		if bestName?
			nameError = true
			if bestName.get('labelText') != "" and bestName.get('labelText') != "unassigned"
				nameError = false
		if nameError
			errors.push
				attribute: 'projectName'
				message: "Name must be set and unique"
		if attrs["project alias"]? #TODO: for now, will require alias to be filled in and unique
			alias = attrs["project alias"].get('labelText')
			if alias is "" or alias is undefined or alias is null
				errors.push
					attribute: 'projectAlias'
					message: "Alias must be set and unique"
		if errors.length > 0
			return errors
		else
			return null

	getAnalyticalFiles: (fileTypes) => #TODO: rename from analytical files to attachFiles or something more generic
#get list of possible kinds of analytical files
		attachFileList = new AttachFileList()
		for type in fileTypes
			analyticalFileState = @get('lsStates').getOrCreateStateByTypeAndKind "metadata", "project metadata"
			analyticalFileValues = analyticalFileState.getValuesByTypeAndKind "fileValue", type.code
			if analyticalFileValues.length > 0 and type.code != "unassigned"
#create new attach file model with fileType set to lsKind and fileValue set to fileValue
#add new afm to attach file list
				for file in analyticalFileValues
					unless file.get('ignored')
						afm = new AttachFile
							fileType: type.code
							fileValue: file.get('fileValue')
							id: file.get('id')
							comments: file.get('comments')
						attachFileList.add afm

		attachFileList

	getProjectLeaders: =>
		projMetaState = @get('lsStates').getStatesByTypeAndKind("metadata", "project metadata")[0]
		projLeaders = projMetaState.getValuesByTypeAndKind "codeValue", "project leader"
		projLeaders

	prepareToSave: ->
		rBy = @get('recordedBy')
		rDate = new Date().getTime()
		@set recordedDate: rDate
		@get('lsLabels').each (lab) =>
			@setRByAndRDate lab
		@get('lsStates').each (state) =>
			@setRByAndRDate state
			state.get('lsValues').each (val) =>
				@setRByAndRDate val
		if @get('secondLsThings')?
			@get('secondLsThings').each (itx) =>
				@setRByAndRDate itx
				itx.get('lsStates').each (state) =>
					@setRByAndRDate state
					state.get('lsValues').each (val) =>
						@setRByAndRDate val

	setRByAndRDate: (data) ->
		rBy = @get('recordedBy')
		rDate = new Date().getTime()
		unless data.get('recordedBy') != ""
			data.set recordedBy: rBy
		unless data.get('recordedDate') != null
			data.set recordedDate: rDate

class window.ProjectList extends Backbone.Collection
	model: Project


class window.ProjectLeaderController extends AbstractFormController
	template: _.template($("#ProjectLeaderView").html())
	tagName: "div"

	events: ->
		"change .bv_scientist": "attributeChanged"
		"click .bv_deleteProjectLeader": "clear"

	initialize: ->
		@errorOwnerName = 'ProjectLeaderController'
		@setBindings()
		@model.on "destroy", @remove, @
#		@model.on "removeLeader", @trigger 'removeLeader'
#		if @options.firstOptionName?
#			@firstOptionName = @options.firstOptionName
#		else
#			@firstOptionName = "Select File Type"
#		if @options.fileTypeList?
#			@fileTypeList = new PickListList @options.fileTypeList
#		else
#			@fileTypeList = new PickListList()

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setupScientistSelect()

		@

	setupScientistSelect: ->
		@scientistList = new PickListList()
		@scientistList.url = "/api/authors"
		@scientistListController = new PickListSelectController
			el: @$('.bv_scientist')
			collection: @scientistList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Scientist"
			selectedCode: @model.get('scientist')

	updateModel: =>
		scientist = @scientistListController.getSelectedCode()
		if @model.get('id')?
			newModel = new ProjectLeader (_.clone(@model.attributes))
			newModel.unset 'id'
			newModel.set
				scientist: scientist
			@model.set "ignored", true
			@$('.bv_projectLeaderWrapper').hide()
			@trigger 'addNewModel', newModel
		else
			@model.set
				scientist: scientist
		@trigger 'amDirty'

	clear: =>
		if @model.get('id')?
			@model.set "ignored", true
			@$('.bv_projectLeaderWrapper').hide()
		else
			@model.destroy()
		@trigger 'amDirty'

class window.ProjectLeaderListController extends Backbone.View
	template: _.template($("#ProjectLeaderListView").html())

	events:
		"click .bv_addProjectLeaderButton": "addNewProjectLeader"

	initialize: ->
		unless @collection?
			@collection = new ProjectLeaderList()
			newModel = new ProjectLeader
			@collection.add newModel

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@collection.each (leaderInfo) =>
			@addProjectLeader(leaderInfo)
		if @collection.length == 0
			@addNewProjectLeader()
		@trigger 'renderComplete'
		@

	addNewProjectLeader: =>
		newModel = new ProjectLeader
		@collection.add newModel
		@addProjectLeader(newModel)
		@trigger 'amDirty'

	addProjectLeader: (leaderInfo) =>
		plc = new ProjectLeaderController
			model: leaderInfo
		plc.on 'addNewModel', (newModel) =>
			@collection.add newModel
			@addProjectLeader newModel
		plc.on 'amDirty', =>
			@trigger 'amDirty'
		@$('.bv_projectLeaderInfo').append plc.render().el

	isValid: =>
		validCheck = true
		errors = @collection.validateCollection()
		if errors.length > 0
			validCheck = false
		@validationError(errors)
		validCheck

	validationError: (errors) =>
		@clearValidationErrorStyles()
		_.each errors, (err) =>
			unless @$('.bv_'+err.attribute).attr('disabled') is 'disabled'
				@$('.bv_group_'+err.attribute).attr('data-toggle', 'tooltip')
				@$('.bv_group_'+err.attribute).attr('data-placement', 'bottom')
				@$('.bv_group_'+err.attribute).attr('data-original-title', err.message)
				#				@$('.bv_group_'+err.attribute).tooltip();
				@$("[data-toggle=tooltip]").tooltip();
				@$("body").tooltip selector: '.bv_group_'+err.attribute
				@$('.bv_group_'+err.attribute).addClass 'input_error error'
				@trigger 'notifyError',  owner: this.errorOwnerName, errorLevel: 'error', message: err.message

	clearValidationErrorStyles: =>
		errorElms = @$('.input_error')
		_.each errorElms, (ee) =>
			$(ee).removeAttr('data-toggle')
			$(ee).removeAttr('data-placement')
			$(ee).removeAttr('title')
			$(ee).removeAttr('data-original-title')
			$(ee).removeClass 'input_error error'

class window.ProjectController extends AbstractFormController
	template: _.template($("#ProjectView").html())
	moduleLaunchName: "project"

	events: ->
		"keyup .bv_projectCode": "handleProjectCodeNameChanged"
		"keyup .bv_projectName": "attributeChanged"
		"keyup .bv_projectAlias": "attributeChanged"
		"keyup .bv_startDate": "attributeChanged"
		"click .bv_startDateIcon": "handleStartDateIconClicked"
		"keyup .bv_shortDescription": "attributeChanged"
		"keyup .bv_projectDetails": "attributeChanged"
		#TODO: add project leader
		"click .bv_save": "handleSaveClicked"
		#TODO: add new project/clear form and cancel buttons

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/things/project/project/codename/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) ->
							alert 'Could not get project for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get project for code in this URL, creating new one'
							else
								proj = new Project json
								proj.set proj.parse(proj.attributes)
								@model = proj
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model=new Project()
		@errorOwnerName = 'ProjectController'
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		@listenTo @model, 'saveFailed', @handleSaveFailed
		@listenTo @model, 'sync', @modelSaveCallback
		@listenTo @model, 'change', @modelChangeCallback
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setupProjectStatusSelect()
		@setupTagList()
		#TODO: setup project leader
		@setupAttachFileListController()
		@setupProjectLeaderListController()
		@render()

	render: =>
		unless @model?
			@model = new Project()
		codeName = @model.get('codeName')
		@$('.bv_projectCode').val(codeName)
		@$('.bv_projectCode').html(codeName)
		bestName = @model.get('lsLabels').pickBestName()
		if bestName?
			@$('.bv_projectName').val bestName.get('labelText')
		if @model.get('project alias')?
			@$('.bv_projectAlias').val @model.get('project alias').get('labelText')
		@$('.bv_startDate').datepicker();
		@$('.bv_startDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		startDate = @model.get('start date').get('value')
		if startDate?
			unless isNaN(startDate)
				@$('.bv_startDate').val UtilityFunctions::convertMSToYMDDate(@model.get('start date').get('value'))
		@$('.bv_shortDescription').val @model.get('short description').get('value')
		@$('.bv_projectDetails').val @model.get('project details').get('value')

		if @readOnly is true
			@displayInReadOnlyMode()
		@$('.bv_save').attr('disabled','disabled')
		if @model.isNew()
			@$('.bv_save').html("Save")
		else
			@$('.bv_save').html("Update")
		@

	handleSaveFailed: =>
		@$('.bv_saveFailed').show()
		@$('.bv_saveComplete').hide()
		@$('.bv_saving').hide()

	modelSaveCallback: (method, model) =>
		@$('.bv_save').show()
		@$('.bv_save').attr('disabled', 'disabled')
		unless @$('.bv_saveFailed').is(":visible")
			@$('.bv_saveComplete').show()
			@$('.bv_saving').hide()
		@setupAttachFileListController()
		@setupProjectLeaderListController()
		@render()
		@trigger 'amClean'

	modelChangeCallback: (method, model) =>
		@trigger 'amDirty'
		@checkFormValid()
		@$('.bv_saveComplete').hide()
		@$('.bv_saveFailed').hide()

	setupProjectStatusSelect: ->
		@statusList = new PickListList()
		@statusList.url = "/api/codetables/project/status"
		@statusListController = new PickListSelectController
			el: @$('.bv_status')
			collection: @statusList
			selectedCode: @model.get('project status').get('value')

	setupTagList: ->
		@$('.bv_tags').val ""
		lsTags = @model.get 'lsTags'
		unless lsTags?
			lsTags = new TagList()
		@tagListController = new TagListController
			el: @$('.bv_tags')
			collection: lsTags
		@tagListController.render()

	setupAttachFileListController: =>
		$.ajax
			type: 'GET'
			url: "/api/codetables/project metadata/file type"
			dataType: 'json'
			error: (err) ->
				alert 'Could not get list of file types'
			success: (json) =>
				if json.length == 0
					alert 'Got empty list of file types'
				else
					attachFileList = @model.getAnalyticalFiles(json)
					@finishSetupAttachFileListController(attachFileList, json)

	finishSetupAttachFileListController: (attachFileList, fileTypeList) ->
		if @attachFileListController?
			@attachFileListController.undelegateEvents()
		@attachFileListController= new AttachFileListController
			autoAddAttachFileModel: false
			el: @$('.bv_attachFileList')
			collection: attachFileList
			firstOptionName: "Select Method"
			allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf', 'mol', 'cdx', 'cdxml', 'afr6', 'afe6', 'afs6']
			fileTypeList: fileTypeList
			required: false
		@attachFileListController.on 'amClean', =>
			@trigger 'amClean'
		@attachFileListController.on 'renderComplete', =>
			@checkDisplayMode()
		@attachFileListController.render()
		@attachFileListController.on 'amDirty', =>
			@trigger 'amDirty' #need to put this after the first time @attachFileListController is rendered or else the module will always start off dirty
			@$('.bv_saveComplete').hide()
			@$('.bv_saveFailed').hide()
			@checkFormValid()

	setupProjectLeaderListController: ->
		if @projectLeaderListController?
			@projectLeaderListController.undelegateEvents()

		projLeadersList = new ProjectLeaderList()
		projLeaders = @model.getProjectLeaders()
		_.each projLeaders, (leader) =>
			newModel = new ProjectLeader leader.attributes
			scientistVal = newModel.get('codeValue')
			newModel.set 'scientist', scientistVal
			projLeadersList.add newModel

		@projectLeaderListController= new ProjectLeaderListController
			el: @$('.bv_projectLeaderList')
			collection: projLeadersList #TODO get saved project leaders
		@projectLeaderListController.on 'amClean', =>
			@trigger 'amClean'
		@projectLeaderListController.on 'renderComplete', =>
			@checkDisplayMode()
		@projectLeaderListController.render()
		@projectLeaderListController.on 'amDirty', =>
			@trigger 'amDirty'
			@$('.bv_saveComplete').hide()
			@$('.bv_saveFailed').hide()
			@checkFormValid()


	handleProjectCodeNameChanged: =>
		codeName = UtilityFunctions::getTrimmedInput @$('.bv_projectCode')
		if codeName is ""
			delete @model.attributes.codeName
			@model.trigger 'change'
		else
			@model.set codeName: codeName

	handleStartDateIconClicked: =>
		@$( ".bv_startDate" ).datepicker( "show" )

	updateModel: =>
		@model.get("project name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_projectName'))
		@model.get("project alias").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_projectAlias'))
		@model.get("start date").set("value", UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_startDate')))
		@model.get("short description").set("value", UtilityFunctions::getTrimmedInput @$('.bv_shortDescription'))
		@model.get("project details").set("value", UtilityFunctions::getTrimmedInput @$('.bv_projectDetails'))

	handleSaveClicked: =>
		@callNameValidationService()

		@$('.bv_saving').show()
		@$('.bv_saveFailed').hide()
		@$('.bv_saveComplete').hide()

	callNameValidationService: ->
		@$('.bv_saving').show()
		@$('.bv_save').attr('disabled', 'disabled')
		reformattedModel = @model.clone()
		reformattedModel.reformatBeforeSaving()
		validateURL = "/api/validateName"
		dataToPost =
			data: #dataToPost needs wrapping key, not sure why
				JSON.stringify(
					lsThing: reformattedModel
					uniqueName: true
				)

		$.ajax
			type: 'POST'
			url: validateURL
			data: dataToPost
			success: (response) =>
				@handleValidateReturn(response)
			error: (err) =>
				@serviceReturn = null
			dataType: 'json'

	handleValidateReturn: (validateResp) =>
		if validateResp?[0]?.errorLevel?
			alert 'The requested project name has already been registered. Please choose a new project name.'
			@$('.bv_saving').hide()
			@$('.bv_saveFailed').show()
		else if validateResp is "validate name failed"
			alert 'There was an error validating the project name. Please try again and/or enter a different name.'
			@$('.bv_saving').hide()
			@$('.bv_saveFailed').show()
		else
			@saveProject()

	saveProject: =>
		@prepareToSaveAttachedFiles()
		@prepareToSaveProjectLeaders()
		@tagListController.handleTagsChanged()
		@model.prepareToSave()
		@model.reformatBeforeSaving()
		if @model.isNew()
			@$('.bv_saveComplete').html('Save Complete')
		else
			@$('.bv_saveComplete').html('Update Complete')
		@$('.bv_save').attr('disabled', 'disabled')
		@model.save null,
			success: (model, response) =>
				if response is "update lsThing failed"
					@model.trigger 'saveFailed'


	prepareToSaveAttachedFiles: =>
		@attachFileListController.collection.each (file) =>
			if file.isNew() #file.get('id') is null
				unless (file.get('ignored') is true or file.get('fileType') is "unassigned")
					newFile = @model.get('lsStates').createValueByTypeAndKind "metadata", "project metadata", "fileValue", file.get('fileType')
					newFile.set
						fileValue: file.get('fileValue')
						comments: file.get('comments')
			else
				if file.get('ignored') is true
					value = @model.get('lsStates').getValueById "metadata", "project metadata", file.get('id')
					value[0].set "ignored", true

	prepareToSaveProjectLeaders: =>
		@projectLeaderListController.collection.each (leader) =>
			if leader.isNew()
				unless (leader.get('ignored') is true or leader.get('scientist') is "unassigned")
					newLeader = @model.get('lsStates').createValueByTypeAndKind "metadata", "project metadata", "codeValue", "project leader"
					newLeader.set
						codeValue: leader.get('scientist')
			else
				if leader.get('ignored') is true
					value = @model.get('lsStates').getValueById "metadata", "project metadata", leader.get('id')
					value[0].set "ignored", true

	validationError: =>
		super()
		@$('.bv_save').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_save').removeAttr('disabled')

	checkDisplayMode: =>
		if @readOnly is true
			@displayInReadOnlyMode()

	displayInReadOnlyMode: =>
		@$(".bv_save").hide()
		@$('button').attr 'disabled', 'disabled'
		@$(".bv_startDateIcon").addClass "uneditable-input"
		@$(".bv_startDateIcon").on "click", ->
			return false
		@disableAllInputs()

	checkFormValid: =>
		if @isValid()
			@$('.bv_save').removeAttr('disabled')
		else
			@$('.bv_save').attr('disabled', 'disabled')

	isValid: =>
		validCheck = super()
		if @attachFileListController?
			if @attachFileListController.isValid() is false
				validCheck = false
		if @projectLeaderListController?
			if @projectLeaderListController.isValid() is false
				validCheck = false
		validCheck
