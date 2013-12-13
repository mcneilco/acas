class window.PrimaryScreenAnalysisParameters extends Backbone.Model
	defaults:
		transformationRule: "unassigned"
		normalizationRule: "unassigned"
		hitEfficacyThreshold: null
		hitSDThreshold: null
		positiveControl: new Backbone.Model()
		negativeControl: new Backbone.Model()
		vehicleControl: new Backbone.Model()
		thresholdType: "sd"

	initialize: ->
		@fixCompositeClasses()


	fixCompositeClasses: =>
		if @get('positiveControl') not instanceof Backbone.Model
			@set positiveControl: new Backbone.Model(@get('positiveControl'))
		@get('positiveControl').on "change", =>
			@trigger 'change'
		if @get('negativeControl') not instanceof Backbone.Model
			@set negativeControl: new Backbone.Model(@get('negativeControl'))
		@get('negativeControl').on "change", =>
			@trigger 'change'
		if @get('vehicleControl') not instanceof Backbone.Model
			@set vehicleControl: new Backbone.Model(@get('vehicleControl'))
		@get('vehicleControl').on "change", =>
			@trigger 'change'

class window.PrimaryScreenExperiment extends Experiment
	getAnalysisParameters: ->
		ap = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "data analysis parameters"
		if ap.get('clobValue')?
			return new PrimaryScreenAnalysisParameters eval(ap.get('clobValue'))
		else
			return new PrimaryScreenAnalysisParameters()

	getAnalysisStatus: ->
		@get('lsStates').getStateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "analysis status"

	getAnalysisResultHTML: ->
		@get('lsStates').getStateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "analysis result html"


class window.PrimaryScreenAnalysisParametersController extends AbstractParserFormController
	template: _.template($("#PrimaryScreenAnalysisParametersView").html())
	autofillTemplate: _.template($("#PrimaryScreenAnalysisParametersAutofillView").html())

	events:
		"change .bv_transformationRule": "updateModel"
		"change .bv_normalizationRule": "updateModel"
		"change .bv_transformationRule": "updateModel"
		"change .bv_hitEfficacyThreshold": "updateModel"
		"change .bv_hitSDThreshold": "updateModel"
		"change .bv_posControlBatch": "updateModel"
		"change .bv_posControlConc": "updateModel"
		"change .bv_negControlBatch": "updateModel"
		"change .bv_negControlConc": "updateModel"
		"change .bv_vehControlBatch": "updateModel"
		"change .bv_thresholdTypeEfficacy": "handleThresholdTypeChanged"
		"change .bv_thresholdTypeSD": "handleThresholdTypeChanged"

	initialize: ->
		@errorOwnerName = 'PrimaryScreenAnalysisParametersController'
		super()

	render: =>
		console.log "got to render"
		@$('.bv_autofillSection').empty()
		console.log @model
		@$('.bv_autofillSection').html @autofillTemplate(@model.attributes)
		@$('.bv_transformationRule').val(@model.get('transformationRule'))
		@$('.bv_normalizationRule').val(@model.get('normalizationRule'))

		@

	updateModel: =>
		@model.set
			transformationRule: @$('.bv_transformationRule').val()
			normalizationRule: @$('.bv_normalizationRule').val()
			hitEfficacyThreshold: @getTrimmedInput('.bv_hitEfficacyThreshold')
			hitSDThreshold: @getTrimmedInput('.bv_hitSDThreshold')
		@model.get('positiveControl').set
			batchCode: @getTrimmedInput('.bv_posControlBatch')
			concentration: @getTrimmedInput('.bv_posControlConc')
		@model.get('negativeControl').set
			batchCode: @getTrimmedInput('.bv_negControlBatch')
			concentration: @getTrimmedInput('.bv_negControlConc')
		@model.get('vehicleControl').set
			batchCode: @getTrimmedInput('.bv_vehControlBatch')
			concentration: null

	handleThresholdTypeChanged: =>
		thresholdType = @$("input[name='bv_thresholdType']:checked").val()
		@model.set thresholdType: thresholdType
		if thresholdType=="efficacy"
			@$('.bv_hitSDThreshold').attr('disabled','disabled')
			@$('.bv_hitEfficacyThreshold').removeAttr('disabled')
		else
			@$('.bv_hitEfficacyThreshold').attr('disabled','disabled')
			@$('.bv_hitSDThreshold').removeAttr('disabled')



