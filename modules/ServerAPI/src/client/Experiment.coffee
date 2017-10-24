class window.Experiment extends BaseEntity
	urlRoot: "/api/experiments"
	defaults: ->
		_(super()).extend(
			protocol: null
			analysisGroups: new AnalysisGroupList()
		)

	initialize: ->
		@.set subclass: "experiment"
		super()
		unless window.conf.include.project?
			console.dir "config for client.include.project is not set"

	parse: (resp) =>
		if resp == "not unique experiment name" or resp == '"not unique experiment name"'
			@trigger 'notUniqueName'
			resp
		else if resp == "saveFailed" or resp == '"saveFailed"'
			@trigger 'saveFailed'
			resp
		else
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
			if resp.analysisGroups?
				if resp.analysisGroups not instanceof AnalysisGroupList
					resp.analysisGroups = new AnalysisGroupList(resp.analysisGroups)
				resp.analysisGroups.on 'change', =>
					@trigger 'change'
			if resp.protocol?
				if resp.protocol not instanceof Protocol
					resp.protocol = new Protocol(resp.protocol)
			if resp.lsTags not instanceof TagList
				resp.lsTags = new TagList(resp.lsTags)
				resp.lsTags.on 'change', =>
					@trigger 'change'
			resp

	copyProtocolAttributes: (protocol) =>
#only need to copy protocol's experiment metadata attributes
		pstates = protocol.get('lsStates')
		pExptMeta = pstates.getStatesByTypeAndKind "metadata", "experiment metadata"
		if pExptMeta.length > 0
			eExptMeta = @.get('lsStates').getStatesByTypeAndKind "metadata", "experiment metadata"
			if eExptMeta.length > 0
				dapVal = eExptMeta[0].getValuesByTypeAndKind "clobValue", "data analysis parameters"
				if dapVal.length > 0
