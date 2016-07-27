class window.BasicFileValidateReviewAndSaveController extends BasicFileValidateAndSaveController
	template: _.template($("#BasicFileValidateReviewAndSaveView").html())

	events: ->
		return _.extend({},BasicFileValidateAndSaveController.prototype.events,{
			'click .bv_linkToDownloadAnnotatedFile' : 'handleClickLinkToDownloadAnnotatedFile'
		});

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

	handleClickLinkToDownloadAnnotatedFile: =>
		console.log "handleClickLinkToDownloadAnnotatedFile"
		# go back to the first screen after downloading the annotated file
		@loadAnother()