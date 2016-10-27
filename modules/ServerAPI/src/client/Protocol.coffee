class window.Protocol extends BaseEntity
	urlRoot: "/api/protocols"

	initialize: ->
		@.set subclass: "protocol"
		super()

	parse: (resp) =>
		if resp == "not unique protocol name" or resp == '"not unique protocol name"'
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
			if resp.lsTags not instanceof TagList
				resp.lsTags = new TagList(resp.lsTags)
				resp.lsTags.on 'change', =>
					@trigger 'change'
			resp

	getCreationDate: ->
		@.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "dateValue", "creation date"

	getAssayTreeRule: ->
		assayTreeRule = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "stringValue", "assay tree rule"
		if assayTreeRule.get('stringValue') is undefined
			assayTreeRule.set stringValue: ""

		assayTreeRule

	getAssayStage: ->
		assayStage = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "codeValue", "assay stage"
		if assayStage.get('codeValue') is undefined or assayStage.get('codeValue') is "" or assayStage.get('codeValue') is null
			assayStage.set codeValue: "unassigned"
			assayStage.set codeType: "assay"
			assayStage.set codeKind: "stage"
			assayStage.set codeOrigin: "ACAS DDICT"

		assayStage

	getAssayPrinciple: ->
		assayPrinciple = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "clobValue", "assay principle"
		if assayPrinciple.get('clobValue') is undefined
			assayPrinciple.set clobValue: ""

		assayPrinciple


	validate: (attrs) ->
		errors = []
		errors.push super(attrs)...
		if attrs.subclass?
			cDate = @getCreationDate().get('dateValue')
			if cDate is undefined or cDate is "" or cDate is null then cDate = "fred"
			if isNaN(cDate)
				errors.push
					attribute: 'creationDate'
					message: "Date must be set"
		#don't call @getAssayTreeRule because will create value if it doesn't exist
		assayTreeRule = @get('lsStates').getStateValueByTypeAndKind "metadata", "protocol metadata", "stringValue", "assay tree rule"
		if assayTreeRule?
			assayTreeRule = assayTreeRule.get('stringValue')
			unless assayTreeRule is "" or assayTreeRule is undefined or assayTreeRule is null
				if assayTreeRule.charAt([0]) != "/"
					errors.push
						attribute: 'assayTreeRule'
						message: "Assay tree rule must start with '/'"
				else if assayTreeRule.charAt([assayTreeRule.length-1]) is "/"
					errors.push
						attribute: 'assayTreeRule'
						message: "Assay tree rule should not end with '/'"

		if errors.length > 0
			return errors
		else
			return null

	isStub: ->
		return @get('lsLabels').length == 0 #protocol stubs won't have this

	duplicateEntity: =>
		copiedEntity = super()
		copiedEntity.getCreationDate().set dateValue: null
		copiedEntity

class window.ProtocolList extends Backbone.Collection
	model: Protocol

class window.ProtocolBaseController extends BaseEntityController
	template: _.template($("#ProtocolBaseView").html())
	moduleLaunchName: "protocol_base"

	events: ->
		_(super()).extend(
			"keyup .bv_protocolName": "handleNameChanged"
			"keyup .bv_assayTreeRule": "handleAssayTreeRuleChanged"
			"change .bv_assayStage": "handleAssayStageChanged"
			"keyup .bv_assayPrinciple": "handleAssayPrincipleChanged"
			"change .bv_creationDate": "handleCreationDateChanged"
			"click .bv_creationDateIcon": "handleCreationDateIconClicked"
			"click .bv_closeDeleteProtocolModal": "handleCloseProtocolModal"
			"click .bv_confirmDeleteProtocolButton": "handleConfirmDeleteProtocolClicked"
			"click .bv_cancelDelete": "handleCancelDeleteClicked"

		)

	initialize: =>
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/protocols/codename/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) ->
							alert 'Could not get protocol for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get protocol for code in this URL, creating new one'
							else
								lsKind = json.lsKind
								if lsKind is "default"
									prot = new Protocol json
									prot.set prot.parse(prot.attributes)
									if window.AppLaunchParams.moduleLaunchParams.copy
										@model = prot.duplicateEntity()
									else
										@model = prot
								else
									alert 'Could not get protocol for code in this URL. Creating new protocol'
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new Protocol()
		@errorOwnerName = 'ProtocolBaseController'
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		if window.conf.protocol?.showAssayTreeRule? and window.conf.protocol.showAssayTreeRule is true
			@$('.bv_group_assayTreeRule').show()
		else
			@$('.bv_group_assayTreeRule').hide()
		@model.on 'notUniqueName', =>
			@$('.bv_protocolSaveFailed').modal('show')
			$('.bv_closeSaveFailedModal').removeAttr('disabled')
			@$('.bv_saveFailed').show()
