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

class window.DoseResponseAnalysisParametersController extends AbstractFormController
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

	initialize: ->
		$(@el).html @template()
		@errorOwnerName = 'DoseResponseAnalysisParametersController'
		@setBindings()

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
		console.log "got valid"
		@$('.bv_fitModelButton').removeAttr('disabled')

	paramsInvalid: =>
		console.log "got invalid"
		@$('.bv_fitModelButton').attr('disabled','disabled')

	launchFit: =>
		console.log "got to launch fit"
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
				console.log 'got ajax error'
				@serviceReturn = null
			dataType: 'json'

	fitReturnSuccess: (json) =>
		unless json.hasError
			@analyzedPreviously = true
			@$('.bv_fitModelButton').html "Re-Fit"
		@$('.bv_modelFitResultsHTML').html(json.results.htmlSummary)
		@$('.bv_modelFitStatus').html(json.results.status)
		@$('.bv_resultsContainer').show()


#TODO code to actually launch fit and show results
			#TODO setup alert to warn about re-fitting wiping out old results
#TODO make the threshold slider work
#TODO add notification component