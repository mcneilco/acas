class window.AbstractFormController extends Backbone.View
# Your initialization function needs at least these lines:
# 	initialize: ->
# 		@errorOwnerName = 'MyControllerName'
#   	@setBindings()

	formFieldDefinitions: []


#	Setup edit lock check for the user session, form and entity identifier
#	disable feature if set to null
#	Override this in initilize() give model key for entity ID like 'codeName'
# Form must open socket, probably during initialize
# @openFormControllerSocket()
#	Form subclass must send request to lock when it has the id in hand
#	@socket.emit 'editLockEntity', @errorOwnerName, @model.get(@lockEditingForSessionKey)
#	This is safe to call repeatedly
	lockEditingForSessionKey: null

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
		if @lockEditingForSessionKey?
			@socket.emit 'updateEditLock', @errorOwnerName, @model.get(@lockEditingForSessionKey)

	disableAllInputs: ->
		@$('input').not('.dontdisable').attr 'disabled', 'disabled'
		@$('button').not('.dontdisable').attr 'disabled', 'disabled'
		@$('select').not('.dontdisable').attr 'disabled', 'disabled'
		@$("textarea").not('.dontdisable').attr 'disabled', 'disabled'
		@$(".bv_experimentCode").not('.dontdisable').css "background-color", "#eeeeee"
		@$(".bv_experimentCode").not('.dontdisable').css "color", "#333333"
		@$(".bv_creationDateIcon").not('.dontdisable').addClass "uneditable-input"
		@$(".bv_creationDateIcon").not('.dontdisable').on "click", ->
			return false
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

	openFormControllerSocket: ->
		if @lockEditingForSessionKey?
			@socket = io '/formController:connected'
			@socket.on 'editLockRequestResult', @handleEditLockRequestResult
			@socket.on 'editLockAvailable', @handleEditLockAvailable

	handleEditLockRequestResult: (result) =>
		if !result.okToEdit
			updateDate = new Date	result.lastActivityDate
			alert "This is being edited by #{result.currentEditor}. It was last edited at #{updateDate}. If you leave this tab open, you will be notified when it becomes available. For now, the form will be displayed as read-only."
			@disableAllInputs()
			@trigger 'editLocked'
		else
			@trigger 'editUnLocked'

	handleEditLockAvailable: =>
		@trigger 'editUnLocked'
		#you should extend this

class window.AbstractThingFormController extends AbstractFormController

	setupFormFields: (fieldDefs, useDirectRef) ->
		unless @formFields?
			@formFields = {}

		fDefs = []
		if fieldDefs.labels? then fDefs = fDefs.concat fieldDefs.labels
		if fieldDefs.values? then fDefs = fDefs.concat fieldDefs.values
		if fieldDefs.firstLsThingItxs? then fDefs = fDefs.concat fieldDefs.firstLsThingItxs
		if fieldDefs.secondLsThingItxs? then fDefs = fDefs.concat fieldDefs.secondLsThingItxs

		for field in fDefs
			if useDirectRef? and useDirectRef
				mdl = @model.get field.key
			else
				mdl = @model
			opts =
				modelKey: field.key
				inputClass: field.fieldSettings.inputClass
				formLabel: field.fieldSettings.formLabel
				placeholder: field.fieldSettings.placeholder
				required: field.fieldSettings.required
				url: field.fieldSettings.url
				thingRef: mdl
				insertUnassigned: field.fieldSettings.insertUnassigned
				modelDefaults: field.modelDefaults
				allowedFileTypes: field.fieldSettings.allowedFileTypes
				extendedLabel: field.fieldSettings.extendedLabel
				tabIndex: field.fieldSettings.tabIndex

			switch field.fieldSettings.fieldType
				when 'label'
					if field.multiple? and field.multiple
						newField = new ACASFormMultiLabelListController opts
					else
						newField = new ACASFormLSLabelFieldController opts
				when 'numericValue' then newField = new ACASFormLSNumericValueFieldController opts
				when 'codeValue' then newField = new ACASFormLSCodeValueFieldController opts
				when 'htmlClobValue'
					opts.rows = field.fieldSettings?.rows
					newField = new ACASFormLSHTMLClobValueFieldController opts
				when 'thingInteractionSelect'
					opts.thingType = field.fieldSettings.thingType
					opts.thingKind = field.fieldSettings.thingKind
					opts.queryUrl = field.fieldSettings.queryUrl
					opts.labelType = field.fieldSettings.labelType
					newField = new ACASFormLSThingInteractionFieldController opts
				when 'stringValue' then newField = new ACASFormLSStringValueFieldController opts
				when 'dateValue' then newField = new ACASFormLSDateValueFieldController opts
				when 'fileValue' then newField = new ACASFormLSFileValueFieldController opts
				when 'locationTree' 
					opts.tubeCode = @model.get('tubeCode')
					newField = new ACASFormLocationTreeController opts

			@$("."+field.fieldSettings.fieldWrapper).append newField.render().el
			newField.afterRender()
			@formFields[field.key] = newField
		if fieldDefs.stateTables?
			@setupFormTables fieldDefs.stateTables
		if fieldDefs.stateDisplayTables?
			@setupFormStateDisplayTables fieldDefs.stateDisplayTables

	fillFieldsFromModels: =>
		for modelKey, formField of @formFields
			formField.renderModelContent()
		for stateKey, formTable of @formTables
			formTable.renderModelContent()
		for stateKey, formDisplayTable of @formDisplayTables
			formDisplayTable.renderModelContent()

	setupFormTables: (tableDefs) ->
		unless @formTables?
			@formTables = {}
		for tDef in tableDefs
			tdiv = $("<div>")
			@$("."+tDef.tableWrapper).append tdiv
			fTable = new ACASFormStateTableController
				el: tdiv
				tableDef: tDef
				thingRef: @model
			fTable.render()
			@formTables[tDef.key] = fTable

	setupFormStateDisplayTables: (tableDefs) ->
		unless @formDisplayTables?
			@formDisplayTables = {}
		for tDef in tableDefs
			tdiv = $("<div>")
			@$("."+tDef.tableWrapper).append tdiv
			fTable = new ACASFormStateDisplayUpdateController
				el: tdiv
				tableDef: tDef
				thingRef: @model
			fTable.render()
			@formDisplayTables[tDef.key] = fTable

	disableAllInputs: ->
		super()
		for key, tbl of @formTables
			tbl.disableInput()
		for key, fld of @formFields
			fld.disableInput()

	enableAllInputs: ->
		super()
		for key, tbl of @formTables
			tbl.enableInput()
		for key, fld of @formFields
			fld.enableInput()
