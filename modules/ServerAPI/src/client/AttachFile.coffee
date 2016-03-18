class window.BasicFile extends Backbone.Model
	#model created from uploading file or entering external url
	defaults: ->
		id: null
		comments: null
		required: false

class window.BasicFileList extends Backbone.Collection
	model: BasicFile

class window.AttachFile extends BasicFile
	defaults: ->
		_(super()).extend(
			fileType: "unassigned"
			fileValue: ""
		)

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

class window.AttachFileList extends BasicFileList
	model: AttachFile

class window.ExperimentAttachFileList extends AttachFileList

	validateCollection: =>
		modelErrors = []
		usedFileTypes={}
		if @.length != 0
			for index in [0..@.length-1]
				model = @.at(index)
				indivModelErrors = model.validate(model.attributes)
				if indivModelErrors != null
					for error in indivModelErrors
						modelErrors.push
							attribute: error.attribute+':eq('+index+')'
							message: error.message
				currentFileType = model.get('fileType')
				uneditableFileTypes = window.conf.experiment.uneditableFileTypes
				unless uneditableFileTypes?
					uneditableFileTypes = ""
				if uneditableFileTypes.indexOf(currentFileType)>-1
					if currentFileType of usedFileTypes
						modelErrors.push
							attribute: 'fileType:eq('+index+')'
							message: "This file type can not be chosen more than once"
						modelErrors.push
							attribute: 'fileType:eq('+usedFileTypes[currentFileType]+')'
							message: "This file type can not be chosen more than once"
					else
						usedFileTypes[currentFileType] = index
		modelErrors



class window.BasicFileController extends AbstractFormController
	template: _.template($("#BasicFileView").html())
	tagName: "div"

	events: ->
		"click .bv_delete": "clear"

	initialize: ->
		@errorOwnerName = 'BasicFileController'
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
		if @options.fileTypeList?
			@fileTypeList = new PickListList @options.fileTypeList
		else
			@fileTypeList = new PickListList()

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		fileValue = @model.get('fileValue')
		urlValue = @model.get('urlValue')
		if ((fileValue is null or fileValue is "" or fileValue is undefined) and (urlValue is null or urlValue is "" or urlValue is undefined))
			@createNewFileChooser()
		else
			if urlValue?
				@$('.bv_uploadFile').html '<div style="margin-top:5px;margin-left:4px;"> <a href="'+ @model.get('urlValue')+'">'+@model.get('urlValue')+'</a></div>'
			else
				@$('.bv_uploadFile').html '<div style="margin-top:5px;margin-left:4px;"> <a href="'+window.conf.datafiles.downloadurl.prefix+fileValue+'">'+@model.get('comments')+'</a></div>'
			@$('.bv_recordedBy').html @model.get("recordedBy")
			@$('.bv_recordedDate').html UtilityFunctions::convertMSToYMDDate @model.get("recordedDate")
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

	handleFileUpload: (nameOnServer) =>
		if @autoAddAttachFileModel
			@$('.bv_delete').show()
			@$('td.delete').hide()
		@model.set fileValue: nameOnServer
		@trigger 'fileUploaded'
		@trigger 'amDirty'

	clear: =>
		if @model.get('id') is null
			@model.destroy()
		else
			@model.set "ignored", true
			@$('.bv_fileInfoWrapper').hide()
		@trigger 'removeFile'
		@trigger 'amDirty'

class window.BasicFileListController extends Backbone.View
	template: _.template($("#BasicFileListView").html())

	initialize: ->
		if @options.required?
			@required = @options.required
		else
			@required = false
		unless @collection?
			@collection = new BasicFileList()
			newModel = new BasicFile
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

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@collection.each (fileInfo) =>
			@addBasicFile(fileInfo)
		if @collection.length == 0
			@uploadNewFile()
		@trigger 'renderComplete'
		@

# For uploading new files
	uploadNewFile: =>
		newModel = new BasicFile
		@collection.add newModel
		@addBasicFile(newModel)
		@trigger 'amDirty'


# For uploading existing attached files
	addBasicFile: (fileInfo) =>
		fileInfo.set required: @required
		afc = new BasicFileController
			model: fileInfo
			autoAddAttachFileModel: @autoAddAttachFileModel
			firstOptionName: @options.firstOptionName
			allowedFileTypes: @allowedFileTypes
		#			fileTypeList: @fileTypeList
		@listenTo afc, 'fileUploaded', @checkIfNeedToAddNew
		@listenTo afc, 'removeFile', @ensureValidCollectionLength
		afc.on 'addNewModel', (newModel) =>
			@collection.add newModel
			@addBasicFile newModel
		afc.on 'amDirty', =>
			@trigger 'amDirty'
		@$('.bv_basicFileInfo').append afc.render().el

	ensureValidCollectionLength: =>
		notIgnoredFiles = @collection.filter (model) ->
			model.get('ignored') == false or model.get('ignored') is undefined
		if notIgnoredFiles.length == 0
			@uploadNewFile()

	checkIfNeedToAddNew: =>
		if @autoAddAttachFileModel
			@uploadNewFile()

	isValid: =>
		validCheck = true
		@collection.each (model) ->
			validModel = model.isValid()
			if validModel is false
				validCheck = false
		validCheck

