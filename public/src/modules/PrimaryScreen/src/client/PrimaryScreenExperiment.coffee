class window.PrimaryScreenAnalysisParameters extends Backbone.Model
	defaults:
		transformationRule: "unassigned"
		normalizationRule: "unassigned"
		hitEfficacyThreshold: null
		hitSDThreshold: null
		positiveControl: new Backbone.Model()
		negativeControl: new Backbone.Model()
		vehicleControl: new Backbone.Model()
		agonistControl: new Backbone.Model()
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
		if @get('agonistControl') not instanceof Backbone.Model
			@set agonistControl: new Backbone.Model(@get('agonistControl'))
		@get('agonistControl').on "change", =>
			@trigger 'change'

	validate: (attrs) ->
		errors = []
		positiveControl = @get('positiveControl').get('batchCode')
		if positiveControl is "" or positiveControl is undefined
			errors.push
				attribute: 'positiveControlBatch'
				message: "Positive control batch much be set"
		positiveControlConc = @get('positiveControl').get('concentration')
		if _.isNaN(positiveControlConc) || positiveControlConc is undefined
			errors.push
				attribute: 'positiveControlConc'
				message: "Positive control conc much be set"
		negativeControl = @get('negativeControl').get('batchCode')
		if negativeControl is "" or negativeControl is undefined
			errors.push
				attribute: 'negativeControlBatch'
				message: "Negative control batch much be set"
		negativeControlConc = @get('negativeControl').get('concentration')
		if _.isNaN(negativeControlConc) || negativeControlConc is undefined
			errors.push
				attribute: 'negativeControlConc'
				message: "Negative control conc much be set"
		agonistControl = @get('agonistControl').get('batchCode')
		if agonistControl is "" or agonistControl is undefined
			errors.push
				attribute: 'agonistControlBatch'
				message: "Agonist control batch much be set"
		agonistControlConc = @get('agonistControl').get('concentration')
		if _.isNaN(agonistControlConc) || agonistControlConc is undefined
			errors.push
				attribute: 'agonistControlConc'
				message: "Agonist control conc much be set"
		vehicleControl = @get('vehicleControl').get('batchCode')
		if vehicleControl is "" or vehicleControl is undefined
			errors.push
				attribute: 'vehicleControlBatch'
				message: "Vehicle control must be set"
		if attrs.transformationRule is "unassigned" or attrs.transformationRule is ""
			errors.push
				attribute: 'transformationRule'
				message: "Transformation rule must be assigned"
		if attrs.normalizationRule is "unassigned" or attrs.normalizationRule is ""
			errors.push
				attribute: 'normalizationRule'
				message: "Normalization rule must be assigned"
		if attrs.thresholdType == "sd" && _.isNaN(attrs.hitSDThreshold)
			errors.push
				attribute: 'hitSDThreshold'
				message: "SD threshold must be assigned"
		if attrs.thresholdType == "efficacy" && _.isNaN(attrs.hitEfficacyThreshold)
			errors.push
				attribute: 'hitEfficacyThreshold'
				message: "Efficacy threshold must be assigned"

		if errors.length > 0
			return errors
		else
			return null

class window.PrimaryScreenExperiment extends Experiment
	getAnalysisParameters: ->
		ap = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "data analysis parameters"
		if ap.get('clobValue')?
			return new PrimaryScreenAnalysisParameters $.parseJSON(ap.get('clobValue'))
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
		"change .bv_positiveControlBatch": "updateModel"
		"change .bv_positiveControlConc": "updateModel"
		"change .bv_negativeControlBatch": "updateModel"
		"change .bv_negativeControlConc": "updateModel"
		"change .bv_vehicleControlBatch": "updateModel"
		"change .bv_agonistControlBatch": "updateModel"
		"change .bv_agonistControlConc": "updateModel"
		"change .bv_thresholdTypeEfficacy": "handleThresholdTypeChanged"
		"change .bv_thresholdTypeSD": "handleThresholdTypeChanged"

	initialize: ->
		@errorOwnerName = 'PrimaryScreenAnalysisParametersController'
		super()

	render: =>
		@$('.bv_autofillSection').empty()
		@$('.bv_autofillSection').html @autofillTemplate(@model.attributes)
		@$('.bv_transformationRule').val(@model.get('transformationRule'))
		@$('.bv_normalizationRule').val(@model.get('normalizationRule'))

		@

	updateModel: =>
		@model.set
			transformationRule: @$('.bv_transformationRule').val()
			normalizationRule: @$('.bv_normalizationRule').val()
			hitEfficacyThreshold: parseFloat(@getTrimmedInput('.bv_hitEfficacyThreshold'))
			hitSDThreshold: parseFloat(@getTrimmedInput('.bv_hitSDThreshold'))
		@model.get('positiveControl').set
			batchCode: @getTrimmedInput('.bv_positiveControlBatch')
			concentration: parseFloat(@getTrimmedInput('.bv_positiveControlConc'))
		@model.get('negativeControl').set
			batchCode: @getTrimmedInput('.bv_negativeControlBatch')
			concentration: parseFloat(@getTrimmedInput('.bv_negativeControlConc'))
		@model.get('vehicleControl').set
			batchCode: @getTrimmedInput('.bv_vehicleControlBatch')
			concentration: null
		@model.get('agonistControl').set
			batchCode: @getTrimmedInput('.bv_agonistControlBatch')
			concentration: parseFloat(@getTrimmedInput('.bv_agonistControlConc'))

	handleThresholdTypeChanged: =>
		thresholdType = @$("input[name='bv_thresholdType']:checked").val()
		@model.set thresholdType: thresholdType
		if thresholdType=="efficacy"
			@$('.bv_hitSDThreshold').attr('disabled','disabled')
			@$('.bv_hitEfficacyThreshold').removeAttr('disabled')
		else
			@$('.bv_hitEfficacyThreshold').attr('disabled','disabled')
			@$('.bv_hitSDThreshold').removeAttr('disabled')

