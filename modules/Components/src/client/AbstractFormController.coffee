class window.AbstractFormController extends Backbone.View
# Your initialization function needs at least these lines:
# 	initialize: ->
# 		@errorOwnerName = 'MyControllerName'
#   	@setBindings()

	formFieldDefinitions: []

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
				@$('.bv_group_'+err.attribute).addClass 'input_error error'
				@trigger 'notifyError',  owner: this.errorOwnerName, errorLevel: 'error', message: err.message
		@trigger 'invalid'

	clearValidationErrorStyles: =>
		errorElms = @$('.input_error')
		@trigger 'clearErrors', @errorOwnerName
		_.each errorElms, (ee) =>
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
		@$('input').not('.dontdisable').attr 'disabled', 'disabled'
		@$('button').not('.dontdisable').attr 'disabled', 'disabled'
		@$('select').not('.dontdisable').attr 'disabled', 'disabled'
		@$("textarea").not('.dontdisable').attr 'disabled', 'disabled'
		@$(".bv_experimentCode").not('.dontdisable').css "background-color", "#eeeeee"
		@$(".bv_experimentCode").not('.dontdisable').css "color", "#333333"
		@$(".bv_completionDateIcon").not('.dontdisable').addClass "uneditable-input"
		@$(".bv_completionDateIcon").not('.dontdisable').on "click", ->
			return false
		@$(".bv_group_tags input").not('.dontdisable').prop "placeholder", ""
		@$(".bv_group_tags input").not('.dontdisable').css "background-color", "#eeeeee"
		@$(".bv_group_tags input").not('.dontdisable').css "color", "#333333"
		@$(".bv_group_tags div.bootstrap-tagsinput").not('.dontdisable').css "background-color", "#eeeeee"
		@$("span.tag.label.label-info span").not('.dontdisable').attr "data-role", ""

	enableAllInputs: ->
		@$('input').removeAttr 'disabled'
		@$('select').removeAttr 'disabled'
		@$("textarea").removeAttr 'disabled'
		@$('button').removeAttr 'disabled'
		@$(".bv_group_tags input").prop "placeholder", "Add tags"
		@$(".bv_group_tags div.bootstrap-tagsinput").css "background-color", "#ffffff"
		@$(".bv_group_tags input").css "background-color", "transparent"


class window.AbstractThingFormController extends AbstractFormController

	setupFormFields: (fieldDefs) ->
		unless @formFields?
			@formFields = {}

		for field in fieldDefs.labels.concat(fieldDefs.values)
			opts =
				modelKey: field.key
				inputClass: field.fieldSettings.inputClass
				formLabel: field.fieldSettings.formLabel
				placeholder: field.fieldSettings.placeholder
				required: field.fieldSettings.required
				thingRef: @model

			switch field.fieldSettings.fieldType
				when 'label' then newField = new ACASFormLSLabelFieldController opts
				when 'numericValue' then newField = new ACASFormLSNumericValueFieldController opts

			@$("."+field.fieldSettings.fieldWrapper).append newField.render().el
			@formFields[field.key] = newField
		@setupFormTables fieldDefs.stateTables

	fillFieldsFromModels: ->
		for modelKey, formField of @formFields
			formField.renderModelContent()
		for stateKey, formTable of @formTables
			formTable.renderModelContent()

	setupFormTables: (tableDefs) ->
		unless @formTables?
			@formTables = {}
		for tDef in tableDefs
			fTable = new ACASFormStateTableController tableDef: tDef, thingRef: @model
			@$("."+tDef.tableWrapper).append fTable.render().el
			@formTables[tDef.key] = fTable
