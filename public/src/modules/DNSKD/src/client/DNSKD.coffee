class window.DNSKDPrimaryScreenAnalysisParametersController extends AbstractParserFormController
	template: _.template($("#DNSKDPrimaryScreenAnalysisParametersView").html())
	autofillTemplate: _.template($("#DNSKDPrimaryScreenAnalysisParametersAutofillView").html())


	initialize: ->
		@errorOwnerName = 'DNSKDPrimaryScreenAnalysisParametersController'
		super()

	render: =>
		console.log "rendering DNSKDPrimaryScreenAnalysisParametersController"
		@$('.bv_autofillSection').empty()
		@$('.bv_autofillSection').html @autofillTemplate(@model.attributes)

		@


class window.DNSKDUploadAndRunPrimaryAnalsysisController extends AbstractUploadAndRunPrimaryAnalsysisController
	initialize: ->
		@fileProcessorURL = "/api/dnsKDAnalysis/runDNSKDPrimaryAnalysis"
		@errorOwnerName = 'DNSKDUploadAndRunPrimaryAnalsysisController'
		@allowedFileTypes = ['xls', 'xlxs']
		@maxFileSize = 200000000
		@loadReportFile = false
		super()
		@$('.bv_moduleTitle').html("Upload Data and Analyze")
		@analysisParameterController = new DNSKDPrimaryScreenAnalysisParametersController
			model: @options.paramsFromExperiment
			el: @$('.bv_additionalValuesForm')
		@completeInitialization()

class window.DNSKDPrimaryScreenExperimentController extends AbstractPrimaryScreenExperimentController
	uploadAndRunControllerName: "DNSKDUploadAndRunPrimaryAnalsysisController"
	modelFitControllerName: "DoseResponseAnalysisController"
	protocolFilter: "?protocolKind=KD"
	moduleLaunchName: "dnskd_screening_assay"
