class AbstractCodeTablesAdminController extends AbstractFormController
	###
		Instances of this controller must supply "moduleLaunchName", "codeType", and "modelClass"
	e.g. other required fields
	codeType: "assay"
	codeKind: "scientist"
	displayName: "assay scientist"
	pluralDisplayName: "assay scientists"
	upperDisplayName: "Assay Scientist"
	upperPluralDisplayName: "Assay Scientists"
	entityClass: "AssayScientist"
	entityControllerClass: "AssayScientistController"
	moduleLaunchName: "assay_scientist_browser"
	###
	template: _.template($("#AbstractCodeTablesAdminView").html())

	events: ->
		"input .bv_codeTablesAdminCode": "handleCodeTablesAdminCodeNameChanged"
		"input .bv_codeTablesAdminName": "handleCodeTablesAdminNameChanged"
		"click .bv_codeTablesAdminIgnore": "handleCodeTablesAdminIgnoreChanged"
		"click .bv_save": "handleSaveClicked"
		"click .bv_backToCodeTablesAdminBrowserBtn": "handleBackToCodeTablesAdminBrowserClicked"
#		"click .bv_newEntity": "handleNewEntityClicked"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_cancelClear": "handleCancelClearClicked"
		"click .bv_confirmClear": "handleConfirmClearClicked"

	initialize: (options) ->
		@options = options
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
							alert "Error getting #{@codeType} for code in this URL. Creating a new project"
							@completeInitialization()
						success: (json) =>
							if json.id?
								@model = new window[@modelClass] json
							else
								alert "Could not get #{@codeType} for code in this URL. Creating a new project"
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
		unless @showIgnore?
			@showIgnore = false
		@listenTo @model, 'saveFailed', @handleSaveFailed
		@listenTo @model, 'sync', @modelSaveCallback
		@listenTo @model, 'change', @modelChangeCallback
		$(@el).empty()
		toDisplay =
			displayName: @displayName
			pluralDisplayName: @pluralDisplayName
			upperDisplayName: @upperDisplayName
			upperPluralDisplayName: @upperPluralDisplayName
		$(@el).html(@template(toDisplay))
		if @showIgnore
			@$(".bv_group_codeTablesAdminIgnore").show()
		else
			@$(".bv_group_codeTablesAdminIgnore").hide()
		@notificationController = new LSNotificationController
			el: @$('.bv_notifications')
			showPreview: false
		@.on 'notifyError', @notificationController.addNotification
		@.on 'clearErrors', @notificationController.clearAllNotificiations
		@render()

	render: =>
		unless @model?
			@model = new window[@modelClass]()
		code = @model.escape('code')
		@$('.bv_codeTablesAdminCode').val(code)
		@$('.bv_codeTablesAdminCode').html(code)
		if @showIgnore
			if @model.get('ignored') is true
				@$('.bv_codeTablesAdminIgnore').attr 'checked', 'checked'
			else
				@$('.bv_codeTablesAdminIgnore').removeAttr 'checked'

		if @model.isNew()
			@$('.bv_save').html("Save")
#			@$('.bv_newEntity').hide()
		else
			@$('.bv_save').html("Update")
		#			@$('.bv_newEntity').show()
		@$('.bv_codeTablesAdminName').val @model.get('name')

		if @readOnly is true
			@displayInReadOnlyMode()
			@$('.bv_backToCodeTablesAdminBrowserBtn').hide()
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

	handleCodeTablesAdminCodeNameChanged: =>
		code = UtilityFunctions::getTrimmedInput @$('.bv_codeTablesAdminCode')

		if code is ""
			@model.set 'code', null
		else
			@model.set 'code', code
		@model.trigger 'change'

	handleBackToCodeTablesAdminBrowserClicked: =>
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

	handleCodeTablesAdminNameChanged: =>
		@model.set("name", UtilityFunctions::getTrimmedInput @$('.bv_codeTablesAdminName'))

	handleCodeTablesAdminIgnoreChanged: =>
		@model.set("ignored", @$('.bv_codeTablesAdminIgnore').is(":checked"))

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
			alert "The requested #{@codeType} #{@codeKind} code has already been registered. Please choose a new #{@codeType} #{@codeKind} code."
			@$('.bv_saving').hide()
			@$('.bv_saveFailed').show()
		else
			@saveCodeTablesAdmin()

	saveCodeTablesAdmin: =>
		if @model.isNew()
			@$('.bv_saveComplete').html('Save Complete')
		else
			@$('.bv_saveComplete').html('Update Complete')
		@$('.bv_save').attr('disabled', 'disabled')

		@model.save null,
			success: (model, response) =>
				if response is "update #{@codeType} failed"
					@model.trigger 'saveFailed'

	validationError: =>
		super()
		@$('.bv_save').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@notificationController.clearAllNotificiations()
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