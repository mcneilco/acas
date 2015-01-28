class window.AttachFile extends Backbone.Model
	defaults:
		fileType: "unassigned"
		fileValue: ""

	validate: (attrs) ->
		console.log "validate"
		errors = []
		if attrs.fileType is "unassigned" && attrs.fileValue != ""
			errors.push
				attribute: 'fileType'
				message: "Option must be selected"
		if attrs.fileType != "unassigned" && attrs.fileValue == ""
			errors.push
				attribute: 'fileType'
				message: "File must be uploaded"
		console.log "validating attach file model"
		console.log attrs.fileValue
		console.log errors
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
		@autoAddAttachFileModel = @options.autoAddAttachFileModel
		console.log "first Option Name?"
		console.log @options.firstOptionName
		if @options.firstOptionName?
			@firstOptionName = @options.firstOptionName
		else
			@firstOptionName = "Select File Type"

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setUpFileTypeSelect()
		@lsFileChooser = new LSFileChooserController({
			el: @$('.bv_uploadFile'),
			formId: 'fieldBlah',
			maxNumberOfFiles: 1,
			requiresValidation: false
			url: UtilityFunctions::getFileServiceURL()
			allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf', 'zip']
			hideDelete: @autoAddAttachFileModel
		});
		@lsFileChooser.render()
		@lsFileChooser.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename
		@lsFileChooser.on('fileDeleted', @handleFileRemoved) #update model with filename
		@

	setUpFileTypeSelect: ->
		@fileTypeList = new PickListList()
		@fileTypeList.url = "/api/dataDict/analytical method/file type"
		@fileTypeListController = new PickListSelectController
			el: @$('.bv_fileType')
			collection: @fileTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: @firstOptionName
			selectedCode: @model.get('fileType')

	handleFileUpload: (nameOnServer) =>
		console.log "@autoAddAttachFileModel attach file controller"
		console.log @autoAddAttachFileModel
		if @autoAddAttachFileModel
			@$('.bv_delete').show()
			console.log "should delete file"
			@$('td.delete').hide()
#			@$('.bv_deleteFile').hide()
		@model.set fileValue: nameOnServer
		console.log @model
		#		@model.getFileInfo().set
		#			fileValue: "path to file"
		console.log @model.get('fileValue')
		@trigger 'fileUploaded'
		@trigger 'amDirty'

	handleFileRemoved: =>
		@model.set fileValue: ""
		@trigger 'amDirty'

	handleFileTypeChanged: =>
		@updateModel()
		@trigger 'amDirty'

	updateModel: =>
		@model.set
			fileType: @$('.bv_fileType').val()
#		@model.getFileInfo().set
#			lsKind: @$('.bv_fileType').val()
		console.log @model

	clear: =>
		console.log "clear"
		@model.destroy()

class window.AttachFileListController extends Backbone.View
	template: _.template($("#AttachFileListView").html())

	initialize: ->
#		@errorOwnerName = 'AttachFileListController'
#		@setBindings()
		console.log "@options.autoAddAttachFileModel?"
		console.log @options.autoAddAttachFileModel?
		unless @collection?
			@collection = new AttachFileList()
			newModel = new AttachFile()
			@collection.add newModel
			console.log "added model to new collection"
		console.log @collection
		if @options.autoAddAttachFileModel?
			@autoAddAttachFileModel = @options.autoAddAttachFileModel
		else
			@autoAddAttachFileModel = true
		if @autoAddAttachFileModel
			@collection.bind 'remove', @ensureValidCollectionLength

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@collection.each (fileInfo) =>
			@addAttachFile(fileInfo)
		if @collection.length == 0
			console.log "collection length is zero"
			@uploadNewAttachFile()
		@

	# For uploading new files
	uploadNewAttachFile: =>
		newModel = new AttachFile()
		@collection.add newModel
		@addAttachFile(newModel)
		console.log "added new attach File"


	# For uploading existing attached files
	addAttachFile: (fileInfo) =>
		console.log "addAttachFile"
		console.log @
		console.log @options.firstOptionName
		afc = new AttachFileController
			model: fileInfo
			autoAddAttachFileModel: @autoAddAttachFileModel
			firstOptionName: @options.firstOptionName
		@listenTo afc, 'fileUploaded', @checkIfNeedToAddNew
#		afc.on 'fileUploaded', =>
#			if @autoAddAttachFileModel
#				@uploadNewAttachFile()
		afc.on 'amDirty', =>
			console.log "afc trigger dirty to aflc"
			@trigger 'amDirty'
		@$('.bv_attachFileInfo').append afc.render().el

	ensureValidCollectionLength: =>
		console.log "ensureValidCollection"
		if @collection.length == 0
			@uploadNewAttachFile()

	checkIfNeedToAddNew: =>
		console.log "check if need to add new"
		console.log @autoAddAttachFileModel
		if @autoAddAttachFileModel
			@uploadNewAttachFile()

	isValid: =>
		console.log "is valid in attach file list controller"
		validCheck = true
		@collection.each (model) ->
			console.log "attach file model"
			console.log model
			validModel = model.isValid()
			console.log "validModel"
			console.log validModel
			if validModel is false
				validCheck = false
		validCheck