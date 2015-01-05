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
		cDate = attrs["completion date"].get('value')
		if cDate is undefined or cDate is "" then cDate = "fred"
		if isNaN(cDate)
			errors.push
				attribute: 'completionDate'
				message: "Date must be set"
		notebook = attrs.notebook.get('value')
		if notebook is "" or notebook is undefined
			errors.push
				attribute: 'notebook'
				message: "Notebook must be set"
		amount = attrs.amount.get('value')
		if amount is "" or amount is undefined or isNaN(amount)
			errors.push
				attribute: 'amount'
				message: "Amount must be set"
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
		"change .bv_parentName": "attributeChanged"
		"change .bv_recordedBy": "attributeChanged"
		"change .bv_completionDate": "attributeChanged"
		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"change .bv_notebook": "attributeChanged"

	initialize: ->
		console.log "initialize parent controller"
		@setBindings()
		@model.on 'sync', =>
			console.log "sync in parent controller"
			@trigger 'amClean'
			#			@$('.bv_saving').hide()
			#			@$('.bv_updateComplete').show()
			#			@$('.bv_save').attr('disabled', 'disabled')
			@render()
		@model.on 'change', =>
			@trigger 'amDirty'
		#			@$('.bv_updateComplete').hide()
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



class window.AbstractBaseComponentBatchController extends AbstractFormController
	template: _.template($("#AbstractBaseComponentBatchView").html())

	events: ->
		"change .bv_recordedBy": "attributeChanged"
		"change .bv_completionDate": "attributeChanged"
		"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
		"change .bv_notebook": "attributeChanged"
		"change .bv_amount": "attributeChanged"
		"change .bv_location": "attributeChanged"

	initialize: ->
		console.log "initialize batch controller"
		@setBindings()
		@model.on 'sync', =>
			console.log "sync"
			@trigger 'amClean'
			#			@$('.bv_saving').hide()
			#			@$('.bv_updateComplete').show()
			#			@$('.bv_save').attr('disabled', 'disabled')
			@render()
		@model.on 'change', =>
			@trigger 'amDirty'
		#			@$('.bv_updateComplete').hide()
		$(@el).empty()
		$(@el).html @template()
		@setupRecordedBySelect()


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

	handleCompletionDateIconClicked: =>
		@$( ".bv_completionDate" ).datepicker( "show" )

	updateModel: =>
		console.log "update batch model"
		@model.set recordedBy: @$('.bv_recordedBy').val()
		@model.get("notebook").set("value", UtilityFunctions::getTrimmedInput @$('.bv_notebook'))
		@model.get("completion date").set("value", UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_completionDate')))
		@model.get("amount").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_amount')))
		@model.get("location").set("value", UtilityFunctions::getTrimmedInput @$('.bv_location'))

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

	setupBatchRegForm: (batch)->
		@batchController.on 'amDirty', =>
			@trigger 'amDirty'
		@batchController.on 'amClean', =>
			@trigger 'amClean'
		@batchController.render()

class window.AbstractBaseComponentController extends Backbone.View
	template: _.template($("#AbstractBaseComponentView").html())

	events: ->
		"click .bv_save": "handleSaveClicked"


	completeInitialization: =>
		$(@el).html @template()
		@setupParentController()
		@setupBatchSelectController()
		#		if @parentController.model.get('codeName') is undefined
		if @parentController.model.isNew()
			@$('.bv_save').attr('disabled', 'disabled')
		else
			@$('.bv_save').hide()


	setupParentController: ->
		@parentController.on 'amDirty', =>
			@checkFormValid()
			@trigger 'amDirty'
		@parentController.on 'amClean', =>
			@trigger 'amClean'
		@parentController.render()
		console.log "rendered parent controller"

	setupBatchSelectController: ->
#		@batchSelectController = new CationicBlockBatchSelectController
#			el: @$('.bv_cationicBlockBatch')
#			parentCodeName: @model.get('codeName')
		@batchSelectController.on 'amDirty', =>
			@trigger 'amDirty'
			@checkFormValid()
		@batchSelectController.on 'amClean', =>
			@trigger 'amClean'
		@batchSelectController.render()

	checkFormValid: ->
		if @parentController.isValid() and @batchSelectController.batchController.isValid()
			@$('.bv_save').removeAttr('disabled')
		else
			@$('.bv_save').attr('disabled', 'disabled')

	handleSaveClicked: ->
		console.log "save clicked"
		@parentController.model.prepareToSave()
		@batchSelectController.batchController.model.prepareToSave()
		@$('.bv_save').hide()
		@$('.bv_saving').show()
		@parentController.model.save()
		@batchSelectController.batchController.model.save()
