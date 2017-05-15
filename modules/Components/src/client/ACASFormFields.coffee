class window.ACASFormAbstractFieldController extends Backbone.View
	###
		Launching controller must:
		- Initialize the model the correct object type
		- Call render then append this controller's new el to the launching controllers DOM
		- Supply the form's label text as an option formLabel, or call setFormLabel()

		Launching controller may:
		- set an option for required: true/false. Defaults to false
		- add a label class with addFormLabelClass() or set formLabelClass as an option
		- add an input class with addInputClass() or set inputClass as an option
		- if you want the AbstractFormController to set and clear validation style, call addControlGroupClass() or provide controlGroupClass as an option
		- set the placeholder text with placeholder option or setPlaceholder

		General:
		- All addXXXCLass() methods also have a removeXXXClass() method

	###

	tagName: "DIV"
	className: "control-group"

#Subclass to supply
#	template: _.template($("#ACASFormLSLabelFieldView").html())

	events: ->
		"keyup input": "handleInputChanged"

	initialize: ->
		@modelKey = @options.modelKey
		@thingRef = @options.thingRef
		@errorSet = false
		@userInputEvent = true

	getModel: ->
		@thingRef.get @modelKey

	handleInputChanged: =>
		@checkEmptyAndRequired()

	checkEmptyAndRequired: ->
		if @required and @isEmpty() and !@errorSet
			@setError "required"

	isEmpty: ->
		empty = false
		mdl = @getModel()
		if mdl.has 'labelText'
			if mdl.get('labelText')=="" then empty = true
		else
			if mdl.get('value')=="" or !mdl.get('value')? or mdl.get('value')=="unassigned" then empty = true

		if mdl.get('ignored') then empty = true
		return empty

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@applyOptions()
		@checkEmptyAndRequired()

		@

#Subclass to extend
	afterRender: ->


	renderModelContent: =>
		@clearError()
		@checkEmptyAndRequired()

	setError: (message) ->
		@errorSet = true
		$(@el).addClass "error"
		@$('.help-inline').removeClass 'hide'
		@$('.help-inline').html message
		@trigger 'validationFail', message

	clearError: ->
		$(@el).removeClass "error"
		@$('.help-inline').addClass 'hide'
		@errorSet = false

	applyOptions: ->
		if @options.maxLabelLength?
			@maxLabelLength = @options.maxLabelLength
		if @options.formLabel?
			@setFormLabel @options.formLabel
		if @options.formLabelClass?
			@addFormLabelClass @options.formLabelClass
		if @options.inputClass?
			@addInputClass @options.inputClass
		if @options.controlGroupClass?
			@addControlGroupClass @options.controlGroupClass
		if @options.placeholder?
			@setPlaceholder @options.placeholder
		@required = if @options.required? then @options.required else false

	setFormLabel: (value) ->
		@$('label').html value

	addFormLabelClass: (value) ->
		@$('label').addClass value

	addInputClass: (value) ->
		@$('input').addClass value

	addControlGroupClass: (value) ->
		$(@el).addClass value

	removeFormLabelClass: (value) ->
		@$('label').removeClass value

	removeInputClass: (value) ->
		@$('input').removeClass value

	removeControlGroupClass: (value) ->
		$(@el).removeClass value

	setPlaceholder: (value) ->
		@$('input').attr 'placeholder', value


class window.ACASFormLSLabelFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSLabel
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSLabelFieldView").html())
	maxLabelLength: 255

	handleInputChanged: =>
		@clearError()
		@userInputEvent = true
		value = UtilityFunctions::getTrimmedInput(@$('input'))

		if @isValid(value)
			if value != ""
				@getModel().set
					labelText: value
					ignored: false
			else
				@setEmptyValue()
		super()

	isValid: (value) ->
		if value.length > @maxLabelLength
			@setError("label is too long")
			@setEmptyValue()
			return false
		else
			@clearError()
			return true

	setEmptyValue: ->
		@getModel().set
			labelText: ""
			ignored: true

	renderModelContent: =>
		@$('input').val @getModel().get('labelText')
		super()

class window.ACASFormLSNumericValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSNumericValueFieldView").html())

	handleInputChanged: =>
		@clearError()
		@userInputEvent = true
		value = UtilityFunctions::getTrimmedInput(@$('input'))
		if value == ""
			@setEmptyValue()
		else
			numVal = parseFloat(value)
			if isNaN(numVal) or isNaN(Number(value))
				@setError("number required")
				@setEmptyValue()
			else
				@getModel().set
					value: numVal
					ignored: false
		super()

	setEmptyValue: ->
		@getModel().set
			value: null
			ignored: true

	renderModelContent: =>
		@$('input').val @getModel().get('value')
		if @getModel().has 'unitKind'
			@$('.bv_units').html @getModel().get('unitKind')
		super()

