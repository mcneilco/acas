class window.DoseResponseKiAnalysisParameters extends Backbone.Model
	defaults:
		smartMode: true
		inactiveThresholdMode: true
		inactiveThreshold: 20
		inverseAgonistMode: false
		max: new Backbone.Model limitType: 'none'
		min: new Backbone.Model limitType: 'none'
		kd: new Backbone.Model
		ligandConc: new Backbone.Model

	initialize: ->
		@fixCompositeClasses()

	fixCompositeClasses: =>
		if @get('max') not instanceof Backbone.Model
			@set max: new Backbone.Model(@get('max'))
		if @get('min') not instanceof Backbone.Model
			@set min: new Backbone.Model(@get('min'))
		if @get('kd') not instanceof Backbone.Model
			@set kd: new Backbone.Model(@get('kd'))
		if @get('ligandConc') not instanceof Backbone.Model
			@set ligandConc: new Backbone.Model(@get('ligandConc'))


	validate: (attrs) ->
		errors = []
		limitType = attrs.min.get('limitType')
		if (limitType == "pin" || limitType == "limit") && (_.isNaN(attrs.min.get('value')) or attrs.min.get('value') == null)
			errors.push
				attribute: 'min_value'
				message: "Min threshold value must be set when limit type is pin or limit"
		limitType = attrs.max.get('limitType')
		if (limitType == "pin" || limitType == "limit") && (_.isNaN(attrs.max.get('value')) or attrs.max.get('value') == null)
			errors.push
				attribute: 'max_value'
				message: "Max threshold value must be set when limit type is pin or limit"
		if (_.isNaN(attrs.kd.get('value')) or attrs.kd.get('value') == null or attrs.kd.get('value') is undefined)
			errors.push
				attribute: 'kd_value'
				message: "Kd threshold value must be set"
		if (_.isNaN(attrs.ligandConc.get('value')) or attrs.ligandConc.get('value') == null or attrs.ligandConc.get('value') is undefined)
			errors.push
				attribute: 'ligandConc_value'
				message: "Ligand Conc. threshold value must be set"
		if  _.isNaN(attrs.inactiveThreshold)
			errors.push
				attribute: 'inactiveThreshold'
				message: "Inactive threshold value must be set to a number"

		if errors.length > 0
			return errors
		else
			return null

class window.DoseResponseKiAnalysisParametersController extends AbstractFormController
	template: _.template($("#DoseResponseKiAnalysisParametersView").html())
	autofillTemplate: _.template($("#DoseResponseKiAnalysisParametersAutofillView").html())

	events:
		"change .bv_smartMode": "handleSmartModeChanged"
		"change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged"
		"change .bv_inactiveThresholdMode": "handleInactiveThresholdModeChanged"
		"click .bv_max_limitType_none": "handleMaxLimitTypeChanged"
		"click .bv_max_limitType_pin": "handleMaxLimitTypeChanged"
		"click .bv_max_limitType_limit": "handleMaxLimitTypeChanged"
		"click .bv_min_limitType_none": "handleMinLimitTypeChanged"
		"click .bv_min_limitType_pin": "handleMinLimitTypeChanged"
		"click .bv_min_limitType_limit": "handleMinLimitTypeChanged"
		"change .bv_max_value": "attributeChanged"
		"change .bv_min_value": "attributeChanged"
		"change .bv_kd_value": "attributeChanged"
		"change .bv_ligandConc_value": "attributeChanged"

	initialize: ->
		$(@el).html @template()
		@errorOwnerName = 'DoseResponseKiAnalysisParametersController'
		@setBindings()

	render: =>
		@$('.bv_autofillSection').empty()
		@$('.bv_autofillSection').html @autofillTemplate($.parseJSON(JSON.stringify(@model)))
		@$('.bv_inactiveThreshold').slider
			value: @model.get('inactiveThreshold')
			min: 0
			max: 100
		@$('.bv_inactiveThreshold').on 'slide', @handleInactiveThresholdMoved
		@$('.bv_inactiveThreshold').on 'slidestop', @handleInactiveThresholdChanged
		@updateThresholdDisplay(@model.get 'inactiveThreshold')
		@setFormTitle()
		@setThresholdModeEnabledState()
		@setInverseAgonistModeEnabledState()
		@

	updateThresholdDisplay: (val)->
		@$('.bv_inactiveThresholdDisplay').html val

	setThresholdModeEnabledState: ->
		if @model.get 'smartMode'
			@$('.bv_inactiveThresholdMode').removeAttr('disabled')
		else
			@$('.bv_inactiveThresholdMode').attr('disabled','disabled')
		@setThresholdSliderEnabledState()

	setThresholdSliderEnabledState: ->
		if @model.get('inactiveThresholdMode') and @model.get('smartMode')
			@$('.bv_inactiveThreshold').slider('enable')
		else
			@$('.bv_inactiveThreshold').slider('disable')

	setInverseAgonistModeEnabledState: ->
		if @model.get 'smartMode'
			@$('.bv_inverseAgonistMode').removeAttr('disabled')
		else
			@$('.bv_inverseAgonistMode').attr('disabled','disabled')

	updateModel: =>
		@model.get('max').set
			value: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_max_value'))
		@model.get('min').set
			value: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_min_value'))
		@model.get('kd').set
			value: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_kd_value'))
		@model.get('ligandConc').set
			value: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_ligandConc_value'))
		@model.set inverseAgonistMode: @$('.bv_inverseAgonistMode').is(":checked"),
			silent: true
		@model.set smartMode: @$('.bv_smartMode').is(":checked"),
			silent: true
		@setThresholdModeEnabledState()
		@setInverseAgonistModeEnabledState()
		@model.trigger 'change'
		@trigger 'updateState'

	handleSmartModeChanged: =>
		@attributeChanged()

	handleInactiveThresholdModeChanged: =>
		@attributeChanged()

	handleInactiveThresholdChanged: (event, ui) =>
		@model.set 'inactiveThreshold': ui.value
		@updateThresholdDisplay(@model.get 'inactiveThreshold')
		@attributeChanged

	handleInactiveThresholdMoved: (event, ui) =>
		@updateThresholdDisplay(ui.value)

	handleInverseAgonistModeChanged: =>
		@attributeChanged()

	handleMaxLimitTypeChanged: =>
		radioValue = @$("input[name='bv_max_limitType']:checked").val()
		@model.get('max').set limitType: radioValue, silent: true
		if radioValue == 'none'
			@$('.bv_max_value').attr('disabled','disabled')
		else
			@$('.bv_max_value').removeAttr('disabled')
		@attributeChanged()

	handleMinLimitTypeChanged: =>
		radioValue = @$("input[name='bv_min_limitType']:checked").val()
		@model.get('min').set limitType: radioValue
		if radioValue == 'none'
			@$('.bv_min_value').attr('disabled','disabled')
		else
			@$('.bv_min_value').removeAttr('disabled')
		@attributeChanged()

	setFormTitle: (title) ->
		if title?
			@formTitle = title
			@$(".bv_formTitle").html @formTitle
		else if @formTitle?
			@$(".bv_formTitle").html @formTitle
		else
			@formTitle = @$(".bv_formTitle").html()
