class Salt extends Backbone.Model
    urlRoot: '/api/cmpdRegAdmin/salts'
    defaults: ->
        recordedBy: window.AppLaunchParams.loginUser.userName
        recordedDate: new Date().getTime()
        enabled: false

    validate: (attrs) ->
        errors = []
        if errors.length > 0
            return errors
        else
            return null

class SaltList extends Backbone.Collection
	model: Salt


class SaltEditorController extends AbstractFormController
	template: _.template($("#SaltEditorView").html())
	moduleLaunchName: "salt"

	events: ->
		"click .bv_save": "handleSaveClicked"
		"click .bv_newEntity": "handleNewEntityClicked"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_cancelClear": "handleCancelClearClicked"
		"click .bv_confirmClear": "handleConfirmClearClicked"


	initialize: (options) ->
		@options = options
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/cmpdRegAdmin/salts/"+encodeURIComponent(window.AppLaunchParams.moduleLaunchParams.code)
						dataType: 'json'
						error: (err) =>
							alert 'Could not get salt object with this code. Creating a new salt'
							@completeInitialization()
						success: (saltObj) =>
							@model = new Salt saltObj
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()


	completeInitialization: =>
		unless @model?
			@model = new Salt()
		@errorOwnerName = 'SaltEditorController'
		@setBindings()

		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
			if window.conf.salt?.editingRoles?
				editingRoles = window.conf.salt.editingRoles.split(",")
				if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, editingRoles)
					@readOnly = true

		$(@el).empty()
		$(@el).html @template()
		@$('.bv_save').attr('disabled', 'disabled')
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'change', @modelChangeCallback

		@render()

	render: =>
		unless @model?
			@model = new Salt()
		@$('.bv_saltName').val(@model.get('name'))
		@$('.bv_abbrev').val(@model.get('abbrev'))
		@$('.bv_formula').val(@model.get('formula'))
		@$('.bv_molWeight').val(@model.get('molWeight'))
		@$('.bv_charge').val(@model.get('charge'))

		if @model.isNew()
			@$('.bv_name').removeAttr 'disabled'
			@$('.bv_save').html("Save")
			@$('.bv_newEntity').hide()
		else
			@$('.bv_name').attr 'disabled', 'disabled'
			@$('.bv_save').html("Update")
			@$('.bv_newEntity').show()
			@$('.bv_cancel').hide()
		@$('.bv_save').attr('disabled', 'disabled')
		@$('.bv_cancel').attr('disabled','disabled')

		if @readOnly is true
			@displayInReadOnlyMode()

		@

	modelSyncCallback: =>
		@trigger 'amClean'
		@$('.bv_saving').hide()
		@$('.bv_saveComplete').show()
		@render()

	modelChangeCallback: =>
		@trigger 'amDirty'
		@$('.bv_saveComplete').hide()
		@$('.bv_cancel').removeAttr('disabled')
		@$('.bv_cancelComplete').hide()

	updateModel: =>

	handleSaveClicked: =>
		if @model.isNew()
			@$('.bv_saveComplete').html "Save Complete"
		else
			@$('.bv_saveComplete').html "Update Complete"
		@$('.bv_save').attr('disabled', 'disabled')
		@$('.bv_saving').show()
		@$('.bv_cancel').hide()
		console.log "handleSaveClicked"
		@model.save null,
			success: (model, response) ->
				console.log 'save successful'
			,
			error: (model, response) ->
				alert JSON.parse response.responseText


	handleNewEntityClicked: =>
		@$('.bv_confirmClearEntity').modal('show')
		@$('.bv_confirmClear').removeAttr('disabled')
		@$('.bv_cancelClear').removeAttr('disabled')
		@$('.bv_closeModalButton').removeAttr('disabled')

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
		@disableAllInputs()


	checkFormValid: =>
		if @isValid()
			@$('.bv_save').removeAttr('disabled')
		else
			@$('.bv_save').attr('disabled', 'disabled')

	isValid: =>
		validCheck = super()
		if @systemRoleListController?
			if @systemRoleListController.isValid() is false
				validCheck = false
		validCheck
