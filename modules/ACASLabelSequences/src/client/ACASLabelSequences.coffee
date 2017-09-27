#MODELS
class window.ACASLabelSequenceRole extends Backbone.Model

class window.ACASLabelSequenceRoleList extends Backbone.Collection
	model: ACASLabelSequenceRole

	validateCollection: =>
		modelErrors = []
		usedRoles={}
		if @.length != 0
			for index in [0..@.length-1]
				model = @.at(index)
				if model.get('lsRole')? and model.get('lsRole').get('id')?
					currentRole =  model.get('lsRole').get('id')
				else
					currentRole = null
				if currentRole of usedRoles
					modelErrors.push
						attribute: 'role:eq('+index+')'
						message: "The same lsRole can not be chosen more than once"
					modelErrors.push
						attribute: 'role:eq('+usedRoles[currentRole]+')'
						message: "The same lsRole can not be chosen more than once"
				else
					usedRoles[currentRole] = index
		modelErrors

class window.ACASLabelSequence extends Backbone.Model
	url: "/api/labelsequences/"
	defaults:
		labelPrefix: ""
		startingNumber: null
		digits: null
		labelSeparator: null
		labelTypeAndKind: null
		thingTypeAndKind: null
		labelSequenceRoles: []

	validate: (attrs) ->
		errors = []
		if attrs.labelPrefix is "" or attrs.labelPrefix is undefined
			errors.push
				attribute: 'labelPrefix'
				message: "Label prefix must be set"
		if isNaN(attrs.startingNumber) or attrs.startingNumber is undefined or attrs.startingNumber is null or attrs.startingNumber.length < 1
			errors.push
				attribute: 'startingNumber'
				message: "Starting Number must set and be a number"
		if isNaN(attrs.digits) or attrs.digits is undefined or attrs.digits is null or attrs.digits.length < 1
			errors.push
				attribute: 'digits'
				message: "Number of digits must set and be a number"
		labelTypeAndKind = @get('labelTypeAndKind')
		if labelTypeAndKind is "unassigned" or labelTypeAndKind is undefined or labelTypeAndKind is "" or labelTypeAndKind is null
			errors.push
				attribute: 'labelTypeAndKind'
				message: "Label Type and Kind must be set"
		thingTypeAndKind = @get('thingTypeAndKind')
		if thingTypeAndKind is "unassigned" or thingTypeAndKind is undefined or thingTypeAndKind is "" or thingTypeAndKind is null
			errors.push
				attribute: 'thingTypeAndKind'
				message: "Thing Type and Kind must be set"
		if errors.length > 0
			return errors
		else
			return null

	getLsRoles: =>
		@get('labelSequenceRoles')

	isEditable: ->
		return false

class window.ACASLabelSequenceList extends Backbone.Collection
	model: ACASLabelSequence

#CONTROLLERS
class window.ACASLabelSequenceRoleController extends AbstractFormController
	template: _.template($("#ACASLabelSequenceRoleView").html())
	tagName: "div"

	events: ->
		"change .bv_role": "updateModel"
		"click .bv_deleteLabelSequenceRole": "clear"

	initialize: ->
		@errorOwnerName = 'ACASLabelSequenceRoleController'
		@setBindings()
		@model.on "destroy", @remove, @

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setupRoleSelect()

		@

	setupRoleSelect: ->
		@roleList = new PickListList()
		@roleList.url = "/api/lsRoles/codeTable"
		@roleListController = new PickListSelectController
			el: @$('.bv_role')
			collection: @roleList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Role"
			selectedCode: @model.get('lsRole')

	updateModel: =>
		role = @roleListController.getSelectedModel()
		if @model.get('id')?
			newModel = new ACASLabelSequenceRole
				lsRole: role
			@model.set "ignored", true
			@$('.bv_labelSequenceRoleWrapper').hide()
			@trigger 'addNewModel', newModel
		else
			@model.set
				lsRole: role
		@trigger 'amDirty'

	clear: =>
		if @model.get('id')?
			@model.set "ignored", true
			@$('.bv_labelSequenceRoleWrapper').hide()
		else
			@model.destroy()
		@trigger 'amDirty'

