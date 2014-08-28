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
#		@get('max').on "change", =>
#			@trigger 'change'
		if @get('min') not instanceof Backbone.Model
			@set min: new Backbone.Model(@get('min'))
#		@get('min').on "change", =>
#			@trigger 'change'
		if @get('slope') not instanceof Backbone.Model
			@set slope: new Backbone.Model(@get('slope'))
#		@get('slope').on "change", =>
#			@trigger 'change'


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

class window.DoseResponseAnalysisParametersController extends AbstractFormController
	template: _.template($("#DoseResponseAnalysisParametersView").html())
	autofillTemplate: _.template($("#DoseResponseAnalysisParametersAutofillView").html())

	events:
		"change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged"
		"click .bv_max_limitType_none": "handleMaxLimitTypeChanged"
		"click .bv_max_limitType_pin": "handleMaxLimitTypeChanged"
		"click .bv_max_limitType_limit": "handleMaxLimitTypeChanged"
		"click .bv_min_limitType_none": "handleMinLimitTypeChanged"
		"click .bv_min_limitType_pin": "handleMinLimitTypeChanged"
		"click .bv_min_limitType_limit": "handleMinLimitTypeChanged"
		"click .bv_slope_limitType_none": "handleSlopeLimitTypeChanged"
		"click .bv_slope_limitType_pin": "handleSlopeLimitTypeChanged"
		"click .bv_slope_limitType_limit": "handleSlopeLimitTypeChanged"
		"change .bv_max_value": "attributeChanged"
		"change .bv_min_value": "attributeChanged"
		"change .bv_slope_value": "attributeChanged"

	initialize: ->
		$(@el).html @template()
		@errorOwnerName = 'DoseResponseAnalysisParametersController'
		@setBindings()

	render: =>
		super()
		@$('.bv_autofillSection').empty()
		@$('.bv_autofillSection').html @autofillTemplate($.parseJSON(JSON.stringify(@model)))
		@$('.bv_inactiveThreshold').slider
			value: @model.get('inactiveThreshold')
			min: 0
			max: 100
		@$('.bv_inactiveThreshold').on 'slide', @handleInactiveThresholdMoved
		@$('.bv_inactiveThreshold').on 'slidestop', @handleInactiveThresholdChanged
		@updateThresholdDisplay(@model.get 'inactiveThreshold')
#		@setThresholdEnabledState()
		@

	updateThresholdDisplay: (val)->
		@$('.bv_inactiveThresholdDisplay').html val

	setThresholdEnabledState: ->
		if @model.get 'inverseAgonistMode'
			@$('.bv_inactiveThreshold').slider('disable')
		else
			@$('.bv_inactiveThreshold').slider('enable')


	updateModel: =>
		@model.get('max').set
			value: parseFloat(@getTrimmedInput('.bv_max_value'))
		@model.get('min').set
			value: parseFloat(@getTrimmedInput('.bv_min_value'))
		@model.get('slope').set
			value: parseFloat(@getTrimmedInput('.bv_slope_value'))
		@model.set inverseAgonistMode: @$('.bv_inverseAgonistMode').is(":checked"),
			silent: true
		@model.trigger 'change'


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
		@model.get('max').set limitType: radioValue,
			silent: true
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

	handleSlopeLimitTypeChanged: =>
		radioValue = @$("input[name='bv_slope_limitType']:checked").val()
		@model.get('slope').set limitType: radioValue
		if radioValue == 'none'
			@$('.bv_slope_value').attr('disabled','disabled')
		else
			@$('.bv_slope_value').removeAttr('disabled')
		@attributeChanged()

class window.DoseResponseAnalysisController extends Backbone.View
	template: _.template($("#DoseResponseAnalysisView").html())
	events:
		"click .bv_fitModelButton": "launchFit"

	initialize: ->
		@model.on "sync", @handleExperimentSaved
		@model.getStatus().on 'change', @handleStatusChanged
		@parameterController = null
		@analyzedPreviously = if @model.getModelFitStatus().get('stringValue') == "not started" then false else true
		$(@el).empty()
		$(@el).html @template()
		@testReadyForFit()

	render: =>
		@showExistingResults()
		buttonText = if @analyzedPreviously then "Re-Fit" else "Fit Data"
		@$('.bv_fitModelButton').html buttonText

	showExistingResults: ->
		fitStatus = @model.getModelFitStatus().get('stringValue')
		@$('.bv_modelFitStatus').html(fitStatus)
		resultValue = @model.getModelFitResultHTML()
		unless not @analyzedPreviously
			if resultValue != null
				res = resultValue.get('clobValue')
				if res == ""
					@$('.bv_resultsContainer').hide()
				else
					@$('.bv_modelFitResultsHTML').html(res)
					@$('.bv_resultsContainer').show()

	testReadyForFit: =>
		if @model.getAnalysisStatus().get('stringValue') == "not started"
			@setNotReadyForFit()
		else
			@setReadyForFit()

	setNotReadyForFit: ->
		@$('.bv_fitOptionWrapper').hide()
		@$('.bv_resultsContainer').hide()
		@$('.bv_analyzeExperimentToFit').show()

	setReadyForFit: =>
		unless @parameterController
			@setupCurveFitAnalysisParameterController()
		@$('.bv_fitOptionWrapper').show()
		@$('.bv_analyzeExperimentToFit').hide()
		@handleStatusChanged()

	primaryAnalysisCompleted: ->
		@testReadyForFit()

	handleStatusChanged: =>
		if @parameterController != null
			if @model.isEditable()
				@parameterController.enableAllInputs()
			else
				@parameterController.disableAllInputs()

	setupCurveFitAnalysisParameterController: ->
		@parameterController = new DoseResponseAnalysisParametersController
			el: @$('.bv_analysisParameterForm')
			model: new DoseResponseAnalysisParameters	@model.getModelFitParameters()
		@parameterController.on 'amDirty', =>
			@trigger 'amDirty'
		@parameterController.on 'amClean', =>
			@trigger 'amClean'
		@parameterController.on 'valid', @paramsValid
		@parameterController.on 'invalid', @paramsInvalid
		@parameterController.render()

	paramsValid: =>
		@$('.bv_fitModelButton').removeAttr('disabled')

	paramsInvalid: =>
		@$('.bv_fitModelButton').attr('disabled','disabled')

	launchFit: =>
		if @analyzedPreviously
			if !confirm("Re-fitting the data will delete the previously fitted results")
				return

		fitData =
			inputParameters: JSON.stringify @parameterController.model
			user: window.AppLaunchParams.loginUserName
#			experimentCode: "fail"
			experimentCode: @model.get('codeName')
			testMode: false

		$.ajax
			type: 'POST'
			url: "/api/doseResponseCurveFit"
			data: fitData
			success: @fitReturnSuccess
			error: (err) =>
				alert 'got ajax error'
				@serviceReturn = null
			dataType: 'json'

	fitReturnSuccess: (json) =>
		unless json.hasError
			@analyzedPreviously = true
			@$('.bv_fitModelButton').html "Re-Fit"
		@$('.bv_modelFitResultsHTML').html(json.results.htmlSummary)
		@$('.bv_modelFitStatus').html(json.results.status)
		@$('.bv_resultsContainer').show()

