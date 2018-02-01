class window.AbstractCmpdRegAdminController extends AbstractFormController
	###
		Instances of this controller must supply "moduleLaunchName", "entityType", and "modelClass"
  	entityTypePlural
  	entityTypeUpper
  	entityTypeUpperPlural
	###
	template: _.template($("#AbstractCmpdRegAdminView").html())

	events: ->
		"keyup .bv_cmpdRegAdminCode": "handleCmpdRegAdminCodeNameChanged"
		"keyup .bv_cmpdRegAdminName": "handleCmpdRegAdminNameChanged"
		"click .bv_cmpdRegAdminIgnore": "handleCmpdRegAdminIgnoreChanged"
		"click .bv_save": "handleSaveClicked"
		"click .bv_backToCmpdRegAdminBrowserBtn": "handleBackToCmpdRegAdminBrowserClicked"
#		"click .bv_newEntity": "handleNewEntityClicked"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_cancelClear": "handleCancelClearClicked"
		"click .bv_confirmClear": "handleConfirmClearClicked"

	initialize: ->
		console.log "initializing Abstract Controller"
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: @model.urlRoot + '/codeName/'+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) =>
							alert "Error getting #{@entityType} for code in this URL. Creating a new project"
							@completeInitialization()
						success: (json) =>
							if json.id?
								@model = new window[@modelClass] json
							else
								alert "Could not get #{@entityType} for code in this URL. Creating a new project"
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()


	completeInitialization: =>
		unless @model?
			@model=new window[@modelClass]()
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		@listenTo @model, 'saveFailed', @handleSaveFailed
		@listenTo @model, 'sync', @modelSaveCallback
		@listenTo @model, 'change', @modelChangeCallback
		$(@el).empty()
		toDisplay =
			entityTypeToDisplay: if @entityTypeToDisplay? then @entityTypeToDisplay else @entityType
			entityTypePluralToDisplay: if @entityTypePluralToDisplay? then @entityTypePluralToDisplay else @entityTypePlural
			entityTypeUpper: @entityTypeUpper
			entityTypeUpperPlural: @entityTypeUpperPlural
		$(@el).html(@template(toDisplay))
		@render()

	render: =>
		unless @model?
			@model = new window[@modelClass]()
		code = @model.get('code')
		@$('.bv_cmpdRegAdminCode').val(code)
		@$('.bv_cmpdRegAdminCode').html(code)
		if @model.get('ignore') is true
			@$('.bv_cmpdRegAdminIgnore').attr 'checked', 'checked'
		else
			@$('.bv_cmpdRegAdminIgnore').removeAttr 'checked'

		if @model.isNew()
			@$('.bv_save').html("Save")
#			@$('.bv_newEntity').hide()
		else
			@$('.bv_save').html("Update")
		#			@$('.bv_newEntity').show()
		@$('.bv_cmpdRegAdminName').val @model.get('name')

		if @readOnly is true
			@displayInReadOnlyMode()
			@$('.bv_backToCmpdRegAdminBrowserBtn').hide()
		@$('.bv_save').attr('disabled','disabled')
		@$('.bv_cancel').attr('disabled','disabled')

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
		@$('.bv_cancel').removeAttr 'disabled'
		@render()
		@trigger 'amClean'

	modelChangeCallback: (method, model) =>
		@trigger 'amDirty'
		@checkFormValid()
		@$('.bv_saveComplete').hide()
		@$('.bv_saveFailed').hide()
		@$('.bv_cancel').removeAttr('disabled')
		@$('.bv_cancelComplete').hide()

	handleCmpdRegAdminCodeNameChanged: =>
		code = UtilityFunctions::getTrimmedInput @$('.bv_cmpdRegAdminCode')

		if code is ""
			@model.set 'code', null
		else
			@model.set 'code', code
		@model.trigger 'change'

	handleBackToCmpdRegAdminBrowserClicked: =>
		@trigger 'backToBrowser'


#	handleNewEntityClicked: =>
#		@$('.bv_confirmClearEntity').modal('show')
#		@$('.bv_confirmClear').removeAttr('disabled')
#		@$('.bv_cancelClear').removeAttr('disabled')
#		@$('.bv_closeModalButton').removeAttr('disabled')

	handleCancelClearClicked: =>
		@$('.bv_confirmClearEntity').modal('hide')

	handleConfirmClearClicked: =>
		@$('.bv_confirmClearEntity').modal('hide')
		@model = null
		@completeInitialization()
		@trigger 'amClean'

	handleCancelClicked: =>
		if @model.isNew()
			@model = null
			@completeInitialization()
		else
			@$('.bv_canceling').show()
			@model.fetch
				success: @handleCancelComplete
		@trigger 'amClean'

	handleCancelComplete: =>
		@$('.bv_canceling').hide()
		@$('.bv_cancelComplete').show()

	handleCmpdRegAdminNameChanged: =>
		@model.set("name", UtilityFunctions::getTrimmedInput @$('.bv_cmpdRegAdminName'))

	handleCmpdRegAdminIgnoreChanged: =>
		@model.set("ignore", @$('.bv_cmpdRegAdminIgnore').is(":checked"))

	handleSaveClicked: =>
		@callNameValidationService()

		@$('.bv_saving').show()
		@$('.bv_saveFailed').hide()
		@$('.bv_saveComplete').hide()


	callNameValidationService: =>
		@$('.bv_saving').show()
		@$('.bv_save').attr('disabled', 'disabled')
		validateURL = @model.urlRoot + '/validateBeforeSave'
		dataToPost =
			data: JSON.stringify(@model)
		$.ajax
			type: 'POST'
			url: validateURL
			data: dataToPost
			dataType: 'json'
			success: (response) =>
				@handleValidateReturn(response)
			error: (err) =>
				@handleValidateError(JSON.parse err.responseText)

	handleValidateError: (err) =>
		if err?[0]?.level? and err[0].level is "ERROR"
			alert "The requested code has already been used"
		@$('.bv_saving').hide()
		@$('.bv_saveFailed').show()

	handleValidateReturn: (validateResp) =>
		if validateResp?[0]?.errorLevel?
			alert "The requested #{@entityType} name has already been registered. Please choose a new #{@entityType} name."
			@$('.bv_saving').hide()
			@$('.bv_saveFailed').show()
		else
			@saveCmpdRegAdmin()

	saveCmpdRegAdmin: =>
		if @model.isNew()
			@$('.bv_saveComplete').html('Save Complete')
		else
			@$('.bv_saveComplete').html('Update Complete')
		@$('.bv_save').attr('disabled', 'disabled')

		@model.save null,
			success: (model, response) =>
				if response is "update #{@entityType} failed"
					@model.trigger 'saveFailed'

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
		@$(".bv_cancel").hide()
		#		@$(".bv_newEntity").hide()
		@$('button').attr 'disabled', 'disabled'
		@disableAllInputs()

	checkFormValid: =>
		if @isValid()
			@$('.bv_save').removeAttr('disabled')
		else
			@$('.bv_save').attr('disabled', 'disabled')