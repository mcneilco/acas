class window.BaseEntity extends Backbone.Model
	urlRoot: "/api/experiments" # should be set the proper value in subclasses

	defaults: ->
		subclass: "entity"
		lsType: "default"
		lsKind: "default"
		recordedBy: window.AppLaunchParams.loginUser.username
		recordedDate: new Date().getTime()
		shortDescription: " "
		lsLabels: new LabelList()
		lsStates: new StateList()

	initialize: ->
		@.set @parse(@.attributes)

	parse: (resp) =>
		if resp.lsLabels?
			if resp.lsLabels not instanceof LabelList
				resp.lsLabels = new LabelList(resp.lsLabels)
			resp.lsLabels.on 'change', =>
				@trigger 'change'
		if resp.lsStates?
			if resp.lsStates not instanceof StateList
				resp.lsStates = new StateList(resp.lsStates)
			resp.lsStates.on 'change', =>
				@trigger 'change'
		if resp.lsTags not instanceof TagList
			resp.lsTags = new TagList(resp.lsTags)
			resp.lsTags.on 'change', =>
				@trigger 'change'
		resp

	getScientist: ->
		metadataKind = @.get('subclass') + " metadata"
		scientist = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "codeValue", "scientist"
		if scientist.get('codeValue') is undefined
			scientist.set codeType: "assay"
			scientist.set codeKind: "scientist"
			scientist.set codeOrigin: window.conf.scientistCodeOrigin
			if @isNew()
				scientist.set codeValue: window.AppLaunchParams.loginUserName
			else
				scientist.set codeValue: "unassigned"
		scientist

	getDetails: ->
		metadataKind = @.get('subclass') + " metadata"
		entityDetails = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "clobValue", @.get('subclass') + " details"
		if entityDetails.get('clobValue') is undefined or entityDetails.get('clobValue') is ""
			entityDetails.set clobValue: ""

		entityDetails

	getComments: ->
		metadataKind = @.get('subclass') + " metadata"
		comments = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "clobValue", "comments"
		if comments.get('clobValue') is undefined or comments.get('clobValue') is ""
			comments.set clobValue: ""

		comments

	getNotebook: ->
		metadataKind = @.get('subclass') + " metadata"
		@.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "stringValue", "notebook"

	getNotebookPage: ->
		metadataKind = @.get('subclass') + " metadata"
		@.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "stringValue", "notebook page"

	getStatus: ->
		subclass = @.get('subclass')
		metadataKind = subclass + " metadata"
		valueKind = subclass + " status"
		status = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "codeValue", valueKind
		if status.get('codeValue') is undefined or status.get('codeValue') is ""
			if window.conf.entity?.status?.default?
				defaultStatus = window.conf.entity.status.default
			else 
				defaultStatus = "created"
			status.set codeValue: defaultStatus
			status.set codeType: subclass
			status.set codeKind: "status"
			status.set codeOrigin: "ACAS DDICT"

		status

	getAttachedFiles: (fileTypes) =>
