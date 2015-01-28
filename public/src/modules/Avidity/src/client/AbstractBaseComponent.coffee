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
		if _.isNaN(attrs.recordedDate)
			errors.push
				attribute: 'recordedDate'
				message: "Recorded date must be set"
		#		unless attrs.codeName is undefined
		unless @isNew()
			if attrs.scientist?
				scientist = attrs.scientist.get('value')
				if scientist is "" or scientist is "unassigned" or scientist is undefined
					errors.push
						attribute: 'scientist'
						message: "Scientist must be set"
			if attrs["completion date"]?
				cDate = attrs["completion date"].get('value')
				if cDate is undefined or cDate is "" then cDate = "fred"
				if isNaN(cDate)
					errors.push
						attribute: 'completionDate'
						message: "Date must be set"
			if attrs.notebook?
				notebook = attrs.notebook.get('value')
				if notebook is "" or notebook is undefined
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

class window.AbstractBaseComponentBatch extends Thing

	validate: (attrs) ->
		errors = []
		if _.isNaN(attrs.recordedDate)
			errors.push
				attribute: 'recordedDate'
				message: "Recorded date must be set"
		if attrs.scientist?
			scientist = attrs.scientist.get('value')
			if scientist is "" or scientist is "unassigned" or scientist is undefined
				errors.push
					attribute: 'scientist'
					message: "Scientist must be set"
		if attrs["completion date"]?
			cDate = attrs["completion date"].get('value')
			if cDate is undefined or cDate is "" then cDate = "fred"
			if isNaN(cDate)
				errors.push
					attribute: 'completionDate'
					message: "Date must be set"
		if attrs.source?
			source = attrs.source.get('value')
			if source is "unassigned" or source is "" or source is undefined
				errors.push
					attribute: 'source'
					message: "Source must be set"
		if attrs.notebook?
			notebook = attrs.notebook.get('value')
			if notebook is "" or notebook is undefined
				errors.push
					attribute: 'notebook'
					message: "Notebook must be set"
		if attrs["amount made"]?
			amountMade = attrs["amount made"].get('value')
			if amountMade is "" or amountMade is undefined or isNaN(amountMade)
				errors.push
					attribute: 'amountMade'
					message: "Amount must be set"
			if isNaN(amountMade)
				errors.push
					attribute: 'amountMade'
					message: "Amount must be a number"
		if attrs.location?
			location = attrs.location.get('value')
			if location is "" or location is undefined
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

	initialize: ->
		@setBindings()
		@listenTo @model, 'sync', @modelSaveCallback
#		@model.on 'sync', =>
#			console.log "sync in parent controller"
#			@$('.bv_updateParent').show()
#			@$('.bv_updateParent').attr('disabled', 'disabled')
#			@$('.bv_updateParentComplete').show()
#			@$('.bv_updatingParent').hide()
#			@trigger 'amClean'
#			@trigger 'parentSaved'
#			@render()
		@listenTo @model, 'change', @modelChangeCallback
#		@model.on 'change', =>
#			@trigger 'amDirty'
#			@$('.bv_updateParentComplete').hide()
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
		@

	modelSaveCallback: (method, model) ->
		@$('.bv_updateParent').show()
		@$('.bv_updateParent').attr('disabled', 'disabled')
		@$('.bv_updateParentComplete').show()
		@$('.bv_updatingParent').hide()
		@trigger 'amClean'
		@trigger 'parentSaved'
		@render()

	modelChangeCallback: (method, model) ->
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
		@model.get("scientist").set("value", @scientistListController.getSelectedCode())
