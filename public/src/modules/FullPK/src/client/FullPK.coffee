class window.FullPKParserController extends BasicFileValidateAndSaveController

	initialize: ->
		@fileProcessorURL = "/api/genericDataParser"
		@errorOwnerName = 'FullPKParser'
		@loadReportFile = true
		super()
		@$('.bv_moduleTitle').html('Full PK Experiment Loader')

