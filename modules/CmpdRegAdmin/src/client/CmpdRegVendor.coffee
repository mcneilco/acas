############################################################################
# models
############################################################################
class window.Vendor extends Backbone.Model
	urlRoot: "/api/cmpdRegAdmin/vendors"
	defaults:
		name: null
		code: null
		id: null

	isEditable: ->
		return true

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
		"change .bv_vendorCode": "handleVendorCodeNameChanged"
		"keyup .bv_vendorName": "attributeChanged"
		"keyup .bv_vendorDetails": "attributeChanged"
		"click .bv_save": "handleSaveClicked"
		"click .bv_newEntity": "handleNewEntityClicked"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_cancelClear": "handleCancelClearClicked"
		"click .bv_confirmClear": "handleConfirmClearClicked"

	initialize: ->
		console.log 'initialize vendorController -- line 38'
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
		code = @model.get('code')
		@$('.bv_vendorCode').val(code)
		@$('.bv_vendorCode').html(code)
		if @model.isNew()
			console.log 'new vendor model -- line 67'
			@$('.bv_vendorCode').removeAttr('disabled')
			@$('.bv_save').removeAttr('disabled')
			@$('.bv_cancel').removeAttr('disabled')
			@$('.VendorView').show()
			@$('.bv_vendorCode').show()
			@$('.bv_vendorName').show()
		else
			console.log 'old vendor model -- line 75'
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
		code = UtilityFunctions::getTrimmedInput @$('.bv_vendorCode')
		console.log 'here is the codeName change -- line 142'
		console.log code
		if code is ""
			console.log 'deleting the code attribute -- line 145'
			delete @model.attributes.code
			@model.trigger 'change'
		else
			#validate codeName
			console.log ' 150 -- checking codeName'
			console.log code
			$.ajax
				type: 'GET'
				url: "/api/cmpdRegAdmin/vendors/findByCode/"+code
				dataType: 'json'
				error: (err) =>
					#codename is new
					console.log 'hit error searching for vendor by code -- line 158'
					@model.set code: code
					console.log JSON.stringify(@model)
					@clearValidationErrorStyles
				success: (json, status) =>
					#codeName is not unique

					console.log 'service did not return an error -- but what is the status code'
					console.log status
					console.log code
					@$('.bv_notUniqueModalTitle').html "Error: Vendor code is not unique"
					@$('.bv_notUniqueModalBody').html "The entered vendor code is already used by another vendor. Please enter in a new code."
					@$('.bv_notUniqueModal').modal('show')
					@$('.bv_vendorCode').val @model.get 'code'

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
		console.log 'line 204 -- updating model'
		@model.set("name", UtilityFunctions::getTrimmedInput @$('.bv_vendorName'))
		@model.set("code", UtilityFunctions::getTrimmedInput @$('.bv_vendorCode'))

	handleSaveClicked: =>
		console.log 'save clicked -- 194'
		@callNameValidationService()

		@$('.bv_saving').show()
		@$('.bv_saveFailed').hide()
		@$('.bv_saveComplete').hide()


	callNameValidationService: =>
		@updateModel()
		@$('.bv_saving').show()
		@$('.bv_save').attr('disabled', 'disabled')
		validateURL = "/api/cmpdRegAdmin/vendors/validateBeforeSave"
		dataToPost =
			data: #dataToPost needs wrapping key, not sure why
				JSON.stringify(@model)
		console.log 'posting data to validate function --- line 225'
		console.log validateURL
		console.log dataToPost
		$.ajax
			type: 'POST'
			url: validateURL
			data: dataToPost
			dataType: 'json'
			success: (response) =>
				console.log 'line 234 -- success return from validating vendor'
				console.log response
				@handleValidateReturn(response)
			error: (err) =>
				console.log 'line 238 -- error return from validating vendor'
				console.log err
				@serviceReturn = null

	handleValidateReturn: (validateResp) =>
		console.log "ValidateResp next line -- 224"
		console.log JSON.stringify validateResp
		if validateResp?[0]?.errorLevel?
			alert 'The requested vendor name has already been registered. Please choose a new vendor name.'
			@$('.bv_saving').hide()
			@$('.bv_saveFailed').show()
		else if validateResp is "validate name failed"
			alert 'There was an error validating the vendor name. Please try again and/or enter a different name.'
			@$('.bv_saving').hide()
			@$('.bv_saveFailed').show()
		else
			@saveVendor()

	saveVendor: =>
		console.log "saveVendor - handle tags changed"
		if @model.isNew()
			@$('.bv_saveComplete').html('Save Complete')
			newVendor = true
		else
			@$('.bv_saveComplete').html('Update Complete')
			newVendor = false
		@$('.bv_save').attr('disabled', 'disabled')
		if @model.isNew() #if vendor was new
			@model.save null,
				success: (model, response) =>
					console.log 'line 268 -- response from saveVendor'
					console.log response
					if response is "update vendor failed"
						@model.trigger 'saveFailed'
		else
			if UtilityFunctions::testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [@adminRole]) or UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, [window.conf.roles.acas.adminRole])
				@updateVendorRoles()
			else
				@model.save null,
					success: (model, response) =>
						console.log 'line 271 -- save vendor response'
						console.log response
						if response is "update lsThing failed"
							@model.trigger 'saveFailed'
					error: (err) =>
						console.log 'line 271 -- save vendor err'
						console.log err
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



