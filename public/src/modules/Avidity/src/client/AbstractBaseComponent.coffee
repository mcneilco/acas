class window.AbstractBaseComponentParent extends Thing

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
				attribute: 'parentName'
				message: "Name must be set"
		unless @isNew()
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

class window.AbstractBaseComponentBatch extends Thing

	validate: (attrs) ->
		errors = []
		if attrs.scientist?
			scientist = attrs.scientist.get('value')
			if scientist is "" or scientist is "unassigned" or scientist is undefined or scientist is null
				errors.push
					attribute: 'scientist'
					message: "Scientist must be set"
		if attrs["completion date"]?
			cDate = attrs["completion date"].get('value')
			if cDate is null or cDate is "" then cDate = "fred"
			if isNaN(cDate)
				errors.push
					attribute: 'completionDate'
					message: "Date must be set"
		if attrs.source?
			source = attrs.source.get('value')
			if source is "unassigned" or source is undefined or source is null
				errors.push
					attribute: 'source'
					message: "Source must be set"
		if attrs.notebook?
			notebook = attrs.notebook.get('value')
			if notebook is "" or notebook is undefined or notebook is null
				errors.push
					attribute: 'notebook'
					message: "Notebook must be set"
		if attrs["amount made"]?
			amountMade = attrs["amount made"].get('value')
			if amountMade is "" or amountMade is undefined or isNaN(amountMade) or amountMade is null
				errors.push
					attribute: 'amountMade'
					message: "Amount must be set"
			if isNaN(amountMade)
				errors.push
					attribute: 'amountMade'
					message: "Amount must be a number"
		if attrs.location?
			location = attrs.location.get('value')
			if location is "" or location is undefined or location is null
				errors.push
					attribute: 'location'
					message: "Location must be set"

		if errors.length > 0
			return errors
		else
			return null

	prepareToSave: ->
		rBy = @get('recordedBy')
		rDate = new Date().getTime()
		@set recordedDate: rDate
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

class window.AbstractBaseComponentParentController extends AbstractFormController
	template: _.template($("#AbstractBaseComponentParentView").html())

	events: ->
		"keyup .bv_parentName": "attributeChanged"
		"change .bv_scientist": "attributeChanged"
		"keyup .bv_completionDate": "attributeChanged"
		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"keyup .bv_notebook": "attributeChanged"
		"click .bv_updateParent": "handleUpdateParent"

	initialize: =>
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		@listenTo @model, 'sync', @modelSaveCallback
		@listenTo @model, 'change', @modelChangeCallback
		$(@el).empty()
		$(@el).html @template()
		if @componentPickerTemplate?