#mark existing data analysis parameters, model fit parameters, and model fit type as ignored
					if dapVal[0].isNew()
						eExptMeta[0].get('lsValues').remove dapVal[0]
					else
						dapVal[0].set ignored: true
			else
				eExptMeta = [@.get('lsStates').getOrCreateStateByTypeAndKind("metadata", "experiment metadata")]
			dap = new Value(_.clone(pstates.getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "data analysis parameters").attributes)
			dap.unset 'id'
			dap.unset 'lsTransaction'
			eExptMeta[0].get('lsValues').add dap

			mfpVal = eExptMeta[0].getValuesByTypeAndKind "clobValue", "model fit parameters"
			if mfpVal.length > 0
				if mfpVal[0].isNew()
					eExptMeta[0].get('lsValues').remove mfpVal[0]
				else
					mfpVal[0].set ignored: true
			mfp = new Value(_.clone(pstates.getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "model fit parameters").attributes)
			mfp.unset 'id'
			mfp.unset 'lsTransaction'
			eExptMeta[0].get('lsValues').add mfp

			mftVal = eExptMeta[0].getValuesByTypeAndKind "codeValue", "model fit type"
			if mftVal.length > 0
				if mftVal[0].isNew()
					eExptMeta[0].get('lsValues').remove mftVal[0]
				else
					mftVal[0].set ignored: true
			mft = new Value(_.clone(pstates.getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "codeValue", "model fit type").attributes)
			mft.unset 'id'
			mft.unset 'lsTransaction'
			eExptMeta[0].get('lsValues').add mft

			mftransVal = eExptMeta[0].getValuesByTypeAndKind "stringValue", "model fit transformation"
			if mftransVal.length > 0
				if mftransVal[0].isNew()
					eExptMeta[0].get('lsValues').remove mftransVal[0]
				else
					mftransVal[0].set ignored: true
			mftrans = new Value(_.clone(pstates.getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "model fit transformation").attributes)
			mftrans.unset 'id'
			mftrans.unset 'lsTransaction'
			eExptMeta[0].get('lsValues').add mftrans

			mftuVal = eExptMeta[0].getValuesByTypeAndKind "codeValue", "model fit transformation units"
			if mftuVal.length > 0
				if mftuVal[0].isNew()
					eExptMeta[0].get('lsValues').remove mftuVal[0]
				else
					mftuVal[0].set ignored: true
			mftu = new Value(_.clone(pstates.getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "codeValue", "model fit transformation units").attributes)
			mftu.unset 'id'
			mftu.unset 'lsTransaction'
			eExptMeta[0].get('lsValues').add mftu

		# 		commented because experiment base does not have these values
		#			@getDryRunStatus().set ignored: true
		#			@getDryRunStatus().set codeValue: 'not started'
		#			@getDryRunResultHTML().set ignored: true
		#			@getDryRunResultHTML().set clobValue: ""

		@set
			lsKind: protocol.get('lsKind')
			protocol: protocol
		@trigger 'change'
		@trigger "protocol_attributes_copied"
		return

	validate: (attrs) ->
		errors = []
		bestName = attrs.lsLabels.pickBestName()
		nameError = true
		if bestName?
			nameError = true
			if bestName.get('labelText') != ""
				nameError = false
			if bestName.get('labelText') == attrs.codeName
				nameError = false
		else if @isNew() and bestName is undefined
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
		if attrs.protocol == null
			errors.push
				attribute: 'protocolCode'
				message: "Protocol must be set"
		if attrs.subclass?
			unless window.conf.save?.project? and window.conf.save.project.toLowerCase() is "false"
				reqProject = window.conf.include.project
				unless reqProject?
					reqProject = "true"
				reqProject = reqProject.toLowerCase()
				unless reqProject is "false"
					projectCode = @getProjectCode().get('codeValue')
					if projectCode is "" or projectCode is "unassigned" or projectCode is undefined
						errors.push
							attribute: 'projectCode'
							message: "Project must be set"
			cDate = @getCompletionDate().get('dateValue')
			if cDate is undefined or cDate is "" or cDate is null then cDate = "fred"
			if isNaN(cDate)
				errors.push
					attribute: 'completionDate'
					message: "Assay completion date must be set"

		if errors.length > 0
			return errors
		else
			return null

	getProjectCode: ->
		projectCodeValue = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "codeValue", "project"
		if projectCodeValue.get('codeValue') is undefined or projectCodeValue.get('codeValue') is ""
			projectCodeValue.set codeValue: "unassigned"
			projectCodeValue.set codeType: "project"
			projectCodeValue.set codeKind: "biology"
			projectCodeValue.set codeOrigin: "ACAS DDICT"

		projectCodeValue

	getAnalysisStatus: ->
		metadataKind = @.get('subclass') + " metadata"
		status = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", metadataKind, "codeValue", "analysis status"
		#		status = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "analysis status"
		if status.get('codeValue') is undefined or status.get('codeValue') is ""
			status.set codeValue: "not started"
			status.set codeType: "analysis"
			status.set codeKind: "status"
			status.set codeOrigin: "ACAS DDICT"

		status

	getCompletionDate: ->
		@.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "dateValue", "completion date"

	getAttachedFiles: (fileTypes) =>