#get list of possible kinds of analytical files
		attachFileList = new AttachFileList()
		for type in fileTypes
			analyticalFileState = @get('lsStates').getOrCreateStateByTypeAndKind "metadata", @get('subclass')+" metadata"
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

		attachFileList

	getAnalysisParameters: =>
		ap = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "data analysis parameters"
		if ap.get('clobValue')?
			return new PrimaryScreenAnalysisParameters $.parseJSON(ap.get('clobValue'))
		else
			return new PrimaryScreenAnalysisParameters()

	getModelFitParameters: =>
		ap = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "model fit parameters"
		if ap.get('clobValue')?
			return $.parseJSON(ap.get('clobValue'))
		else
			return {}


	isEditable: ->
		status = @getStatus().get 'codeValue'
		switch status
			when "created" then return true
			when "started" then return true
			when "complete" then return true
			when "approved" then return false
			when "rejected" then return false
			when "deleted" then return false
		return true

	validate: (attrs) ->
		errors = []
		bestName = attrs.lsLabels.pickBestName()
		nameError = true
		if bestName?
			nameError = true
			if bestName.get('labelText') != ""
				nameError = false
		if nameError
			errors.push
				attribute: attrs.subclass+'Name'
				message: attrs.subclass+" name must be set"
		if _.isNaN(attrs.recordedDate)
			errors.push
				attribute: 'recordedDate'
				message: attrs.subclass+" date must be set"
		if attrs.subclass?
			saveNotebook = true #default
			if window.conf.entity?.notebook?.save?
				saveNotebook= window.conf.entity.notebook.save
			requireNotebook = true #default
			if window.conf.entity?.notebook?.require?
				requireNotebook= window.conf.entity.notebook.require
			if saveNotebook and requireNotebook
				notebook = @getNotebook().get('stringValue')
				if notebook is "" or notebook is undefined or notebook is null
					errors.push
						attribute: 'notebook'
						message: "Notebook must be set"

				saveNotebookPage = true #default
				if window.conf.entity?.notebookPage?.save?
					saveNotebookPage = window.conf.entity.notebookPage.save
				requireNotebookPage = false #default
				if window.conf.entity?.notebookPage?.require?
					requireNotebookPage= window.conf.entity.notebookPage.require
				if saveNotebookPage and requireNotebookPage
					notebookPage = @getNotebookPage().get('stringValue')
					if notebookPage is "" or notebookPage is undefined or notebookPage is null
						errors.push
							attribute: 'notebookPage'
							message: "Notebook Page must be set"
						
			scientist = @getScientist().get('codeValue')
			if scientist is "unassigned" or scientist is undefined or scientist is "" or scientist is null
				errors.push
					attribute: 'scientist'
					message: "Scientist must be set"

		if errors.length > 0
			return errors
		else
			return null

	prepareToSave: ->
		rBy = window.AppLaunchParams.loginUser.username
		rDate = new Date().getTime()
		@set recordedDate: rDate
		@get('lsLabels').each (lab) ->
			unless lab.get('recordedBy') != ""
				lab.set recordedBy: rBy
			unless lab.get('recordedDate') != null
				lab.set recordedDate: rDate
		@get('lsStates').each (state) ->
			unless state.get('recordedBy') != ""
				state.set recordedBy: rBy
			unless state.get('recordedDate') != null
				state.set recordedDate: rDate
			state.get('lsValues').each (val) ->
				unless val.get('recordedBy') != ""
					val.set recordedBy: rBy
				unless val.get('recordedDate') != null
					val.set recordedDate: rDate
		if @attributes.subclass?
			delete @attributes.subclass
		if @attributes.protocol?
			if @attributes.protocol.attributes.subclass?
				delete @attributes.protocol.attributes.subclass
		@trigger "readyToSave", @

	duplicateEntity: =>
		copiedEntity = @.clone()
		copiedEntity.unset 'lsLabels'
		copiedEntity.unset 'lsStates'
		copiedEntity.unset 'id'
		copiedEntity.unset 'codeName'
		copiedStates = new StateList()
		origStates = @get('lsStates')
		origStates.each (st) ->
			unless st.get('ignored')
				copiedState = new State(_.clone(st.attributes))
				copiedState.unset 'id'
				copiedState.unset 'lsTransactions'
				copiedState.unset 'lsValues'
				copiedValues = new ValueList()
				origValues = st.get('lsValues')
				origValues.each (sv) ->
					unless sv.get('ignored')
						unless sv.attributes.lsType == 'fileValue'
							copiedVal = new Value(sv.attributes)
							copiedVal.unset 'id'
							copiedVal.unset 'lsTransaction'
							copiedValues.add(copiedVal)
				copiedState.set lsValues: copiedValues
				copiedStates.add(copiedState)
		copiedEntity.set
			lsLabels: new LabelList()
			lsStates: copiedStates
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
			version: 0
		if window.conf.entity?.status?.default?
			defaultStatus = window.conf.entity.status.default
		else
			defaultStatus = "created"
		copiedEntity.getStatus().set codeValue: defaultStatus
		copiedEntity.getNotebook().set stringValue: ""
		copiedEntity.getNotebookPage().set stringValue: ""
		copiedEntity.getScientist().set codeValue: "unassigned"

		copiedEntity

