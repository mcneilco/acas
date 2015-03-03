class window.AttachFile extends Backbone.Model
	defaults:
		fileType: "unassigned"
		fileValue: ""
		required: false

	validate: (attrs) ->
		errors = []
		if @get('required') is true
			if attrs.fileType is "unassigned" && attrs.fileValue == ""
				errors.push
					attribute: 'fileType'
					message: "Option must be selected and file must be uploaded"
		if attrs.fileType is "unassigned" && attrs.fileValue != ""
			errors.push
				attribute: 'fileType'
				message: "Option must be selected"
		if attrs.fileType != "unassigned" && attrs.fileValue == ""
			errors.push
				attribute: 'fileType'
				message: "File must be uploaded"
		if errors.length > 0
			return errors
		else
			return null

class window.AttachFileList extends Backbone.Collection
	model: AttachFile

class window.AttachFileController extends AbstractFormController
	template: _.template($("#AttachFileView").html())
	tagName: "div"

	events:
		"change .bv_fileType": "handleFileTypeChanged"
		"click .bv_delete": "clear"
		"click .bv_deleteSavedFile": "handleDeleteSavedStructuralFile"

	initialize: ->
		@errorOwnerName = 'AttachFileController'
		@setBindings()
		@model.on "destroy", @remove, @
		@autoAddAttachFileModel = @options.autoAddAttachFileModel
		if @options.firstOptionName?
			@firstOptionName = @options.firstOptionName
		else
			@firstOptionName = "Select File Type"
		if @options.allowedFileTypes?
			@allowedFileTypes = @options.allowedFileTypes
		else
			@allowedFileTypes = ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf']
		if @options.fileTypeListURL?
			@fileTypeListURL = @options.fileTypeListURL
		else
			@fileTypeListURL = alert 'a file type list url must be provided'

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setUpFileTypeSelect()
		fileValue = @model.get('fileValue')
		if fileValue is null or fileValue is "" or fileValue is undefined
			@createNewFileChooser()
			@$('.bv_deleteSavedFile').hide()
		else
			@$('.bv_uploadFile').html '<a href='+fileValue+'>'+fileValue+'</a>'
		@

	createNewFileChooser: =>
		@lsFileChooser = new LSFileChooserController({
			el: @$('.bv_uploadFile'),
			formId: 'fieldBlah',
			maxNumberOfFiles: 1,
			requiresValidation: false
			url: UtilityFunctions::getFileServiceURL()
			allowedFileTypes: @allowedFileTypes
			hideDelete: @autoAddAttachFileModel
		});
		@lsFileChooser.render()
		@lsFileChooser.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename
		@lsFileChooser.on('fileDeleted', @handleFileRemoved) #update model with filename
		@

	setUpFileTypeSelect: ->
		@fileTypeList = new PickListList()
		@fileTypeList.url = @fileTypeListURL
		@fileTypeListController = new PickListSelectController
			el: @$('.bv_fileType')
			collection: @fileTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: @firstOptionName
			selectedCode: @model.get('fileType')

	handleFileUpload: (nameOnServer) =>
		if @autoAddAttachFileModel
			@$('.bv_delete').show()
			@$('td.delete').hide()
		@model.set fileValue: nameOnServer
		@trigger 'fileUploaded'
		@trigger 'amDirty'

	handleFileRemoved: =>
		@model.set fileValue: ""
		@trigger 'amDirty'

	handleFileTypeChanged: =>
		@updateModel()
		@trigger 'amDirty'

	handleDeleteSavedStructuralFile: =>
		@handleFileRemoved()
		@$('.bv_deleteSavedFile').hide()
		@createNewFileChooser()

	updateModel: =>
		@model.set
			fileType: @$('.bv_fileType').val()

	clear: =>
		@model.destroy()

class window.AttachFileListController extends Backbone.View
	template: _.template($("#AttachFileListView").html())

	initialize: ->
		if @options.required?
			@required = @options.required
		else
			@required = false
		console.log "@required in file list controller"
		console.log @required
		unless @collection?
			@collection = new AttachFileList()
			newModel = new AttachFile
			#				required: @required
			@collection.add newModel
		if @options.autoAddAttachFileModel?
			@autoAddAttachFileModel = @options.autoAddAttachFileModel
		else
			@autoAddAttachFileModel = true
		if @autoAddAttachFileModel
			@collection.bind 'remove', @ensureValidCollectionLength
		if @options.allowedFileTypes?
			@allowedFileTypes = @options.allowedFileTypes
		else
			@allowedFileTypes = ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf']
		if @options.fileTypeListURL?
			@fileTypeListURL = @options.fileTypeListURL
		else
			@fileTypeListURL = alert 'a file type list url must be provided'

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@collection.each (fileInfo) =>
			@addAttachFile(fileInfo)
		if @collection.length == 0
			@uploadNewAttachFile()
		@trigger 'renderComplete'
		@

	# For uploading new files
	uploadNewAttachFile: =>
		newModel = new AttachFile
		#			required: @required
		@collection.add newModel
		@addAttachFile(newModel)


	# For uploading existing attached files
	addAttachFile: (fileInfo) =>
		console.log "add Attach File, fileInfo"
		console.log fileInfo
		console.log fileInfo.get('required')
		fileInfo.set required: @required
		afc = new AttachFileController
			model: fileInfo
			autoAddAttachFileModel: @autoAddAttachFileModel
			firstOptionName: @options.firstOptionName
			allowedFileTypes: @allowedFileTypes
			fileTypeListURL: @fileTypeListURL
		@listenTo afc, 'fileUploaded', @checkIfNeedToAddNew
		#		afc.on 'fileUploaded', =>
		#			if @autoAddAttachFileModel
		#				@uploadNewAttachFile()
		afc.on 'amDirty', =>
			@trigger 'amDirty'
		@$('.bv_attachFileInfo').append afc.render().el

	ensureValidCollectionLength: =>
		if @collection.length == 0
			@uploadNewAttachFile()

	checkIfNeedToAddNew: =>
		if @autoAddAttachFileModel
			@uploadNewAttachFile()

	isValid: =>
		validCheck = true
		@collection.each (model) ->
			validModel = model.isValid()
			if validModel is false
				validCheck = false
		validCheck