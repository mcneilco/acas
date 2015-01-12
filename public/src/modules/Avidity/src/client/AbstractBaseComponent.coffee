class window.AbstractBaseComponentParent extends Thing
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
		if attrs.recordedBy is "" or attrs.recordedBy is "unassigned"
			errors.push
				attribute: 'recordedBy'
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
		if attrs.amount?
			amount = attrs.amount.get('value')
			if amount is "" or amount is undefined or isNaN(amount)
				errors.push
					attribute: 'amount'
					message: "Amount must be set"
			if isNaN(amount)
				errors.push
					attribute: 'amount'
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
		"change .bv_recordedBy": "attributeChanged"
		"keyup .bv_completionDate": "attributeChanged"
		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"keyup .bv_notebook": "attributeChanged"
		"click .bv_updateParent": "handleUpdateParent"

	initialize: ->
		console.log "initialize parent controller"
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
		console.log "autofill template?"
		console.log @additionalParentAttributesTemplate?
		if @additionalParentAttributesTemplate?
			@$('.bv_additionalParentAttributes').html @additionalParentAttributesTemplate()
		@setupRecordedBySelect()


	render: =>
		codeName = @model.get('codeName')
		@$('.bv_parentCode').val(codeName)
		@$('.bv_parentCode').html(codeName)
		bestName = @model.get('lsLabels').pickBestName()
		if bestName?
			@$('.bv_parentName').val bestName.get('labelText')
		@$('.bv_recordedBy').val(@model.get('recordedBy'))
		console.log @model.get('recordedBy')
