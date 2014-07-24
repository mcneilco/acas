class window.PrimaryScreenAnalysisParameters extends Backbone.Model
	defaults:
		instrumentReader: "unassigned"
		signalDirectionRule: "unassigned"
		aggregateBy1: "unassigned"
		aggregateBy2: "unassigned"
		transformationRule: "unassigned"
		normalizationRule: "unassigned"
		assayVolume: null
		transferVolume: null
		dilutionFactor: null
		hitEfficacyThreshold: null
		hitSDThreshold: null
		positiveControl: new Backbone.Model()
		negativeControl: new Backbone.Model()
		vehicleControl: new Backbone.Model()
		agonistControl: new Backbone.Model()
		thresholdType: "sd"
		volumeType: "dilution"
		autoHitSelection: true
		primaryAnalysisRead: new Backbone.Model()
#		primaryAnalysisReadList: new Backbone.Collection()

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
		if attrs.instrumentReader is "unassigned" or attrs.instrumentReader is ""
			errors.push
				attribute: 'instrumentReader'
				message: "Instrument reader must be assigned"
		if attrs.signalDirectionRule is "unassigned" or attrs.signalDirectionRule is ""
			errors.push
				attribute: 'signalDirectionRule'
				message: "Signal Direction Rule must be assigned"
		if attrs.aggregateBy1 is "unassigned" or attrs.aggregateBy1 is ""
			errors.push
				attribute: 'aggregateBy1'
				message: "Aggregate By1 must be assigned"
		if attrs.aggregateBy2 is "unassigned" or attrs.aggregateBy2 is ""
			errors.push
				attribute: 'aggregateBy2'
				message: "Aggregate By2 must be assigned"
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
		if attrs.assayVolume is "" or _.isNaN(attrs.assayVolume)
			errors.push
				attribute: 'assayVolume'
				message: "Assay volume must be assigned"
		if attrs.volumeType == "dilution" && _.isNaN(attrs.dilutionFactor)
			errors.push
				attribute: 'dilutionFactor'
				message: "Dilution factor must be a number"
		if attrs.volumeType == "transfer" && _.isNaN(attrs.transferVolume)
			errors.push
				attribute: 'transferVolume'
				message: "Transfer volume must be assigned"
#		if attrs.readSummaryList is "unassigned" or attrs.readSummaryList is ""
#			errors.push
#				attribute: 'readSummaryList'
#				message: "ReadSummaryList must be assigned"
#

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

	getModelFitParameters: ->
		ap = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "model fit parameters"
		if ap.get('clobValue')?
			return $.parseJSON(ap.get('clobValue'))
		else
			return {}

	getAnalysisStatus: ->
		status = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "analysis status"
		if !status.has('stringValue')
			status.set stringValue: "not started"

		status

	getAnalysisResultHTML: ->
		result = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "analysis result html"
		if !result.has('clobValue')
			result.set clobValue: ""

		result

	getModelFitStatus: ->
		status = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "model fit status"
		if !status.has('stringValue')
			status.set stringValue: "not started"

		status

	getModelFitResultHTML: ->
		result = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "model fit result html"
		if !result.has('clobValue')
			result.set clobValue: ""

		result

