class window.BulkLoadSampleTransfersController extends BasicFileValidateAndSaveController

	initialize: ->
		super()
		@fileProcessorURL = "/api/bulkLoadSampleTransfers"
		@errorOwnerName = 'BulkLoadSampleTransfersController'
		@$('.bv_moduleTitle').html('Load Sample Transfer Log')
		@$('.bv_additionalValuesForm').hide()
		@$('.bv_resultStatus').hide()


