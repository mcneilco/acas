class window.AttachFile extends Backbone.Model
	defaults:
		fileType: "unassigned"
		fileValue: ""

	validate: (attrs) ->
		console.log attrs
		errors = []
		if attrs.fileType is "unassigned" && attrs.fileValue != ""
			errors.push
				attribute: 'fileType'
				message: "File type must be assigned"
		console.log "validating attach file model"
		console.log attrs.fileValue
		console.log errors
		if errors.length > 0
			return errors
		else
			return null

class window.AttachFileList extends Backbone.Collection
	model: AttachFile

class window.AttachFileController extends Backbone.View
	template: _.template($("#AttachFileView").html())
	tagName: "div"

	events:
		"change .bv_fileType": "handleFileTypeChanged"
		"click .bv_delete": "clear"

	initialize: ->
		@model.on "destroy", @remove, @
		@canRemoveAttachFileModel = @options.canRemoveAttachFileModel

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
			hideDelete: true
		});
		@lsFileChooser.render()
		@lsFileChooser.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename

		@

	setUpFileTypeSelect: ->
		@fileTypeList = new PickListList()
		@fileTypeList.url = "/api/dataDict/analytical method/file type"
		@fileTypeList = new PickListSelectController
			el: @$('.bv_fileType')
			collection: @fileTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select File Type"
			selectedCode: @model.get('fileType')

	handleFileUpload: (nameOnServer) =>
		console.log "@canRemoveAttachFileModel attach file controller"
		console.log @canRemoveAttachFileModel
		if @canRemoveAttachFileModel
			@$('.bv_delete').show()
			console.log "should delete file"
			@$('td.delete').hide()
#			@$('.bv_deleteFile').hide()
		@model.set fileValue: nameOnServer
		#		@model.getFileInfo().set
		#			fileValue: "path to file"
		console.log @model.get('fileValue')
		@trigger 'fileUploaded'
		@trigger 'amDirty'


	handleFileTypeChanged: =>
		@updateModel()

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
	canRemoveAttachFileModel: true

	initialize: ->
		console.log "@options.canRemoveAttachFileModel?"
		console.log @options.canRemoveAttachFileModel?
		unless @collection?
			@collection = new AttachFileList()
			newModel = new AttachFile()
			@collection.add newModel
			console.log "added model to new collection"
		console.log @collection
		if @canRemoveAttachFileModel
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
	addAttachFile: (fileInfo) ->
		console.log "addAttachFile"
		afc = new AttachFileController
			model: fileInfo
			canRemoveAttachFileModel: @canRemoveAttachFileModel
		@listenTo afc, 'fileUploaded', @checkIfNeedToAddNew
#		afc.on 'fileUploaded', =>
#			if @canRemoveAttachFileModel
#				@uploadNewAttachFile()
		afc.on 'amDirty', =>
			@trigger 'amDirty'
		@$('.bv_attachFileInfo').append afc.render().el

	ensureValidCollectionLength: =>
		console.log "ensureValidCollection"
		if @collection.length == 0
			@uploadNewAttachFile()

	checkIfNeedToAddNew: =>
		console.log "check if need to add new"
		console.log @canRemoveAttachFileModel
		if @canRemoveAttachFileModel
			@uploadNewAttachFile()
