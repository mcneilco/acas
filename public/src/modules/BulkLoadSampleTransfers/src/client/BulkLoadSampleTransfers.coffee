
class window.BulkLoadSampleTransfersController extends BasicFileValidateAndSaveController

	initialize: ->
		super()
		@fileProcessorURL = "/api/bulkLoadSampleTransfers"
		@errorOwnerName = 'BulkLoadSampleTransfersController'
		@$('.bv_moduleTitle').html('Load Sample Transfer Log')
