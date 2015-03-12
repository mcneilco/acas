class window.AttachFile extends Backbone.Model
	defaults:
		fileType: "unassigned"
		fileValue: ""
		id: null
		comments: null
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

	initialize: ->
		@errorOwnerName = 'AttachFileController'
		@setBindings()
		@model.on "destroy", @remove, @
		@model.on "removeFile", @trigger 'removeFile'
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
		else
			@$('.bv_uploadFile').html '<div style="margin-top:5px;margin-left:4px;"> <a href="'+window.conf.datafiles.downloadurl.prefix+fileValue+'">'+@model.get('comments')+'</a></div>'
		@

	createNewFileChooser: =>
		@lsFileChooser = new LSFileChooserController({
			el: @$('.bv_uploadFile'),
			formId: 'fieldBlah',
			maxNumberOfFiles: 1,
			requiresValidation: false
			url: UtilityFunctions::getFileServiceURL()
			allowedFileTypes: @allowedFileTypes
			hideDelete: true
		});
		@lsFileChooser.render()
		@lsFileChooser.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename
		#		@lsFileChooser.on('fileDeleted', @handleFileRemoved) #update model with filename
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

	handleFileTypeChanged: =>
		@updateModel()
		@trigger 'amDirty'

	updateModel: =>
		@model.set
			fileType: @$('.bv_fileType').val()

	clear: =>
		if @model.get('id') is null
			@model.destroy()
		else
			@model.set "ignored", true
			@$('.bv_fileInfoWrapper').hide()
		@trigger 'removeFile'
		@trigger 'amDirty'

class window.AttachFileListController extends Backbone.View
	template: _.template($("#AttachFileListView").html())

	events:
		"click .bv_addFileInfo": "uploadNewAttachFile"

	initialize: ->
		if @options.required?
			@required = @options.required
		else
			@required = false
		unless @collection?
			@collection = new AttachFileList()
			newModel = new AttachFile
			@collection.add newModel
		if @options.autoAddAttachFileModel?
			@autoAddAttachFileModel = @options.autoAddAttachFileModel
		else
			@autoAddAttachFileModel = true
		if @autoAddAttachFileModel
			@collection.on 'removeFile', @ensureValidCollectionLength
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
		@collection.add newModel
		@addAttachFile(newModel)
		@trigger 'amDirty'


	# For uploading existing attached files
	addAttachFile: (fileInfo) =>
		fileInfo.set required: @required
		afc = new AttachFileController
			model: fileInfo
			autoAddAttachFileModel: @autoAddAttachFileModel
			firstOptionName: @options.firstOptionName
			allowedFileTypes: @allowedFileTypes
			fileTypeListURL: @fileTypeListURL
		@listenTo afc, 'fileUploaded', @checkIfNeedToAddNew
		@listenTo afc, 'removeFile', @ensureValidCollectionLength
		afc.on 'amDirty', =>
			@trigger 'amDirty'
		@$('.bv_attachFileInfo').append afc.render().el

	ensureValidCollectionLength: =>
		notIgnoredFiles = @collection.filter (model) ->
			model.get('ignored') == false or model.get('ignored') is undefined
		if notIgnoredFiles.length == 0
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