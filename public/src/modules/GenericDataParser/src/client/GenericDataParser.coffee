
class window.GenericDataParserController extends BasicFileValidateAndSaveController

	initialize: ->
		@fileProcessorURL = "/api/genericDataParser"
		@errorOwnerName = 'GenericDataParser'
		@loadReportFile = true
		@loadImagesFile = true
		super()
		@$('.bv_moduleTitle').html('Simple Experiment Loader')
