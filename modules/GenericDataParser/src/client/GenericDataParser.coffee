
class GenericDataParserController extends BasicFileValidateAndSaveController

	initialize: ->
		@fileProcessorURL = "/api/genericDataParser"
		@errorOwnerName = 'GenericDataParser'
		@loadReportFile = true
		@loadImagesFile = true
		super()
		@$('.bv_moduleTitle').html("Simple #{window.conf.experiment.label} Loader")

	validateParseFile: =>
		
		# check the number of files uploaded by checking the number of rows in the table of uploaded files
		# if it is more than one, we want to block the validation 
		# it is possible for the user to upload more than one via drag and drop even if the button only allows one upload
		filesUploaded = @$(".files tr").length

		if filesUploaded == 1
			if @parseFileUploaded and not @$(".bv_next").attr('disabled')
				@notificationController.clearAllNotificiations()
				@$('.bv_validateStatusDropDown').modal
					backdrop: "static"
				@$('.bv_validateStatusDropDown').modal "show"
				dataToPost = @prepareDataToPost(true)
				$.ajax
					type: 'POST'
					url: @fileProcessorURL
					data: dataToPost
					success: @handleValidationReturnSuccess
					error: (err) =>
						@$('.bv_validateStatusDropDown').modal("hide")
					dataType: 'json',

