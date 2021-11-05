class ACASFormMultiFileListController extends ACASFormAbstractFieldController
	###
  	Launching controller must instantiate with the full field conf including modelDefaults, not just the fieldDefinition.
  	Controls a flexible-length list of LSFile input fields within ACASFormMultiFileControllers with an add button.
	###
	template: _.template($("#ACASFormMultiFileListView").html())

	initialize: (options)->
		super(options)
		@setupAttachFileListController()
		if !@options.allowedFileTypes?
			@options.allowedFileTypes = ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf', 'mol', 'cdx', 'cdxml', 'afr6', 'afe6', 'afs6']

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@

	getMyState: =>
		@options.thingRef.get('lsStates').getOrCreateStateByTypeAndKind @options.modelDefaults.stateType, @options.modelDefaults.stateKind

	updateAttachFileList: () =>
#get list of possible kinds of  files
		attachFileList = new AttachFileList()
		for type in @fileTypeList
			analyticalFileState = @getMyState()
			analyticalFileValues = analyticalFileState.getValuesByTypeAndKind "fileValue", type.code
			if analyticalFileValues.length > 0 and type.code != "unassigned"
#create new attach file model with fileType set to lsKind and fileValue set to fileValue
#add new afm to attach file list
				for file in analyticalFileValues
					if file.get('ignored') is false
						afm = new AttachFile
							fileType: type.code
							fileValue: file.get('fileValue')
							id: file.get('id')
							comments: file.get('comments')
						attachFileList.add afm
		@attachFileList = attachFileList
		
	setupAttachFileListController: =>
		$.ajax
			type: 'GET'
			url: @options.url
			dataType: 'json'
			error: (err) ->
				alert 'Could not get list of file types'
			success: (json) =>
				if json.length == 0
					alert 'Got empty list of file types'
				else
					@fileTypeList = json
					@renderModelContent()

	isValid: =>
		validCheck = true
		errors = @collection.validateCollection()
		if errors.length > 0
			validCheck = false
		@validationError(errors)
		validCheck

	updateModel: () ->
		currentFiles = @attachFileListController.collection.each (file) =>
			unless file.get('fileType') is "unassigned"
				if file.get('id') is null
					newFile = @getMyState().getOrCreateValueByTypeAndKind("fileValue", file.get('fileType'))
					newFile.set "fileValue", file.get("fileValue")
				else
					if file.get('ignored') is true
						value = @options.thingRef.get('lsStates').getValueById @options.modelDefaults.stateType, @options.modelDefaults.stateKind, file.get('id')
						value[0].set "ignored", true

	finishSetupAttachFileListController: () ->
		@updateAttachFileList()
		if @attachFileListController?
			@attachFileListController.undelegateEvents()
		@attachFileListController= new AttachFileListController
			autoAddAttachFileModel: false
			el: @$('.bv_multiFiles')
			collection: @attachFileList
			firstOptionName: "Select File Type"
			allowedFileTypes: @options.allowedFileTypes
			fileTypeList: @fileTypeList
			required: false
		@attachFileListController.on 'amClean', =>
			@trigger 'amClean'
		@attachFileListController.on 'renderComplete', =>
			@checkDisplayMode()
		@attachFileListController.on 'renderComplete', =>
			@checkDisplayMode()
		@attachFileListController.render()
		@attachFileListController.on 'amDirty', =>
			@updateModel()
			# @checkFormValid()

	checkDisplayMode: =>
		if @readOnly is true
			@displayInReadOnlyMode()

	renderModelContent: ->
		@finishSetupAttachFileListController()
		