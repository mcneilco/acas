class window.BasicFileValidateAndSaveController extends Backbone.View
	notificationController: null
	parseFileController: null
	parseFileNameOnServer: ""
	parseFileUploaded: false
	filePassedValidation: false
	reportFileNameOnServer: null
	loadReportFile: false
	imagesFileNameOnServer: null
	loadImagesFile: false
	#TODO replace filePath with value from config file, or don't send path and let R find it
	filePath: ""
	additionalData: {experimentId: 1234, otherparam: "fred"}
	allowedFileTypes: ['xls', 'xlsx', 'csv']
	maxFileSize: 200000000
	attachReportFile: false
	attachImagesFile: false


	template: _.template($("#BasicFileValidateAndSaveView").html())

	events:
		'click .bv_next' : 'validateParseFile'
		'click .bv_save' : 'parseAndSave'
		'click .bv_back' : 'backToUpload'
		'click .bv_loadAnother' : 'loadAnother'
		'click .bv_attachReportFile': 'handleAttachReportFileChanged'
		'click .bv_attachImagesFile': 'handleAttachImagesFileChanged'


	initialize: ->
		$(@el).html @template()
		@notificationController = new LSNotificationController
			el: @$('.bv_notifications')
			showPreview: false

		@parseFileController = new LSFileInputController
			el: @$('.bv_parseFile')
			inputTitle: ''
			url: UtilityFunctions::getFileServiceURL()
			fieldIsRequired: false
			allowedFileTypes: @allowedFileTypes
			maxFileSize: @maxFileSize

		@parseFileController.on('fileInput:uploadComplete', @handleParseFileUploaded)
		@parseFileController.on('fileInput:removedFile', @handleParseFileRemoved)
		@parseFileController.render()

		if @loadReportFile
			@reportFileController = new LSFileInputController
				el: @$('.bv_reportFile')
				inputTitle: ''
				url: UtilityFunctions::getFileServiceURL()
				fieldIsRequired: false
				allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf']
			@reportFileController.on('fileInput:uploadComplete', @handleReportFileUploaded)
			@reportFileController.on('fileInput:removedFile', @handleReportFileRemoved)
			@reportFileController.render()
			@handleAttachReportFileChanged()
		else
			@$('.bv_reportFileFeature').hide()


		if @loadImagesFile
			@imagesFileController = new LSFileInputController
				el: @$('.bv_imagesFile')
				inputTitle: ''
				url: UtilityFunctions::getFileServiceURL()
				fieldIsRequired: false
				allowedFileTypes: ['zip']
			@imagesFileController.on('fileInput:uploadComplete', @handleImagesFileUploaded)
			@imagesFileController.on('fileInput:removedFile', @handleImagesFileRemoved)
			@imagesFileController.render()
			@handleAttachImagesFileChanged()
		else
			@$('.bv_imagesFileFeature').hide()


		@showFileSelectPhase()

	render: =>
		unless @parseFileUploaded
			@handleFormInvalid()

		@

	handleParseFileUploaded: (fileName) =>
		@parseFileUploaded = true
		@parseFileNameOnServer = @filePath+fileName
		@handleFormValid()
		@trigger 'amDirty'

	handleParseFileRemoved: =>
		@parseFileUploaded = false
		@parseFileNameOnServer = ""
		@notificationController.clearAllNotificiations()
		@handleFormInvalid()

	handleReportFileUploaded: (fileName) =>
		@reportFileNameOnServer = @filePath+fileName
		@trigger 'amDirty'

	handleReportFileRemoved: =>
		@reportFileNameOnServer = null


	handleImagesFileUploaded: (fileName) =>
		@imagesFileNameOnServer = @filePath+fileName
		@trigger 'amDirty'

	handleImagesFileRemoved: =>
		@imagesFileNameOnServer = null

	validateParseFile: =>
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



	parseAndSave: =>
		if @parseFileUploaded and @filePassedValidation
			@notificationController.clearAllNotificiations()
			@$('.bv_saveStatusDropDown').modal
				backdrop: "static"
			@$('.bv_saveStatusDropDown').modal("show")
			dataToPost = @prepareDataToPost(false)
			$.ajax
				type: 'POST'
				url: @fileProcessorURL,
				data: dataToPost
				success: @handleSaveReturnSuccess
				dataType: 'json',

	prepareDataToPost: (dryRun) ->
		user = @userName
		unless user?
			user = window.AppLaunchParams.loginUserName
		data =
			fileToParse: @parseFileNameOnServer
			reportFile: @reportFileNameOnServer
			imagesFile: @imagesFileNameOnServer
			dryRunMode: dryRun
			user: user
		$.extend(data,@additionalData)

		data

	handleValidationReturnSuccess: (json) =>
		summaryStr = "Validation Results: "
		if not json.hasError
			@filePassedValidation = true
			@parseFileController.lsFileChooser.filePassedServerValidation()
			summaryStr += "Success "
			if json.hasWarning then summaryStr += "but with warnings"
		else
			@filePassedValidation = false
			@parseFileController.lsFileChooser.fileFailedServerValidation()
			summaryStr += "Failed due to errors "
			@handleFormInvalid()
		@showFileUploadPhase()
		@$('.bv_resultStatus').html(summaryStr)
		@notificationController.addNotifications(@errorOwnerName, json.errorMessages)
		if json.results?.htmlSummary?
			@$('.bv_htmlSummary').html(json.results.htmlSummary)
		@$('.bv_validateStatusDropDown').modal("hide")
		if json.results.csvDataPreview?
			@showCSVPreview json.results.csvDataPreview

	handleSaveReturnSuccess: (json) =>
		summaryStr = "Upload Results: "
		if not json.hasError
			summaryStr += "Success "
		else
			summaryStr += "Failed due to errors "
		@notificationController.addNotifications(@errorOwnerName, json.errorMessages)
		@$('.bv_htmlSummary').html(json.results.htmlSummary)
		@newExperimentCode = json.results.experimentCode
		@showFileUploadCompletePhase()
		@$('.bv_resultStatus').html(summaryStr)
		@$('.bv_saveStatusDropDown').modal("hide")
		@trigger 'amClean'

	backToUpload: =>
		@showFileSelectPhase()

	loadAnother: =>
		#TODO This is bad style, but the LSFileInputController has no API for deleting and resetting
		@showFileSelectPhase()
		#TODO Why does this need a delay to work?
		fn = -> @$('.bv_deleteFile').click()
		setTimeout fn , 200


	showFileSelectPhase: ->
		@$('.bv_resultStatus').hide()
		@$('.bv_resultStatus').html("")
		@$('.bv_htmlSummary').hide()
		@$('.bv_htmlSummary').html('')
		@$('.bv_fileUploadWrapper').show()
		@$('.bv_nextControlContainer').show()
		@$('.bv_saveControlContainer').hide()
		@$('.bv_completeControlContainer').hide()
		@$('.bv_notifications').hide()
		@$('.bv_csvPreviewContainer').hide()

	handleAttachReportFileChanged: ->
		attachReportFile = @$('.bv_attachReportFile').is(":checked")
		if attachReportFile
			@$('.bv_reportFileWrapper').show()
		else
			@handleReportFileRemoved()
			@$('.bv_reportFileWrapper').hide()
			@reportFileController.render()

	handleAttachImagesFileChanged: ->
		attachImagesFile = @$('.bv_attachImagesFile').is(":checked")
		if attachImagesFile
			@$('.bv_imagesFileWrapper').show()
		else
			@handleImagesFileRemoved()
			@$('.bv_imagesFileWrapper').hide()
			@imagesFileController.render()


	showFileUploadPhase: ->
		@$('.bv_resultStatus').show()
		@$('.bv_htmlSummary').show()
		@$('.bv_fileUploadWrapper').hide()
		@$('.bv_nextControlContainer').hide()
		@$('.bv_saveControlContainer').show()
		@$('.bv_completeControlContainer').hide()
		@$('.bv_notifications').show()

	showFileUploadCompletePhase: ->
		@$('.bv_resultStatus').show()
		@$('.bv_htmlSummary').show()
		@$('.bv_csvPreviewContainer').hide()
		@$('.bv_fileUploadWrapper').hide()
		@$('.bv_nextControlContainer').hide()
		@$('.bv_saveControlContainer').hide()
		@$('.bv_completeControlContainer').show()
		@$('.bv_notifications').show()

	handleFormInvalid: =>
		@$(".bv_next").attr 'disabled', 'disabled'
		@$(".bv_save").attr 'disabled', 'disabled'
		@$('.bv_notifications').show()

	handleFormValid: =>
		@$(".bv_next").removeAttr 'disabled'
		@$(".bv_save").removeAttr 'disabled'

	showCSVPreview: (csv) ->
		@$('.csvPreviewTHead').empty()
		@$('.csvPreviewTBody').empty()

		csvRows = csv.split('\n')
		if csvRows.length > 1
			headCells = csvRows[0].split(',')
			if headCells.length > 1
				@$('.csvPreviewTHead').append "<tr></tr>"
				for val in  headCells
					@$('.csvPreviewTHead tr').append "<th>"+val+"</th>"
				for r in [1..csvRows.length-2]
					@$('.csvPreviewTBody').append "<tr></tr>"
					rowCells = csvRows[r].split(',')
					for val in rowCells
						@$('.csvPreviewTBody tr:last').append "<td>"+val+"</td>"
				@$('.bv_csvPreviewContainer').show()

	getNewExperimentCode: ->
		@newExperimentCode