class window.UploadAndRunPrimaryAnalsysisController extends BasicFileValidateAndSaveController
	initialize: ->
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
		@handleMSFormInvalid() #start invalid since file won't be loaded

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

	handleSaveReturnSuccess: (json) =>
		super(json)
		@$('.bv_loadAnother').html("Re-Analyze")
		@trigger 'analysis-completed'

	showFileSelectPhase: ->
		super()
		if @psapc?
			@psapc.enableAllInputs()

	disableAll: ->
		@psapc.disableAllInputs()
		@$('.bv_htmlSummary').hide()
		@$('.bv_fileUploadWrapper').hide()
		@$('.bv_nextControlContainer').hide()
		@$('.bv_saveControlContainer').hide()
		@$('.bv_completeControlContainer').hide()
		@$('.bv_notifications').hide()

	enableAll: ->
		@psapc.enableAllInputs()
		@showFileSelectPhase()

	validateParseFile: =>
		@psapc.updateModel()
		unless !@psapc.isValid()
			@additionalData =
				inputParameters: JSON.stringify @psapc.model
				primaryAnalysisExperimentId: @experimentId
				testMode: false
			super()

	setUser: (user) ->
		@userName = user

	setExperimentId: (expId) ->
		@experimentId = expId

class window.PrimaryScreenAnalysisController extends Backbone.View
	template: _.template($("#PrimaryScreenAnalysisView").html())

	initialize: ->
		@model.on "sync", @handleExperimentSaved
		@model.getStatus().on 'change', @handleStatusChanged
		$(@el).empty()
		$(@el).html @template()
		if @model.isNew()
			@setExperimentNotSaved()
		else
			@setupDataAnalysisController()
			@setExperimentSaved()

	render: =>
		@showExistingResults()

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
			@$('.bv_resultsContainer').show()

	setExperimentNotSaved: ->
		@$('.bv_fileUploadWrapper').hide()
		@$('.bv_resultsContainer').hide()
		@$('.bv_saveExperimentToAnalyze').show()

	setExperimentSaved: =>
		@$('.bv_saveExperimentToAnalyze').hide()
		@$('.bv_fileUploadWrapper').show()

	handleExperimentSaved: =>
		unless @dataAnalysisController?
			@setupDataAnalysisController()
		@setExperimentSaved()

	handleAnalysisComplete: =>
		console.log "got analysis complete"
		# Results are shown analysis controller, so redundant here until experiment is reloaded, which resets analysis controller
		@$('.bv_resultsContainer').hide()

	handleStatusChanged: =>
		console.log "got status change"
		if @model.isEditable()
			@dataAnalysisController.enableAll()
		else
			@dataAnalysisController.disableAll()



	setupDataAnalysisController: ->
		@dataAnalysisController = new UploadAndRunPrimaryAnalsysisController
			el: @$('.bv_fileUploadWrapper')
			paramsFromExperiment:	@model.getAnalysisParameters()
		@dataAnalysisController.setUser(@model.get('recordedBy'))
		@dataAnalysisController.setExperimentId(@model.id)
		@dataAnalysisController.on 'analysis-completed', @handleAnalysisComplete

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

