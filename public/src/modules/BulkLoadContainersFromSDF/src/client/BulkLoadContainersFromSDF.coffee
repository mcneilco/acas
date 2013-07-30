
class window.BulkLoadContainersFromSDFController extends BasicFileValidateAndSaveController

	initialize: ->
		super()
		@fileProcessorURL = "/api/bulkLoadContainersFromSDF"
		@errorOwnerName = 'BulkLoadContainersFromSDFController'
		@$('.bv_moduleTitle').html('Load Containers From SDF')
