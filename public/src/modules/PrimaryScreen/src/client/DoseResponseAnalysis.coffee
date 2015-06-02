class window.DoseResponseAnalysisParameters extends Backbone.Model
	defaults:
		smartMode: true
		inactiveThresholdMode: true
		inactiveThreshold: 20
		inverseAgonistMode: false
		max: new Backbone.Model limitType: 'none'
		min: new Backbone.Model limitType: 'none'
		slope: new Backbone.Model limitType: 'none'

	initialize: ->
		@fixCompositeClasses()

	fixCompositeClasses: =>
		if @get('max') not instanceof Backbone.Model
			@set max: new Backbone.Model(@get('max'))
		if @get('min') not instanceof Backbone.Model
			@set min: new Backbone.Model(@get('min'))
		if @get('slope') not instanceof Backbone.Model
			@set slope: new Backbone.Model(@get('slope'))


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
		limitType = attrs.slope.get('limitType')
		if (limitType == "pin" || limitType == "limit") && (_.isNaN(attrs.slope.get('value')) or attrs.slope.get('value') == null)
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
		"change .bv_smartMode": "handleSmartModeChanged"
		"change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged"
		"change .bv_inactiveThresholdMode": "handleInactiveThresholdModeChanged"
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
		@model.get('slope').set
			value: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_slope_value'))
		@model.set inactiveThresholdMode: @$('.bv_inactiveThresholdMode').is(":checked"),
			silent: true
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

	handleSlopeLimitTypeChanged: =>
		radioValue = @$("input[name='bv_slope_limitType']:checked").val()
		@model.get('slope').set limitType: radioValue
		if radioValue == 'none'
			@$('.bv_slope_value').attr('disabled','disabled')
		else
			@$('.bv_slope_value').removeAttr('disabled')
		@attributeChanged()

	setFormTitle: (title) ->
		if title?
			@formTitle = title
			@$(".bv_formTitle").html @formTitle
		else if @formTitle?
			@$(".bv_formTitle").html @formTitle
		else
			@formTitle = @$(".bv_formTitle").html()

class window.ModelFitTypeController extends Backbone.View
	template: _.template($("#ModelFitTypeView").html())

	events:
		"change .bv_modelFitType": "handleModelFitTypeChanged"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupModelFitTypeSelect()
		modelFitType = @model.getModelFitType().get('codeValue')
		@setupParameterController(modelFitType)

	setupModelFitTypeSelect: =>
		modelFitType = @model.getModelFitType().get('codeValue')
		@modelFitTypeList = new PickListList()
		@modelFitTypeList.url = "/api/codetables/model fit/type"
		@modelFitTypeListController = new PickListSelectController
			el: @$('.bv_modelFitType')
			collection: @modelFitTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Model Fit Type"
			selectedCode: modelFitType

	setupParameterController: (modelFitType) =>
		curvefitClassesCollection = new Backbone.Collection $.parseJSON window.conf.curvefit.modelfitparameter.classes
		curveFitClasses =  curvefitClassesCollection.findWhere({codeValue: modelFitType})
		if curveFitClasses?
			parametersClass =  curveFitClasses.get 'parametersClass'
			drapType = window[parametersClass]
			controllerClass =  curveFitClasses.get 'controllerClass'
			drapcType = window[controllerClass]
		else
			drapType = 'unassigned'

		if @parameterController?
			@parameterController.undelegateEvents()
		if drapType is "unassigned"
			@$('.bv_analysisParameterForm').empty()
			@parameterController = null
			mfp = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "model fit parameters"
			unless mfp.get('clobValue') is "" or "[]"
				mfp.set clobValue: ""

		else
			if @model.getModelFitParameters() is {}
				drap = new drapType()
			else
				drap = new drapType @model.getModelFitParameters()

			@parameterController = new drapcType
				el: @$('.bv_analysisParameterForm')
				model: drap
			@trigger 'updateState'
			@parameterController.on 'amDirty', =>
				@trigger 'amDirty'
			@parameterController.on 'amClean', =>
				@trigger 'amClean'
			@parameterController.model.on 'change', =>
				@trigger 'updateState'
			@parameterController.render()

	handleModelFitTypeChanged: =>
		modelFitType = @$('.bv_modelFitType').val()
		@setupParameterController(modelFitType)
		@updateModel()
		@modelFitTypeListController.trigger 'change'

	updateModel: =>
		@model.getModelFitType().set
			codeValue: @modelFitTypeListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		@model.trigger 'change'

