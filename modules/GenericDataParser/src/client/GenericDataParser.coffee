
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
		filesUploaded = @$(".files tr.template-download").length

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
		else
			# if there are multiple files show warning, clear the table, bring back the upload button
			@$(".bv_multipleFileWarning").show()
			@$('.bv_manualFileSelect').css("display", "block")
			@$(".files").html ""
