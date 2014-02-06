class window.LSFileChooserModel extends Backbone.Model
	defaults:
		fileName: ''
		fileNameOnServer: ''
		fileType: ''
		
	initialize: ->
		_.bindAll(@,
			'isDirty')

	
	isDirty: ->
		return @.get('fileNameOnServer') == ''

class window.LSFileModelCollection extends Backbone.Collection
	model: LSFileChooserModel


class window.LSFileChooserController extends Backbone.View
	allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf']
	dropZoneClassId: "fileupload"
	allowMultipleFiles: false
	maxNumberOfFiles: 3
	autoUpload: true
	maxFileSize: 200000000
	listOfFileModels: []
	currentNumberOfFiles : 0
	requiresValidation: true
	
	initialize: ->
		_.bindAll(@,
			'render',
			'handleDragOverDocument', 
			'handleDragLeaveDocument',
			'handleDeleteFileUIChanges',
			'handleFileAddedEvent',
			'fileUploadComplete',
			'fileUploadFailed',
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
		@currentNumberOfFiles = 0

	events:
		#'click .bv_deleteFile': 'handleDeleteFileUIChanges'
		'click .bv_cancelFile': 'handleDeleteFileUIChanges'
	
	canAcceptAnotherFile: ->
		return @currentNumberOfFiles < @maxNumberOfFiles
	
	handleDragOverDocument: ->
		if @canAcceptAnotherFile()
			@$('.bv_manualFileSelect').hide()
			@$('.' + @.options.dropZoneClassId).show()    
	
	handleDragLeaveDocument: ->
		if !@mouseIsInDropField
			if @canAcceptAnotherFile()
				@$('.' + @.options.dropZoneClassId).hide()
				@$('.bv_manualFileSelect').show()
	
	handleDeleteFileUIChanges: ->
		@$('.bv_manualFileSelect').show("slide")
		@currentNumberOfFiles--
		this.trigger('fileUploader:removedFile')
		
	handleFileAddedEvent: (e, data) ->
		@currentNumberOfFiles++
		unless @canAcceptAnotherFile()
			@$('.bv_manualFileSelect').hide("slide")

	fileUploadComplete:(e, data) ->
		self = @
		_.each(data.result, (result) ->
			self.listOfFileModels.push(new LSFileChooserModel({fileNameOnServer: result.name}))
		)
		this.trigger('fileUploader:uploadComplete', data.result[0].name)
		if (@requiresValidation)
			@$('.dv_validatingProgressBar').show("slide")
		@delegateEvents()

		#window.notificationController.addInfo("file uploaded!")
	
	fileUploadFailed: (e, data) ->
		this.trigger('fileUploader:uploadFailed')
		window.notificationController.addError("file upload failed!")
	
	filePassedServerValidation: ->
		@$('.bv_status').addClass('icon-ok-sign')
		#window.notificationController.addInfo("file is valid!")
		@$('.dv_validatingProgressBar').hide("slide")
		
	fileFailedServerValidation: ->
		@$('.bv_status').addClass('icon-exclamation-sign')
		#window.notificationController.addError("file is invalid!")
		@$('.dv_validatingProgressBar').hide("slide")

	render: ->
		self = @
		$(@el).html ""
		template = _.template($("#LSFileChooserView").html(), {uploadUrl: @uploadUrl, paramname: @paramname, dragOverMessage: @dragOverMessage, dropZoneClassId: @dropZoneClassId, allowMultipleFiles: @allowMultipleFiles})
		$(@el).html template
		
		@$('.bv_fileDropField').html(@defaultMessage)
		@$('.fileupload').fileupload()
		@$('.fileupload').fileupload('option', {
			url: self.url,
			maxFileSize: self.maxFileSize,
			#acceptFileTypes: /(\.|\/)(xls|txt|xlsx|csv|sdf|zip)$/i,
			acceptFileTypes: RegExp('(\\.|\\/)(' + @allowedFileTypes.join('|') + ')$', 'i')
			autoUpload: self.autoUpload
			dropZone:  @$('.' + self.dropZoneClassId)
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

		