class window.AttachFileController extends BasicFileController
	template: _.template($("#AttachFileView").html())
	tagName: "div"

	events: ->
		_(super()).extend(
			"change .bv_fileType": "handleFileTypeChanged"
		)

	initialize: ->
		super()
		@errorOwnerName = 'AttachFileController'

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setUpFileTypeSelect()
		fileValue = @model.get('fileValue')
		if fileValue is null or fileValue is "" or fileValue is undefined
			@createNewFileChooser()
		else
			@$('.bv_uploadFile').html '<div style="margin-top:5px;margin-left:4px;"> <a href="'+window.conf.datafiles.downloadurl.prefix+fileValue+'">'+@model.get('comments')+'</a></div>'

		uneditableFileTypes = window.conf.experiment.uneditableFileTypes
		unless uneditableFileTypes?
			uneditableFileTypes = ""
		if uneditableFileTypes.indexOf(@model.get('fileType'))>-1 and @model.get('id')?
			@$('.bv_delete').hide()
			@$('.bv_fileType').attr 'disabled', 'disabled'
		else
			@$('.bv_delete').show()
			@$('.bv_fileType').removeAttr 'disabled'
		@

	setUpFileTypeSelect: ->
		@fileTypeListController = new PickListSelectController
			el: @$('.bv_fileType')
			collection: @fileTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: @firstOptionName
			selectedCode: @model.get('fileType')
			autoFetch: false

	handleFileTypeChanged: =>
		@updateModel()
		@trigger 'amDirty'

	updateModel: =>
		if @model.get('id') is null
			@model.set
				fileType: @$('.bv_fileType').val()
		else
			newModel = new AttachFile (_.clone(@model.attributes))
			newModel.unset 'id'
			newModel.set
				fileType: @$('.bv_fileType').val()
			@model.set "ignored", true
			@$('.bv_fileInfoWrapper').hide()
			@trigger 'addNewModel', newModel


class window.AttachFileListController extends BasicFileListController
	template: _.template($("#AttachFileListView").html())

	events:
		"click .bv_addFileInfo": "uploadNewFile"

	initialize: ->
		unless @collection?
			@collection = new AttachFileList()
			newModel = new AttachFile
			@collection.add newModel
		super()
		if @options.fileTypeList?
			@fileTypeList = @options.fileTypeList
		else
			@fileTypeList = new PickListList()

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@collection.each (fileInfo) =>
			@addAttachFile(fileInfo)
		if @collection.length == 0
			@uploadNewFile()
		@trigger 'renderComplete'
		@

# For uploading new files
	uploadNewFile: =>
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
			fileTypeList: @fileTypeList
		@listenTo afc, 'fileUploaded', @checkIfNeedToAddNew
		@listenTo afc, 'removeFile', @ensureValidCollectionLength
		afc.on 'addNewModel', (newModel) =>
			@collection.add newModel
			@addAttachFile newModel
		afc.on 'amDirty', =>
			@trigger 'amDirty'
		@$('.bv_attachFileInfo').append afc.render().el

class window.ExperimentAttachFileListController extends AttachFileListController

	initialize: ->
		unless @collection?
			@collection = new ExperimentAttachFileList()
			newModel = new AttachFile
			@collection.add newModel
		super()
		if @options.fileTypeList?
			@fileTypeList = @options.fileTypeList
		else
			@fileTypeList = new PickListList()

	isValid: =>
		validCheck = true
		errors = @collection.validateCollection()
		if errors.length > 0
			validCheck = false
		@validationError(errors)
		validCheck

	validationError: (errors) =>
		@clearValidationErrorStyles()
		_.each errors, (err) =>
			unless @$('.bv_'+err.attribute).attr('disabled') is 'disabled'
				@$('.bv_group_'+err.attribute).attr('data-toggle', 'tooltip')
				@$('.bv_group_'+err.attribute).attr('data-placement', 'bottom')
				@$('.bv_group_'+err.attribute).attr('data-original-title', err.message)
				#				@$('.bv_group_'+err.attribute).tooltip();
				@$("[data-toggle=tooltip]").tooltip();
				@$("body").tooltip selector: '.bv_group_'+err.attribute
				@$('.bv_group_'+err.attribute).addClass 'input_error error'
				@trigger 'notifyError',  owner: this.errorOwnerName, errorLevel: 'error', message: err.message

	clearValidationErrorStyles: =>
		errorElms = @$('.input_error')
		_.each errorElms, (ee) =>
			$(ee).removeAttr('data-toggle')
			$(ee).removeAttr('data-placement')
			$(ee).removeAttr('title')
			$(ee).removeAttr('data-original-title')
			$(ee).removeClass 'input_error error'
