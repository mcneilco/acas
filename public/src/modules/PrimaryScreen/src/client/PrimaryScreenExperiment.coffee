class window.PrimaryScreenExperimentController extends Backbone.View
	template: _.template($("#PrimaryScreenExperimentView").html())
	events:
		"click .bv_save": "handleSaveClicked"

	initialize: ->
		unless @model?
			@model = new Experiment()

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

	handleSaveClicked: =>
		#TODO add validation code and keep this button disabled until saving is a good idea
		#console.log JSON.stringify @model
		@model.save()

	handleExperimentSaved: =>
		#console.log @model
		@analysisController.render()

	handleProtocolAttributesCopied: =>
		@analysisController.render()


class window.PrimaryScreenAnalysisController extends Backbone.View
	template: _.template($("#PrimaryScreenAnalysisView").html())
	events:
		"change .bv_hitThreshold": "handleHitThresholdChanged"

	initialize: ->
		@model.on "synced_and_repaired", @handleExperimentSaved

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@getControlStates()
		@$('.bv_hitThreshold').val(@getHitThreshold())
		@showExistingResults()
		if not @model.isNew()
			@handleExperimentSaved()
		@

	getControlStates: ->
		@controlStates = @model.get('lsStates').getStatesByTypeAndKind("metadata", "experiment controls")

	getHitThreshold: ->
		value = @model.get('lsStates').getStateValueByTypeAndKind "metadata", "experiment analysis parameters", "numericValue", "active efficacy threshold"
		desc = ""
		if value != null
			desc = value.get('numericValue')
		desc

	showExistingResults: ->
		analysisStatus = @model.get('lsStates').getStateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "analysis status"
		if analysisStatus != null
			@analysisStatus = analysisStatus.get('stringValue')
			@$('.bv_analysisStatus').html(@analysisStatus)
		else
			@analysisStatus = "not started"
		resultValue = @model.get('lsStates').getStateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "analysis result html"
		if resultValue != null
			@$('.bv_analysisResultsHTML').html(resultValue.get('clobValue'))

	handleHitThresholdChanged: =>
		value = @model.get('lsStates').getStateValueByTypeAndKind "metadata", "experiment analysis parameters", "numericValue", "active efficacy threshold"
		value.set numericValue: parseFloat($.trim(@$('.bv_hitThreshold').val()))

	handleExperimentSaved: =>
		if @analysisStatus is "complete"
			@$('.bv_fileUploadWrapper').html("")
		else
			@dataAnalysisController = new UploadAndRunPrimaryAnalsysisController
				el: @$('.bv_fileUploadWrapper')
			@dataAnalysisController.setUser(@model.get('recordedBy'))
			@dataAnalysisController.setExperimentId(@model.id)

class window.UploadAndRunPrimaryAnalsysisController extends BasicFileValidateAndSaveController
	initialize: ->
		UploadAndRunPrimaryAnalsysisController.__super__.initialize.apply(@, arguments)
		@fileProcessorURL = "/api/primaryAnalysis/runPrimaryAnalysis"
		@errorOwnerName = 'UploadAndRunPrimaryAnalsysisController'
		@$('.bv_moduleTitle').html("Upload Data and Analyze")

	setUser: (user) ->
		@userName = user

	setExperimentId: (expId) ->
		@additionalData =
			primaryAnalysisExperimentId: expId
			testMode: false

