
class window.BulkLoadContainersFromSDFController extends BasicFileValidateAndSaveController

	initialize: ->
		BulkLoadContainersFromSDFController.__super__.initialize.apply(@, arguments)
		@fileProcessorURL = @serverName + ":"+SeuratAddOns.configuration.portNumber+"/api/bulkLoadContainersFromSDF"
		@errorOwnerName = 'BulkLoadContainersFromSDFController'
		@$('.bv_moduleTitle').html('Load Containers From SDF')
