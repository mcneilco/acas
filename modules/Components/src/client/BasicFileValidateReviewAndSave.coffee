class BasicFileValidateReviewAndSaveController extends BasicFileValidateAndSaveController
	template: _.template($("#BasicFileValidateReviewAndSaveView").html())


	initialize: (options) ->
		@options = options
		console.log "BasicFileValidateReviewAndSaveController"
		super(options)

	handleValidationReturnSuccess: (json) =>
		console.log "handleValidationReturnSuccess"
		console.log json
		if json.results?.pathToIntermediateFile?
			console.log "in handleValidationRetrunSuccess"
			@$('.bv_linkToDownloadAnnotatedFile').prop("href", json.results.pathToIntermediateFile)

		super(json)

	handleSaveReturnSuccess: (json) =>

		console.log "handleValidationReturnSuccess"
		console.log json
		if json.results?.pathToInvalidsFile?
			console.log "in handleValidationRetrunSuccess"
			@$('.bv_linkToDownloadInvalidsFile').prop("href", json.results.pathToInvalidsFile)
			@$('.bv_linkToDownloadInvalidsFile').removeClass "hide"


		super(json)

	loadAnother: =>
		@$(".bv_linkToDownloadInvalidsFile").addClass "hide"
		super()