class window.BaseEntityList extends Backbone.Collection
	model: BaseEntity

class window.BaseEntityController extends AbstractThingFormController #TODO: check to see if this is ok
	template: _.template($("#BaseEntityView").html())

	events: ->
		"change .bv_scientist": "handleScientistChanged"
		"keyup .bv_shortDescription": "handleShortDescriptionChanged"
		"keyup .bv_details": "handleDetailsChanged"
		"keyup .bv_comments": "handleCommentsChanged"
		"keyup .bv_entityName": "handleNameChanged"
		"keyup .bv_notebook": "handleNotebookChanged"
		"keyup .bv_notebookPage": "handleNotebookPageChanged"
		"change .bv_status": "handleStatusChanged"
		"click .bv_save": "handleSaveClicked"
		"click .bv_newEntity": "handleNewEntityClicked"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_cancelClear": "handleCancelClearClicked"
		"click .bv_confirmClear": "handleConfirmClearClicked"

	initialize: ->
		unless @model?
			@model=new BaseEntity()
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'change', @modelChangeCallback
		@errorOwnerName = 'BaseEntityController'
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_save').attr('disabled', 'disabled')
		@setupStatusSelect()
		@setupScientistSelect()
		@setupTagList()
		@model.getStatus().on 'change', @updateEditable

	render: =>
		unless @model?
			@model = new BaseEntity()
		subclass = @model.get('subclass')
		unless @model.get('shortDescription') is " "
			@$('.bv_shortDescription').html @model.get('shortDescription')
		bestName = @model.get('lsLabels').pickBestName()
		if bestName?
			@$('.bv_'+subclass+'Name').val bestName.get('labelText')
		@$('.bv_scientist').val(@model.getScientist().get('codeValue'))
		@$('.bv_'+subclass+'Code').html(@model.get('codeName'))
		@$('.bv_'+subclass+'Kind').html(@model.get('lsKind')) #should get value from protocol create form
		@$('.bv_details').val(@model.getDetails().get('clobValue'))
		@$('.bv_comments').val(@model.getComments().get('clobValue'))
		saveNotebook = true #default
		if window.conf.entity?.notebook?.save?
			saveNotebook= window.conf.entity.notebook.save
		requireNotebook = true #default
		if window.conf.entity?.notebook?.require?
			requireNotebook= window.conf.entity.notebook.require
		if saveNotebook
			@$('.bv_notebook').val @model.getNotebook().get('stringValue')
			if requireNotebook
				console.log "require notebook"
				@$('.bv_notebookLabel').html "*Notebook"
			else
				@$('.bv_notebookLabel').html "Notebook"
			saveNotebookPage = true #default
			if window.conf.entity?.notebookPage?.save?
				saveNotebookPage = window.conf.entity.notebookPage.save
			requireNotebookPage = false #default
			if window.conf.entity?.notebookPage?.require?
				requireNotebookPage= window.conf.entity.notebookPage.require
			if saveNotebookPage
				@$('.bv_notebookPage').val @model.getNotebookPage().get('stringValue')
				if requireNotebookPage
					@$('.bv_notebookPageLabel').html "*Notebook Page"
				else
					@$('.bv_notebookPageLabel').html "Notebook Page"
			else
				@$('.bv_group_notebookPage').hide()


		else
			@$('.bv_group_notebook').hide()
			@$('.bv_group_notebookPage').hide()

		@$('.bv_status').val(@model.getStatus().get('codeValue'))
		if @model.isNew()
			@$('.bv_save').html("Save")
			@$('.bv_newEntity').hide()
		else
			@$('.bv_save').html("Update")
			@$('.bv_newEntity').show()
		@updateEditable()
		@$('.bv_save').attr('disabled', 'disabled')
		@$('.bv_cancel').attr('disabled','disabled')
		if @readOnly is true or !@canEdit()
			@displayInReadOnlyMode()

		@

	modelSyncCallback: =>
		@trigger 'amClean'
		unless @model.get('subclass')?
			@model.set subclass: 'entity'
		@$('.bv_saving').hide()
		@$('.bv_updateComplete').show()
		@render()

	modelChangeCallback: =>
		@trigger 'amDirty'
		@$('.bv_updateComplete').hide()
		@$('.bv_cancel').removeAttr('disabled')
		@$('.bv_cancelComplete').hide()

	canEdit: ->
		if @model.isNew() or @model.getScientist().get('codeValue') is "unassigned"
			return true
		else
			if window.conf.entity?.editingRoles? and $.trim(window.conf.entity.editingRoles).length > 0
				rolesToTest = []
				for role in window.conf.entity.editingRoles.split(",")
					role = $.trim(role)
					if role is 'entityScientist'
						if (window.AppLaunchParams.loginUserName is @model.getScientist().get('codeValue'))
							return true
					else if role is 'projectAdmin'
						projectAdminRole =
							lsType: "Project"
							lsKind: @model.getProjectCode().get('codeValue')
							roleName: "Administrator"
						if UtilityFunctions::testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [projectAdminRole])
							return true
					else
						rolesToTest.push role
				if rolesToTest.length is 0
					return false
				if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, rolesToTest
					return true
				else
					return false
			else
				return true

	canDelete: ->
		if window.conf.entity?.deletingRoles?
			rolesToTest = []
			for role in window.conf.entity.deletingRoles.split(",")
				role = $.trim(role)
				if role is 'entityScientist'
					if (window.AppLaunchParams.loginUserName is @model.getScientist().get('codeValue'))
						return true
				else if role is 'projectAdmin'
					projectAdminRole =
						lsType: "Project"
						lsKind: @model.getProjectCode().get('codeValue')
						roleName: "Administrator"
					if UtilityFunctions::testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [projectAdminRole])
						return true
				else
					rolesToTest.push role
			if rolesToTest.length is 0
				return false
			unless UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, rolesToTest
				return false
		return true

	setupStatusSelect: ->
		statusState = @model.getStatus()
		@statusList = new PickListList()
		@statusList.url = "/api/codetables/"+statusState.get('codeType')+"/"+statusState.get('codeKind')
		@statusListController = new PickListSelectController
			el: @$('.bv_status')
			collection: @statusList
			selectedCode: statusState.get 'codeValue'
		@listenTo @statusList, 'sync', @editStatusOptions

	editStatusOptions: =>
		if window.conf.entity?.approvalRole?
			unless UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, window.conf.entity.approvalRole
				@$(".bv_status option[value='approved']").attr 'disabled', 'disabled'
				@$(".bv_status option[value='rejected']").attr 'disabled', 'disabled'
		if !@canDelete()
			@$(".bv_status option[value='deleted']").attr 'disabled', 'disabled'

	setupScientistSelect: ->
		@scientistList = new PickListList()
		@scientistList.url = "/api/authors"
		@scientistListController = new PickListSelectController
			el: @$('.bv_scientist')
			collection: @scientistList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Scientist"
			selectedCode: @model.getScientist().get('codeValue')

	setupAttachFileListController: =>
		$.ajax
			type: 'GET'
			url: "/api/codetables/"+@model.get('subclass')+" metadata/file type"
			dataType: 'json'
			error: (err) ->
				alert 'Could not get list of file types'
			success: (json) =>
				if json.length == 0
					alert 'Got empty list of file types'
				else
					attachFileList = @model.getAttachedFiles(json)
					@finishSetupAttachFileListController(attachFileList,json)

	finishSetupAttachFileListController: (attachFileList, fileTypeList) ->
		if @attachFileListController?
			@attachFileListController.undelegateEvents()
		@attachFileListController= new AttachFileListController
			autoAddAttachFileModel: false
			el: @$('.bv_attachFileList')
			collection: attachFileList
			firstOptionName: "Select Method"
			allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf', 'rar', 'gzip', 'gz']
			fileTypeList: fileTypeList
			required: false
		@attachFileListController.on 'amClean', =>
			@trigger 'amClean'
		@attachFileListController.on 'renderComplete', =>
			@checkDisplayMode()
		@attachFileListController.render()
		@attachFileListController.on 'amDirty', =>
			@trigger 'amDirty' #need to put this after the first time @attachFileListController is rendered or else the module will always start off dirty
			@model.trigger 'change'

	setupTagList: ->
		@$('.bv_tags').val ""
		@tagListController = new TagListController
			el: @$('.bv_tags')
			collection: @model.get 'lsTags'
		@tagListController.render()


	handleScientistChanged: =>
		value = @scientistListController.getSelectedCode()
		@handleValueChanged "Scientist", value

	handleShortDescriptionChanged: =>
		trimmedDesc = UtilityFunctions::getTrimmedInput @$('.bv_shortDescription')
		if trimmedDesc == ""
			trimmedDesc = " " #fix for oracle persistance bug
		@model.set
			shortDescription: trimmedDesc

	handleDetailsChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_details')
		@handleValueChanged "Details", value

	handleCommentsChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_comments')
		@handleValueChanged "Comments", value

	handleNameChanged: =>
		subclass = @model.get('subclass')
		newName = UtilityFunctions::getTrimmedInput @$('.bv_'+subclass+'Name')
		@model.get('lsLabels').setBestName new Label
			lsKind: subclass+" name"
			labelText: newName
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		#TODO label change propagation isn't really working, so this is the work-around
		@model.trigger 'change'

	handleNotebookChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_notebook')
		@handleValueChanged "Notebook", value

	handleNotebookPageChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_notebookPage')
		@handleValueChanged "NotebookPage", value

	handleStatusChanged: =>
		value = @statusListController.getSelectedCode()
		if (value is "approved" or value is "rejected") and !@isValid()
			value = value.charAt(0).toUpperCase() + value.substring(1);
			alert 'All fields must be valid before changing the status to "'+ value + '"'
			@statusListController.setSelectedCode @model.getStatus().get('codeValue')
		else if value is "deleted"
			@handleDeleteStatusChosen()
		else
			@handleValueChanged "Status", value
			# this is required in addition to model change event watcher only for spec. real app works without it
			@updateEditable()
			@model.trigger 'change'
			@model.trigger 'statusChanged'

	handleValueChanged: (vKind, value) =>
		currentVal = @model["get"+vKind]()
		unless currentVal.isNew()
			currentVal.set ignored: true
			currentVal = @model["get"+vKind]() #this will create a new value
		#		currentVal.set vType, value
		currentVal.set currentVal.get('lsType'), value
		# this is required only for spec. real app works without it
		@model.trigger 'change'

	updateEditable: =>
		if @readOnly
			@displayInReadOnlyMode()
		else
			if @model.isEditable()
				@enableAllInputs()
				@$('.bv_lock').hide()
			else
				@disableAllInputs()
				@$('.bv_status').removeAttr('disabled')
				@$('.bv_lock').show()
				@$('.bv_newEntity').removeAttr('disabled')
				if @model.getStatus().get('codeValue') is "deleted"
					@$('.bv_status').attr 'disabled', 'disabled'
			if @model.isNew()
				@$('.bv_status').attr("disabled", "disabled")
			else
				unless @model.getStatus().get('codeValue') is "deleted"
					@$('.bv_status').removeAttr("disabled")
			if window.conf.entity?.scientist?.editable? and window.conf.entity.scientist.editable is false
				@$('.bv_scientist').attr 'disabled', 'disabled'
			else
				@$('.bv_scientist').removeAttr 'disabled'


		@model.trigger 'statusChanged'

	beginSave: =>
		@prepareToSaveAttachedFiles()
		@tagListController.handleTagsChanged()
		if @model.checkForNewPickListOptions?
			@model.checkForNewPickListOptions()
		else
			@trigger "noEditablePickLists"

	handleSaveClicked: =>
		@saveEntity()

	saveEntity: =>
		@prepareToSaveAttachedFiles()
		@tagListController.handleTagsChanged()
		@model.prepareToSave()
		if @model.isNew()
			@$('.bv_updateComplete').html "Save Complete"
		else
			@$('.bv_updateComplete').html "Update Complete"
		@$('.bv_save').attr('disabled', 'disabled')
		@$('.bv_saving').show()
		@model.save()

	prepareToSaveAttachedFiles: =>
		@attachFileListController.collection.each (file) =>
			unless file.get('fileType') is "unassigned"
				if file.get('id') is null
					newFile = @model.get('lsStates').createValueByTypeAndKind "metadata", @model.get('subclass')+" metadata", "fileValue", file.get('fileType')
					newFile.set fileValue: file.get('fileValue')
				else
					if file.get('ignored') is true
						value = @model.get('lsStates').getValueById "metadata", @model.get('subclass')+" metadata", file.get('id')
						value[0].set "ignored", true

	handleNewEntityClicked: =>
		@$('.bv_confirmClearEntity').modal('show')
		@$('.bv_confirmClear').removeAttr('disabled')
		@$('.bv_cancelClear').removeAttr('disabled')
		@$('.bv_closeModalButton').removeAttr('disabled')

	handleCancelClearClicked: =>
		@$('.bv_confirmClearEntity').modal('hide')

	handleConfirmClearClicked: =>
		@$('.bv_confirmClearEntity').modal('hide')
		if @model.get('lsKind') is "default" #base protocol/experiment
			@model = null
			@completeInitialization()
		else
			@trigger 'reinitialize'
		@trigger 'amClean'

	handleCancelClicked: =>
		if @model.isNew()
			if @model.get('lsKind') is "default" #base protocol/experiment
				@model = null
				@completeInitialization()
			else
				@trigger 'reinitialize'
		else
			@$('.bv_canceling').show()
			@model.fetch
				success: @handleCancelComplete
		@trigger 'amClean'

	handleCancelComplete: =>
		@$('.bv_canceling').hide()
		@$('.bv_cancelComplete').show()

	validationError: =>
		super()
		@$('.bv_save').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_save').removeAttr('disabled')

	checkDisplayMode: =>
		status = @model.getStatus().get('codeValue')
		if @readOnly is true or !@canEdit()
			@displayInReadOnlyMode()
		else if status is "deleted" or status is "approved" or status is "rejected"
			@disableAllInputs()
			if @model.getStatus().get('codeValue') != "deleted" and @canEdit()
				@$('.bv_status').removeAttr 'disabled'
			@$('.bv_newEntity').removeAttr('disabled')
			@$('.bv_newEntity').removeAttr('disabled')

	displayInReadOnlyMode: =>
		@$(".bv_save").hide()
		@$(".bv_cancel").hide()
		@$(".bv_newEntity").hide()
		@$(".bv_addFileInfo").hide()
		@disableAllInputs()

	isValid: =>
		validCheck = super()
		if @attachFileListController?
			if @attachFileListController.isValid() is true
				return validCheck
			else
				@$('.bv_save').attr('disabled', 'disabled')
				return false
		else
			return validCheck