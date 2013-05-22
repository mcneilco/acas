
class window.GenericDataParserController extends BasicFileValidateAndSaveController

	initialize: ->
		BulkLoadContainersFromSDFController.__super__.initialize.apply(@, arguments)
		@fileProcessorURL = @serverName + ":"+SeuratAddOns.configuration.portNumber+"/api/genericDataParser"
		@errorOwnerName = 'GenericDataParser'
		@$('.bv_moduleTitle').html('Generic Data Parser')

