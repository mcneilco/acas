class window.DoseResponseAnalysisParameters extends Backbone.Model
	defaults:
		inactiveThreshold: 20
		inverseAgonistMode: false
		max: new Backbone.Model()
		min: new Backbone.Model()
		slope: new Backbone.Model()

	initialize: ->
		@fixCompositeClasses()

	fixCompositeClasses: =>
		if @get('max') not instanceof Backbone.Model
			@set max: new Backbone.Model(@get('max'))
		@get('max').on "change", =>
			@trigger 'change'
		if @get('min') not instanceof Backbone.Model
			@set min: new Backbone.Model(@get('min'))
		@get('min').on "change", =>
			@trigger 'change'
		if @get('slope') not instanceof Backbone.Model
			@set slope: new Backbone.Model(@get('slope'))
		@get('slope').on "change", =>
			@trigger 'change'


	validate: (attrs) ->
		errors = []

		limitType = attrs.min.get('limitType')
		if (limitType == "pin" || limitType == "limit") && _.isNaN(attrs.min.get('value'))
			errors.push
				attribute: 'min_value'
				message: "Min threshold value must be set when limit type is pin or limit"
		limitType = attrs.max.get('limitType')
		if (limitType == "pin" || limitType == "limit") && _.isNaN(attrs.max.get('value'))
			errors.push
				attribute: 'max_value'
				message: "Max threshold value must be set when limit type is pin or limit"
		limitType = attrs.slope.get('limitType')
		if (limitType == "pin" || limitType == "limit") && _.isNaN(attrs.slope.get('value'))
			errors.push
				attribute: 'slope_value'
				message: "Slope threshold value must be set when limit type is pin or limit"
		if  _.isNaN(attrs.inactiveThreshold)
			errors.push
				attribute: 'inactiveThreshold'
				message: "Inactive threshold value must be set to a number"

		if errors.length > 0
			return errors
		else
			return null

class window.DoseResponseAnalysisParametersController extends AbstractParserFormController
	template: _.template($("#DoseResponseAnalysisParametersView").html())
	autofillTemplate: _.template($("#DoseResponseAnalysisParametersAutofillView").html())

	events:
		"change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged"
		"change .bv_max_limitType_none": "handleMaxLimitTypeChanged"
		"change .bv_max_limitType_pin": "handleMaxLimitTypeChanged"
		"change .bv_max_limitType_limit": "handleMaxLimitTypeChanged"
		"change .bv_min_limitType_none": "handleMinLimitTypeChanged"
		"change .bv_min_limitType_pin": "handleMinLimitTypeChanged"
		"change .bv_min_limitType_limit": "handleMinLimitTypeChanged"
		"change .bv_slope_limitType_none": "handleSlopeLimitTypeChanged"
		"change .bv_slope_limitType_pin": "handleSlopeLimitTypeChanged"
		"change .bv_slope_limitType_limit": "handleSlopeLimitTypeChanged"
		"change .bv_max_value": "attributeChanged"
		"change .bv_min_value": "attributeChanged"
		"change .bv_slope_value": "attributeChanged"

	render: =>
		super()
		@$('.bv_autofillSection').empty()
		@$('.bv_autofillSection').html @autofillTemplate($.parseJSON(JSON.stringify(@model)))

	updateModel: =>
		@model.get('max').set
			value: parseFloat(@getTrimmedInput('.bv_max_value'))
		@model.get('min').set
			value: parseFloat(@getTrimmedInput('.bv_min_value'))
		@model.get('slope').set
			value: parseFloat(@getTrimmedInput('.bv_slope_value'))

	handleInverseAgonistModeChanged: =>
		@model.set inverseAgonistMode: @$('.bv_inverseAgonist').is(":checked")
		@attributeChanged()

	handleMaxLimitTypeChanged: =>
		@model.get('max').set limitType: @$("input[name='bv_max_limitType']:checked").val()
		@attributeChanged()

	handleMinLimitTypeChanged: =>
		@model.get('min').set limitType: @$("input[name='bv_min_limitType']:checked").val()
		@attributeChanged()

	handleSlopeLimitTypeChanged: =>
		@model.get('slope').set limitType: @$("input[name='bv_slope_limitType']:checked").val()
		@attributeChanged()