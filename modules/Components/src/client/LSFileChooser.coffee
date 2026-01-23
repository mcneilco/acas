class LSFileChooserModel extends Backbone.Model
	defaults:
		fileName: ''
		fileNameOnServer: ''
		fileType: ''
		
	initialize: (options) ->
		@options = options
		_.bindAll(@,
			'isDirty')

	
	isDirty: ->
		return @.get('fileNameOnServer') == ''

class LSFileModelCollection extends Backbone.Collection
	model: LSFileChooserModel


class LSFileChooserController extends Backbone.View
	allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf']
	dropZoneClassId: "fileupload"
	allowMultipleFiles: false
	maxNumberOfFiles: 3
	autoUpload: true
	maxFileSize: 200000000
	listOfFileModels: []
	currentNumberOfFiles : 0
	requiresValidation: true
	hideDelete: false #for hiding delete button after successful file upload
	
	initialize: (options) ->
		@options = options
		_.bindAll(@,
			'render',
			'handleDragOverDocument', 
			'handleDragLeaveDocument',
			'handleDeleteFileUIChanges',
			'handleFileAddedEvent',
			'fileUploadComplete',
			'fileUploadFailed',
			'handleFileValidationFailed',
			'canAcceptAnotherFile',
			'filePassedServerValidation')

		self = @
		$(document).bind('dragover', (e) ->
			self.handleDragOverDocument()
		)
		$(document).bind('drop dragleave', (e) ->
			self.handleDragLeaveDocument()
		)
		if @options.allowedFileTypes?
			@allowedFileTypes = @options.allowedFileTypes
		if @options.defaultMessage?
			@defaultMessage = @options.defaultMessage
		if @options.dragOverMessage?
			@dragOverMessage = @options.dragOverMessage
		if @options.dropZoneClassId?
			@dropZoneClassId = @options.dropZoneClassId
		if @options.allowMultipleFiles?
			@allowMultipleFiles = @options.allowMultipleFiles
		if @options.maxNumberOfFiles?
			@maxNumberOfFiles = @options.maxNumberOfFiles
		if @options.url?
			@url = @options.url
		if @options.autoUpload?
			@autoUpload = @options.autoUpload
		if @options.maxFileSize?
			@maxFileSize = @options.maxFileSize
		if @options.requiresValidation?
			@requiresValidation = @options.requiresValidation
		if @options.hideDelete?
			@hideDelete = @options.hideDelete
		@currentNumberOfFiles = 0

	events:
		#'click .bv_deleteFile': 'handleDeleteFileUIChanges'
		'click .bv_deleteFile': 'handleFileValueChanged'
		'click .bv_cancelFile': 'handleDeleteFileUIChanges'
	
	canAcceptAnotherFile: ->
		return @currentNumberOfFiles < @maxNumberOfFiles
	
	handleDragOverDocument: ->
		if @canAcceptAnotherFile()
			@$('.bv_manualFileSelect').removeClass('in').addClass('hide')
			@$('.' + @.options.dropZoneClassId).addClass('fade in')    
	
	handleDragLeaveDocument: ->
		if !@mouseIsInDropField
			if @canAcceptAnotherFile()
				@$('.' + @.options.dropZoneClassId).removeClass('in')
				@$('.bv_manualFileSelect').removeClass('hide').addClass('fade in')

	handleFileValueChanged: ->
		@trigger 'fileDeleted'

	handleDeleteFileUIChanges: ->
		@currentNumberOfFiles--
		# Ensure counter doesn't go below zero
		if @currentNumberOfFiles < 0
			@currentNumberOfFiles = 0
		@$('.bv_manualFileSelect').removeClass('hide').addClass('fade in')
		this.trigger('fileUploader:removedFile')
		
	handleFileAddedEvent: (e, data) ->
		@currentNumberOfFiles++
		unless @canAcceptAnotherFile()
			@$('.bv_manualFileSelect').removeClass('in').addClass('hide')

	fileUploadComplete:(e, data) ->
		self = @
		# this is a work around for hiding the delete button after files are uploaded
		unless @options.hideDelete
			@$('.delete').addClass('fade in')
		_.each(data.result.files, (result) ->
			self.listOfFileModels.push(new LSFileChooserModel({fileNameOnServer: result.name}))
		)
		this.trigger('fileUploader:uploadComplete', data.result.files[0])
		if (@requiresValidation)
			@$('.dv_validatingProgressBar').addClass('fade in')
		@delegateEvents()

		#window.notificationController.addInfo("file uploaded!")
	
	fileUploadFailed: (e, data) ->
		this.trigger('fileUploader:uploadFailed')
		window.notificationController.addError("file upload failed!")
	
	filePassedServerValidation: ->
		@$('.bv_status').addClass('glyphicon glyphicon-ok-sign')
		#window.notificationController.addInfo("file is valid!")
		@$('.dv_validatingProgressBar').removeClass('in')
		
	fileFailedServerValidation: ->
		@$('.bv_status').addClass('glyphicon glyphicon-exclamation-sign')
		#window.notificationController.addError("file is invalid!")
		@$('.dv_validatingProgressBar').removeClass('in')
	
	handleFileValidationFailed: (e, data) ->
		# Re-render template to show error message
		@$('.files').empty()
		@$('.fileupload').fileupload('add', data)
		# Decrement counter for failed file and show browse button if space available
		@currentNumberOfFiles--
		if @canAcceptAnotherFile()
			@$('.bv_manualFileSelect').removeClass('hide').addClass('fade in')

	render: ->
		self = @
		$(@el).html ""
		template = _.template($("#LSFileChooserView").html())
		$(@el).html template({uploadUrl: @uploadUrl, paramname: @paramname, dragOverMessage: @dragOverMessage, dropZoneClassId: @dropZoneClassId, allowMultipleFiles: @allowMultipleFiles})
		
		@$('.bv_fileDropField').html(@defaultMessage)
		@$('.fileupload').fileupload()
		@$('.fileupload').fileupload('option', {
			url: self.url,
			maxFileSize: self.maxFileSize,
			#acceptFileTypes: /(\.|\/)(xls|txt|xlsx|csv|sdf|zip)$/i,
			acceptFileTypes: RegExp('(\\.|\\/)(' + @allowedFileTypes.join('|') + ')$', 'i')
			autoUpload: self.autoUpload
			dropZone:  @$('.' + self.dropZoneClassId)
			maxNumberOfFiles: @maxNumberOfFiles
			progressall: (e, data) ->
				progress = parseInt(data.loaded / data.total * 100, 10)
				$('.progress .progress-bar').css('width', progress + '%')
		})
		
		@$('.' + @dropZoneClassId).bind('mouseover', (e) -> @mouseIsInDropField = true)
		@$('.' + @dropZoneClassId).bind('mouseout', (e) -> @mouseIsInDropField = false)
		@$('.' + @dropZoneClassId).bind('dragover', (e) -> self.handleDragOverDocument())
		@$('.' + @dropZoneClassId).bind('dragleave', (e) -> self.handleDragLeaveDocument())
		
		@$('.fileupload').bind('fileuploaddrop', @handleDragLeaveDocument)
		@$('.fileupload').bind('fileuploadadd', @handleFileAddedEvent)
		#@$('.fileupload').bind('fileuploadfailed', @handleFileUploadFailed)
		@$('.fileupload').bind('fileuploadcompleted', @fileUploadComplete)
		@$('.fileupload').bind('fileUploadFailed', @fileUploadComplete)
		@$('.fileupload').bind('fileuploaddestroyed', @handleDeleteFileUIChanges)
		#@$('.fileupload').bind('fileuploadstopped', @handleDeleteFileUIChanges)
		
		# Handle file validation failures (e.g., wrong file type)
		@$('.fileupload').bind('fileuploadprocessfail', @handleFileValidationFailed)

		if @maxNumberOfFiles == 1
			@$(".fileinput-button input").attr("multiple", false)

		
