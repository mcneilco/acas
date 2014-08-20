
class window.GenericDataParserController extends BasicFileValidateAndSaveController

	initialize: ->
		@fileProcessorURL = "/api/genericDataParser"
		@errorOwnerName = 'GenericDataParser'
		super()
		@$('.bv_moduleTitle').html('Simple Experiment Loader')
		@$('.bv_additionalValuesForm').hide()
		@$('.bv_resultStatus').hide()