#			@$('.bv_componentPicker').html @componentPickerTemplate()
			@setupComponentPickerController()
		if @additionalParentAttributesTemplate?
			@$('.bv_additionalParentAttributes').html @additionalParentAttributesTemplate()
		@setupScientistSelect()


	render: =>
		codeName = @model.get('codeName')
		@$('.bv_parentCode').val(codeName)
		@$('.bv_parentCode').html(codeName)
		bestName = @model.get('lsLabels').pickBestName()
		if bestName?
			@$('.bv_parentName').val bestName.get('labelText')
		@$('.bv_scientist').val @model.get('scientist').get('value')
		@$('.bv_completionDate').datepicker();
		@$('.bv_completionDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.get('completion date').get('value')?
			@$('.bv_completionDate').val UtilityFunctions::convertMSToYMDDate(@model.get('completion date').get('value'))
		@$('.bv_notebook').val @model.get('notebook').get('value')
		if @model.isNew()
			@$('.bv_scientist').attr('disabled','disabled')
			@$('.bv_completionDate').attr('disabled','disabled')
			@$('.bv_notebook').attr('disabled','disabled')
			@$('.bv_completionDateIcon').on "click", ->
				return false
		else
			@$('.bv_scientist').removeAttr('disabled')
			@$('.bv_completionDate').removeAttr('disabled')
			@$('.bv_notebook').removeAttr('disabled')
			@$('.bv_completionDateIcon').on "click", ->
				return true
		if @readOnly is true
			@displayInReadOnlyMode()
		@

	modelSaveCallback: (method, model) =>
		@$('.bv_updateParent').show()
		@$('.bv_updateParent').attr('disabled', 'disabled')
		@$('.bv_updateParentComplete').show()
		@$('.bv_updatingParent').hide()
		@trigger 'amClean'
		@trigger 'parentSaved'
		@render()

	modelChangeCallback: (method, model) =>
		@trigger 'amDirty'
		@$('.bv_updateParentComplete').hide()

	setupComponentPickerController: ->
		@componentPickerController = new ComponentPickerController
			el: @$('.bv_componentPicker')
		@componentPickerController.on 'amDirty', =>
			@trigger 'amDirty'
		@componentPickerController.on 'amClean', =>
			@trigger 'amClean'
		@componentPickerController.render()

	setupScientistSelect: ->
		if @model.isNew()
			defaultOption = "Filled from first batch"
		else
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

	updateModel: =>
		console.log "update abc parent model"
		@model.get("scientist").set("value", @scientistListController.getSelectedCode())
#		@model.get("cationic block name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_cationicBlockParentName'))
		@model.get("notebook").set("value", UtilityFunctions::getTrimmedInput @$('.bv_notebook'))
		@model.get("completion date").set("value", UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_completionDate')))

	validationError: =>
		super()
		@$('.bv_updateParent').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_updateParent').removeAttr('disabled')

	validateParentName: ->
		@$('.bv_updateParent').attr('disabled', 'disabled')
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
			@handleUpdateParent()
		else
			alert 'The requested parent name has already been registered. Please choose a new parent name.'

	handleUpdateParent: =>
		@model.reformatBeforeSaving()
		@$('.bv_updatingParent').show()
		@$('.bv_updateParentComplete').html('Update Complete.')
		@$('.bv_updateParent').attr('disabled', 'disabled')
		@model.save()

	displayInReadOnlyMode: =>
		@$(".bv_updateParent").hide()
		@$('button').attr 'disabled', 'disabled'
		@$(".bv_completionDateIcon").addClass "uneditable-input"
		@$(".bv_completionDateIcon").on "click", ->
			return false
		@disableAllInputs()

	updateBatchNumber: =>
		@model.fetch
			success: console.log @model

class window.AbstractBaseComponentBatchController extends AbstractFormController
	template: _.template($("#AbstractBaseComponentBatchView").html())

	events: ->
		"change .bv_scientist": "attributeChanged"
		"keyup .bv_completionDate": "attributeChanged"
		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"change .bv_source": "attributeChanged"
		"keyup .bv_sourceId": "attributeChanged"
		"keyup .bv_notebook": "attributeChanged"
		"keyup .bv_amountMade": "attributeChanged"
		"keyup .bv_location": "attributeChanged"
		"click .bv_saveBatch": "handleSaveBatch"

	initialize: ->
		@setBindings()
		@parentCodeName = @options.parentCodeName
		@listenTo @model, 'sync', @modelSaveCallback
		@listenTo @model, 'change', @modelChangeCallback
		$(@el).empty()
		$(@el).html @template()
		if @additionalBatchAttributesTemplate?
			@$('.bv_additionalBatchAttributes').html @additionalBatchAttributesTemplate()
		@setupScientistSelect()
		@setupSourceSelect()
		@setupAttachFileListController()


	render: =>
		@$('.bv_batchCode').val(@model.get('codeName'))
		@$('.bv_batchCode').html(@model.get('codeName'))
		@$('.bv_scientist').val(@model.get('scientist').get('value'))
		@$('.bv_completionDate').datepicker();
		@$('.bv_completionDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.get('completion date').get('value')?
			@$('.bv_completionDate').val UtilityFunctions::convertMSToYMDDate(@model.get('completion date').get('value'))
		else
			@$('.bv_completionDate').val ""
		@$('.bv_source').val @model.get('source').get('value')
		@$('.bv_sourceId').val @model.get('source id').get('value')
		@$('.bv_notebook').val @model.get('notebook').get('value')
		@$('.bv_amountMade').val(@model.get('amount made').get('value'))
		@$('.bv_location').val(@model.get('location').get('value'))
		if @model.isNew()
			@$('.bv_saveBatch').html("Save Batch")
		else
			@$('.bv_saveBatch').html("Update Batch")
#			@model.urlRoot = "/api/cationicBlockBatches/"+@parentCodeName
		@trigger 'renderComplete'
		if @parentCodeName is undefined
			@$('.bv_saveBatch').hide()
		else
			@$('.bv_saveBatch').show()
		@

	modelSaveCallback: (method, model) =>
		@$('.bv_saveBatch').show()
		@$('.bv_saveBatch').attr('disabled', 'disabled')
		@$('.bv_savingBatch').hide()
		@render()
		@trigger 'amClean'
		@trigger 'batchSaved'

	modelChangeCallback: (method, model) =>
		@trigger 'amDirty'
		@$('.bv_saveBatchComplete').hide()

	setupScientistSelect: ->
		@scientistList = new PickListList()
		@scientistList.url = "/api/authors"
		@scientistListController = new PickListSelectController
			el: @$('.bv_scientist')
			collection: @scientistList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Scientist"
			selectedCode: @model.get('scientist').get('value')

	setupSourceSelect: ->
		@sourceList = new PickListList()
		@sourceList.url = "/api/codetables/component/source"
		@sourceListController = new PickListSelectController
			el: @$('.bv_source')
			collection: @sourceList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Source"
			selectedCode: @model.get('source').get('value')

	setupAttachFileListController: =>
		$.ajax
			type: 'GET'
			url: "/api/codetables/analytical method/file type"
			dataType: 'json'
			error: (err) ->
				alert 'Could not get list of analytical file types'
			success: (json) =>
				if json.length == 0
					alert 'Got empty list of analytical file types'
				else
					@analyticalMethodFileTypesJSON = json
					attachFileList = @model.getAnalyticalFiles(json)
					@finishSetupAttachFileListController(attachFileList)

	finishSetupAttachFileListController: (attachFileList) ->
#		attachFileList = @model.getAttachFileList()
		@attachFileListController= new AttachFileListController
			autoAddAttachFileModel: false
			el: @$('.bv_attachFileList')
			collection: attachFileList
			firstOptionName: "Select Method"
			allowedFileTypes: ['pdf']
			fileTypeListURL: "/api/codetables/analytical method/file type"
		@attachFileListController.on 'amDirty', =>
			@trigger 'amDirty'
		@attachFileListController.on 'amClean', =>
			@trigger 'amClean'
		@attachFileListController.on 'renderComplete', =>
			@trigger 'renderComplete'
#		@attachFileListController.insertFirstOption.set name: "Select Method"
		@attachFileListController.render()

	handleCompletionDateIconClicked: =>
		@$( ".bv_completionDate" ).datepicker( "show" )

	updateModel: =>
		@model.get("scientist").set("value", @scientistListController.getSelectedCode())
		@model.get("source").set("value", @sourceListController.getSelectedCode())
		@model.get("source id").set("value", UtilityFunctions::getTrimmedInput @$('.bv_sourceId'))
		@model.get("notebook").set("value", UtilityFunctions::getTrimmedInput @$('.bv_notebook'))
		@model.get("completion date").set("value", UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_completionDate')))
		@model.get("amount made").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_amountMade')))
		@model.get("location").set("value", UtilityFunctions::getTrimmedInput @$('.bv_location'))

	validationError: =>
		super()
		@$('.bv_saveBatch').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_saveBatch').removeAttr('disabled')

	handleSaveBatch: =>
		@$('.bv_savingBatch').show()
		@saveAnalyticalMethod()
		@model.prepareToSave()
		@model.reformatBeforeSaving()
		if @model.isNew() is true
			@model.urlRoot = @model.urlRoot+"/"+@parentCodeName
		else
			@model.urlRoot = @model.get('urlRoot')
		@$('.bv_saveBatch').attr('disabled', 'disabled')
		@model.save()

	saveAnalyticalMethod: =>
		console.log "save analytical method"
		#TODO: unset all analytical methods lsValues
		console.log @model
		for fileType in @analyticalMethodFileTypesJSON
#			search to see if @attachFileListController.collection has a model with this file type
			console.log @attachFileListController.collection
			console.log fileType
			matchedModel=@attachFileListController.collection.findWhere {fileType:fileType.code}
			analyticalMethodValue = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", @model.get('lsKind')+" batch", "fileValue", fileType.code
			if matchedModel is undefined
				console.log "no matched model"
				#the file type doesn't have a file uploaded for it
				#set fileValue to null
				analyticalMethodValue.set fileValue: ""
			else
				console.log "matched model"
				fileValue = matchedModel.get('fileValue')
				console.log fileValue
				analyticalMethodValue.set fileValue: fileValue

#		@attachFileListController.collection.each (attachFileModel) =>
#			console.log attachFileModel
#			console.log attachFileModel.get('fileType')
#			console.log attachFileModel.get('fileValue')
#			analyticalMethod = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", @model.get('lsKind')+" batch", "fileValue", attachFileModel.get('fileType')
#			fileValue = attachFileModel.get('fileValue')
#			if fileValue is null or fileValue is "" or fileValue is undefined
##				@model.unset analyticalMethod
#				analyticalMethod.set fileValue: ""
#				console.log "need to delete fileValue"
#				console.log analyticalMethod
#				console.log @model
#			else
#				analyticalMethod.set fileValue: attachFileModel.get('fileValue')

	isValid: =>
		validCheck = super()
		if @attachFileListController?
			if @attachFileListController.isValid() is true
				return validCheck
			else
				return false
		else
			return validCheck

	displayInReadOnlyMode: =>
		@$(".bv_saveBatch").addClass "hide"
		@$('button').attr 'disabled', 'disabled'
		@$(".bv_completionDateIcon").addClass "uneditable-input"
		@$(".bv_completionDateIcon").on "click", ->
			return false
		@disableAllInputs()

class window.AbstractBaseComponentBatchSelectController extends Backbone.View
	template: _.template($("#AbstractBaseComponentBatchSelectView").html())

	events: ->
		"change .bv_batchList": "handleSelectedBatchChanged"

	initialize: =>
		@parentCodeName = @options.parentCodeName
		if @options.batchCodeName?
			@batchCodeName = @options.batchCodeName
		else
			@batchCodeName = "new batch"
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		$(@el).empty()
		$(@el).html @template()
		@setupBatchSelect()

	setupBatchSelect: =>
		unless @setupBatch?
			@setupBatch = true
		@batchList = new PickListList()
		@batchList.url = "/api/batches/"+@options.lsKind+"/parentCodeName/"+@parentCodeName
		$.ajax
			type: 'GET'
			url: @batchList.url
			dataType: 'json'
			error: (err) ->
				alert 'Could not get batch list'
			success: (json) =>
				@batchList = new ComponentList json
				@translateIntoPickListFormat()

	translateIntoPickListFormat: =>
		codes = new PickListList
		@batchList.each (batch) =>
			batchOption = new PickList
				code: batch.get('codeName')
				name: batch.get('codeName')
				ignored: batch.get('ignored')
			codes.add batchOption
		@batchListOptions = codes
		@finishBatchSetup()

	finishBatchSetup: =>
		@batchListController = new PickListSelectController
			el: @$('.bv_batchList')
			collection: @batchListOptions
			insertFirstOption: new PickList
				code: "new batch"
				name: "Register New Batch"
			selectedCode: @batchCodeName
			autoFetch: false
		@batchListController.render()

		if @setupBatch is true
			if @batchModel is undefined
				@handleSelectedBatchChanged()
			else
				@setupBatchRegForm()
		else
			@setupBatch = true

	setupBatchRegForm: =>
		lsKind = @batchModel.get('lsKind')
		lsKind = lsKind.replace /(^|[^a-z0-9-])([a-z])/g, (m, m1, m2, p) -> m1 + m2.toUpperCase()
		lsKind = lsKind.replace /\s/g, ''
		if @batchController?
			@batchController.undelegateEvents()
		@batchController = new window[lsKind+"BatchController"]
			model: @batchModel
			el: @$('.bv_batchRegForm')
			parentCodeName: @parentCodeName
			readOnly: @readOnly
		@batchController.on 'amDirty', =>
			@trigger 'amDirty'
		@batchController.on 'amClean', =>
			@trigger 'amClean'
		@batchController.on 'batchSaved', =>
			@batchCodeName = @batchController.model.get('codeName')
			@batchModel = @batchController.model
			@setupBatch = false #so that the batch controller does not re-render and remove the update batch successful message
			@setupBatchSelect()
			@$('.bv_saveBatchComplete').show()
			@trigger 'batchSaved'
		@batchController.on 'renderComplete', =>
			@checkDisplayMode()
		@batchController.render()
		if @setupBatch is false
			@$('.bv_saveBatchComplete').show()
			@setupBatch = true
		@$('.bv_saveBatch').attr('disabled','disabled')
		if @batchController.model.isNew()
			@$('.bv_saveBatch').html("Save Batch")
			@$('.bv_saveBatchComplete').html("Save Complete")
		else
			@$('.bv_saveBatch').html("Update Batch")
			@$('.bv_saveBatchComplete').html("Update Complete")

	checkIfFirstBatch: ->
		@batchListController.collection.length==1

	checkDisplayMode: =>
		if @readOnly is true
			@displayInReadOnlyMode()

	displayInReadOnlyMode: =>
		@$('.bv_batchList').attr 'disabled', 'disabled'
		if @batchController?
			@batchController.displayInReadOnlyMode()

class window.AbstractBaseComponentController extends Backbone.View
	template: _.template($("#AbstractBaseComponentView").html())

	events: ->
#		"click .bv_save": "handleSaveClicked"
		"click .bv_save": "validateParentName"

	completeInitialization: =>
		$(@el).html @template()
		unless @batchCodeName?
			if @options.batchCodeName?
				@batchCodeName = @options.batchCodeName
			else
				@batchCodeName = "new batch"
		unless @readOnly?
			if @options.readOnly?
				@readOnly = @options.readOnly
			else
				@readOnly = false
		unless @batchModel?
			if @options.batchModel?
				@batchModel = @options.batchModel
			else
				@batchModel = null
		@setupParentController()
		@setupBatchSelectController()
		#		if @parentController.model.get('codeName') is undefined
		@$('.bv_save').attr('disabled', 'disabled')
		if @parentController.model.isNew()
			@$('.bv_updateParent').hide()
			@$('.bv_saveBatch').hide()
		else
			@$('.bv_save').hide()
			@$('.bv_updateParent').show()
			@$('.bv_saveBatch').show()

	setupParentController: ->
		@parentController.on 'amDirty', =>
			@checkFormValid()
			@trigger 'amDirty'
		@parentController.on 'amClean', =>
			@trigger 'amClean'
		@parentController.on 'parentSaved', =>
			@handleParentSaved()
		@parentController.render()
		@$('.bv_updateParent').attr('disabled', 'disabled')
		@firstSave = @parentController.model.isNew()


	handleParentSaved: ->
		if @firstSave is true
			@$('.bv_saveParentComplete').show()
			@firstSave = false
		else
			@$('.bv_saveParentComplete').hide()
			@$('.bv_saveFirstBatchComplete').hide()
#		@$('.bv_updateParentComplete').hide()

	setupBatchSelectController: =>
#		@batchSelectController = new CationicBlockBatchSelectController
#			el: @$('.bv_cationicBlockBatch')
#			parentCodeName: @model.get('codeName')
		@batchSelectController.on 'amDirty', =>
			@trigger 'amDirty'
			@checkFormValid()
		@batchSelectController.on 'amClean', =>
			@trigger 'amClean'
		@batchSelectController.on 'batchSaved', =>
			@handleBatchSaved()
			@parentController.updateBatchNumber()
		@batchSelectController.render()

	handleBatchSaved: =>
		if @batchSelectController.checkIfFirstBatch() is true
			@$('.bv_saveFirstBatchComplete').show()
		else
			@$('.bv_saveFirstBatchComplete').hide()
			@$('.bv_saveParentComplete').hide()
		@$('.bv_saveBatch').show()
		@$('.bv_saving').hide()
#		@$('.bv_saveBatchComplete').hide()

	checkFormValid: ->
		if @parentController.isValid() and @batchSelectController.batchController.isValid()
			@$('.bv_save').removeAttr('disabled')
		else
			@$('.bv_save').attr('disabled', 'disabled')

	validateParentName: ->
		@$('.bv_save').attr('disabled', 'disabled')
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
			@handleSaveClicked()
		else
			alert 'The requested parent name has already been registered. Please choose a new parent name.'

	handleSaveClicked: =>
		@saveNewParentAttributes()
		@parentController.model.prepareToSave()
		@$('.bv_save').hide()
		@$('.bv_saving').show()
		@parentController.model.reformatBeforeSaving()
		@$('.bv_updateParentComplete').html("Save Complete")
		@parentController.model.save @parentController.model.attributes, success: @saveFirstBatch

	saveNewParentAttributes: =>
		scientist = @batchSelectController.batchController.model.get('scientist').get('value')
		cDate = @batchSelectController.batchController.model.get('completion date').get('value')
		notebook = @batchSelectController.batchController.model.get('notebook').get('value')
		@parentController.model.get('scientist').set('value', scientist)
		@parentController.model.get('completion date').set('value', cDate)
		@parentController.model.get('notebook').set('value', notebook)

	saveFirstBatch: (json) =>
		@batchSelectController.batchController.saveAnalyticalMethod()
		@batchSelectController.batchController.model.prepareToSave()
		@batchSelectController.batchController.model.reformatBeforeSaving()
		@$('.bv_saveBatch').html("Save Batch")
		batchDataToPost = @batchSelectController.batchController.model
		@parentCodeName = @parentController.model.get('codeName')
		@batchSelectController.parentCodeName = @parentCodeName
		batchDataToPost.urlRoot = batchDataToPost.urlRoot + "/"+@parentCodeName
		@batchSelectController.batchController.model.save()