#			@$('.bv_protocolSaveFailed').on 'hide.bs.modal', =>
#				@$('.bv_saveFailed').hide()
			$('.bv_protocolSaveFailed').on 'hidden', =>
				@$('.bv_saveFailed').hide()
		@model.on 'saveFailed', =>
			@$('.bv_saveFailed').show()
		@setupStatusSelect()
		@setupScientistSelect()
		@setupTagList()
		@setUpAssayStageSelect()
		@setupAttachFileListController()
		@render()
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'change', @modelChangeCallback
		@model.getStatus().on 'change', @updateEditable
#		@trigger 'amClean' #so that module starts off clean when initialized

	render: =>
		unless @model?
			@model = new Protocol()
		@setUpAssayStageSelect()
		@$('.bv_creationDate').datepicker();
		@$('.bv_creationDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.getCreationDate().get('dateValue')?
			@$('.bv_creationDate').val UtilityFunctions::convertMSToYMDDate(@model.getCreationDate().get('dateValue'))
		@$('.bv_assayTreeRule').val @model.getAssayTreeRule().get('stringValue')
		@$('.bv_assayPrinciple').val @model.getAssayPrinciple().get('clobValue')
		super()
		@

	modelSyncCallback: =>
		unless @model.get('subclass')?
			@model.set subclass: 'protocol'
		@$('.bv_saving').hide()
		if @$('.bv_saveFailed').is(":visible") or @$('.bv_cancelComplete').is(":visible")
			@$('.bv_updateComplete').hide()
			@trigger 'amDirty'
		else
			@$('.bv_updateComplete').show()
		unless @model.get('lsKind') is "default"
			@$('.bv_newEntity').hide()
			@$('.bv_cancel').hide()
			@$('.bv_save').hide()
		@trigger 'amClean'
		@render()
		if @model.get('lsType') is "default"
			@setupAttachFileListController()

	setUpAssayStageSelect: ->
		@assayStageList = new PickListList()
		@assayStageList.url = "/api/codetables/assay/stage"
		@assayStageListController = new PickListSelectController
			el: @$('.bv_assayStage')
			collection: @assayStageList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Assay Stage"
			selectedCode: @model.getAssayStage().get('codeValue')

	finishSetupAttachFileListController: (attachFileList, fileTypeList) ->
		if @attachFileListController?
			@attachFileListController.undelegateEvents()
		@attachFileListController= new AttachFileListController
			autoAddAttachFileModel: false
			el: @$('.bv_attachFileList')
			collection: attachFileList
			firstOptionName: "Select Method"
			allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf', 'rar', 'zip', 'tar']
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

	handleDeleteStatusChosen: =>
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingProtocolMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_experimentDeletedSuccessfullyMessage").addClass "hide"
		@$(".bv_confirmDeleteProtocolModal").removeClass "hide"

		@$('.bv_confirmDeleteProtocolModal').modal
			backdrop: 'static'

	handleCloseProtocolModal: =>
		@statusListController.setSelectedCode @model.getStatus().get('codeValue')

	handleConfirmDeleteProtocolClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		@$(".bv_protocolCodeName").html @model.get('codeName')
		$.ajax(
			url: "/api/protocols/browser/#{@model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_protocolDeletedSuccessfullyMessage").removeClass "hide"
				@handleValueChanged "Status", "deleted"
				@updateEditable()
				@trigger 'amClean'
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingProtocolMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteProtocolModal").modal('hide')
		@statusListController.setSelectedCode @model.getStatus().get('codeValue')

	handleCreationDateChanged: =>
		value = UtilityFunctions::convertYMDDateToMs(UtilityFunctions::getTrimmedInput @$('.bv_creationDate'))
		@handleValueChanged "CreationDate", value


	handleCreationDateIconClicked: =>
		@$( ".bv_creationDate" ).datepicker( "show" )

	handleAssayStageChanged: =>
		value = @assayStageListController.getSelectedCode()
		@handleValueChanged "AssayStage", value

	handleAssayPrincipleChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_assayPrinciple')
		@handleValueChanged "AssayPrinciple", value

	handleAssayTreeRuleChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_assayTreeRule')
		@handleValueChanged "AssayTreeRule", value