class window.PrimaryScreenAnalysisParametersController extends AbstractParserFormController
	template: _.template($("#PrimaryScreenAnalysisParametersView").html())
	autofillTemplate: _.template($("#PrimaryScreenAnalysisParametersAutofillView").html())

	events:
		"change .bv_instrumentReader": "attributeChanged"
		"change .bv_signalDirectionRule": "attributeChanged"
		"change .bv_aggregateBy1": "attributeChanged"
		"change .bv_aggregateBy2": "attributeChanged"
		"change .bv_transformationRule": "attributeChanged"
		"change .bv_normalizationRule": "attributeChanged"
		"change .bv_assayVolume": "attributeChanged"
		"change .bv_dilutionFactor": "attributeChanged"
		"change .bv_transferVolume": "attributeChanged"
		"change .bv_hitEfficacyThreshold": "attributeChanged"
		"change .bv_hitSDThreshold": "attributeChanged"
		"change .bv_positiveControlBatch": "attributeChanged"
		"change .bv_positiveControlConc": "attributeChanged"
		"change .bv_negativeControlBatch": "attributeChanged"
		"change .bv_negativeControlConc": "attributeChanged"
		"change .bv_vehicleControlBatch": "attributeChanged"
		"change .bv_agonistControlBatch": "attributeChanged"
		"change .bv_agonistControlConc": "attributeChanged"
		"change .bv_thresholdTypeEfficacy": "handleThresholdTypeChanged"
		"change .bv_thresholdTypeSD": "handleThresholdTypeChanged"
		"change .bv_volumeTypeTransfer": "handleVolumeTypeChanged"
		"change .bv_volumeTypeDilution": "handleVolumeTypeChanged"
		"change .bv_autoHitSelection": "handleAutoHitSelectionChanged"




	initialize: ->
		@errorOwnerName = 'PrimaryScreenAnalysisParametersController'
		super()
		@setupInstrumentReaderSelect()
		@setupSignalDirectionSelect()
		@setupAggregateBy1Select()
		@setupAggregateBy2Select()
		@setupTransformationSelect()
		@setupNormalizationSelect()




	render: =>
		@$('.bv_autofillSection').empty()
		@$('.bv_autofillSection').html @autofillTemplate(@model.attributes)
		@setupInstrumentReaderSelect()
		@setupSignalDirectionSelect()
		@setupAggregateBy1Select()
		@setupAggregateBy2Select()
		@setupTransformationSelect()
		@setupNormalizationSelect()
		@handleAutoHitSelectionChanged()



		@


	setupInstrumentReaderSelect: ->
		@instrumentList = new PickListList()
		@instrumentList.url = "/api/primaryAnalysis/runPrimaryAnalysis/instrumentReaderCodes"
		@instrumentListController = new PickListSelectController
			el: @$('.bv_instrumentReader')
			collection: @instrumentList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Instrument"
			selectedCode: @model.get('instrumentReader')

	setupSignalDirectionSelect: ->
		@signalDirectionList = new PickListList()
		@signalDirectionList.url = "/api/primaryAnalysis/runPrimaryAnalysis/signalDirectionCodes"
		@signalDirectionListController = new PickListSelectController
			el: @$('.bv_signalDirectionRule')
			collection: @signalDirectionList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Signal Direction"
			selectedCode: @model.get('signalDirectionRule')

	setupAggregateBy1Select: ->
		@aggregateBy1List = new PickListList()
		@aggregateBy1List.url = "/api/primaryAnalysis/runPrimaryAnalysis/aggregateBy1Codes"
		@aggregateBy1ListController = new PickListSelectController
			el: @$('.bv_aggregateBy1')
			collection: @aggregateBy1List
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Aggregate By1"
			selectedCode: @model.get('aggregateBy1')

	setupAggregateBy2Select: ->
		@aggregateBy2List = new PickListList()
		@aggregateBy2List.url = "/api/primaryAnalysis/runPrimaryAnalysis/aggregateBy2Codes"
		@aggregateBy2ListController = new PickListSelectController
			el: @$('.bv_aggregateBy2')
			collection: @aggregateBy2List
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Aggregate By2"
			selectedCode: @model.get('aggregateBy2')

	setupTransformationSelect: ->
		@transformationList = new PickListList()
		@transformationList.url = "/api/primaryAnalysis/runPrimaryAnalysis/transformationCodes"
		@transformationListController = new PickListSelectController
			el: @$('.bv_transformationRule')
			collection: @transformationList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Rule"
			selectedCode: @model.get('transformationRule')

	setupNormalizationSelect: ->
		@normalizationList = new PickListList()
		@normalizationList.url = "/api/primaryAnalysis/runPrimaryAnalysis/normalizationCodes"
		@normalizationListController = new PickListSelectController
			el: @$('.bv_normalizationRule')
			collection: @normalizationList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Rule"
			selectedCode: @model.get('normalizationRule')

	updateModel: =>
		@model.set
			instrumentReader: @$('.bv_instrumentReader').val()
			signalDirectionRule: @$('.bv_signalDirectionRule').val()
			aggregateBy1: @$('.bv_aggregateBy1').val()
			aggregateBy2: @$('.bv_aggregateBy2').val()
			transformationRule: @$('.bv_transformationRule').val()
			normalizationRule: @$('.bv_normalizationRule').val()
			hitEfficacyThreshold: parseFloat(@getTrimmedInput('.bv_hitEfficacyThreshold'))
			hitSDThreshold: parseFloat(@getTrimmedInput('.bv_hitSDThreshold'))
			assayVolume: parseFloat(@getTrimmedInput('.bv_assayVolume'))
			transferVolume: parseFloat(@getTrimmedInput('.bv_transferVolume'))
			dilutionFactor: parseFloat(@getTrimmedInput('.bv_dilutionFactor'))
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
		@attributeChanged()

	handleAutoHitSelectionChanged: =>
		autoHitSelection = @$('.bv_autoHitSelection').is(":checked")
		@model.set autoHitSelection: autoHitSelection
		if autoHitSelection
			@$('.bv_thresholdControls').show()
		else
			@$('.bv_thresholdControls').hide()
		@attributeChanged()

	handleVolumeTypeChanged: =>
		volumeType = @$("input[name='bv_volumeType']:checked").val()
		@model.set volumeType: volumeType
		if volumeType=="transfer"
			@$('.bv_dilutionFactor').attr('disabled','disabled')
			@$('.bv_transferVolume').removeAttr('disabled')
		else
			@$('.bv_transferVolume').attr('disabled','disabled')
			@$('.bv_dilutionFactor').removeAttr('disabled')
		@attributeChanged()