#get list of possible kinds of analytical files
		attachFileList = new ExperimentAttachFileList()
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

			# get files not saved in metadata_experiment metadata state
			if (type.code is "source file") or type.code is "annotation file"
				if type.code is "source file"
					file = @getSourceFile()
				else
					file = @getSELReportFile()
				if file?
					displayName = file.get('comments')
					fileModel = new AttachFile
						fileType: type.code
						fileValue: file.get('fileValue')
						id: file.get('id')
						comments: displayName
					attachFileList.add fileModel
		attachFileList

	getSourceFile: ->
		@get('lsStates').getStateValueByTypeAndKind "metadata", "experiment metadata", "fileValue", "source file"

	getSELReportFile: -> #for getting report files uploaded through SEL
		@get('lsStates').getStateValueByTypeAndKind "metadata", "report locations", "fileValue", "annotation file"

	duplicateEntity: =>
		copiedEntity = super()
		copiedEntity.getCompletionDate().set dateValue: null
		copiedEntity

	prepareToSave: =>
		valuesToDelete = [
			type: 'codeValue'
			kind: 'analysis status'
		,
			type: 'codeValue'
			kind: 'dry run status'
		,
			type: 'codeValue'
			kind: 'model fit status'
		,
			type: 'clobValue'
			kind: 'data analysis parameters'
		,
			type: 'clobValue'
			kind: 'model fit parameters'
		,
			type: 'clobValue'
			kind: 'analysis result html'
		,
			type: 'clobValue'
			kind: 'dry run result html'
		,
			type: 'codeValue'
			kind: 'model fit type'
		,
			type: 'clobValue'
			kind: 'model fit result html'
		,
			type: 'fileValue'
			kind: 'source file'
		,
			type: 'fileValue'
			kind: 'dryrun source file'
		,
			type: 'stringValue'
			kind: 'hts format'
		,
			type: 'stringValue'
			kind: 'model fit transformation'
		,
			type: 'codeValue'
			kind: 'model fit transformation units'
		]
		unless @isNew()
			expState = @get('lsStates').getStatesByTypeAndKind("metadata", "experiment metadata")[0]
			for val in valuesToDelete
				value = expState.getValuesByTypeAndKind(val.type, val.kind)[0]
				if value?
					if ((val.kind is "data analysis parameters" or val.kind is "model fit parameters" or val.kind is "model fit type" or val.kind is "dry run status" or val.kind  is "dry run html" or val.kind is "source file") and value.isNew())
					else
						expState.get('lsValues').remove value
		super()

class window.ExperimentList extends Backbone.Collection
	model: Experiment

class window.ExperimentBaseController extends BaseEntityController
	template: _.template($("#ExperimentBaseView").html())
	moduleLaunchName: "experiment_base"

	events: ->
		_(super()).extend(
			"click .bv_exptNameChkbx": "handleExptNameChkbxClicked"
			"keyup .bv_experimentName": "handleNameChanged"
			"click .bv_useProtocolParameters": "handleUseProtocolParametersClicked"
			"change .bv_protocolCode": "handleProtocolCodeChanged"
			"change .bv_projectCode": "handleProjectCodeChanged"
			"change .bv_completionDate": "handleDateChanged"
			"click .bv_completionDateIcon": "handleCompletionDateIconClicked"
			"click .bv_keepOldParams": "handleKeepOldParams"
			"click .bv_useNewParams": "handleUseNewParams"
			"click .bv_closeDeleteExperimentModal": "handleCloseExperimentModal"
			"click .bv_confirmDeleteExperimentButton": "handleConfirmDeleteExperimentClicked"
			"click .bv_cancelDelete": "handleCancelDeleteClicked"
		)

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					if window.AppLaunchParams.moduleLaunchParams.createFromOtherEntity
						@createExperimentFromProtocol(window.AppLaunchParams.moduleLaunchParams.code)
						@completeInitialization()
					else
						$.ajax
							type: 'GET'
							url: "/api/experiments/codename/"+window.AppLaunchParams.moduleLaunchParams.code
							dataType: 'json'
							error: (err) =>
								alert 'Could not get experiment for code in this URL, creating new one'
								@completeInitialization()
							success: (json) =>
								if json.length == 0
									alert 'Could not get experiment for code in this URL, creating new one'
								else
									lsKind = json.lsKind #doesn't work for specRunner mode. In stubs mode, doesn't return array but for non-stubsMode,this works for now - see todo above
									if lsKind is "default"
										expt = new Experiment json
										expt.set expt.parse(expt.attributes)
										if window.AppLaunchParams.moduleLaunchParams.copy
											@model = expt.duplicateEntity()
										else
											@model = expt
									else
										alert 'Could not get experiment for code in this URL. Creating new experiment'
								@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	createExperimentFromProtocol: (code) ->
		@model = new Experiment()
		@model.set protocol: new Protocol
			codeName: code
		@getAndSetProtocol(code, true)

	completeInitialization: ->
		unless @model?
			@model = new Experiment()
		@errorOwnerName = 'ExperimentBaseController'
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		if window.conf.experiment?.hideFields? and window.conf.experiment.hideFields != null
			for field in window.conf.experiment.hideFields.split(",")
				field = $.trim field
				@$('.bv_group_'+field).hide()
		@model.on 'notUniqueName', =>