class window.ACASLabelSequenceRoleListController extends Backbone.View
	template: _.template($("#ACASLabelSequenceRoleListView").html())

	events:
		"click .bv_addLabelSequenceRoleButton": "addNewLabelSequenceRole"

	initialize: ->
		unless @collection?
			@collection = new ACASLabelSequenceRoleList()
			newModel = new ACASLabelSequenceRole
			@collection.add newModel

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@collection.each (roleInfo) =>
			@addLabelSequenceRole(roleInfo)
		if @collection.length == 0
			@addNewLabelSequenceRole()
		@trigger 'renderComplete'
		@

	addNewLabelSequenceRole: =>
		newModel = new ACASLabelSequenceRole
		@collection.add newModel
		@addLabelSequenceRole(newModel)
		@trigger 'amDirty'

	addLabelSequenceRole: (roleInfo) =>
		labelSeqRoleController = new ACASLabelSequenceRoleController
			model: roleInfo
		labelSeqRoleController.on 'addNewModel', (newModel) =>
			@collection.add newModel
			@addLabelSequenceRole newModel
		labelSeqRoleController.on 'amDirty', =>
			@trigger 'amDirty'
		@$('.bv_labelSequenceRoleInfo').append labelSeqRoleController.render().el

	isValid: =>
		validCheck = true
		errors = @collection.validateCollection()
		if errors.length > 0
			validCheck = false
		@validationError(errors)
		validCheck

	validationError: (errors) =>
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

	clearValidationErrorStyles: =>
		errorElms = @$('.input_error')
		_.each errorElms, (ee) =>
			$(ee).removeAttr('data-toggle')
			$(ee).removeAttr('data-placement')
			$(ee).removeAttr('title')
			$(ee).removeAttr('data-original-title')
			$(ee).removeClass 'input_error error'