class window.AbstractUploadAndRunPrimaryAnalsysisController extends BasicFileValidateAndSaveController
#	See UploadAndRunPrimaryAnalsysisController for example required initialization function

	completeInitialization: ->
		@analysisParameterController.on 'valid', @handleMSFormValid
		@analysisParameterController.on 'invalid', @handleMSFormInvalid
		@analysisParameterController.on 'notifyError', @notificationController.addNotification
		@analysisParameterController.on 'clearErrors', @notificationController.clearAllNotificiations
		@analysisParameterController.on 'amDirty', =>
			@trigger 'amDirty'
		@analyzedPreviously = @options.analyzedPreviously
		@analysisParameterController.render()
		if @analyzedPreviously
			@$('.bv_save').html("Re-Analyze")
		@handleMSFormInvalid() #start invalid since file won't be loaded

	handleMSFormValid: =>
		if @parseFileUploaded
			@handleFormValid()

	handleMSFormInvalid: =>
		@handleFormInvalid()

	handleFormValid: ->
		if @analysisParameterController.isValid()
			super()

	parseAndSave: =>
		if @analyzedPreviously
			if !confirm("Re-analyzing the data will delete the previously saved results")
				return
		super()

	handleValidationReturnSuccess: (json) =>
		super(json)
		@analysisParameterController.disableAllInputs()

	handleSaveReturnSuccess: (json) =>
		super(json)
		@$('.bv_loadAnother').html("Re-Analyze")
		@trigger 'analysis-completed'

	showFileSelectPhase: ->
		super()
		if @analysisParameterController?
			@analysisParameterController.enableAllInputs()

	disableAll: ->
		@analysisParameterController.disableAllInputs()
		@$('.bv_htmlSummary').hide()
		@$('.bv_fileUploadWrapper').hide()
		@$('.bv_nextControlContainer').hide()
		@$('.bv_saveControlContainer').hide()
		@$('.bv_completeControlContainer').hide()
		@$('.bv_notifications').hide()

	enableAll: ->
		@analysisParameterController.enableAllInputs()
		@showFileSelectPhase()

	validateParseFile: =>
		@analysisParameterController.updateModel()
		unless !@analysisParameterController.isValid()
			@additionalData =
				inputParameters: JSON.stringify @analysisParameterController.model
				primaryAnalysisExperimentId: @experimentId
				testMode: false
			super()

	setUser: (user) ->
		@userName = user

	setExperimentId: (expId) ->
		@experimentId = expId

