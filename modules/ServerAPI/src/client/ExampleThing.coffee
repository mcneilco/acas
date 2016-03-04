class window.ExampleThing extends Thing
	urlRoot: "/api/things/parent/cationic block"
	className: "CationicBlockParent"

	initialize: ->
		@.set
			lsType: "parent"
			lsKind: "cationic block"
		super()

	lsProperties:
		defaultLabels: [
			key: 'cationic block name'
			type: 'name'
			kind: 'cationic block'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'scientist'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'codeValue'
			kind: 'scientist'
			codeOrigin: window.conf.scientistCodeOrigin
			value: "unassigned"
		,
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'dateValue'
			kind: 'completion date'
			value: NaN
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'stringValue'
			kind: 'notebook'
			value: ""
		,
			key: 'structural file'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'fileValue'
			kind: 'structural file'
			value: ""
		,
			key: 'batch number'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'numericValue'
			kind: 'batch number'
			value: 0
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
			if bestName.get('labelText') != ""
				nameError = false
		if nameError
			errors.push
				attribute: 'thingName'
				message: "Name must be set"
		if attrs.scientist?
			scientist = attrs.scientist.get('value')
			if scientist is "" or scientist is "unassigned" or scientist is undefined or scientist is null
				errors.push
					attribute: 'scientist'
					message: "Scientist must be set"
		if attrs["completion date"]?
			cDate = attrs["completion date"].get('value')
			if cDate is undefined or cDate is "" or cDate is null then cDate = "fred"
			if isNaN(cDate)
				errors.push
					attribute: 'completionDate'
					message: "Date must be set"
		if attrs.notebook?
			notebook = attrs.notebook.get('value')
			if notebook is "" or notebook is undefined or notebook is null
				errors.push
					attribute: 'notebook'
					message: "Notebook must be set"
		if errors.length > 0
			return errors
		else
			return null

	prepareToSave: ->
		rBy = @get('recordedBy')
		rDate = new Date().getTime()
		@set recordedDate: rDate
		@get('lsLabels').each (lab) ->
			unless lab.get('recordedBy') != ""
				lab.set recordedBy: rBy
			unless lab.get('recordedDate') != null
				lab.set recordedDate: rDate
		@get('lsStates').each (state) ->
			unless state.get('recordedBy') != ""
				state.set recordedBy: rBy
			unless state.get('recordedDate') != null
				state.set recordedDate: rDate
			state.get('lsValues').each (val) ->
				unless val.get('recordedBy') != ""
					val.set recordedBy: rBy
				unless val.get('recordedDate') != null
					val.set recordedDate: rDate

	duplicate: =>
		copiedThing = super()
		copiedThing.get("batch number").set value: 0
		copiedThing

class window.ExampleThingController extends AbstractFormController
	template: _.template($("#ExampleThingView").html())
	moduleLaunchName: "cationic_block"

	events: ->
		"keyup .bv_thingName": "attributeChanged"
		"change .bv_scientist": "attributeChanged"
		"keyup .bv_completionDate": "attributeChanged"
		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"keyup .bv_notebook": "attributeChanged"
		"click .bv_saveThing": "handleUpdateThing"
		"click .bv_deleteSavedFile": "handleDeleteSavedStructuralFile"

	initialize: =>
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					launchCode = window.AppLaunchParams.moduleLaunchParams.code
					if launchCode.indexOf("-") == -1
						@batchCodeName = "new batch"
					else
						@batchCodeName = launchCode
						launchCode =launchCode.split("-")[0]
					$.ajax
						type: 'GET'
						url: "/api/things/parent/cationic block/codename/"+launchCode
						dataType: 'json'
						error: (err) ->
							alert 'Could not get parent for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get parent for code in this URL, creating new one'
							else
								#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
#								cbp = new CationicBlockParent json
								cbp = new ExampleThing json
								cbp.set cbp.parse(cbp.attributes)
								@model = cbp
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model=new ExampleThing()
		@errorOwnerName = 'ExampleThingController'
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		@listenTo @model, 'sync', @modelSaveCallback
		@listenTo @model, 'change', @modelChangeCallback
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setupScientistSelect()
		@render()


	render: =>
		unless @model?
			@model = new ExampleThing()
		@setupStructuralFileController()
		codeName = @model.get('codeName')
		@$('.bv_thingCode').val(codeName)
		@$('.bv_thingCode').html(codeName)
		bestName = @model.get('lsLabels').pickBestName()
		if bestName?
			@$('.bv_thingName').val bestName.get('labelText')
		@$('.bv_scientist').val @model.get('scientist').get('value')
		@$('.bv_completionDate').datepicker();
		@$('.bv_completionDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		compDate = @model.get('completion date').get('value')
		if compDate?
			unless isNaN(compDate)
				@$('.bv_completionDate').val UtilityFunctions::convertMSToYMDDate(@model.get('completion date').get('value'))
		@$('.bv_notebook').val @model.get('notebook').get('value')
		if @readOnly is true
			@displayInReadOnlyMode()
		@$('.bv_saveThing').attr('disabled','disabled')
		if @model.isNew()
			@$('.bv_saveThing').html("Save")
		else
			@$('.bv_saveThing').html("Update")
		@

	modelSaveCallback: (method, model) =>
		@$('.bv_saveThing').show()
		@$('.bv_saveThing').attr('disabled', 'disabled')
		@$('.bv_saveThingComplete').show()
		@$('.bv_updatingThing').hide()
		@trigger 'amClean'
		@trigger 'thingSaved'
		@render()

	modelChangeCallback: (method, model) =>
		@trigger 'amDirty'
		@$('.bv_saveThingComplete').hide()

	setupStructuralFileController: =>
		structuralFileValue = @model.get('structural file').get('value')
		if structuralFileValue is null or structuralFileValue is "" or structuralFileValue is undefined
			@createNewFileChooser()
			@$('.bv_deleteSavedFile').hide()
		else
			@$('.bv_structuralFile').html '<a href="'+window.conf.datafiles.downloadurl.prefix+structuralFileValue+'">'+@model.get('structural file').get('comments')+'</a>'
			@$('.bv_deleteSavedFile').show()

	setupScientistSelect: ->
		defaultOption = "Select Scientist"
		@scientistList = new PickListList()
		@scientistList.url = "/api/authors"
		@scientistListController = new PickListSelectController
			el: @$('.bv_scientist')
			collection: @scientistList
			insertFirstOption: new PickList
				code: "unassigned"
				name: defaultOption
			selectedCode: @model.get('scientist').get('value')

	handleCompletionDateIconClicked: =>
		@$( ".bv_completionDate" ).datepicker( "show" )

	createNewFileChooser: =>
		@structuralFileController = new LSFileChooserController
			el: @$('.bv_structuralFile')
			formId: 'fieldBlah',
			maxNumberOfFiles: 1,
			requiresValidation: false
			url: UtilityFunctions::getFileServiceURL()
			allowedFileTypes: ['png', 'jpeg']
			hideDelete: false
		@structuralFileController.on 'amDirty', =>
			@trigger 'amDirty'
		@structuralFileController.on 'amClean', =>
			@trigger 'amClean'
		@structuralFileController.render()
		@structuralFileController.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename
		@structuralFileController.on('fileDeleted', @handleFileRemoved) #update model with filename

	handleFileUpload: (nameOnServer) =>
		newFileValue = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "cationic block parent", "fileValue", "structural file"
		@model.set "structural file", newFileValue
		@model.get("structural file").set("value", nameOnServer)

	handleFileRemoved: =>
		@model.get("structural file").set("ignored", true)
		@model.unset "structural file"

	handleDeleteSavedStructuralFile: =>
		@handleFileRemoved()
		@$('.bv_deleteSavedFile').hide()
		@createNewFileChooser()

	updateModel: =>
		@model.get("cationic block name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_thingName'))
		@model.get("scientist").set("value", @scientistListController.getSelectedCode())
		@model.get("notebook").set("value", UtilityFunctions::getTrimmedInput @$('.bv_notebook'))
		@model.get("completion date").set("value", UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_completionDate')))

	validationError: =>
		super()
		@$('.bv_saveThing').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_saveThing').removeAttr('disabled')

	validateThingName: ->
		@$('.bv_saveThing').attr('disabled', 'disabled')
		lsKind = @model.get('lsKind')
		name= [@model.get(lsKind+' name').get('labelText')]
		$.ajax
			type: 'POST'
			url: "/api/validateName/"+lsKind
			data:
				requestName: name
			success: (response) =>
				@handleValidateReturn(response)
			error: (err) =>
				@serviceReturn = null
			dataType: 'json'

	handleValidateReturn: (validNewLabel) =>
		if validNewLabel is true
			@handleUpdateThing()
		else
			alert 'The requested thing name has already been registered. Please choose a new thing name.'

	handleUpdateThing: =>
		@model.prepareToSave()
		@model.reformatBeforeSaving()
		@$('.bv_updatingThing').show()
		@$('.bv_saveThingComplete').html('Update Complete.')
		@$('.bv_saveThing').attr('disabled', 'disabled')
		@model.save()

	displayInReadOnlyMode: =>
		@$(".bv_saveThing").hide()
		@$('button').attr 'disabled', 'disabled'
		@$(".bv_completionDateIcon").addClass "uneditable-input"
		@$(".bv_completionDateIcon").on "click", ->
			return false
		@disableAllInputs()

	updateBatchNumber: =>
		@model.fetch()
