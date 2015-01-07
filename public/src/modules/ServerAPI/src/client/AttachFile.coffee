class window.AttachFile extends Backbone.Model
	defaults:
		fileType: "unassigned"
		nameOnServer: ""

	validate: (attrs) ->
		console.log attrs
		errors = []
		if attrs.fileType is "unassigned" && attrs.nameOnServer != ""
			errors.push
				attribute: 'fileType'
				message: "Read name must be assigned"
		console.log "validating attach file model"
		console.log attrs.nameOnServer
		console.log errors
		if errors.length > 0
			return errors
		else
			return null

class window.AttachFileController extends Backbone.View
	template: _.template($("#AttachFileView").html())
	tagName: "div"
	className: "form-inline"

	events:
		"change .bv_fileType": "handleFileTypeChanged"
#		"click .bv_delete": "clear"

	initialize: ->
#		@model.on "destroy", @remove, @

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
		@$('.bv_delete').show()
		@model.set nameOnServer: nameOnServer
		#		@model.getFileInfo().set
		#			fileValue: "path to file"
		console.log @model.get('nameOnServer')
		@trigger 'fileUploaded'
		@trigger 'amDirty'


	handleFileTypeChanged: =>
		@updateModel()

	updateModel: =>
		@model.set
			fileType: @$('.bv_fileType').val()
#		@model.getFileInfo().set
#			lsKind: @$('.bv_fileType').val()



#	clear: =>
#		console.log "clear"
#		@model.destroy()