class window.ACASFormLSCodeValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###
	events: ->
		"change select": "handleInputChanged"

	template: _.template($("#ACASFormLSCodeValueFieldView").html())

	handleInputChanged: =>
		@clearError()
		value = @pickListController.getSelectedCode()
		if value == "" or value=="unassigned"
			@setEmptyValue()
		else
			@getModel().set
				value: value
				ignored: false
		super()

	setEmptyValue: ->
		@getModel().set
			value: null
			ignored: true

	renderModelContent: =>
		@pickListController.setSelectedCode @getModel().get('value')
		super()

	setupSelect: ->
		@pickList = new PickListList()
		mdl = @getModel()
		@pickList.url = "/api/codetables/#{mdl.get 'codeType'}/#{mdl.get 'codeKind'}"
		plOptions =
			el: @$('select')
			collection: @pickList
			selectedCode: mdl.get('value')
			parameter: @options.modelKey
			codeType: mdl.get 'codeType'
			codeKind: mdl.get 'codeKind'

		if @options.insertUnassigned?
			if @options.insertUnassigned
				plOptions.insertFirstOption = new PickList
					code: "unassigned"
					name: "Select Category"

		@pickListController = new PickListSelectController plOptions
		@pickListController.render()


	render: =>
		super()
		@setupSelect()

		@

class window.ACASFormLSThingInteractionFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSInteraction
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###
	events: ->
		"change select": "handleInputChanged"

	template: _.template($("#ACASFormLSThingInteractionFieldView").html())
	@

	applyOptions: ->
		super()
		if @options.thingType?
			@thingType = @options.thingType
		if @options.thingKind?
			@thingKind = @options.thingKind
		if @options.labelType?
			@labelType = @options.labelType
		if @options.queryUrl?
			@queryUrl = @options.queryUrl


	handleInputChanged: =>
		@clearError()
		if @userInputEvent
			thingID = @thingSelectController.getSelectedID()
			if thingID?
				@getModel().setItxThing id: thingID
			else
				@setEmptyValue()
		super()

	setEmptyValue: ->
		@getModel().set ignored: true
		@setItxThing null

	isEmpty: ->
		empty = true
		mdl = @getModel()
		iThing = @getModel().getItxThing()
		if iThing? and !mdl.get('ignored')
			if iThing.id?
				empty = false

		return empty

	renderModelContent: =>
		@userInputEvent = false
		if  @getModel().getItxThing().id?
			labels = new LabelList @getModel().getItxThing().lsLabels
			labelText = labels.pickBestNonEmptyLabel().get('labelText')
			@thingSelectController.setSelectedCode
				code: @getModel().getItxThing().codeName
				label: labelText
			super()
		@userInputEvent = true

	setupSelect: ->
		opts =
			el: @$('select')
			placeholder: @placeholder
			labelType: @labelType
		if @queryUrl?
			opts.queryUrl = @queryUrl
		else
			opts.thingType = @thingType
			opts.thingKind = @thingKind
		@thingSelectController = new ThingLabelComboBoxController opts
		@thingSelectController.render()

	render: =>
		super()
		@setupSelect()

		@


class window.ACASFormLSHTMLClobValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    - You may include a rows option to set the height of the textarea
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSHTMLClobValueFieldView").html())

	applyOptions: ->
		super()
		if @options.rows?
			@rows = @options.rows
			@$('textarea').attr 'rows', @rows

	afterRender: ->
		@setupTinyMCE()

	textChanged: (content) ->
		@clearError()
		if content == ""
			@setEmptyValue()
		else
			@getModel().set
				value: content
				ignored: false

	setEmptyValue: ->
		@getModel().set
			value: ""
			ignored: true

	renderModelContent: =>
		@editor.setContent @getModel().get('value')
		super()

	setupTinyMCE: ->
		mdl = @getModel()
		cname = mdl.get('lsKind').replace(" ","")+"_"+mdl.cid
		selector = "."+cname
		@$('.bv_wysiwygEditor').addClass cname
		@wysiwygEditor = tinymce.init
			selector: selector
			inline: true
			setup: (editor) =>
				editor.on 'init', (e) =>
					@editor = editor
				editor.on 'change', (e) =>
					@textChanged editor.getContent()

class window.ACASFormLSStringValueFieldController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormLSStringValueFieldView").html())

	handleInputChanged: =>
		@clearError()
		@userInputEvent = true
		value = UtilityFunctions::getTrimmedInput(@$('input'))
		if value == ""
			@setEmptyValue()
		else
			@getModel().set
				value: value
				ignored: false
		super()

	setEmptyValue: ->
		@getModel().set
			value: null
			ignored: true

	renderModelContent: =>
		@$('input').val @getModel().get('value')
		super()
