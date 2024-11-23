class DoseResponseDataParserController extends BasicFileValidateAndSaveController

	initialize: (options) ->
		@options = options
		@loadReportFile = true
		@fileProcessorURL = "/api/genericDataParser"
		@errorOwnerName = 'DoseResponseDataParserController'
		@additionalData = requireDoseResponse: true
		super(options)
		@$('.bv_moduleTitle').html('Load Efficacy Data for Dose Response Fit')

	handleSaveReturnSuccess: (json) =>
		super(json)
		@trigger 'dataUploadComplete'
		@$('.bv_completeControlContainer').hide()



class DoseResponseFitController extends Backbone.View
	template: _.template($("#DoseResponseFitView").html())
	events:
		"click .bv_fitModelButton": "launchFit"
		"change .bv_modelFitType": "handleModelFitTypeChanged"

	initialize: (options) ->
		@options = options
		if !@options.experimentCode?
			alert("DoseResponseFitController must be initialized with an experimentCode")

	render: =>
		@parameterController = null
		$(@el).empty()
		$(@el).html @template()
		@setupModelFitTypeSelect()

	setupModelFitTypeSelect: ->
		@modelFitTypeList = new PickListList()
		@modelFitTypeList.url = "/api/codetables/model fit/type"
		@modelFitTypeListController = new PickListSelectController
			el: @$('.bv_modelFitType')
			collection: @modelFitTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Model Fit Type"
			selectedCode: "unassigned"

	setupParameterController: (modelFitType) =>
		curvefitClassesCollection = new Backbone.Collection $.parseJSON window.conf.curvefit.modelfitparameter.classes
		curveFitClasses =  curvefitClassesCollection.findWhere({code: modelFitType})
		if curveFitClasses?
			parametersClass =  curveFitClasses.get 'parametersClass'
			drapType = window[parametersClass]
			controllerClass =  curveFitClasses.get 'parametersController'
			drapcType = window[controllerClass]
			parametersOptions = curveFitClasses.get 'parametersOptions'
		else
			drapType = 'unassigned'

		if drapType is "unassigned"
			@$('.bv_analysisParameterForm').empty()
			@$('.bv_fitModelButton').hide()
		else
			@$('.bv_fitModelButton').show()
			if @options? && @options.initialAnalysisParameters?
				drap = new drapType @options.initialAnalysisParameters, parametersOptions
			else
				drap = new drapType null, parametersOptions
			@parameterController = new drapcType
				el: @$('.bv_analysisParameterForm')
				model: drap

			@parameterController.on 'amDirty', =>
				@trigger 'amDirty'
			@parameterController.on 'amClean', =>
				@trigger 'amClean'
			@parameterController.on 'valid', @paramsValid
			@parameterController.on 'invalid', @paramsInvalid
			@parameterController.render()

	handleModelFitTypeChanged: ->
		modelFitType = @$('.bv_modelFitType').val()
		@setupParameterController(modelFitType)
		if @parameterController?
			if @parameterController.isValid() is true
				@paramsValid()
			else
				@paramsInvalid()

	paramsValid: =>
		@$('.bv_fitModelButton').removeAttr('disabled')

	paramsInvalid: =>
		@$('.bv_fitModelButton').attr('disabled','disabled')

	launchFit: =>
		@$('.bv_fitStatusDropDown').modal
			backdrop: "static"
		@$('.bv_fitStatusDropDown').modal "show"

		fitData =
			inputParameters: JSON.stringify @parameterController.model
			user: window.AppLaunchParams.loginUserName
			experimentCode: @options.experimentCode
			modelFitType: @modelFitTypeListController.getSelectedCode()
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
		if json.results?.htmlSummary?
			htmlSummary = json.results.htmlSummary
		else
			htmlSummary = "Internal error please contact your administrator"
		@$('.bv_modelFitResultsHTML').html(htmlSummary)
		@$('.bv_resultsContainer').show()
		@$('.bv_fitModelButton').hide()
		@$('.bv_fitOptionWrapper').hide()
		@$('.bv_fitStatusDropDown').modal("hide")
		@trigger 'fitComplete'
		@trigger 'amClean'


class DoseResponseFitWorkflowController extends Backbone.View
	template: _.template($("#DoseResponseFitWorkflowView").html())
	events:
		"click .bv_loadAnother": "handleFitAnother"

	render: =>
		@$el.empty()
		@$el.html @template()
		@intializeParserController()

		@

	intializeParserController: ->
		@$('.bv_dataParser').empty()
		@drdpc = new DoseResponseDataParserController
			el: @$('.bv_dataParser')
		@drdpc.on 'dataUploadComplete', @handleDataUploadComplete
		@drdpc.on 'amDirty', =>
			@trigger 'amDirty'
		@drdpc.on 'amClean', =>
			@trigger 'amClean'
		@drdpc.render()

	initializeCurveFitController: =>
		@$('.bv_doseResponseAnalysis').empty()
		if @modelFitController?
			@modelFitController.undelegateEvents()
		@modelFitController = new DoseResponseFitController
			experimentCode: @drdpc.getNewExperimentCode()
			el: @$('.bv_doseResponseAnalysis')

		@modelFitController.on 'amDirty', =>
			@trigger 'amDirty'
		@modelFitController.on 'amClean', =>
			@trigger 'amClean'
		@modelFitController.render()
		@modelFitController.on 'fitComplete', @handleFitComplete

	handleDataUploadComplete: =>
		@$('.bv_modelFitTabLink').click()
		@initializeCurveFitController()
		@trigger 'amDirty'

	handleFitComplete: =>
		@$('.bv_completeControlContainer').show()
		@drdpc.$('.bv_loadAnother').hide()

	handleFitAnother: =>
		@drdpc.loadAnother()
		@$('.bv_doseResponseAnalysis').empty()
		@$('.bv_doseResponseAnalysis').append "<div class='bv_uploadDataToFit span10'>Data must be uploaded first before fitting.</div>"
		@$('.bv_completeControlContainer').hide()
		@$('.bv_uploadDataTabLink').click()