#		@$('.bv_molecularWeight').val(@model.get('molecular weight').get('value'))
		@$('.bv_completionDate').datepicker();
		@$('.bv_completionDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.get('completion date').get('value')?
			@$('.bv_completionDate').val UtilityFunctions::convertMSToYMDDate(@model.get('completion date').get('value'))
		@$('.bv_notebook').val @model.get('notebook').get('value')
		if @model.isNew()
			console.log "model is new"
			@$('.bv_recordedBy').attr('disabled','disabled')
			@$('.bv_completionDate').attr('disabled','disabled')
			@$('.bv_notebook').attr('disabled','disabled')
			@$('.bv_completionDateIcon').on "click", ->
				return false

		@

	modelSaveCallback: (method, model) ->
		console.log "sync in parent controller"
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

	setupRecordedBySelect: ->
		console.log "setup recorded by"
		console.log @model.get('recordedBy')
		if @model.isNew()
			defaultOption = "Filled from first batch"
		else
			defaultOption = "Select Scientist"
		@recordedByList = new PickListList()
		@recordedByList.url = "/api/authors"
		@recordedByListController = new PickListSelectController
			el: @$('.bv_recordedBy')
			collection: @recordedByList
			insertFirstOption: new PickList
				code: "unassigned"
				name: defaultOption
			selectedCode: @model.get('recordedBy')

	handleCompletionDateIconClicked: =>
		@$( ".bv_completionDate" ).datepicker( "show" )

	updateModel: =>
		@model.set recordedBy: @$('.bv_recordedBy').val()
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
		console.log "handle update parent"
		@model.reformatBeforeSaving()
		@$('.bv_updatingParent').show()
		@$('.bv_updateParentComplete').html('Update Complete.')
		@model.save()

class window.AbstractBaseComponentBatchController extends AbstractFormController
	template: _.template($("#AbstractBaseComponentBatchView").html())

	events: ->
		"change .bv_recordedBy": "attributeChanged"
		"keyup .bv_completionDate": "attributeChanged"
		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"keyup .bv_notebook": "attributeChanged"
		"keyup .bv_amount": "attributeChanged"
		"keyup .bv_location": "attributeChanged"
		"click .bv_saveBatch": "handleSaveBatch"

	initialize: ->
		console.log "initialize batch controller"
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
		console.log @additionalBatchAttributesTemplate?
		if @additionalBatchAttributesTemplate?
			@$('.bv_additionalBatchAttributes').html @additionalBatchAttributesTemplate()
		@setupRecordedBySelect()
		@setupAttachFileListController()


	render: =>
		@$('.bv_batchCode').val(@model.get('codeName'))
		@$('.bv_batchCode').html(@model.get('codeName'))
		@$('.bv_recordedBy').val(@model.get('recordedBy'))
		@$('.bv_completionDate').datepicker();
		@$('.bv_completionDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.get('completion date').get('value')?
			@$('.bv_completionDate').val UtilityFunctions::convertMSToYMDDate(@model.get('completion date').get('value'))
		else
			@$('.bv_completionDate').val ""
		@$('.bv_notebook').val @model.get('notebook').get('value')
		@$('.bv_amount').val(@model.get('amount').get('value'))
		@$('.bv_location').val(@model.get('location').get('value'))

		@

	modelSaveCallback: (method, model) ->
		console.log "sync in batch controller"
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

	setupRecordedBySelect: ->
		@recordedByList = new PickListList()
		@recordedByList.url = "/api/authors"
		@recordedByListController = new PickListSelectController
			el: @$('.bv_recordedBy')
			collection: @recordedByList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Scientist"
			selectedCode: @model.get('recordedBy')

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
					console.log "success"
					console.log json
					attachFileList = @model.getAnalyticalFiles(json)
					@finishSetupAttachFileListController(attachFileList)

	finishSetupAttachFileListController: (attachFileList) ->
		console.log attachFileList
		console.log "finish set up attach file list controller"
#		attachFileList = @model.getAttachFileList()
#		console.log attachFileList
#		console.log "done getting afl"
		@attachFileListController= new AttachFileListController
#			canRemoveAttachFileModel: false
			el: @$('.bv_attachFileList')
			collection: attachFileList
		@attachFileListController.on 'amDirty', =>
			console.log "aflc trigger dirty to batch controller"
			@trigger 'amDirty'
		@attachFileListController.on 'amClean', =>
			@trigger 'amClean'
		@attachFileListController.render()

	handleCompletionDateIconClicked: =>
		@$( ".bv_completionDate" ).datepicker( "show" )

	updateModel: =>
		console.log "update batch model"
		@model.set recordedBy: @$('.bv_recordedBy').val()
		@model.get("notebook").set("value", UtilityFunctions::getTrimmedInput @$('.bv_notebook'))
		@model.get("completion date").set("value", UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_completionDate')))
		@model.get("amount").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_amount')))
		@model.get("location").set("value", UtilityFunctions::getTrimmedInput @$('.bv_location'))

	validationError: =>
		super()
		@$('.bv_saveBatch').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_saveBatch').removeAttr('disabled')

	handleSaveBatch: =>
		console.log "handle save batch"
		@model.reformatBeforeSaving()
		@$('.bv_savingBatch').show()
		console.log @model
		console.log @model.get('id')
		@model.save()

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
		console.log "setup Batch Select"
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
			console.log "batch controller trigger dirty to batch select controller"
			@trigger 'amDirty'
		@batchController.on 'amClean', =>
			@trigger 'amClean'
		@batchController.on 'batchSaved', =>
			console.log "batch adn batch select trigger"
			@setupBatchSelect()
			@batchListController.setSelectedCode(@batchController.model.get('codeName'))
			@trigger 'batchSaved'
		@batchController.render()
		@$('.bv_saveBatch').attr('disabled','disabled')
		console.log "is model new?"
		if @batchController.model.isNew()
			@$('.bv_saveBatch').html("Save Batch")
			@$('.bv_saveBatchComplete').html("Save Complete")
		else
			@$('.bv_saveBatch').html("Update Batch")
			@$('.bv_saveBatchComplete').html("Update Complete")

	checkIfFirstBatch: ->
		console.log "checkIfFirstBatch"
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
		console.log "rendered parent controller"
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
			console.log "batch select controller trigger amDirty to base batch component controller"
			@trigger 'amDirty'
			@checkFormValid()
		@batchSelectController.on 'amClean', =>
			@trigger 'amClean'
		@batchSelectController.on 'batchSaved', =>
			@handleBatchSaved()
		@batchSelectController.render()

	handleBatchSaved: =>
		console.log "first batch saved	"
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
		console.log "save clicked"
		@saveNewParentAttributes()
		@parentController.model.prepareToSave()
		@batchSelectController.batchController.model.prepareToSave()
		@$('.bv_save').hide()
		@$('.bv_saving').show()
		@parentController.model.reformatBeforeSaving()
		@batchSelectController.batchController.model.reformatBeforeSaving()
		console.log @parentController.model
		@$('.bv_updateParentComplete').html("Save Complete")
		@$('.bv_saveBatch').html("Save Batch")
		@parentController.model.save()
		@batchSelectController.batchController.model.save()

	saveNewParentAttributes: =>
		recordedBy = @batchSelectController.batchController.model.get('recordedBy')
		cDate = @batchSelectController.batchController.model.get('completion date').get('value')
		notebook = @batchSelectController.batchController.model.get('notebook').get('value')
		@parentController.model.set 'recordedBy', recordedBy
		@parentController.model.get('completion date').set('value', cDate)
		@parentController.model.get('notebook').set('value', notebook)
