
class window.GenericDataParserController extends BasicFileValidateAndSaveController

	initialize: ->
		@loadReportFile = true
		@fileProcessorURL = "/api/genericDataParser"
		@errorOwnerName = 'GenericDataParser'
		super()
		@$('.bv_moduleTitle').html('Simple Experiment Loader')

