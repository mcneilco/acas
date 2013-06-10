class window.BasicFileValidateAndSaveController extends Backbone.View
	notificationController: null
	parseFileController: null
	parseFileNameOnServer: ""
	parseFileUploaded: false
	filePassedValidation: false
	reportFileNameOnServer: null
	loadReportFile: false
	filePath: "serverOnlyModules/blueimp-file-upload-node/public/files/"
	additionalData: {experimentId: 1234, otherparam: "fred"}

	template: _.template($("#BasicFileValidateAndSaveView").html())

	events:
		'click .bv_next' : 'validateParseFile'
		'click .bv_save' : 'parseAndSave'
		'click .bv_back' : 'backToUpload'
		'click .bv_loadAnother' : 'loadAnother'

	initialize: ->
		$(@el).html @template()
		@notificationController = new LSNotificationController
			el: @$('.bv_notifications')
			showPreview: false

		@parseFileController = new LSFileInputController
			el: @$('.bv_parseFile')
			inputTitle: ''
			url: window.configurationNode.serverConfigurationParams.configuration.fileServiceURL
			fieldIsRequired: false
		@parseFileController.on('fileInput:uploadComplete', @handleParseFileUploaded)
		@parseFileController.on('fileInput:removedFile', @handleParseFileRemoved)
		@parseFileController.render()

		if @loadReportFile
			@reportFileController = new LSFileInputController
				el: @$('.bv_reportFile')
				inputTitle: ''
				url: window.configurationNode.serverConfigurationParams.configuration.fileServiceURL
				fieldIsRequired: false
			@reportFileController.on('fileInput:uploadComplete', @handleReportFileUploaded)
			@reportFileController.on('fileInput:removedFile', @handleReportFileRemoved)
			@reportFileController.render()
			@$('.bv_reportFileWrapper').show()

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

	validateParseFile: =>
		if @parseFileUploaded and not @$(".bv_next").attr('disabled')
			@notificationController.clearAllNotificiations()

			@$('.bv_validateStatusDropDown').modal
				backdrop: "static"
			@$('.bv_validateStatusDropDown').modal "show"
			$.ajax
				type: 'POST'
				url: @fileProcessorURL
				data: @prepareDataToPost(true)
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
			$.ajax
				type: 'POST'
				url: @fileProcessorURL,
				data: @prepareDataToPost(false)
				success: @handleSaveReturnSuccess
				dataType: 'json',

	prepareDataToPost: (dryRun) ->
		user = @userName
		unless user?
			user = window.AppLaunchParams.loginUserName
		data =
			fileToParse: @parseFileNameOnServer
			reportFile: @reportFileNameOnServer
			dryRunMode: dryRun
			user: user
		$.extend(data,@additionalData)

		data

	handleValidationReturnSuccess: (json) =>
		console.log json
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

	handleSaveReturnSuccess: (json) =>
		summaryStr = "Upload Results: "
		if not json.hasError
			summaryStr += "Success "
		else
			summaryStr += "Failed due to errors "
		@notificationController.addNotifications(@errorOwnerName, json.errorMessages)
		@$('.bv_htmlSummary').html(json.results.htmlSummary)
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
		@$('.bv_resultStatus').html("")
		@$('.bv_htmlSummary').hide()
		@$('.bv_htmlSummary').html('')
		@$('.bv_fileUploadWrapper').show()
		@$('.bv_nextControlContainer').show()
		@$('.bv_saveControlContainer').hide()
		@$('.bv_completeControlContainer').hide()
		@$('.bv_notifications').hide()

	showFileUploadPhase: ->
		@$('.bv_htmlSummary').show()
		@$('.bv_fileUploadWrapper').hide()
		@$('.bv_nextControlContainer').hide()
		@$('.bv_saveControlContainer').show()
		@$('.bv_completeControlContainer').hide()
		@$('.bv_notifications').show()

	showFileUploadCompletePhase: ->
		@$('.bv_htmlSummary').show()
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
