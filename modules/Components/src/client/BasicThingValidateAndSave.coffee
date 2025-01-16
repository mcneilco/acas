class BasicThingValidateAndSaveController extends Backbone.View
	notificationController: null
	additionalData: {}

	template: _.template($("#BasicThingValidateAndSaveView").html())

	events:
		'click .bv_next' : 'validateData'
		'click .bv_save' : 'validateAndSave'
		'click .bv_back' : 'back'
		'click .bv_loadAnother' : 'loadAnother'

	initialize: (options) ->
		@options = options
		$(@el).html @template()
		@notificationController = new LSNotificationController
			el: @$('.bv_notifications')
			showPreview: false
		@showInputPhase()

	render: =>
		@

	validateData: =>
		@notificationController.clearAllNotificiations()
		@$('.bv_validateStatusDropDown').modal
			backdrop: "static"
		@$('.bv_validateStatusDropDown').modal "show"
		dataToPost = @prepareDataToPost(true)
		$.ajax
			type: 'POST'
			url: @registrationURL
			data: JSON.stringify(dataToPost)
			success: @handleValidationReturnSuccess
			error: @handleValidationReturnError
			dataType: 'json',
			contentType: 'application/json'

	validateAndSave: =>
		@notificationController.clearAllNotificiations()
		@$('.bv_saveStatusDropDown').modal
			backdrop: "static"
		@$('.bv_saveStatusDropDown').modal("show")
		dataToPost = @prepareDataToPost(false)
		$.ajax
			type: 'POST'
			url: @registrationURL,
			data: JSON.stringify(dataToPost)
			success: @handleSaveReturnSuccess
			error: @handleSaveReturnError
			dataType: 'json',
			contentType: 'application/json'

	prepareDataToPost: (dryRun) ->
		user = @userName
		unless user?
			user = window.AppLaunchParams.loginUserName
		data =
			user: user
			dryRunMode: dryRun
		$.extend(data,@additionalData)

		data

	handleValidationReturnSuccess: (json) =>
		summaryStr = "Validation Results: "
		if not json.hasError
			@passedValidation = true
			summaryStr += "Success "
			if json.hasWarning then summaryStr += "but with warnings"
		else
			@passedValidation = false
			summaryStr += "Failed due to errors "
			@handleFormInvalid()
		@showValidatingPhase()
		@$('.bv_resultStatus').html(summaryStr)
		@notificationController.addNotifications(@errorOwnerName, json.errorMessages)
		if json.results?.htmlSummary?
			@$('.bv_htmlSummary').html(json.results.htmlSummary)
		if json.results?.preProcessorHTMLSummary?
			@showPreProcessorHTMLSUmmary json.results.preProcessorHTMLSummary
		@$('.bv_validateStatusDropDown').modal("hide")
		if json.results?.csvDataPreview?
			@showCSVPreview json.results.csvDataPreview


	handleValidationReturnError: (xhr, textStatus, error) =>
		summaryStr = "Validation Results: "
		@passedValidation = false
		summaryStr += "Failed due to errors "
		@handleFormInvalid()
		@showValidatingPhase()
		@$('.bv_resultStatus').html(summaryStr)
		@notificationController.addNotifications(@errorOwnerName, [{"errorLevel":"error", "message":error}])
		@$('.bv_htmlSummary').html("#{error}<br>#{xhr.responseText}")
		@$('.bv_validateStatusDropDown').modal("hide")

	handleSaveReturnSuccess: (json) =>
		summaryStr = "Upload Results: "
		if not json.hasError
			summaryStr += "Success "
		else
			summaryStr += "Failed due to errors "
		@notificationController.addNotifications(@errorOwnerName, json.errorMessages)
		@$('.bv_htmlSummary').html(json.results.htmlSummary)
		@newExperimentCode = json.results.experimentCode
		@showValidationCompletePhase()
		if json.results?.preProcessorHTMLSummary?
			@showPreProcessorHTMLSUmmary json.results.preProcessorHTMLSummary
		@$('.bv_resultStatus').html(summaryStr)
		@$('.bv_saveStatusDropDown').modal("hide")
		@trigger 'amClean'

	handleSaveReturnError: (xhr, textStatus, error) =>
		summaryStr += "Failed due to errors "
		@notificationController.addNotifications(@errorOwnerName, [{"errorLevel":"error", "message":error}])
		@$('.bv_htmlSummary').html("#{error}<br>#{xhr.responseText}")
		@showValidationCompletePhase()
		@$('.bv_resultStatus').html(summaryStr)
		@$('.bv_saveStatusDropDown').modal("hide")
		@trigger 'amClean'

	back: =>
		@showInputPhase()

	loadAnother: =>
		#TODO This is bad style, but the LSFileInputController has no API for deleting and resetting
		@showInputPhase()
		#TODO Why does this need a delay to work?
		fn = -> @$('.bv_deleteFile').click()
		setTimeout fn , 200

	showInputPhase: ->
		@$('.bv_resultStatus').hide()
		@$('.bv_resultStatus').html("")
		@$('.bv_htmlSummary').hide()
		@$('.bv_htmlSummary').html('')
		@$('.bv_nextControlContainer').show()
		@$('.bv_saveControlContainer').hide()
		@$('.bv_completeControlContainer').hide()
		@$('.bv_notifications').hide()
		@$('.bv_csvPreviewContainer').hide()
		@$('.bv_preProcessorHTMLSummary').hide()
		@$('.bv_preProcessorHTMLSummary').hide('')

	showValidatingPhase: ->
		@$('.bv_resultStatus').show()
		@$('.bv_htmlSummary').show()
		@$('.bv_nextControlContainer').hide()
		@$('.bv_saveControlContainer').show()
		@$('.bv_completeControlContainer').hide()
		@$('.bv_notifications').show()

	showValidationCompletePhase: ->
		@$('.bv_resultStatus').show()
		@$('.bv_htmlSummary').show()
		@$('.bv_csvPreviewContainer').hide()
		@$('.bv_preProcessorHTMLSummary').hide()
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

	showPreProcessorHTMLSUmmary: (preProcessorSummaryHTML) ->
		console.log "showing here"
		@$('.bv_preProcessorHTMLSummary').html(preProcessorSummaryHTML)
		@$('.bv_preProcessorHTMLSummary').show()

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