class window.ACASLabelSequenceController extends AbstractFormController
	template: _.template($("#ACASLabelSequenceView").html())
	moduleLaunchName: "acasLabelSequence"

	events: ->
		"keyup .bv_labelPrefix": "attributeChanged"
		"keyup .bv_startingNumber": "attributeChanged"
		"keyup .bv_digits": "attributeChanged"
		"keyup .bv_labelSeparator": "attributeChanged"
		"change .bv_labelTypeAndKind": "attributeChanged"
		"change .bv_thingTypeAndKind": "attributeChanged"
		"click .bv_save": "handleSaveClicked"
		"click .bv_cancel": "handleCancelClicked"

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/labelsequences/getAuthorizedLabelSequences"
						dataType: 'json'
						error: (err) =>
							alert 'Could not get label sequences for this user. Creating a new label sequence'
							@completeInitialization()
						success: (labelSequencesList) =>
							if _.where(labelSequencesList, {code: window.AppLaunchParams.moduleLaunchParams.code}).length > 0
								@getACASLabelSequence()
							else
								alert 'Could not get label sequence for code in this URL, creating new one'
								@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	attributeChanged: =>
		super()
		@updatePreview()
		@isValid()

	updatePreview: =>
		prefix = @model.get('labelPrefix')
		firstNum = @model.get('startingNumber')
		numDigits = @model.get('digits')
		labelSep = @model.get('labelSeparator')
		previewLabel = prefix + labelSep + firstNum.toString().padStart(numDigits, '0')
		$('.bv_labelPreview').val previewLabel

	getACASLabelSequence: =>
		$.ajax
			type: 'GET'
			url: "/api/labelsequences/"+window.AppLaunchParams.moduleLaunchParams.code
			dataType: 'json'
			error: (err) =>
				alert 'Could not get label sequence for code in this URL, creating new one'
				@completeInitialization()
			success: (json) =>
				if json.length == 0
					alert 'Could not get label sequence for code in this URL, creating new one'
				else
					labelSeq = new ACASLabelSequence json
					labelSeq.set labelSeq.parse(labelSeq.attributes)
					@model = labelSeq
				@completeInitialization()


	completeInitialization: =>
		unless @model?
			@model=new ACASLabelSequence()
		@errorOwnerName = 'ACASLabelSequenceController'
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		@listenTo @model, 'saveFailed', @handleSaveFailed
		@listenTo @model, 'sync', @modelSaveCallback
		@listenTo @model, 'change', @modelChangeCallback
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setupACASLabelSequenceRoleListController()
		@setupLabelTypeAndKindSelect()
		@setupThingTypeAndKindSelect()
		@render()

	render: =>
		unless @model?
			@model = new ACASLabelSequence()
		#TODO
		#@$('.bv_shortDescription').val @model.get('short description').get('value')
		if @readOnly is true
			@displayInReadOnlyMode()
		@$('.bv_save').attr('disabled','disabled')
		@$('.bv_cancel').attr('disabled','disabled')
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
		@$('.bv_save').attr('disabled', 'disabled')
		unless @$('.bv_saveFailed').is(":visible")
			@$('.bv_saveComplete').show()
			@$('.bv_saving').hide()
		@setupACASLabelSequenceRoleListController()
		@render()
		@trigger 'amClean'

	modelChangeCallback: (method, model) =>
		@trigger 'amDirty'
		@checkFormValid()
		@$('.bv_saveComplete').hide()
		@$('.bv_saveFailed').hide()
		@$('.bv_cancel').removeAttr('disabled')
		@$('.bv_cancelComplete').hide()

	setupACASLabelSequenceRoleListController: ->
		if @acasLabelSequenceRoleListController?
			@acasLabelSequenceRoleListController.undelegateEvents()

		rolesList = new ACASLabelSequenceRoleList()
		roles = @model.getLsRoles()
		_.each roles, (role) =>
			newModel = new ACASLabelSequenceRole role.attributes
			newModel.set 'lsRole', role
			rolesList.add newModel

		@acasLabelSequenceRoleListController= new ACASLabelSequenceRoleListController
			el: @$('.bv_acasLabelSequenceRoleList')
			collection: rolesList
		@acasLabelSequenceRoleListController.on 'amClean', =>
			@trigger 'amClean'
		@acasLabelSequenceRoleListController.on 'renderComplete', =>
			@checkDisplayMode()
		@acasLabelSequenceRoleListController.render()
		@acasLabelSequenceRoleListController.on 'amDirty', =>
			@trigger 'amDirty'
			@$('.bv_saveComplete').hide()
			@$('.bv_saveFailed').hide()
			@checkFormValid()

	setupLabelTypeAndKindSelect: ->
		@labelTypeAndKindList = new PickListList()
		@labelTypeAndKindList.url = "/api/labelTypeAndKinds/codetable"
		@labelTypeAndKindListController = new PickListSelectController
			el: @$('.bv_labelTypeAndKind')
			collection: @labelTypeAndKindList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Label Type And Kind"
			selectedCode: @model.get('labelTypeAndKind')

	setupThingTypeAndKindSelect: ->
		@thingTypeAndKindList = new PickListList()
		@thingTypeAndKindList.url = "/api/thingTypeAndKinds/codetable"
		@thingTypeAndKindListController = new PickListSelectController
			el: @$('.bv_thingTypeAndKind')
			collection: @thingTypeAndKindList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Thing Type And Kind"
			selectedCode: @model.get('thingTypeAndKind')

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
		@model.set("labelPrefix", UtilityFunctions::getTrimmedInput @$('.bv_labelPrefix'))
		@model.set("startingNumber", UtilityFunctions::getTrimmedInput @$('.bv_startingNumber'))
		@model.set("digits", UtilityFunctions::getTrimmedInput @$('.bv_digits'))
		@model.set("labelSeparator", UtilityFunctions::getTrimmedInput @$('.bv_labelSeparator'))
		@model.set("labelTypeAndKind", UtilityFunctions::getTrimmedInput @$('.bv_labelTypeAndKind'))
		@model.set("thingTypeAndKind", UtilityFunctions::getTrimmedInput @$('.bv_thingTypeAndKind'))

	prepareToSaveLabelSequenceRoles: =>
		reformattedLabelSequenceRoles = []
		@acasLabelSequenceRoleListController.collection.each (labelSequenceRoleModel) =>
			console.log labelSequenceRoleModel
			if labelSequenceRoleModel.get('lsRole')?.get('id')?
				labelSequenceRole =
					roleEntry: {id: labelSequenceRoleModel.get('lsRole').get('id')}
				reformattedLabelSequenceRoles.push labelSequenceRole
		@model.set('labelSequenceRoles', reformattedLabelSequenceRoles)

	handleSaveClicked: =>
		@saveLabelSequence()
		@$('.bv_saving').show()
		@$('.bv_saveFailed').hide()
		@$('.bv_saveComplete').hide()

	saveLabelSequence: =>
		@prepareToSaveLabelSequenceRoles()
		console.log @model
		if @model.isNew()
			@$('.bv_saveComplete').html('Save Complete')
		else
			@$('.bv_saveComplete').html('Update Complete')
		@$('.bv_save').attr('disabled', 'disabled')
		if @model.isNew()
			@model.save null,
				success: (model, response) =>
					if response is "save label sequence failed"
						@model.trigger 'saveFailed'
					else
						@modelSaveCallback

		else
			@model.save null,
				success: (model, response) =>
					if response is "update label sequence failed"
						@model.trigger 'saveFailed'
					else
						@modelSaveCallback
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
		@$(".bv_startDateIcon").addClass "uneditable-input"
		@$(".bv_startDateIcon").on "click", ->
			return false
		@disableAllInputs()

	checkFormValid: =>
		if @isValid()
			@$('.bv_save').removeAttr('disabled')
		else
			@$('.bv_save').attr('disabled', 'disabled')

	isValid: =>
		validCheck = super()
		if @acasLabelSequenceRoleListController?
			if @acasLabelSequenceRoleListController.isValid() is false
				validCheck = false
		validCheck