class window.PrimaryScreenAnalysisController extends Backbone.View
	template: _.template($("#PrimaryScreenAnalysisView").html())

	initialize: ->
		@model.on "synced_and_repaired", @handleExperimentSaved

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@showExistingResults()
		if not @model.isNew()
			@handleExperimentSaved()
		@

	showExistingResults: ->
		analysisStatus = @model.getAnalysisStatus()
		if analysisStatus != null
			analysisStatus = analysisStatus.get('stringValue')
		else
			analysisStatus = "not started"
		@$('.bv_analysisStatus').html(analysisStatus)
		resultValue = @model.getAnalysisResultHTML()
		if resultValue != null
			@$('.bv_analysisResultsHTML').html(resultValue.get('clobValue'))

	handleExperimentSaved: =>
		@dataAnalysisController = new UploadAndRunPrimaryAnalsysisController
			el: @$('.bv_fileUploadWrapper')
			paramsFromExperiment:	@model.getAnalysisParameters()
		@dataAnalysisController.setUser(@model.get('recordedBy'))
		@dataAnalysisController.setExperimentId(@model.id)

class window.UploadAndRunPrimaryAnalsysisController extends BasicFileValidateAndSaveController
	initialize: ->
		UploadAndRunPrimaryAnalsysisController.__super__.initialize.apply(@, arguments)
		@fileProcessorURL = "/api/primaryAnalysis/runPrimaryAnalysis"
		@errorOwnerName = 'UploadAndRunPrimaryAnalsysisController'
		@allowedFileTypes = ['zip']
		@loadReportFile = false
		super()
		@$('.bv_moduleTitle').html("Upload Data and Analyze")
		@psapc = new PrimaryScreenAnalysisParametersController
			model: @options.paramsFromExperiment
			el: @$('.bv_additionalValuesForm')
		@psapc.on 'valid', @handleMSFormValid
		@psapc.on 'invalid', @handleMSFormInvalid
		@psapc.on 'notifyError', @notificationController.addNotification
		@psapc.on 'clearErrors', @notificationController.clearAllNotificiations
		@psapc.on 'amDirty', =>
			@trigger 'amDirty'
		@psapc.render()

	handleMSFormValid: =>
		if @parseFileUploaded
			@handleFormValid()

	handleMSFormInvalid: =>
		@handleFormInvalid()

	handleFormValid: ->
		if @psapc.isValid()
			super()

	handleValidationReturnSuccess: (json) =>
		super(json)
		@psapc.disableAllInputs()

	showFileSelectPhase: ->
		super()
		if @psapc?
			@psapc.enableAllInputs()

	validateParseFile: =>
		@psapc.updateModel()
		unless !@psapc.isValid()
			@additionalData =
				inputParameters: @psapc.model.toJSON()
			super()

	validateParseFile: =>
		@psapc.updateModel()
		unless !@psapc.isValid()
			@additionalData =
				inputParameters: @psapc.model.toJSON()
				primaryAnalysisExperimentId: @experimentId
				testMode: false
			super()

	setUser: (user) ->
		@userName = user

	setExperimentId: (expId) ->
		@experimentId = expId





# This wraps all the tabs
class window.PrimaryScreenExperimentController extends Backbone.View
	template: _.template($("#PrimaryScreenExperimentView").html())

	initialize: ->
		unless @model?
			@model = new PrimaryScreenExperiment()

		$(@el).html @template()
		@model.on 'sync', @handleExperimentSaved
		@experimentBaseController = new ExperimentBaseController
			model: @model
			el: @$('.bv_experimentBase')
		@analysisController = new PrimaryScreenAnalysisController
			model: @model
			el: @$('.bv_primaryScreenDataAnalysis')
		@doseRespController = new DoseResponseAnalysisController
			model: @model
			el: @$('.bv_doseResponseAnalysis')
		@model.on "protocol_attributes_copied", @handleProtocolAttributesCopied

	render: ->
		@experimentBaseController.render()
		@analysisController.render()
		@doseRespController.render()
		return @

	handleExperimentSaved: =>
		@analysisController.render()

	handleProtocolAttributesCopied: =>
		@analysisController.render()

