class window.ACASFormLSLabelFieldController extends Backbone.View
	###
		Launching controller must:
		- Initialize the model with an LSLabel
		- Call render then append this controller's new el to the launching controllers DOM
		- Supply the label text as an option formLabel, or call setFormLabel()

		Launching controller may:
		- add a label class with addLabelClass() or set labelClass as an option
		- add an input class with addInputClass() or set inputClass as an option
		- if you want the AbstractFormController to set and clear validation style, call addControlGroupClass() or provide controlGroupClass as an option

		General:
		- All addXXXCLass() methods also have a removeXXXClass() method

	###
	tagName: "DIV"
	className: "control-group"
	template: _.template($("#ACASFormLabelFieldView").html())
	maxLabelLength: 10

	events: ->
		"keyup input": "handleInputChanged"

	handleInputChanged: =>
		value = UtilityFunctions::getTrimmedInput(@$('input'))

		if @isValid(value)
			if value != ""
				@model.set
					labelText: value
					ignored: false
			else
				@setEmptyValue()

	isValid: (value) ->
		if value.length > @maxLabelLength
			@setError("label is too long")
			@setEmptyValue()
			return false

		@clearError()
		return true


	setEmptyValue: ->
		@model.set
			labelText: ""
			ignored: true


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@$('input').val @model.get('labelText')
		@applyOptions()

		@

	setError: (message) ->
		$(@el).addClass "error"
		@$('.help-inline').removeClass 'hide'
		@$('.help-inline').html message
		@trigger 'validationFail', message

	clearError: ->
		$(@el).removeClass "error"
		@$('.help-inline').addClass 'hide'

	applyOptions: ->
		if @options.maxLabelLength?
			@maxLabelLength = @options.maxLabelLength
		if @options.formLabel?
			@setFormLabel @options.formLabel
		if @options.labelClass?
			@addLabelClass @options.labelClass
		if @options.inputClass?
			@addInputClass @options.inputClass
		if @options.controlGroupClass?
			@addControlGroupClass @options.controlGroupClass

	setFormLabel: (value) ->
		@$('label').html value

	addLabelClass: (value) ->
		@$('label').addClass value

	addInputClass: (value) ->
		@$('input').addClass value

	addControlGroupClass: (value) ->
		$(@el).addClass value

	removeLabelClass: (value) ->
		@$('label').removeClass value

	removeInputClass: (value) ->
		@$('input').removeClass value

	removeControlGroupClass: (value) ->
		$(@el).removeClass value