class window.UploadAndRunPrimaryAnalsysisController extends AbstractUploadAndRunPrimaryAnalsysisController
	initialize: ->
		@fileProcessorURL = "/api/primaryAnalysis/runPrimaryAnalysis"
		@errorOwnerName = 'UploadAndRunPrimaryAnalsysisController'
		@allowedFileTypes = ['zip']
		@maxFileSize = 200000000
		@loadReportFile = false
		super()
		@$('.bv_moduleTitle').html("Upload Data and Analyze")
		@analysisParameterController = new PrimaryScreenAnalysisParametersController
			model: @options.paramsFromExperiment
			el: @$('.bv_additionalValuesForm')
		@completeInitialization()

class window.PrimaryScreenAnalysisController extends Backbone.View
	template: _.template($("#PrimaryScreenAnalysisView").html())

	initialize: ->
		@model.on "sync", @handleExperimentSaved
		@model.getStatus().on 'change', @handleStatusChanged
		@dataAnalysisController = null
		$(@el).empty()
		$(@el).html @template()
		if @model.isNew()
			@setExperimentNotSaved()
		else
			@setupDataAnalysisController(@options.uploadAndRunControllerName)
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
			res = resultValue.get('clobValue')
			if res == ""
				@$('.bv_resultsContainer').hide()
			else
				@$('.bv_analysisResultsHTML').html(res)
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
			@setupDataAnalysisController(@options.uploadAndRunControllerName)
		@model.getStatus().on 'change', @handleStatusChanged
		@setExperimentSaved()

	handleAnalysisComplete: =>
		# Results are shown analysis controller, so redundant here until experiment is reloaded, which resets analysis controller
		@$('.bv_resultsContainer').hide()
		@trigger 'analysis-completed'

	handleStatusChanged: =>
		if @dataAnalysisController != null
			if @model.isEditable()
				@dataAnalysisController.enableAll()
			else
				@dataAnalysisController.disableAll()

	setupDataAnalysisController: (dacClassName) ->
		newArgs =
			el: @$('.bv_fileUploadWrapper')
			paramsFromExperiment:	@model.getAnalysisParameters()
			analyzedPreviously: @model.getAnalysisStatus().get('stringValue')!="not started"
		@dataAnalysisController = new window[dacClassName](newArgs)
		@dataAnalysisController.setUser(window.AppLaunchParams.loginUserName)
		@dataAnalysisController.setExperimentId(@model.id)
		@dataAnalysisController.on 'analysis-completed', @handleAnalysisComplete
		@dataAnalysisController.on 'amDirty', =>
			@trigger 'amDirty'
		@dataAnalysisController.on 'amClean', =>
			@trigger 'amClean'


# This wraps all the tabs
class window.AbstractPrimaryScreenExperimentController extends Backbone.View
	template: _.template($("#PrimaryScreenExperimentView").html())

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/experiments/codename/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) ->
							alert 'Could not get experiment for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get experiment for code in this URL, creating new one'
							else
								console.log "got an expt"
								#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
								exp = new PrimaryScreenExperiment json
#								exp = new PrimaryScreenExperiment json[0]
								exp.fixCompositeClasses()
								@model = exp
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new PrimaryScreenExperiment()

		console.log @model.get('codeName')
		$(@el).html @template()
		@model.on 'sync', @handleExperimentSaved
		@experimentBaseController = new ExperimentBaseController
			model: @model
			el: @$('.bv_experimentBase')
			protocolFilter: @protocolFilter
		@experimentBaseController.on 'amDirty', =>
			@trigger 'amDirty'
		@experimentBaseController.on 'amClean', =>
			@trigger 'amClean'
		@analysisController = new PrimaryScreenAnalysisController
			model: @model
			el: @$('.bv_primaryScreenDataAnalysis')
			uploadAndRunControllerName: @uploadAndRunControllerName
		@analysisController.on 'amDirty', =>
			@trigger 'amDirty'
		@analysisController.on 'amClean', =>
			@trigger 'amClean'
		#@setupModelFitController(@modelFitControllerName)
