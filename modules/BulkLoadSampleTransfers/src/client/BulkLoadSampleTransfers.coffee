class window.BulkLoadSampleTransfersController extends BasicFileValidateAndSaveController

	initialize: ->
		@allowedFileTypes = ['zip', 'csv']
		super()
		@fileProcessorURL = "/api/bulkLoadSampleTransfers"
		@errorOwnerName = 'BulkLoadSampleTransfersController'
		@$('.bv_moduleTitle').html('Load Sample Transfer Log')