class window.DoseResponseAnalysisController extends Backbone.View
	template: _.template($("#DoseResponseAnalysisView").html())
	events:
		"click .bv_fitModelButton": "launchFit"

	initialize: ->
		@model.on "sync", @handleExperimentSaved
		@model.getStatus().on 'change', @handleStatusChanged
		@parameterController = null
		@analyzedPreviously = if @model.getModelFitStatus().get('codeValue') == "not started" then false else true
		$(@el).empty()
		$(@el).html @template()
		@testReadyForFit()

	render: =>
		#need to reset analyzedPreviously because after successful re-analysis, the model fit status is reset to not started
		@analyzedPreviously = if @model.getModelFitStatus().get('codeValue') == "not started" then false else true
		@showExistingResults()
		buttonText = if @analyzedPreviously then "Re-Fit" else "Fit Data"
		@$('.bv_fitModelButton').html buttonText

	showExistingResults: ->
		fitStatus = @model.getModelFitStatus().get('codeValue')
		@$('.bv_modelFitStatus').html(fitStatus)
		if @analyzedPreviously
			resultValue = @model.getModelFitResultHTML()
			if resultValue != null
				res = resultValue.get('clobValue')
				if res == ""
					@$('.bv_resultsContainer').hide()
				else
					@$('.bv_modelFitResultsHTML').html(res)
					@$('.bv_resultsContainer').show()
		else
			@$('.bv_resultsContainer').hide()

	testReadyForFit: =>
		if @model.getAnalysisStatus().get('codeValue') == "not started"
			@setNotReadyForFit()
		else
			@setReadyForFit()

	setNotReadyForFit: ->
		@$('.bv_fitOptionWrapper').hide()
		@$('.bv_resultsContainer').hide()
		@$('.bv_analyzeExperimentToFit').show()

	setReadyForFit: =>
		@setupModelFitTypeController()
		@$('.bv_fitOptionWrapper').show()
		@$('.bv_analyzeExperimentToFit').hide()
		@handleStatusChanged()

	primaryAnalysisCompleted: ->
		@testReadyForFit()

	handleStatusChanged: =>
		if @parameterController != null and @parameterController != undefined
			if @model.isEditable()
				@parameterController.enableAllInputs()
			else
				@parameterController.disableAllInputs()

	handleModelStatusChanged: =>
		if @model.isEditable()
			@$('.bv_fitModelButton').removeAttr('disabled')
			@$('select').removeAttr('disabled')
			if @parameterController?
				@parameterController.enableAllInputs()
		else
			@$('.bv_fitModelButton').attr('disabled','disabled')
			@$('select').attr('disabled','disabled')
			if @parameterController?
				@parameterController.disableAllInputs()

	setupModelFitTypeController: ->
		@modelFitTypeController = new ModelFitTypeController
			model: @model
			el: @$('.bv_analysisParameterForm')
		@modelFitTypeController.render()
		@parameterController = @modelFitTypeController.parameterController
		@modelFitTypeController.modelFitTypeListController.on 'change', => @handleModelFitTypeChanged()
		modelFitType = @model.getModelFitType().get('codeValue')
		if modelFitType is "unassigned"
			@$('.bv_fitModelButton').hide()
		else
			@$('.bv_fitModelButton').show()

	handleModelFitTypeChanged: =>
		modelFitType = @modelFitTypeController.modelFitTypeListController.getSelectedCode()
		if modelFitType is "unassigned"
			@$('.bv_fitModelButton').hide()
			if @modelFitTypeController.parameterController?
				@modelFitTypeController.parameterController.undelegateEvents()
		else
			@$('.bv_fitModelButton').show()
			if @modelFitTypeController.parameterController?
				@modelFitTypeController.parameterController.on 'valid', @paramsValid
				@modelFitTypeController.parameterController.on 'invalid', @paramsInvalid
				if @modelFitTypeController.parameterController.isValid() is true
					@paramsValid()
				else
					@paramsInvalid()

	paramsValid: =>
		@$('.bv_fitModelButton').removeAttr('disabled')

	paramsInvalid: =>
		@$('.bv_fitModelButton').attr('disabled','disabled')

	launchFit: =>
		if @analyzedPreviously
			if !confirm("Re-fitting the data will delete the previously fitted results")
				return

		@$('.bv_fitStatusDropDown').modal
			backdrop: "static"
		@$('.bv_fitStatusDropDown').modal "show"

		fitData =
			inputParameters: JSON.stringify @modelFitTypeController.parameterController.model
			user: window.AppLaunchParams.loginUserName
#			experimentCode: "fail"
			experimentCode: @model.get('codeName')
			modelFitType: @modelFitTypeController.modelFitTypeListController.getSelectedCode()
			testMode: false

		$.ajax
			type: 'POST'
			url: "/api/doseResponseCurveFit"
			data: fitData
			success: @fitReturnSuccess
			error: (err) =>
				alert 'got ajax error'
				@serviceReturn = null
				@$('.bv_fitStatusDropDown').modal("hide")
			dataType: 'json'

	fitReturnSuccess: (json) =>
		unless json.hasError
			@analyzedPreviously = true
			@$('.bv_fitModelButton').html "Re-Fit"
		@$('.bv_modelFitResultsHTML').html(json.results.htmlSummary)
		@$('.bv_modelFitStatus').html(json.results.status)
		@$('.bv_resultsContainer').show()
		@$('.bv_fitStatusDropDown').modal("hide")