#			@$('.bv_exptLink').attr("href", "/api/experiments/experimentName/"+@model.get('lsLabels').pickBestName().get('labelText'))
#TODO: redirect user to experiment browser with a list of experiments with same name
			@$('.bv_experimentSaveFailed').modal('show')
			@$('.bv_closeSaveFailedModal').removeAttr('disabled')
			@$('.bv_saveFailed').show()
			@$('.bv_experimentSaveFailed').on 'hide.bs.modal', =>
				@$('.bv_saveFailed').hide()
		@model.on 'saveFailed', =>
			@$('.bv_saveFailed').show()
		@setupStatusSelect()
		@setupScientistSelect()
		@setupTagList()
		@setupProtocolSelect(@options.protocolFilter, @options.protocolKindFilter)
		if window.conf.save?.project? and window.conf.save.project.toLowerCase() is "false"
			@$('.bv_group_projectCode').hide()
		else
			@setupProjectSelect()
		@setupAttachFileListController()
		@setupCustomExperimentMetadataController()
		@render()
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'change', @modelChangeCallback
		@model.getStatus().on 'change', @updateEditable

	render: =>
		unless @model?
			@model = new Experiment()
		if @model.get('protocol') != null
			@$('.bv_protocolCode').val(@model.get('protocol').get('codeName'))
		unless window.conf.save?.project? and window.conf.save.project.toLowerCase() is "false"
			@$('.bv_projectCode').val(@model.getProjectCode().get('codeValue'))
		@setUseProtocolParametersDisabledState()
		@$('.bv_completionDate').datepicker();
		@$('.bv_completionDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.getCompletionDate().get('dateValue')?
			@$('.bv_completionDate').val UtilityFunctions::convertMSToYMDDate(@model.getCompletionDate().get('dateValue'))
		super()
		if @model.isNew()
			@$('.bv_experimentName').attr('disabled','disabled')
			@$('.bv_openInQueryToolWrapper').hide()
		else
			@setupExptNameChkbx()
			if @model.getStatus().get('codeValue') is 'deleted'
				@$('.bv_openInQueryToolWrapper').hide()
			else
				@$('.bv_openInQueryToolWrapper').show()
			@$('.bv_queryToolDisplayName').html window.conf.service.result.viewer.displayName
			@$('.bv_openInQueryToolLink').attr 'href', "/openExptInQueryTool?experiment="+@model.get('codeName')
		@

	modelSyncCallback: =>
		unless @model.get('subclass')?
			@model.set subclass: 'experiment'
		@$('.bv_saving').hide()
		@render()
		if @$('.bv_saveFailed').is(":visible") or @$('.bv_cancelComplete').is(":visible")
			@$('.bv_updateComplete').hide()
			@trigger 'amDirty'
		else if @$('.bv_cancelComplete').is(":visible")
			@trigger 'amClean'
		else
			@$('.bv_updateComplete').show()
			@trigger 'amClean'
			@model.trigger 'saveSuccess'
		@setupAttachFileListController()

	finishSetupAttachFileListController: (attachFileList, fileTypeList) ->
		if @attachFileListController?
			@attachFileListController.undelegateEvents()
		@attachFileListController= new ExperimentAttachFileListController
			autoAddAttachFileModel: false
			el: @$('.bv_attachFileList')
			collection: attachFileList
			firstOptionName: "Select Method"
			allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf', 'zip']
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

	setupExptNameChkbx: ->
		code = @model.get('codeName')
		if @model.get('lsLabels').pickBestName()?
			name = @model.get('lsLabels').pickBestName().get('labelText')
		else
			name = ""
		if code == name
			@$('.bv_experimentName').attr('disabled', 'disabled')
			@$('.bv_exptNameChkbx').attr('checked','checked')
		else
			@$('.bv_exptNameChkbx').removeAttr('checked')

	setupProtocolSelect: (protocolFilter, protocolKindFilter) ->
		if @model.get('protocol') != null
			protocolCode = @model.get('protocol').get('codeName')
		else
			protocolCode = "unassigned"
		@protocolList = new PickListList()
		if protocolFilter?
			@protocolList.url = "/api/protocolCodes/"+protocolFilter
		else if protocolKindFilter?
			@protocolList.url = "/api/protocolCodes/"+protocolKindFilter
		else
			@protocolList.url = "/api/protocolCodes/?protocolKind=default"

		@protocolListController = new PickListSelectController
			el: @$('.bv_protocolCode')
			collection: @protocolList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Protocol"
			selectedCode: protocolCode

	setupProjectSelect: ->
		reqProject = window.conf.include.project
		if reqProject?
			if reqProject.toLowerCase() is "false"
				@$('.bv_projectLabel').html "Project"
		@projectList = new PickListList()
		@projectList.url = "/api/projects"
		@projectListController = new PickListSelectController
			el: @$('.bv_projectCode')
			collection: @projectList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Project"
			selectedCode: @model.getProjectCode().get('codeValue')

	setupStatusSelect: ->
		@statusList = new PickListList()
		@statusList.url = "/api/codetables/experiment/status"
		@statusListController = new PickListSelectController
			el: @$('.bv_status')
			collection: @statusList
			selectedCode: @model.getStatus().get 'codeValue'

	setupTagList: ->
		@$('.bv_tags').val ""
		@tagListController = new TagListController
			el: @$('.bv_tags')
			collection: @model.get 'lsTags'
		@tagListController.render()

	setupCustomExperimentMetadataController: ->
		experimentStates = @model.get('lsStates')
		customExperimentMetaDataState = experimentStates.getStatesByTypeAndKind "metadata", "custom experiment metadata"
		if customExperimentMetaDataState.length > 0
			@customerExperimentMetadataListController = new CustomExperimentMetadataListController
				el: @$('.bv_custom_experiment_metadata')
				model: @model
			@customerExperimentMetadataListController.render()

	setUseProtocolParametersDisabledState: ->
		if (not @model.isNew()) or (@model.get('protocol') == null) or (@protocolListController.getSelectedCode() == "")
			@$('.bv_useProtocolParameters').attr("disabled", "disabled")
		else
			@$('.bv_useProtocolParameters').removeAttr("disabled")

	handleDeleteStatusChosen: =>
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingExperimentMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_experimentDeletedSuccessfullyMessage").addClass "hide"
		@$(".bv_confirmDeleteExperimentModal").removeClass "hide"

		@$('.bv_confirmDeleteExperimentModal').modal
			backdrop: 'static'

	handleCloseExperimentModal: =>
		@statusListController.setSelectedCode @model.getStatus().get('codeValue')

	handleConfirmDeleteExperimentClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		@$(".bv_experimentCodeName").html @model.get('codeName')
		$.ajax(
			url: "/api/experiments/#{@model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_experimentDeletedSuccessfullyMessage").removeClass "hide"
				@handleValueChanged "Status", "deleted"
				@updateEditable()
				@trigger 'amClean'
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingExperimentMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteExperimentModal").modal('hide')
		@statusListController.setSelectedCode @model.getStatus().get('codeValue')

	getFullProtocol: ->
		if @model.get('protocol') != null
			if @model.get('protocol').isStub()
				@model.get('protocol').fetch success: =>
					newProtName = @model.get('protocol').get('lsLabels').pickBestLabel().get('labelText')
					@setUseProtocolParametersDisabledState()
					unless !@model.isNew()
						@handleUseProtocolParametersClicked()
			else
				@setUseProtocolParametersDisabledState()
				@handleUseProtocolParametersClicked()

	handleExptNameChkbxClicked: =>
		checked = @$('.bv_exptNameChkbx').is(":checked")
		if checked
			@$('.bv_experimentName').attr('disabled', 'disabled')
			@$('.bv_experimentName').val @model.get('codeName')
			@handleNameChanged()
			if @model.isNew()
				@model.get('lsLabels').pickBestName().set labelText: undefined
#need to specifically set this here or else labelText is set to "" and will have an error even if the checkbox is checked
		else
			@$('.bv_experimentName').removeAttr('disabled')
			@handleNameChanged()

	handleProtocolCodeChanged: =>
		code = @protocolListController.getSelectedCode()
		if @model.isNew()
			@getAndSetProtocol(code, true)
		unless @model.isNew()
			if (@model.get('lsKind') is "default")
				@getAndSetProtocol(code, false) #base experiments don't have analysis parameters
			else
				analysisStatus = @model.getAnalysisStatus().get('codeValue')
				if analysisStatus is "not started"
					@$('.bv_askChangeProtocolParameters').modal({
						backdrop: 'static'
					})
					@$('.bv_askChangeProtocolParameters').modal('show')
				else
					@$('.bv_dontChangeProtocolParameters').modal('show')
					@getAndSetProtocol(code, false)

	getAndSetProtocol: (code, setAnalysisParams) ->
		if code == "" || code == "unassigned"
			@model.set 'protocol': null
			#@getFullProtocol()
			@setUseProtocolParametersDisabledState()
		else
			@$('.bv_protocolCode').attr('disabled','disabled')
			@$('.bv_spinner').spin('aligned')
			$.ajax
				type: 'GET'
				url: "/api/protocols/codename/"+code
				success: (json) =>
					@$('.bv_spinner').spin(false)
					@$('.bv_protocolCode').removeAttr('disabled')
					if json.length == 0
						alert("Could not find selected protocol in database")
					else
						@model.set protocol: new Protocol(json)
						if setAnalysisParams
							@getFullProtocol() # this will fetch full protocol
				error: (err) ->
					alert 'got ajax error from getting protocol '+ code
				dataType: 'json'

	handleKeepOldParams: =>
		@$('.bv_askChangeProtocolParameters').modal('hide')
		@getAndSetProtocol(@protocolListController.getSelectedCode(), false)

	handleUseNewParams: =>
		@$('.bv_askChangeProtocolParameters').modal('hide')
		@getAndSetProtocol(@protocolListController.getSelectedCode(), true)

	handleProjectCodeChanged: =>
		value = @projectListController.getSelectedCode()
		@handleValueChanged "ProjectCode", value

	handleUseProtocolParametersClicked: =>
		@model.copyProtocolAttributes(@model.get('protocol'))
		exptChkbx = @$('.bv_exptNameChkbx').attr('checked') #render will always disable the expt name field if new.
		# Remember if checkbox was checked and then display expt name field properly after render is called.
		@render()
		if exptChkbx is "checked"
			@$('.bv_experimentName').attr('disabled', 'disabled')
		else
			@$('.bv_experimentName').removeAttr('disabled')
		@model.trigger 'change' #need to trigger change because render will call updateEditable, which disables the save button
		unless @model.isNew()
			@model.trigger 'changeProtocolParams'

	handleDateChanged: =>
		value = UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_completionDate'))
		@handleValueChanged "CompletionDate", value

	handleCompletionDateIconClicked: =>
		@$( ".bv_completionDate" ).datepicker( "show" )

	handleSaveClicked: =>
		@$('.bv_saveFailed').hide()
		if @model.isNew() and @$('.bv_exptNameChkbx').is(":checked")
			@getNextLabelSequence()
		else
			@saveEntity()

	getNextLabelSequence: =>
		$.ajax
			type: 'POST'
			url: "/api/getNextLabelSequence"
			data:
				JSON.stringify
					thingTypeAndKind: "document_experiment"
					labelTypeAndKind: "id_codeName"
					numberOfLabels: 1
			contentType: 'application/json'
			dataType: 'json'
			success: (response) =>
				if response is "getNextLabelSequenceFailed"
					alert 'Error getting the next label sequence'
					@model.trigger 'saveFailed'
				else
					@addNameAndCode(response[0].autoLabel)
			error: (err) =>
				alert 'could not get next label sequence'
				@serviceReturn = null

	addNameAndCode: (codeName) ->
		@model.set codeName: codeName
		if @model.get('lsLabels').pickBestName()?
			@model.get('lsLabels').pickBestName().set labelText: codeName
		else
			@model.get('lsLabels').setBestName new Label
				lsKind: "experiment name"
				labelText: codeName
				recordedBy: window.AppLaunchParams.loginUser.username
				recordedDate: new Date().getTime()

		@saveEntity()


	displayInReadOnlyMode: =>
		super()
		@$('.bv_openInQueryToolWrapper').hide()