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
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'structural file'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'fileValue'
			kind: 'structural file'
		,
			key: 'batch number'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'numericValue'
			kind: 'batch number'
			value: 0
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
	template: _.template($("#AbstractBaseComponentThingView").html())

	events: ->
		"keyup .bv_thingName": "attributeChanged"
		"change .bv_scientist": "attributeChanged"
		"keyup .bv_completionDate": "attributeChanged"
		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"keyup .bv_notebook": "attributeChanged"
		"click .bv_updateThing": "handleUpdateThing"
		"click .bv_deleteSavedFile": "handleDeleteSavedStructuralFile"

	initialize: =>
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
		$(@el).html @template()
		@setupScientistSelect()


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
		if @model.get('completion date').get('value')?
			@$('.bv_completionDate').val UtilityFunctions::convertMSToYMDDate(@model.get('completion date').get('value'))
		@$('.bv_notebook').val @model.get('notebook').get('value')
		if @readOnly is true
			@displayInReadOnlyMode()
		@$('.bv_updateThing').attr('disabled','disabled')
		@

	modelSaveCallback: (method, model) =>
		@$('.bv_updateThing').show()
		@$('.bv_updateThing').attr('disabled', 'disabled')
		@$('.bv_updateThingComplete').show()
		@$('.bv_updatingThing').hide()
		@trigger 'amClean'
		@trigger 'thingSaved'
		@render()

	modelChangeCallback: (method, model) =>
		@trigger 'amDirty'
		@$('.bv_updateThingComplete').hide()

	setupStructuralFileController: =>
		structuralFileValue = @model.get('structural file').get('value')
		if structuralFileValue is null or structuralFileValue is "" or structuralFileValue is undefined
			console.log "structural file is null"
			@createNewFileChooser()
			@$('.bv_deleteSavedFile').hide()
		else
			console.log "structural file is not null"
			@$('.bv_structuralFile').html '<a href='+structuralFileValue+'>'+structuralFileValue+'</a>'
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
			hideDelete: false
		@structuralFileController.on 'amDirty', =>
			@trigger 'amDirty'
		@structuralFileController.on 'amClean', =>
			@trigger 'amClean'
		@structuralFileController.render()
		@structuralFileController.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename
		@structuralFileController.on('fileDeleted', @handleFileRemoved) #update model with filename

	handleFileUpload: (nameOnServer) =>
		@model.get("structural file").set("value", nameOnServer)

	handleFileRemoved: =>
		@model.get("structural file").set("value", "")

	handleDeleteSavedStructuralFile: =>
		console.log "handle delete saved structural file"
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
		@$('.bv_updateThing').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_updateThing').removeAttr('disabled')

	validateThingName: ->
		@$('.bv_updateThing').attr('disabled', 'disabled')
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
		@model.reformatBeforeSaving()
		@$('.bv_updatingThing').show()
		@$('.bv_updateThingComplete').html('Update Complete.')
		@$('.bv_updateThing').attr('disabled', 'disabled')
		@model.save()

	displayInReadOnlyMode: =>
		@$(".bv_updateThing").hide()
		@$('button').attr 'disabled', 'disabled'
		@$(".bv_completionDateIcon").addClass "uneditable-input"
		@$(".bv_completionDateIcon").on "click", ->
			return false
		@disableAllInputs()

	updateBatchNumber: =>
		@model.fetch
			success: console.log @model

