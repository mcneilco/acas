
class window.BulkLoadSampleTransfersController extends BasicFileValidateAndSaveController

	initialize: ->
		BulkLoadSampleTransfersController.__super__.initialize.apply(@, arguments)
		@fileProcessorURL = @serverName + ":"+SeuratAddOns.configuration.portNumber+"/api/bulkLoadSampleTransfers"
		@errorOwnerName = 'BulkLoadSampleTransfersController'
		@$('.bv_moduleTitle').html('Load Sample Transfer Log')
