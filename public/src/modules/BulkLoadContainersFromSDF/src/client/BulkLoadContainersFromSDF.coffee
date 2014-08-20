
class window.BulkLoadContainersFromSDFController extends BasicFileValidateAndSaveController

	initialize: ->
    @fileProcessorURL = "/api/bulkLoadContainersFromSDF"
    @errorOwnerName = 'BulkLoadContainersFromSDFController'
    @allowedFileTypes = ['sdf', 'csv']
    @loadReportFile = false
    super()
    @$('.bv_moduleTitle').html('Load Containers From SDF')
    @$('.bv_additionalValuesForm').hide()
    @$('.bv_resultStatus').hide()