#		@model.get("cationic block name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_cationicBlockParentName'))
		@model.get("notebook").set("value", UtilityFunctions::getTrimmedInput @$('.bv_notebook'))
		@model.get("completion date").set("value", UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_completionDate')))
#		@model.get("molecular weight").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_molecularWeight')))

	validationError: =>
		super()
		@$('.bv_updateParent').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_updateParent').removeAttr('disabled')

	handleUpdateParent: =>
		@model.reformatBeforeSaving()
		@$('.bv_updatingParent').show()
		@$('.bv_updateParentComplete').html('Update Complete.')
		@model.save()

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
		@listenTo @model, 'sync', @modelSaveCallback
#		@model.on 'sync', =>
#			console.log "sync in batch controller"
#			@$('.bv_saveBatch').show()
#			@$('.bv_saveBatch').attr('disabled', 'disabled')
#			@$('.bv_saveBatchComplete').show()
#			@$('.bv_savingBatch').hide()
#			@trigger 'amClean'
#			@trigger 'firstBatchSaved'
#			@render()
		@listenTo @model, 'change', @modelChangeCallback
#		@model.on 'change', =>
#			@trigger 'amDirty'
#			@$('.bv_saveBatchComplete').hide()
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

		@

	modelSaveCallback: (method, model) ->
		@$('.bv_saveBatch').show()
		@$('.bv_saveBatch').attr('disabled', 'disabled')
		@$('.bv_saveBatchComplete').show()
		@$('.bv_savingBatch').hide()
		@trigger 'amClean'
		@trigger 'batchSaved'
		@render()

	modelChangeCallback: (method, model) ->
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
		@sourceList.url = "/api/dataDict/component/source"
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
			url: "/api/dataDict/analytical method/file type"
			dataType: 'json'
			error: (err) ->
				alert 'Could not get list of analytical file types'
			success: (json) =>
				if json.length == 0
					alert 'Got empty list of analytical file types'
				else
					attachFileList = @model.getAnalyticalFiles(json)
					@finishSetupAttachFileListController(attachFileList)

	finishSetupAttachFileListController: (attachFileList) ->
#		attachFileList = @model.getAttachFileList()
#		console.log attachFileList
#		console.log "done getting afl"
		@attachFileListController= new AttachFileListController
			autoAddAttachFileModel: false
			el: @$('.bv_attachFileList')
			collection: attachFileList
			firstOptionName: "Select Method"
		@attachFileListController.on 'amDirty', =>
			@trigger 'amDirty'
		@attachFileListController.on 'amClean', =>
			@trigger 'amClean'
#		@attachFileListController.insertFirstOption.set name: "Select Method"
		@attachFileListController.render()
		console.log @attachFileListController

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
		@model.reformatBeforeSaving()
		@$('.bv_savingBatch').show()
		@model.save()

	isValid: =>
		validCheck = super()
		console.log "overwrite isValid"
		if @attachFileListController?
			if @attachFileListController.isValid() is true
				console.log "attach list controller is valid"
				return validCheck
			else
				console.log "attach list controller is invalid"
				return false
		else
			return validCheck

class window.AbstractBaseComponentBatchSelectController extends Backbone.View
	template: _.template($("#AbstractBaseComponentBatchSelectView").html())

	events: ->
		"change .bv_batchList": "handleSelectedBatchChanged"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@setupBatchSelect()
		@setupBatchRegForm()
		@parentCodeName = @options.parentCodeName

	setupBatchSelect: ->
		@batchList = new PickListList()
		@batchList.url = "/api/batches/parentCodename/"+@parentCodeName
		@batchListController = new PickListSelectController
			el: @$('.bv_batchList')
			collection: @batchList
			insertFirstOption: new PickList
				code: "new batch"
				name: "Register New Batch"
			selectedCode: "new batch"

	setupBatchRegForm: (batch) =>
		@batchController.on 'amDirty', =>
			@trigger 'amDirty'
		@batchController.on 'amClean', =>
			@trigger 'amClean'
		@batchController.on 'batchSaved', =>
			@setupBatchSelect()
			@batchListController.setSelectedCode(@batchController.model.get('codeName'))
			@trigger 'batchSaved'
		@batchController.render()
		@$('.bv_saveBatch').attr('disabled','disabled')
		if @batchController.model.isNew()
			@$('.bv_saveBatch').html("Save Batch")
			@$('.bv_saveBatchComplete').html("Save Complete")
		else
			@$('.bv_saveBatch').html("Update Batch")
			@$('.bv_saveBatchComplete').html("Update Complete")

	checkIfFirstBatch: ->
		@batchListController.collection.length==1

class window.AbstractBaseComponentController extends Backbone.View
	template: _.template($("#AbstractBaseComponentView").html())

	events: ->
		"click .bv_save": "handleSaveClicked"


	completeInitialization: =>
		$(@el).html @template()
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
		if @firstSave
			@$('.bv_saveParentComplete').show()
			@firstSave = false
		else
			@$('.bv_saveParentComplete').hide()
			@$('.bv_saveFirstBatchComplete').hide()
#		@$('.bv_updateParentComplete').hide()

	setupBatchSelectController: ->
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
		@batchSelectController.render()

	handleBatchSaved: =>
		if @batchSelectController.checkIfFirstBatch()
			@$('.bv_saveFirstBatchComplete').show()
		else
			@$('.bv_saveFirstBatchComplete').hide()
			@$('.bv_saveParent').hide()
		@$('.bv_saving').hide()
#		@$('.bv_saveBatchComplete').hide()

	checkFormValid: ->
		if @parentController.isValid() and @batchSelectController.batchController.isValid()
			@$('.bv_save').removeAttr('disabled')
		else
			@$('.bv_save').attr('disabled', 'disabled')

	handleSaveClicked: ->
		@saveNewParentAttributes()
		@parentController.model.prepareToSave()
		@batchSelectController.batchController.model.prepareToSave()
		@$('.bv_save').hide()
		@$('.bv_saving').show()
		@parentController.model.reformatBeforeSaving()
		@batchSelectController.batchController.model.reformatBeforeSaving()
		@$('.bv_updateParentComplete').html("Save Complete")
		@$('.bv_saveBatch').html("Save Batch")
		@parentController.model.save()
		@batchSelectController.batchController.model.save()

	saveNewParentAttributes: =>
		scientist = @batchSelectController.batchController.model.get('scientist').get('value')
		cDate = @batchSelectController.batchController.model.get('completion date').get('value')
		notebook = @batchSelectController.batchController.model.get('notebook').get('value')
		@parentController.model.get('scientist').set('value', scientist)
		@parentController.model.get('completion date').set('value', cDate)
		@parentController.model.get('notebook').set('value', notebook)
