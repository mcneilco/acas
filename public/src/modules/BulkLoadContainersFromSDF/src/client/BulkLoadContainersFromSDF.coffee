
class window.BulkLoadContainersFromSDFController extends BasicFileValidateAndSaveController

	initialize: ->
    @fileProcessorURL = "/api/bulkLoadContainersFromSDF"
    @errorOwnerName = 'BulkLoadContainersFromSDFController'
    @allowedFileTypes = ['sdf']
    @loadReportFile = false
    super()
    @$('.bv_moduleTitle').html('Load Containers From SDF')
