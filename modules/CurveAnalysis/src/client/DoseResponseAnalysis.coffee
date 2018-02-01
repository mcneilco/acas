class window.DoseResponseAnalysisParameters extends Backbone.Model
	defaults:
		smartMode: true
		inactiveThresholdMode: true
		inactiveThreshold: 20
		theoreticalMaxMode: false
		theoreticalMax: null
		inverseAgonistMode: false
		max: new Backbone.Model limitType: 'none'
		min: new Backbone.Model limitType: 'none'
		slope: new Backbone.Model limitType: 'none'
		baseline: new Backbone.Model(value: 0)

	initialize: (attributes, options) ->
		
		if attributes?
			if(typeof(attributes.inactiveThreshold) == "undefined")
				@set 'inactiveThreshold', null
			else
				@set 'inactiveThreshold', attributes.inactiveThreshold

			if(typeof(attributes.theoreticalMax) == "undefined")
				@set 'theoreticalMax', null
			else
				@set 'theoreticalMax', attributes.theoreticalMax

			if(typeof(attributes.baseline) == "undefined")
				if options?.defaultBaseline?
					baseline = options.defaultBaseline
				else
					baseline = 0
				@get("baseline").set "value", baseline
			else
				@set 'baseline', attributes.baseline
		else
			if options?.defaultBaseline?
				@get("baseline").set "value", options.defaultBaseline
			else
				@get("baseline").set "value", 0
			if options?.defaultBaseline?
				@get("baseline").set "value", options.defaultBaseline
			else
				@get("baseline").set "value", 0
		@fixCompositeClasses()
		@on 'change:inactiveThreshold', @handleInactiveThresholdChanged
		@on 'change:theoreticalMax', @handleTheoreticalMaxChanged

	fixCompositeClasses: =>
		if @get('max') not instanceof Backbone.Model
			@set max: new Backbone.Model(@get('max'))
		if @get('min') not instanceof Backbone.Model
			@set min: new Backbone.Model(@get('min'))
		if @get('slope') not instanceof Backbone.Model
			@set slope: new Backbone.Model(@get('slope'))
		if @get('baseline') not instanceof Backbone.Model
			@set baseline: new Backbone.Model(@get('baseline'))


	handleInactiveThresholdChanged: =>
		if _.isNaN(@get('inactiveThreshold')) or @get('inactiveThreshold') == null
			@set 'inactiveThresholdMode': false
				,
					silent: true
		else
			@set 'inactiveThresholdMode': true
				,
					silent: true

	handleTheoreticalMaxChanged: =>
		if _.isNaN(@get('theoreticalMax')) or @get('theoreticalMax') == null
			@set 'theoreticalMaxMode': false
			,
				silent: true
		else
			@set 'theoreticalMaxMode': true
			,
				silent: true

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
		if  attrs.inactiveThresholdMode &&_.isNaN(attrs.inactiveThreshold)
			errors.push
				attribute: 'inactiveThreshold'
				message: "Inactive threshold value must be set to a number"
		if  attrs.theoreticalMaxMode && _.isNaN(attrs.theoreticalMax)
			errors.push
				attribute: 'theoreticalMax'
				message: "Theoretical max value must be set to a number"
		if  (attrs.smartMode && (_.isNaN(attrs.baseline.get('value')) or attrs.baseline.get('value') == null))
			errors.push
				attribute: 'baseline'
				message: "Baseline value must be set to a number"
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
		"change .bv_inactiveThreshold": "attributeChanged"
		"change .bv_theoreticalMax": "attributeChanged"
		"change .bv_baseline": "attributeChanged"

	initialize: ->
		$(@el).html @template()
		@errorOwnerName = 'DoseResponseAnalysisParametersController'
		@setBindings()

	render: =>
		@$('.bv_autofillSection').empty()
		@$('.bv_autofillSection').html @autofillTemplate($.parseJSON(JSON.stringify(@model)))
		@setFormTitle()
		@setInverseAgonistModeEnabledState()
		@

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
		@model.get('baseline').set
			value: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_baseline'))
		@model.set
			inverseAgonistMode: @$('.bv_inverseAgonistMode').is(":checked")
			smartMode: @$('.bv_smartMode').is(":checked")
			inactiveThreshold: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_inactiveThreshold'))
			theoreticalMax: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_theoreticalMax'))
			,
				silent: true
		@model.handleInactiveThresholdChanged()
		@model.handleTheoreticalMaxChanged()

		@setInverseAgonistModeEnabledState()
		@model.trigger 'change'
		@trigger 'updateState'

	handleSmartModeChanged: =>
		if @$('.bv_smartMode').is(":checked")
			@$('.bv_inactiveThreshold').removeAttr 'disabled'
			@$('.bv_theoreticalMax').removeAttr 'disabled'
			@$('.bv_baseline').removeAttr 'disabled'
		else
			@$('.bv_inactiveThreshold').attr 'disabled', 'disabled'
			@$('.bv_inactiveThreshold').val ""
			@$('.bv_theoreticalMax').attr 'disabled', 'disabled'
			@$('.bv_theoreticalMax').val ""
			@$('.bv_baseline').attr 'disabled', 'disabled'

		@attributeChanged()

	handleInverseAgonistModeChanged: =>
		@attributeChanged()

	handleMaxLimitTypeChanged: =>
		radioValue = @$("input[name='bv_max_limitType']:checked").val()
		@model.get('max').set limitType: radioValue
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
		"change .bv_fitTransformation": "handleFitTransformationChanged"
		"change .bv_transformationUnits": "handleTransformationUnitsChanged"

	initialize: =>
		$(@el).empty()
		$(@el).html @template()
		#get tranformation fit options
		$.ajax
			type: 'GET'
			url: '/api/codetables/analysis parameter/transformation'
			dataType: 'json'
			error: (err) ->
				alert 'Could not get list of transformation options'
			success: (json) =>
				if json.length == 0
					alert 'Returned empty list of transformation options'
				else
					@transformationFitOptions = new PickListList json

					transformationRuleList = @model.getAnalysisParameters().get('transformationRuleList')
					fitTransformationList = new PickListList()
					transformationRuleList.each (rule) =>
						unless rule.get('transformationRule') is "unassigned"
							rule = @transformationFitOptions.where(code: rule.get('transformationRule'))[0]
							fitTransformationList.add new PickList
								code: rule.get('name')
								name: rule.get('name')

					@setupFitTransformationSelect(fitTransformationList)


	render: =>
		@setupModelFitTypeSelect()
		@setupTransformationUnitsSelect()
		modelFitType = @model.getModelFitType().get('codeValue')
		if modelFitType is "unassigned"
			@$('.bv_modelFitTransformationWrapper').hide()
		else
			@$('.bv_modelFitTransformationWrapper').show()
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

	setupFitTransformationSelect: (fitTransformationList) =>
		if @fitTransformationListController?
			@fitTransformationListController.undelegateEvents()
		@fitTransformationListController = new PickListSelectController
			el: @$('.bv_fitTransformation')
			collection: fitTransformationList
			autoFetch: false
			insertFirstOption: new PickList
				code: "Select Fit Transformation"
				name: "Select Fit Transformation"
			selectedCode: @model.getModelFitTransformation().get('stringValue')

	setupTransformationUnitsSelect: =>
		transformationUnits = @model.getModelFitTransformationUnits().get('codeValue')
		@transformationUnitsList = new PickListList()
		@transformationUnitsList.url = "/api/codetables/model fit/transformation units"
		@transformationUnitsListController = new PickListSelectController
			el: @$('.bv_transformationUnits')
			collection: @transformationUnitsList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Transformation Unit"
			selectedCode: transformationUnits

	setupParameterController: (modelFitType) =>
		curvefitClassesCollection = new Backbone.Collection $.parseJSON window.conf.curvefit.modelfitparameter.classes
		curveFitClasses =  curvefitClassesCollection.findWhere({code: modelFitType})
		if curveFitClasses?
			parametersClass =  curveFitClasses.get 'parametersClass'
			drapType = window[parametersClass]
			controllerClass =  curveFitClasses.get 'parametersController'
			drapcType = window[controllerClass]
			defaultBaseline = curveFitClasses.get 'defaultBaseline'
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
			fitParameters = @model.getModelFitParameters()
			if defaultBaseline?
				fitParameters.set defaultBaseline: defaultBaseline
			drap = new drapType fitParameters

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
		if modelFitType is "unassigned"
			@$('.bv_modelFitTransformationWrapper').hide()
			@fitTransformationListController.setSelectedCode "Select Fit Transformation"
			@transformationUnitsListController.setSelectedCode "unassigned"
			@updateModel()
		else
			@$('.bv_modelFitTransformationWrapper').show()
		@setupParameterController(modelFitType)
		@updateModel()
		@modelFitTypeListController.trigger 'change'

	handleFitTransformationChanged: =>
		@updateModel()
		@trigger 'change'

	handleTransformationUnitsChanged: =>
		@updateModel()
		@trigger 'change'

	handleTransformationRuleChanged: (transformationRuleList) =>
		fitTransformationList = new PickListList()
		transformationRuleList.each (rule) =>
			unless rule.get('transformationRule') is "unassigned"
				rule = @transformationFitOptions.where(code: rule.get('transformationRule'))[0]
				fitTransformationList.add new PickList
					code: rule.get('name')
					name: rule.get('name')
		@model.getModelFitTransformation().set 'stringValue', 'Select Fit Transformation'
		@setupFitTransformationSelect(fitTransformationList)

	updateModel: =>
		@model.getModelFitType().set
			codeValue: @modelFitTypeListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		@model.getModelFitTransformation().set
			stringValue: @fitTransformationListController.getSelectedModel().get('name')
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		@model.getModelFitTransformationUnits().set
			codeValue: @transformationUnitsListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		@model.trigger 'change'

	isValid: ->
		validCheck = true
		errors = []
		errors.push @parameterController.model.validationError...
		errors.push @model.validateModelFitParams()...
		if errors.length > 0
			validCheck = false
		@validationError errors

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
		if @model.getAnalysisStatus().get('codeValue') != "complete"
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
		@modelFitTypeController.on 'change', => @validateModelFitTab()
		@modelFitTypeController.render()
		@parameterController = @modelFitTypeController.parameterController
		@modelFitTypeController.modelFitTypeListController.on 'change', => @handleModelFitTypeChanged()
		if @parameterController?
			@parameterController.model.on 'change', => @validateModelFitTab()
		modelFitType = @model.getModelFitType().get('codeValue')
		if modelFitType is "unassigned"
			@$('.bv_fitModelButton').hide()
		else
			@$('.bv_fitModelButton').show()

	handleModelFitTypeChanged: =>
		modelFitType = @modelFitTypeController.modelFitTypeListController.getSelectedCode()
		if modelFitType is "unassigned"
			@$('.bv_fitModelButton').hide()
			@$('.bv_modelFitTransformationWrapper').hide()
			if @modelFitTypeController.parameterController?
				@modelFitTypeController.parameterController.undelegateEvents()
		else
			@$('.bv_fitModelButton').show()
			@$('.bv_modelFitTransformationWrapper').show()
			if @modelFitTypeController.parameterController?
				@modelFitTypeController.parameterController.on 'valid', @validateModelFitTab
				@modelFitTypeController.parameterController.on 'invalid', @validateModelFitTab
				@validateModelFitTab()

	validateModelFitTab: =>
		if @modelFitTypeController.isValid() and @modelFitTypeController.parameterController.isValid()
			@paramsValid()
		else
			@paramsInvalid()

	paramsValid: =>
		@$('.bv_fitModelButton').removeAttr('disabled')

	paramsInvalid: =>
		@$('.bv_fitModelButton').attr('disabled','disabled')

	handleTransformationRuleChanged: (transformationRuleList) ->
		@modelFitTypeController.handleTransformationRuleChanged transformationRuleList

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
			modelFitTransformation: JSON.stringify @model.getModelFitTransformation()
			modelFitTransformationUnits: JSON.stringify @model.getModelFitTransformationUnits()

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

class window.DoseResponsePlotCurveLL4 extends Backbone.Model

	log10: (val) ->
		Math.log(val) / Math.LN10

	render: (brd, curve, plotWindow) =>
		log10 = @log10
		fct = (x) ->
			curve.min + (curve.max - curve.min) / (1 + Math.exp(curve.slope * Math.log(Math.pow(10,x) / curve.ec50)))
		brd.create('functiongraph', [fct, plotWindow[0], plotWindow[2]], {strokeWidth:2});
		if curve.curveAttributes.EC50?
			intersect = fct(log10(curve.curveAttributes.EC50))
			if curve.curveAttributes.Operator?
				color = '#ff0000'
			else
				color = '#808080'
			#				Horizontal Line
			brd.create('line',[[plotWindow[0],intersect],[log10(curve.curveAttributes.EC50),intersect]], {fixed: true, straightFirst:false, straightLast:false, strokeWidth:2, dash: 3, strokeColor: color});
			#				Vertical Line
			brd.create('line',[[log10(curve.curveAttributes.EC50),intersect],[log10(curve.curveAttributes.EC50),0]], {fixed: true, straightFirst:false, straightLast:false, strokeWidth:2, dash: 3, strokeColor: color});
