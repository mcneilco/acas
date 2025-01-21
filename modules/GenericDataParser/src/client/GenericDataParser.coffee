
class GenericDataParserController extends BasicFileValidateAndSaveController

	initialize: (options) ->
		@options = options
		@fileProcessorURL = "/api/genericDataParser"
		@errorOwnerName = 'GenericDataParser'
		@loadReportFile = true
		@loadImagesFile = true
		super(options)
		@$('.bv_moduleTitle').html("Simple #{window.conf.experiment.label} Loader")
