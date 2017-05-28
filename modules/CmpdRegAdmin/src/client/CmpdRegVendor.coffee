class window.Vendor extends Backbone.Model
	urlRoot: "/api/cmpdRegAdmin/vendors"
	defaults:
		name: null
		code: null
		id: null

	isEditable: ->
		return true

class window.Vendors extends Backbone.Collection
	model: Vendor

class window.VendorController extends AbstractFormController
	template: _.template($("#VendorView").html())
	moduleLaunchName: "vendor"

	events: ->
		"change .bv_vendorCode": "handleVendorCodeNameChanged"
		"keyup .bv_vendorName": "attributeChanged"
		"keyup .bv_vendorDetails": "attributeChanged"
		"click .bv_save": "handleSaveClicked"
		"click .bv_newEntity": "handleNewEntityClicked"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_cancelClear": "handleCancelClearClicked"
		"click .bv_confirmClear": "handleConfirmClearClicked"

	initialize: ->
		console.log 'initialize vendorController -- line 30'
		template = _.template( $("#VendorView").html());
		$(@el).empty()
		$(@el).html template
		if @model?
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
		@listenTo @model, 'change', @modelChangeCallback
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@render()

	render: =>
		unless @model?
			@model = new Vendor()
		codeName = @model.get('code')
		@$('.bv_vendorCode').val(codeName)
		@$('.bv_vendorCode').html(codeName)
		if @model.isNew()
			console.log 'new vendor model -- line 56'
			@$('.bv_vendorCode').removeAttr 'disabled'
			@$('.bv_save').removeAttr('disabled')
			@$('.bv_cancel').removeAttr('disabled')
			@$('.VendorView').show()
			@$('.bv_vendorCode').show()
			@$('.bv_vendorName').show()
		else
			console.log 'old vendor model -- line 59'
			@$('.bv_vendorCode').attr 'disabled', 'disabled'
		bestName = @model.get('name')
		if bestName?
			@$('.bv_vendorName').val bestName
		if @model.isNew()
			@$('.bv_saveBeforeManagingPermissions').show()
			if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, [window.conf.roles.cmpdreg.adminRole]
				@$('.bv_saveBeforeManagingPermissions').show()
		else
			@updateEditable()
		if @readOnly is true
			@displayInReadOnlyMode()
#		@$('.bv_save').attr('disabled','disabled')
#		@$('.bv_cancel').attr('disabled','disabled')
		@$('.VendorView').show()
		@$('.bv_vendorCode').show()

		if @model.isNew()
			@$('.bv_save').html("Save")
			@$('.bv_newEntity').hide()
		else
			@$('.bv_save').html("Update")
			@$('.bv_newEntity').show()
		@

	handleSaveFailed: =>
		@$('.bv_saveFailed').show()
		@$('.bv_saveComplete').hide()
		@$('.bv_saving').hide()

	modelSaveCallback: (method, model) =>
		@$('.bv_save').show()
#		@$('.bv_save').attr('disabled', 'disabled')
		unless @$('.bv_saveFailed').is(":visible")
			@$('.bv_saveComplete').show()
			@$('.bv_saving').hide()
		@render()
		@trigger 'amClean'

	modelChangeCallback: (method, model) =>
		@trigger 'amDirty'
		@checkFormValid()
		@$('.bv_saveComplete').hide()
		@$('.bv_saveFailed').hide()
		@$('.bv_cancel').removeAttr('disabled')
		@$('.bv_cancelComplete').hide()

	updateEditable: =>
		if @model.isEditable()
			if UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, [window.conf.roles.acas.adminRole])
				@enableAllInputs()
				@$('.bv_vendorCode').attr 'disabled', 'disabled'
				@$('.bv_saveBeforeManagingPermissions').hide()
			else
				@enableLimitedEditing()
				@$('.bv_manageUserPermissions').hide()
		else
			@disableAllInputs()
			@$('.bv_newEntity').removeAttr('disabled')
		@$('.bv_status').attr 'disabled', 'disabled' #for now, don't allow status editing

	enableLimitedEditing: ->
		@disableAllInputs()

	handleVendorCodeNameChanged: =>
		codeName = UtilityFunctions::getTrimmedInput @$('.bv_vendorCode')
		if codeName is ""
			delete @model.attributes.codeName
			@model.trigger 'change'
		else
			#validate codeName
			$.ajax
				type: 'GET'
				url: "/api/cmpdRegAdmin/vendors/findByCode/"+codeName
				dataType: 'json'
				error: (err) =>
					#codename is new
					@model.set codeName: codeName
					@clearValidationErrorStyles
				success: (json) =>
					#codeName is not unique
					@$('.bv_notUniqueModalTitle').html "Error: Vendor code is not unique"
					@$('.bv_notUniqueModalBody').html "The entered vendor code is already used by another vendor. Please enter in a new code."
					@$('.bv_notUniqueModal').modal('show')
					@$('.bv_vendorCode').val @model.get 'codeName'

	handleNewEntityClicked: =>
		@$('.bv_confirmClearEntity').modal('show')
		@$('.bv_confirmClear').removeAttr('disabled')
		@$('.bv_cancelClear').removeAttr('disabled')
		@$('.bv_closeModalButton').removeAttr('disabled')
		@$('.bv_save').removeAttr('disabled')

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

	updateModel: =>
		@model.set("name", UtilityFunctions::getTrimmedInput @$('.bv_vendorName'))
		@model.set("code", UtilityFunctions::getTrimmedInput @$('.bv_vendorCode'))

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
		validateURL = "/api/cmpdRegAdmin/vendors/validate"
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
			alert 'The requested vendor name has already been registered. Please choose a new vendor name.'
			@$('.bv_saving').hide()
			@$('.bv_saveFailed').show()
		else if validateResp is "validate name failed"
			alert 'There was an error validating the vendor name. Please try again and/or enter a different name.'
			@$('.bv_saving').hide()
			@$('.bv_saveFailed').show()
		else
			@saveVendorAndRoles()

	saveVendorAndRoles: =>
		console.log "saveVendorAndRoles - handle tags changed"
		@model.prepareToSave()
		@model.reformatBeforeSaving()
		if @model.isNew()
			@$('.bv_saveComplete').html('Save Complete')
			newVendor = true
		else
			@$('.bv_saveComplete').html('Update Complete')
			newVendor = false
		@$('.bv_save').attr('disabled', 'disabled')
		if @model.isNew() #if vendor was new, trigger roleKind and user/admin lsRole creation
			@model.save null,
				success: (model, response) =>
					if response is "update lsThing failed"
						@model.trigger 'saveFailed'
		else
			if UtilityFunctions::testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [@adminRole]) or UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, [window.conf.roles.acas.adminRole])
				@updateVendorRoles()
			else
				@model.save null,
					success: (model, response) =>
						if response is "update lsThing failed"
							@model.trigger 'saveFailed'
					error: (err) =>
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
		@$(".bv_newEntity").hide()
		@$('button').attr 'disabled', 'disabled'
		@disableAllInputs()

	checkFormValid: =>
		if @isValid()
			@$('.bv_save').removeAttr('disabled')
		else
			@$('.bv_save').attr('disabled', 'disabled')

	isValid: =>
		validCheck = super()
		validCheck



