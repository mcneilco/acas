class ThingAttachFileList extends AttachFileList

	validate: =>
		modelErrors = []
		usedFileTypes={}
		if @.length != 0
			for index in [0..@.length-1]
				model = @.at(index)
				currentFileType = model.get('fileType')
				# If the model is unassigned or ignored we can ignore it from validation
				if (currentFileType == "unassigned" || model.get('ignored'))
					continue

				indivModelErrors = model.validate(model.attributes)
				if indivModelErrors != null
					for error in indivModelErrors
						modelErrors.push
							attribute: error.attribute+':eq('+index+')'
							message: error.message

				# Leaving this here in case we want to turn on uniqueness by file type
				if false
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

	validate: =>
		@clearError()
		isValid = true

		# This calls validate on each model to find out if they are valid or not
		# It doesn't return a list of errors but it tells us if they are saveable or not
		isValid = @attachFileListController.isValid()
		if !isValid
			@setError("Please select a file attachment or remove the file in error")
			return isValid
		
		# This will return a set of errors
		errors = @attachFileListController.collection.validate()
		if errors.length > 0
			isValid = false
			@setError(errors[0].message)
		return isValid

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@

	getMyState: =>
		@options.thingRef.get('lsStates').getOrCreateStateByTypeAndKind @options.modelDefaults.stateType, @options.modelDefaults.stateKind

	updateCurrentManagedThingFileValues: () =>
		# Goal here is to get a list of all of the managed thing values
		# which are those thing values in the state type and kind which are file values
		# that have an lsKind which matches that of one of the file types managed by the service

		attachFileList = new ThingAttachFileList

		# Get the state that is managed
		myManagedState = @getMyState()

		# Loop through all of the file types that are managed
		for type in @fileTypeList

			# Fetch all file values from the state which match the managed file ls kind
			managedFileValues = myManagedState.getValuesByTypeAndKind "fileValue", type.code

			# Don't need to worry about the special "unassigned" file type are unassigned 
			# or if there are no managed file values
			if managedFileValues.length > 0 and type.code != "unassigned"
				# create new attach file model with fileType set to lsKind and fileValue set to fileValue
				# add new afm to attach file list
				for file in managedFileValues
					afm = new AttachFile
						fileType: type.code
						fileValue: file.get('fileValue')
						id: file.get('id')
						comments: file.get('comments')
					attachFileList.add afm

		# Keep ordered by id so this is order is displayed in the GUI nicely
		attachFileList.comparator = (value) =>
			value.get("id")
		attachFileList.sort()

		@currentManagedThingFileValues = attachFileList
		
		
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

	updateThingFromFileListController: () ->
		# Goals here is to keep the thing up to date with any
		# changes made to the attachment file list managed by 
		# @attachFileListController

		# Remove on managed file values that have not been saved
		# we will be adding them back below if they are still
		# in the attachFileListController
		myManagedState = @getMyState()
		for type in @fileTypeList
			managedFileValues = myManagedState.getValuesByTypeAndKind "fileValue", type.code
			for managedFileValue in managedFileValues
				if managedFileValue.isNew()
					myManagedState.get("lsValues").remove(managedFileValue)

		# Now that the thing no longer has any unsaved values
		# Create any new models that have been added
		# or ignore any that have been removed
		@attachFileListController.collection.each (file) =>
			if file.isNew() #file.get('id') is null
				unless (file.get('ignored') is true or file.get('fileType') is "unassigned")
					newFile = @options.thingRef.get('lsStates').createValueByTypeAndKind @options.modelDefaults.stateType, @options.modelDefaults.stateKind, "fileValue", file.get('fileType')
					newFile.set
						fileValue: file.get('fileValue')
						comments: file.get('comments')
			else
				if file.get('ignored') is true
					value = @options.thingRef.get('lsStates').getValueById @options.modelDefaults.stateType, @options.modelDefaults.stateKind, file.get('id')
					value[0].set "ignored", true
	


	finishSetupAttachFileListController: () ->
		# Updates @currentManagedThingFileValues from the thing
		# @currentManagedThingFileValues is a collection which will be managed
		# by attachFileListController and synced to the thing when the collection
		# changes
		@updateCurrentManagedThingFileValues()
		if @attachFileListController?
			@attachFileListController.undelegateEvents()
		@attachFileListController= new AttachFileListController
			autoAddAttachFileModel: false
			el: @$('.bv_multiFiles')
			collection: @currentManagedThingFileValues
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
			@updateThingFromFileListController()
			@validate()

	checkDisplayMode: =>
		if @readOnly is true
			@displayInReadOnlyMode()

	renderModelContent: ->
		# Only render if our file type list has been fetched
		# otherwise its not ready yet
		if @fileTypeList?
			@finishSetupAttachFileListController()
		