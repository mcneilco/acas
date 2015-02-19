class window.AbstractFormController extends Backbone.View
# Your initialization function needs at least these lines:
# 	initialize: ->
# 		@errorOwnerName = 'MyControllerName'
#   	@setBindings()

	show: ->
		$(@el).show()

	hide: ->
		$(@el).hide()

	cancel: ->
		@clearValidationErrorStyles()
		@hide()

	setModel: (model) ->
		@model = model
		@setBindings()
		@render()

	attributeChanged: =>
		@trigger 'amDirty'
		@updateModel()

	setBindings: ->
		@model.on 'invalid', @validationError
		@model.on 'change', @handleModelChange

	validationError: =>
		errors = @model.validationError
		@clearValidationErrorStyles()

		_.each errors, (err) =>
			unless @$('.bv_'+err.attribute).attr('disabled') is 'disabled'
				@$('.bv_group_'+err.attribute).attr('data-toggle', 'tooltip')
				@$('.bv_group_'+err.attribute).attr('data-placement', 'bottom')
				@$('.bv_group_'+err.attribute).attr('data-original-title', err.message)
	#				@$('.bv_group_'+err.attribute).tooltip();
				@$("[data-toggle=tooltip]").tooltip();
				@$("body").tooltip selector: '.bv_group_'+err.attribute
				@$('.bv_group_'+err.attribute).addClass 'input_error error'
				@trigger 'notifyError',  owner: this.errorOwnerName, errorLevel: 'error', message: err.message
		@trigger 'invalid'

	clearValidationErrorStyles: =>
		errorElms = @$('.input_error')
		@trigger 'clearErrors', @errorOwnerName
		_.each errorElms, (ee) =>
			$(ee).removeAttr('data-toggle')
			$(ee).removeAttr('data-placement')
			$(ee).removeAttr('title')
			$(ee).removeAttr('data-original-title')
			$(ee).removeClass 'input_error error'

	isValid: ->
		@model.isValid()

	handleModelChange: =>
		@clearValidationErrorStyles()
		if @isValid()
			@trigger 'valid'
		else
			@trigger 'invalid'

	disableAllInputs: ->
		@$('input').attr 'disabled', 'disabled'
		@$('button').attr 'disabled', 'disabled'
		@$('select').attr 'disabled', 'disabled'
		@$("textarea").attr 'disabled', 'disabled'
		@$(".bv_experimentCode").css "background-color", "#eeeeee"
		@$(".bv_experimentCode").css "color", "#333333"
		@$(".bv_completionDateIcon").addClass "uneditable-input"
		@$(".bv_completionDateIcon").on "click", ->
			return false
		@$(".bv_group_tags input").prop "placeholder", ""
		@$(".bv_group_tags input").css "background-color", "#eeeeee"
		@$(".bv_group_tags input").css "color", "#333333"
		@$(".bv_group_tags div.bootstrap-tagsinput").css "background-color", "#eeeeee"



	enableAllInputs: ->
		@$('input').removeAttr 'disabled'
		@$('select').removeAttr 'disabled'
		@$("textarea").removeAttr 'disabled'
		@$('button').removeAttr 'disabled'
