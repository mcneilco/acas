class window.ACASFormAbstractFieldController extends Backbone.View
	###
		Launching controller must:
		- Initialize the model teh correct object type
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
		@errorSet = false
		@userInputEvent = false
		@model.on 'change', @renderModelContent

	handleInputChanged: =>
		@checkEmptyAndRequired()

	checkEmptyAndRequired: ->
		if @required and @isEmpty() and !@errorSet
			@setError "required"

	isEmpty: ->
		empty = false
		console.log @model.get('labelText')==""
		console.log @model.get('ignored')
		if @model.has 'labelText'
			if @model.get('labelText')=="" then empty = true
		else
			if @model.get('value')=="" or !@model.get('value')? then empty = true

		if @model.get('ignored') then empty = true

		return empty

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@applyOptions()
		@checkEmptyAndRequired()
		@renderModelContent()

		@

	setModel: (mod) ->
		@model = mod
		@model.on 'change', @renderModelContent
		@renderModelContent()

#Subclass to extend
	renderModelContent: =>
		@userInputEvent = false

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
				@model.set
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
		@model.set
			labelText: ""
			ignored: true

	renderModelContent: =>
		unless @errorSet or @userInputEvent
			@$('input').val @model.get('labelText')
		@userInputEvent = false

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
		console.log value
		if value == ""
			@setEmptyValue()
		else
			numVal = parseFloat(value)
			console.log numVal
			if isNaN(numVal) or isNaN(Number(value))
				@setError("number required")
				console.log "about to set number empty"
				@setEmptyValue()
			else
				console.log "about to set number good"
				@model.set
					value: numVal
					ignored: false
				console.log @model.get 'value'
				console.log @model.get 'ignored'
				debugger
		super()



	setEmptyValue: ->
		@model.set
			value: null
			ignored: true

	renderModelContent: =>
		unless @errorSet or @userInputEvent
			@$('input').val @model.get('value')
		@userInputEvent = false


