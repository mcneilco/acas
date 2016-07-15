class window.BasicFileValidateReviewAndSaveController extends BasicFileValidateAndSaveController
	template: _.template($("#BasicFileValidateReviewAndSaveView").html())

	initialize: ->
		console.log "BasicFileValidateReviewAndSaveController"
		super()

	handleValidationReturnSuccess: (json) =>
		console.log "handleValidationReturnSuccess"
		console.log json
		if json.results?.pathToIntermediateFile?
			console.log "in handleValidationRetrunSuccess"
			@$('.bv_linkToDownloadAnnotatedFile').prop("href", json.results.pathToIntermediateFile)

		super(json)