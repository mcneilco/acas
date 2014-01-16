class window.LSFileInputController extends Backbone.View
	
	fieldIsRequired: true
	inputTitle: "A title should go here"
	lsFileChooser: null
	requiresValidation: false
	maxNumberOfFiles: 1
	maxFileSize: 200000000
	defaultMessage: "Drop a file here to upload it"
	dragOverMessage: "Drop the file here to upload it"
	nameOnServer: ""
	allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg']

	
	initialize: ->
		_.bindAll(@,
			'render',
			'handleFileChooserUploadComplete',
			'handleFileChooserUploadFailed',
			'handleFileChooserRemovedFile')
		if @options.inputTitle?
			@inputTitle = @.options.inputTitle
		if @options.fieldIsRequired?
			@fieldIsRequired = @.options.fieldIsRequired
		if @options.requiresValidation?
			@requiresValidation = @.options.requiresValidation
		if @options.maxNumberOfFiles?
			@maxNumberOfFiles = @.options.maxNumberOfFiles
		if @options.url?
			@url = @.options.url
		if @options.defaultMessage?
			@defaultMessage = @.options.defaultMessage
		if @options.dragOverMessage?
			@dragOverMessage = @.options.dragOverMessage
		if @options.allowedFileTypes?
			@allowedFileTypes = @options.allowedFileTypes
		if @options.maxFileSize?
			@maxFileSize = @options.maxFileSize

	handleFileChooserUploadComplete: (nameOnServer) ->
		#@$('.bv_status').addClass('icon-ok-sign')
		#@lsFileChooser.filePassedServerValidation()
		@nameOnServer = nameOnServer
		@trigger('fileInput:uploadComplete', nameOnServer)
		
	handleFileChooserUploadFailed: ->
		@$('.bv_status').addClass('icon-exclamation-sign')
	
	handleFileChooserRemovedFile: ->
		@trigger('fileInput:removedFile')

	
	render: ->
		self = @
		$(@el).html ""
		template = _.template($("#LSFileInputView").html(), {inputTitle: @inputTitle, fieldIsRequired: @fieldIsRequired})
		$(@el).html template
		@lsFileChooser = new LSFileChooserController({
			el: @$('.bv_fileChooserContainer'), 
			formId: 'fieldBlah', 
			maxNumberOfFiles: @maxNumberOfFiles, 
			requiresValidation: @requiresValidation,
			url: @url,
			defaultMessage: @defaultMessage,
			dragOverMessage: @dragOverMessage
			allowedFileTypes: @allowedFileTypes
		});
		@lsFileChooser.render()
		@lsFileChooser.on('fileUploader:uploadComplete', @handleFileChooserUploadComplete)
		@lsFileChooser.on('fileUploader:uploadFailed', @handleFileChooserUploadFailed)
		@lsFileChooser.on('fileUploader:removedFile', @handleFileChooserRemovedFile)
		@