#		@analysisController.on 'analysis-completed', =>
#			@modelFitController.primaryAnalysisCompleted()
		@model.on "protocol_attributes_copied", @handleProtocolAttributesCopied
		@experimentBaseController.render()
		@analysisController.render()
		#@modelFitController.render()

	setupModelFitController: (modelFitControllerName) ->
		newArgs =
			model: @model
			el: @$('.bv_doseResponseAnalysis')
		@modelFitController = new window[modelFitControllerName](newArgs)
		@modelFitController.on 'amDirty', =>
			@trigger 'amDirty'
		@modelFitController.on 'amClean', =>
			@trigger 'amClean'

	handleExperimentSaved: =>
		@analysisController.render()

	handleProtocolAttributesCopied: =>
		@analysisController.render()

class window.PrimaryScreenExperimentController extends AbstractPrimaryScreenExperimentController
	uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
	modelFitControllerName: "DoseResponseAnalysisController"
	protocolFilter: "?protocolName=FLIPR"
	moduleLaunchName: "flipr_screening_assay"


class window.PrimaryAnalysisRead extends Backbone.Model
	defaults:
		readOrder: null
		readName: "unassigned"
		matchReadName: true

	validate: (attrs) ->
		errors = []
		if attrs.readOrder is "" or _.isNaN(attrs.readOrder)
			errors.push
				attribute: 'readOrder'
				message: "Read order must be a number"
		if attrs.readName is "unassigned" or attrs.readName is ""
			errors.push
				attribute: 'readName'
				message: "Read name must be assigned"
		if errors.length > 0
			return errors
		else
			return null








#class window.ReadSummaryController extends Backbone.View
#	template: _.template($("#ReadSummaryView").html())
#	tagName: "div"
#	className: "form-inline"
#	events:
#		"change .bv_readName": "attributeChanged"
#		"change .bv_matchReadName": "handleMatchReadNameChanged"
#		"click .bv_delete": "clear"
#
#	initialize: ->
#		@model.set readOrder: @options.readOrder
##		@model.set matchReadName: true
#		@model.on "destroy", @remove, @
#
#	render: =>
#		$(@el).empty()
#		$(@el).html @template(@model.attributes)
#		@$('.bv_readOrder').html @model.get('readOrder')
#		@setupReadNameSelect()
#
#
#
#		@
#
#	setupReadNameSelect: ->
#		@readNameList = new PickListList()
#		@readNameList.url = "/api/primaryAnalysis/runPrimaryAnalysis/readNameCodes"
#		@readNameList = new PickListSelectController
#			el: @$('.bv_readName')
#			collection: @readNameList
#			insertFirstOption: new PickList
#				code: "unassigned"
#				name: "Select Read Name"
#			selectedCode: @model.get('readName')
#
#
#	updateModel: =>
#		@model.set
#			readName: @$('.bv_readName').val()
#
#	handleMatchReadNameChanged: =>
#		matchReadName = @$('.bv_matchReadName').is(":checked")
#		@model.set matchReadName: matchReadName
#		if matchReadName
#			console.log "matchReadName checked"
#		else
#			console.log "matchReadName not checked"
#		@attributeChanged()
#
#	clear: =>
#		@model.destroy()


# TODO: implement matchReadName's function



#class window.ReadSummaryListController extends Backbone.View
#	template: _.template($("#ReadSummarylListView").html())
#	events:
#		"click .bv_addRead": "addOne"
#
#	initialize: ->
#	@nextReadNumber = 1
#
#	render: =>
#		$(@el).empty()
#		$(@el).html @template()
#
#		@
#
#	addOne: =>
#	newModel = new Backbone.Model()
#	@collection.add newModel
#	rslc = new ExperimentResultFilterTermController
#		model: newModel
#		filterOptions: @filterOptions
#		termName: @TERM_NUMBER_PREFIX+@nextTermNumber++
#	@$('.bv_filterTerms').append erftc.render().el
#	@on "updateFilterModels", erftc.updateModel

