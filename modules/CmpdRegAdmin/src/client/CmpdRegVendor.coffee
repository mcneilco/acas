############################################################################
# models
############################################################################
class window.Vendor extends Backbone.Model
	urlRoot: "/api/cmpdRegAdmin/vendors"
	defaults:
		name: null
		code: null
		id: null

	validate: (attrs) ->
		errors = []
		if attrs.code? and @isNew()
			validChars = attrs.code.match(/[a-zA-Z0-9 _\-+]/g)
			unless validChars.length is attrs.code.length
				errors.push
					attribute: 'vendorCode'
					message: "Vendor code can not contain special characters"
		if !attrs.name? or attrs.name is ""
			errors.push
				attribute: 'vendorName'
				message: "Vendor name must be set and unique"
		if errors.length > 0
			return errors
		else
			return null

############################################################################
class window.Vendors extends Backbone.Collection
	model: Vendor
############################################################################

############################################################################
# controllers
############################################################################

class window.VendorController extends AbstractFormController
	template: _.template($("#VendorView").html())
	moduleLaunchName: "vendor"

	events: ->
		"keyup .bv_vendorCode": "handleVendorCodeNameChanged"
		"keyup .bv_vendorName": "handleVendorNameChanged"
		"click .bv_save": "handleSaveClicked"
		"click .bv_backToVendorBrowserBtn": "handleBackToVendorBrowserClicked"
#		"click .bv_newEntity": "handleNewEntityClicked"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_cancelClear": "handleCancelClearClicked"
		"click .bv_confirmClear": "handleConfirmClearClicked"

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/cmpdRegAdmin/vendors/codeName/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) =>
							alert 'Error getting vendor for code in this URL. Creating a new project'
							@completeInitialization()
						success: (json) =>
							if json.id?
								@model = new Vendor json
							else
								alert 'Could not get vendor for code in this URL. Creating a new project'
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()


	completeInitialization: =>
		unless @model?
			@model=new Vendor()
		@errorOwnerName = 'VendorController'
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		@listenTo @model, 'saveFailed', @handleSaveFailed
		@listenTo @model, 'sync', @modelSaveCallback
		@listenTo @model, 'change', @modelChangeCallback
		$(@el).empty()
		$(@el).html @template()
		@render()

	render: =>
		unless @model?
			@model = new Vendor()
		code = @model.get('code')
		@$('.bv_vendorCode').val(code)
		@$('.bv_vendorCode').html(code)
		if @model.isNew()
			@$('.bv_save').html("Save")
#			@$('.bv_newEntity').hide()
		else
			@$('.bv_save').html("Update")
#			@$('.bv_newEntity').show()
		@$('.bv_vendorName').val @model.get('name')

		if @readOnly is true
			@displayInReadOnlyMode()
			@$('.bv_backToVendorBrowserBtn').hide()
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

	handleVendorCodeNameChanged: =>
		code = UtilityFunctions::getTrimmedInput @$('.bv_vendorCode')

		if code is ""
			@model.set 'code', null
		else
			@model.set 'code', code
		@model.trigger 'change'
	
	handleBackToVendorBrowserClicked: =>
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

	handleVendorNameChanged: =>
		@model.set("name", UtilityFunctions::getTrimmedInput @$('.bv_vendorName'))

	handleSaveClicked: =>
		@callNameValidationService()

		@$('.bv_saving').show()
		@$('.bv_saveFailed').hide()
		@$('.bv_saveComplete').hide()


	callNameValidationService: =>
		@$('.bv_saving').show()
		@$('.bv_save').attr('disabled', 'disabled')
		validateURL = "/api/cmpdRegAdmin/vendors/validateBeforeSave"
		dataToPost =
			data: #dataToPost needs wrapping key, not sure why
				JSON.stringify(@model)
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
			alert 'The requested vendor name has already been registered. Please choose a new vendor name.'
			@$('.bv_saving').hide()
			@$('.bv_saveFailed').show()
		else
			@saveVendor()

	saveVendor: =>
		if @model.isNew()
			@$('.bv_saveComplete').html('Save Complete')
		else
			@$('.bv_saveComplete').html('Update Complete')
		@$('.bv_save').attr('disabled', 'disabled')

		@model.save null,
			success: (model, response) =>
				if response is "update vendor failed"
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
