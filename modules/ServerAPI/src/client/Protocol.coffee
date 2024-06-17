class Protocol extends BaseEntity
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
				.bind(@)
			if resp.lsStates?
				if resp.lsStates not instanceof StateList
					resp.lsStates = new StateList(resp.lsStates)
				resp.lsStates.on 'change', =>
					@trigger 'change'
				.bind(@)
			if resp.lsTags not instanceof TagList
				resp.lsTags = new TagList(resp.lsTags)
				resp.lsTags.on 'change', =>
					@trigger 'change'
				.bind(@)
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

	getRequiredEntityType: ->
		requiredEntityType = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "codeValue", "required entity type"
		if requiredEntityType.get('codeValue') is undefined or requiredEntityType.get('codeValue') is "" or requiredEntityType.get('codeValue') is null
			requiredEntityType.set codeValue: "unassigned"
			requiredEntityType.set codeType: "entity type"
			requiredEntityType.set codeKind: "required entity type"
			requiredEntityType.set codeOrigin: "ACAS Configured Entity"

		requiredEntityType

	getAssayPrinciple: ->
		assayPrinciple = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "clobValue", "assay principle"
		if assayPrinciple.get('clobValue') is undefined
			assayPrinciple.set clobValue: ""

		assayPrinciple

	getProjectCode: ->
		projectCodeValue = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "codeValue", "project"
		if projectCodeValue.get('codeValue') is undefined or projectCodeValue.get('codeValue') is ""
			projectCodeValue.set codeValue: "unassigned"
			projectCodeValue.set codeType: "project"
			projectCodeValue.set codeKind: "biology"
			projectCodeValue.set codeOrigin: "ACAS DDICT"

		projectCodeValue

	getSelRequiredAttr: (attr) =>
		selRequiredAttrCodeValue = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "codeValue", attr
		if selRequiredAttrCodeValue.get('codeValue') is undefined or selRequiredAttrCodeValue.get('codeValue') is ""
			selRequiredAttrCodeValue.set codeValue: "false"
			selRequiredAttrCodeValue.set codeType: "protocol"
			selRequiredAttrCodeValue.set codeKind: "sel required attribute"
			selRequiredAttrCodeValue.set codeOrigin: "ACAS DDICT"

		selRequiredAttrCodeValue

	getCurveDisplayMin: ->
		minY = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "screening assay", "numericValue", "curve display min"
		if (minY.get('numericValue') is undefined or minY.get('numericValue') is "") and @isNew()
			minY.set numericValue: -20.0

		minY

	getCurveDisplayMax: ->
		maxY = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "screening assay", "numericValue", "curve display max"
		if (maxY.get('numericValue') is undefined or maxY.get('numericValue') is "") and @isNew()
			maxY.set numericValue: 120.0

		maxY
			
	getStrictEndpointMatching: ->
		strictEndpointMatching = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "codeValue", "strict endpoint matching"		
		if strictEndpointMatching.get('codeValue') is undefined or strictEndpointMatching.get('codeValue') is ""
			if window.conf.protocol.strictEndpointMatchingDefault == false 
				strictEndpointMatching.set codeValue: "false"
			else 
				strictEndpointMatching.set codeValue: "true"
			strictEndpointMatching.set codeType: "boolean"
			strictEndpointMatching.set codeKind: "boolean"
			strictEndpointMatching.set codeOrigin: "ACAS DDICT"

		strictEndpointMatching
		
	validate: (attrs) ->
		errors = super(attrs)
		if !errors?
			errors = []

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
		if window.conf.protocol?.requiredEntityType?.save? and window.conf.protocol.requiredEntityType.save
			if window.conf.protocol?.requiredEntityType?.allowEmpty? and window.conf.protocol.requiredEntityType.allowEmpty is false
				ret = @getRequiredEntityType().get('codeValue')
				if ret is "unassigned" or ret is undefined or ret is "" or ret is null
					errors.push
						attribute: 'requiredEntityType'
						message: "Required entity type must be set"
		if window.conf.protocol?.showCurveDisplayParams?
			showCurveDisplayParams = window.conf.protocol.showCurveDisplayParams
		else
			showCurveDisplayParams = true
		if showCurveDisplayParams
			maxY = @getCurveDisplayMax().get('numericValue')
			if isNaN(maxY) and maxY != "" and maxY?
				errors.push
					attribute: 'maxY'
					message: "maxY must be a number"
			minY = @getCurveDisplayMin().get('numericValue')
			if isNaN(minY) and minY != "" and minY?
				errors.push
					attribute: 'minY'
					message: "minY must be a number"
			if maxY<minY and (maxY!="" and maxY? and minY!="" and minY?)
				errors.push
					attribute: 'maxY'
					message: "maxY must be greater than minY"
				errors.push
					attribute: 'minY'
					message: "minY must be less than maxY"

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

class ProtocolList extends Backbone.Collection
	model: Protocol

class ProtocolBaseController extends BaseEntityController
	template: _.template($("#ProtocolBaseView").html())
	moduleLaunchName: "protocol_base"

	events: ->
		_(super()).extend(
			"keyup .bv_protocolName": "handleNameChanged"
			"keyup .bv_assayTreeRule": "handleAssayTreeRuleChanged"
			"change .bv_assayStage": "handleAssayStageChanged"
			"change .bv_requiredEntityType": "handleRequiredEntityTypeChanged"
			"change .bv_projectCode": "handleProjectCodeChanged"
			"keyup .bv_assayPrinciple": "handleAssayPrincipleChanged"
			"change .bv_creationDate": "handleCreationDateChanged"
			"click .bv_creationDateIcon": "handleCreationDateIconClicked"
			"keyup .bv_maxY": "handleCurveDisplayMaxChanged"
			"keyup .bv_minY": "handleCurveDisplayMinChanged"
			"click .bv_closeDeleteProtocolModal": "handleCloseProtocolModal"
			"click .bv_confirmDeleteProtocolButton": "handleConfirmDeleteProtocolClicked"
			"click .bv_cancelDelete": "handleCancelDeleteClicked"
			"click .bv_strictEndpointMatchingCheckbox": "handleStrictEndpointMatchingChanged"

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
						error: (err) =>
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
									alert 'Could not get #{window.conf.protocol.label} for code in this URL. Creating new #{window.conf.protocol.label}'
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		if !@model?
			@model = new Protocol()
			newProtocol = true 
		else
			newProtocol = false
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
		if window.conf.protocol?.hideFields? and window.conf.protocol.hideFields != null
			for field in window.conf.protocol.hideFields.split(",")
				field = $.trim field
				console.log field
				@$('.bv_group_'+field).hide()
		@model.on 'notUniqueName', =>
			@$('.bv_protocolSaveFailed').modal('show')
			$('.bv_closeSaveFailedModal').removeAttr('disabled')
			@$('.bv_saveFailed').show()
			#			@$('.bv_protocolSaveFailed').on 'hide.bs.modal', =>
			#				@$('.bv_saveFailed').hide()
			$('.bv_protocolSaveFailed').on 'hidden', =>
				@$('.bv_saveFailed').hide()
			.bind(@)
		.bind(@)
		@model.on 'saveFailed', =>
			@$('.bv_saveFailed').show()
		.bind(@)
		@setupStatusSelect()
		@setupScientistSelect()
		@setupTagList()
		@setUpAssayStageSelect()
		@setupAttachFileListController()
		if window.conf.protocol?.save?.project? and !window.conf.protocol.save.project
			@$('.bv_group_projectCode').hide()
		else
			@setupProjectSelect()
		@setupSelRequiredAttrs()
		@render()
		@listenTo @model, 'sync', @modelSyncCallback.bind(@)
		@listenTo @model, 'change', @modelChangeCallback.bind(@)
		@model.getStatus().on 'change', @updateEditable.bind(@)
#		@trigger 'amClean' #so that module starts off clean when initialized

		#if endpoint manager is enabled, render the endpoint table 
		if window.conf.protocol.endpointManager.enabled == true
			# Hack to get Protocol working with Thing-based ACASFormStateTable classes
			@model.lsProperties = {'defaultValues': []}
			# The 'data column order' states are a StateTable
			# Get any existing states with that type & kind

			# Create the controller for the Endpoints table which manages all the states
			@endpointListController = new EndpointListController
				el: @$('.bv_endpointTable')
				model: @model
				readOnly: false
				newProtocol: newProtocol
				view: "protocol"

			@endpointListController.render()

	render: =>
		unless @model?
			@model = new Protocol()
		@setUpAssayStageSelect()
		unless window.conf.protocol?.save?.project? and !window.conf.protocol.save.project
			@$('.bv_projectCode').val(@model.getProjectCode().get('codeValue'))
		@$('.bv_creationDate').datepicker();
		@$('.bv_creationDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.getCreationDate().get('dateValue')?
			@$('.bv_creationDate').val UtilityFunctions::convertMSToYMDDate(@model.getCreationDate().get('dateValue'))
		@$('.bv_assayTreeRule').val @model.getAssayTreeRule().get('stringValue')
		@$('.bv_assayPrinciple').val @model.getAssayPrinciple().get('clobValue')

		#If the endpoint manager is disabled, remove it
		if window.conf.protocol.endpointManager.enabled == false
			@$(".bv_endpointManagerSection").remove()
		else
			#@model.getStrictEndpointMatching().get('codeValue') gives us a string that needs to be converted to a boolean...
			#Using Boolean() will give us true even if we pass "false", so we have to use an if...else... logic to convert it manually. 
			if @model.getStrictEndpointMatching().get('codeValue') == "false"
				strictEndpointMatchingCode = false
			else
				strictEndpointMatchingCode = true
			@$('.bv_strictEndpointMatchingInputCheckbox').prop("checked", strictEndpointMatchingCode);
		showCurveDisplayParams = true
		if window.conf.protocol?.showCurveDisplayParams?
			showCurveDisplayParams = window.conf.protocol.showCurveDisplayParams
		if showCurveDisplayParams
			@$('.bv_maxY').val(@model.getCurveDisplayMax().get('numericValue'))
			@$('.bv_minY').val(@model.getCurveDisplayMin().get('numericValue'))
		else
			@$('.bv_group_curveDisplayWrapper').hide()
		showRequiredEntityType = false
		if window.conf.protocol?.requiredEntityType?.save?
			showRequiredEntityType = window.conf.protocol.requiredEntityType.save
		if showRequiredEntityType
			@setupRequiredEntityType()
		else
			@$('.bv_group_requiredEntityType').hide()
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

	setupRequiredEntityType: ->
		if window.conf.protocol?.requiredEntityType?.allowEmpty? and window.conf.protocol.requiredEntityType.allowEmpty is false
			@$('.bv_requiredEntityTypeLabel').html '*Required Entity Type'
		else
			@$('.bv_requiredEntityTypeLabel').html 'Required Entity Type'
		@requiredEntityTypeList = new PickListList()
		@requiredEntityTypeList.url = "/api/entitymeta/configuredTestedEntityTypes/displayName?asCodes=true"
		@requiredEntityTypeListController = new PickListSelectController
			el: @$('.bv_requiredEntityType')
			collection: @requiredEntityTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Entity Type"
			selectedCode: @model.getRequiredEntityType().get('codeValue')

	setupProjectSelect: ->
		@projectList = new PickListList()
		@projectList.url = "/api/projects"
		@projectListController = new PickListSelectController
			el: @$('.bv_projectCode')
			collection: @projectList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Not Restricted"
			selectedCode: @model.getProjectCode().get('codeValue')

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
		.bind(@)
		@attachFileListController.on 'renderComplete', =>
			@checkDisplayMode()
		.bind(@)
		@attachFileListController.render()
		@attachFileListController.on 'amDirty', =>
			@trigger 'amDirty' #need to put this after the first time @attachFileListController is rendered or else the module will always start off dirty
			@model.trigger 'change'
		.bind(@)

	setupSelRequiredAttrs: =>
		#get codetable values for required sel attrs
		$.ajax
			type: 'GET'
			url: "/api/codetables/protocol/sel required attribute"
			dataType: 'json'
			error: (err) ->
				alert 'Could not get list of sel required attributes'
			success: (json) =>
				unless json.length == 0
					for attr in json
						@setupSelRequiredAttrCheckboxes attr

	setupSelRequiredAttrCheckboxes: (attr) =>
		camelCaseAttrCode = attr.code.replace /\s(.)/g, (match, group1) -> group1.toUpperCase()
		@$('.bv_selRequiredAttributesSection').append '<div class="control-group bv_group_'+camelCaseAttrCode+'">
		<label class="control-label" style="padding-top:2px;">'+attr.name+' Required</label><div class="controls"><input type="checkbox" name="bv_'+camelCaseAttrCode+'" class="bv_'+camelCaseAttrCode+'"/></div></div>'

		currentVal = @model.getSelRequiredAttr attr.code
		if currentVal.get('codeValue') is "true"
			@$(".bv_#{camelCaseAttrCode}").attr 'checked', 'checked'
		else
			@$(".bv_#{camelCaseAttrCode}").removeAttr 'checked'
		@$(".bv_#{camelCaseAttrCode}").on "click", =>
			@handleSelRequiredAttrChkbxChanged attr.code, camelCaseAttrCode
		.bind(@)

	handleSelRequiredAttrChkbxChanged: (attrCode, camelCaseAttrCode) =>
		currentVal = @model.getSelRequiredAttr attrCode
		unless currentVal.isNew()
			currentVal.set 'ignored', true
			currentVal = @model.getSelRequiredAttr attrCode
		currentVal.set 'codeValue', JSON.stringify(@$(".bv_#{camelCaseAttrCode}").is(":checked"))

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
		@$(".bv_protocolCodeName").html @model.escape('codeName')
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

	handleRequiredEntityTypeChanged: =>
		value = @requiredEntityTypeListController.getSelectedCode()
		@handleValueChanged "RequiredEntityType", value

	handleProjectCodeChanged: =>
		value = @projectListController.getSelectedCode()
		@handleValueChanged "ProjectCode", value

	handleAssayPrincipleChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_assayPrinciple')
		@handleValueChanged "AssayPrinciple", value

	handleAssayTreeRuleChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_assayTreeRule')
		@handleValueChanged "AssayTreeRule", value

	handleCurveDisplayMaxChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_maxY')
		unless value is ""
			value = parseFloat value
		@handleValueChanged "CurveDisplayMax", value

	handleCurveDisplayMinChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_minY')
		unless value is ""
			value = parseFloat value
		@handleValueChanged "CurveDisplayMin", value

	handleStrictEndpointMatchingChanged: =>
		value = $('.bv_strictEndpointMatchingInputCheckbox').is(":checked")
		@handleValueChanged "StrictEndpointMatching", value


class EndpointController extends ACASFormStateTableFormController
	template: _.template($("#EndpointRowView").html())

	events:
		"click .bv_remove": "removeRow"


	initialize: (options) =>
		$(@el).empty()
		$(@el).html @template()

		super(options)

		if options.readOnly == true
			# hide remove buttons, disable all fields
			@$('.bv_remove').attr("disabled", "disabled")
			@$('input').attr("disabled", "disabled")
			@$('select').attr("disabled", "disabled")

			# enable tooltip
			@$('[data-toggle="tooltip"]').tooltip()

			# set the title for each field to be disabled
			toolTipMsg = "Endpoint still in use by an experiment."
			@$(".bv_columnNamePickList").attr("data-original-title", toolTipMsg)
			@$(".bv_unitsPickList").attr("data-original-title", toolTipMsg)
			@$(".bv_dataTypePickList").attr("data-original-title", toolTipMsg)
			@$(".bv_columnTimeInput").attr("data-original-title", toolTipMsg)
			@$(".bv_columnTimeUnitsPickList").attr("data-original-title", toolTipMsg)
			@$(".bv_columnConcentrationInput").attr("data-original-title", toolTipMsg)
			@$(".bv_columnConcentrationUnitsPickList").attr("data-original-title", toolTipMsg)
			@$(".bv_endpointHiddenCheckbox").attr("data-original-title", toolTipMsg)
			@$(".bv_endpointConditionCheckbox").attr("data-original-title", toolTipMsg)

			# since buttons are disabled, they aren't interactive so we nest the button it in a <span>,
			# and have to set style="pointer-events: none" on the disabled button for it to show up
			@$(".bv_removeRowToolTip").attr("data-original-title", toolTipMsg)
			@$(".bv_remove").attr("style", "pointer-events: none")
	
	removeRow: =>
		# Remove UI element
		@el.remove()
		# Ignore the state
		state = @getStateForRow()
		state.set 
			ignored: true
			modifiedBy: window.AppLaunchParams.loginUser.username
			modifiedDate: new Date().getTime()
			isDirty: true
		# Alert the parent controller to destroy this controller
		@trigger 'rowRemoved', @rowNumber

				
# Protocol Endpoints definition
EndpointsValuesConf = [
	key: 'column name'
	modelDefaults:
		type: 'codeValue'
		kind: 'column name'
		codeType: 'data column'
		codeKind: 'column name'
		codeOrigin: 'ACAS DDict'
		value: null
	fieldSettings:
		fieldType: 'codeValue'
		formLabel: ''
		fieldWrapper: 'bv_columnNamePickList'
		insertUnassigned: true
		firstSelectText: "Select Column Name"
		required: true
		editablePicklist: true
		autoSavePickListItem: true
		editablePicklistRoles: [window.conf.roles.acas.userRole]
		parameter: 'Column Name'
,
	key: 'column units'
	modelDefaults:
		type: 'codeValue'
		kind: 'column units'
		codeType: 'data column'
		codeKind: 'column units'
		codeOrigin: 'ACAS DDict'
		value: null
	fieldSettings:
		fieldType: 'codeValue'
		formLabel: ''
		fieldWrapper: 'bv_unitsPickList'
		insertUnassigned: true
		firstSelectText: "(unitless)"
		required: false
		editablePicklist: true
		autoSavePickListItem: true
		editablePicklistRoles: [window.conf.roles.acas.userRole]
		parameter: 'Column Units'
,
	key: 'column type'
	modelDefaults:
		type: 'codeValue'
		kind: 'column type'
		codeType: 'data column'
		codeKind: 'column type'
		codeOrigin: 'ACAS DDict'
		value: null
	fieldSettings:
		fieldType: 'codeValue'
		formLabel: ''
		fieldWrapper: 'bv_dataTypePickList'
		insertUnassigned: true
		firstSelectText: "Select Column Type"
		required: true
		editablePicklist: false
		parameter: 'Column Type'
,
	key: 'column time'
	modelDefaults:
		type: 'numericValue'
		kind: 'column time'
		value: null
		unitType: null
		unitKind: null
	fieldSettings:
		fieldType: 'numericValue'
		fieldWrapper: "bv_columnTimeInput"
		formLabel: ""
		format: "0.00"
		required: false
,
	key: 'column time units'
	modelDefaults:
		type: 'codeValue'
		kind: 'column time units'
		codeType: 'data column'
		codeKind: 'column time units'
		codeOrigin: 'ACAS DDict'
		value: null
	fieldSettings:
		fieldType: 'codeValue'
		formLabel: ''
		fieldWrapper: 'bv_columnTimeUnitsPickList'
		insertUnassigned: true
		firstSelectText: "Select Column Time Units"
		required: false
		editablePicklist: true
		autoSavePickListItem: true
		editablePicklistRoles: [window.conf.roles.acas.userRole]
		parameter: 'Column Time Units'
,
	key: 'column concentration'
	modelDefaults:
		type: 'numericValue'
		kind: 'column concentration'
		value: null
		unitType: null
		unitKind: null
	fieldSettings:
		fieldType: 'numericValue'
		fieldWrapper: 'bv_columnConcentrationInput'
		formLabel: ""
		format: "0.00"
		required: false
,
	key: 'column conc units'
	modelDefaults:
		type: 'codeValue'
		kind: 'column conc units'
		codeType: 'data column'
		codeKind: 'column conc units'
		codeOrigin: 'ACAS DDict'
		value: null
	fieldSettings:
		fieldType: 'codeValue'
		formLabel: ''
		fieldWrapper: 'bv_columnConcentrationUnitsPickList'
		insertUnassigned: true
		firstSelectText: "Select Column Concentration Units"
		required: false
		editablePicklist: true
		autoSavePickListItem: true
		editablePicklistRoles: [window.conf.roles.acas.userRole]
		parameter: 'Column Concentration Units'
,
	key: 'hide column'
	modelDefaults:
		type: 'codeValue'
		kind: 'hide column'
		codeType: 'boolean'
		codeKind: 'boolean'
		codeOrigin: 'ACAS DDict'
		value: null
	fieldSettings:
		fieldType: 'booleanValue'
		formLabel: ''
		fieldWrapper: "bv_endpointHiddenCheckbox"
,
	key: 'condition column'
	modelDefaults:
		type: 'codeValue'
		kind: 'condition column'
		codeType: 'boolean'
		codeKind: 'boolean'
		codeOrigin: 'ACAS DDict'
		value: null
	fieldSettings:
		fieldType: 'booleanValue'
		formLabel: ''
		fieldWrapper: "bv_endpointConditionCheckbox"
]

class EndpointListController extends AbstractFormController
	template: _.template($("#EndpointListView").html())

	events:
		"click .bv_addEndpoint": "handleAddEndpointPressed"
		"rowRemoved": "handleRowRemoved"
		"click .bv_endpointRow": "handleEndpointRowPressed"
		"click .bv_downloadFiles": "downloadFiles"
		"click .bv_downloadSELFile": "downloadSELFile"
	
	rowNumberKind: "column order"
	stateType: "metadata"
	stateKind: "data column order"
	
	initialize: (options) =>
		@model = options.model

		endpointStates = @model.get("lsStates").getStatesByTypeAndKind @stateType, @stateKind

		# Sort the collection by the "column order" values
		@collection = endpointStates.sort (stateA, stateB) =>
			rnA = @getRowNumberForState(stateA)
			rnB = @getRowNumberForState(stateB)
			return rnA - rnB

	render: => 
		$(@el).empty()
		$(@el).html @template()

		#If the table is read-only, remove the remove and add buttons
		if @options.readOnly == true
			#remove column
			@$(".bv_endpointColumnRemove").remove()
			#remove add endpoint button
			@$(".bv_addEndpoint").remove()
			@$(".bv_endpointManagerInstructions").hide()
		
		if @options.newProtocol == true
			@$(".bv_downloadFiles").hide()
			@$(".bv_endpointManagerInstructions").hide()
			@endpointControllers = [] # initialize empty endpoint controller list since it won't be automatically made for new protocol 

		#check whether or not to display time and concentration columns in the endpoint table
		@showTimeAndConcentration()
		

		if @options.readOnly == false && @options.newProtocol == false 	#Only render experiments if the protocol is not new and is not read only 
			@getExperimentsForProtocol()
		else #if the table isn't rendered, don't render the download files button either
			@$(".bv_downloadFiles").hide() 
			if @options.view == "experiment"
				@getEndpointTable()

		@
	
	showTimeAndConcentration: =>
		#if time/units or concentration/units are disabled, remove the columns and cells from the endpoint controller whenever table is made or a row added
		if window.conf.protocol.endpointManager.showTime == false
			@$(".bv_endpointColumnTime").remove()
			@$(".bv_endpointColumnTimeUnits").remove()
			@$(".bv_timeUnitsPickListParent").remove()
			@$(".bv_timeInputParent").remove()

		if window.conf.protocol.endpointManager.showConcentration == false
			@$(".bv_endpointColumnConcentration").remove()
			@$(".bv_endpointColumnConcentrationUnits").remove()
			@$(".bv_concentrationUnitsPickListParent").remove()
			@$(".bv_concentrationInputParent").remove()
	
	getExperimentsForProtocol: => 
		# Get all the experiments associated with the protocol
		protocolCode = @model.escape('codeName')		
		$.ajax
			type: 'GET'
			#there are two similar routes in ExperimentBrowserRoutes.coffee and ExperimentServiceRoutes.coffee
			#url: "/api/experimentsForProtocol/#{protocolCode}" #ExperimentBrowserRoutes.coffee route
			url: "/api/experiments/protocolCodename/#{protocolCode}" #ExperimentServiceRoutes.coffee route
			success: (experiments) =>

				# want to remove any ignored or deleted experiments
				validExperiments = []
				for experiment in experiments
					if experiment.ignored == false && experiment.deleted == false
						validExperiments.push experiment

				#save the experiments so we don't have to retrieve them again 
				if window.conf.experiment?.mainControllerClassName? and window.conf.experiment.mainControllerClassName is "EnhancedExperimentBaseController"
					@protocolExperiments = new EnhancedExperimentList validExperiments
				else
					@protocolExperiments = new ExperimentList validExperiments
				
				# set up the initial experiment table 
				@getExperimentSummaryTable()

				# set up the initial endpoint table
				@getEndpointTable()

				
			error: (err) ->
				console.log "There was an error retrieving experiments for this protocol: " + err
			
	getExperimentSummaryTable: =>
		#hide previously shown warnings/success text
		@$(".bv_downloadSuccess").hide()
		@$(".bv_downloadWarning").hide()

		protocolCode = @model.escape('codeName')	
		@setupExperimentSummaryTable @protocolExperiments
		
		@$(".bv_experimentTableControllerTitle").html "Experiments using " + protocolCode + ":"
	
	getEndpointTable: =>

		# get all the endpoints being used for all existing experiments (need this to enable/disable rows in endpoint table)
		if @options.view == "protocol"
			@experimentEndpoints = @getEndpointsFromExperiments()

		# Create a list to hold the endpoint controllers in, so we can iterate through them later
		@endpointControllers = []
		for lsState in @collection
			@.addOne(lsState)
			if @options.readOnly == true
				#hide remove buttons
				@$(".bv_remove_row").hide()				

	resetBackgroundColor: (tr) => 
		# Reset the background color of all rows
		for elm in tr.parent()[0].childNodes
			for subelm in elm.childNodes
				try
					subelm.style.background = "#F9F9F9"
				catch
					#not all elements can be styled, so do nothing
	
	setBackgroundColor: (tr) =>
		# Highlight the background color of the cells within the selected row 
		for elm in tr
			for subelm in elm.childNodes
				try
					subelm.style.background = "#D9EDF7"
				catch
					#not all elements can be styled, so do nothing

	getRowData: (tr) =>
		# Extract and convert the values for a given row
		endpointRowValues = tr[0].querySelectorAll("span.select2-selection__rendered")
		rowEndpointName = endpointRowValues[0].title
		rowUnits = endpointRowValues[1].title
		rowDataType = endpointRowValues[2].title

		#convert the input into the data type for matching when we search the experiment metadata
		if rowDataType == "Number"
			rowDataType = "numericValue"
		else if rowDataType == "Text"
			rowDataType = "stringValue"
		else if rowDataType == "Image File"
			rowDataType = "inlineFileValue" 
		else if rowDataType == "Date"
			rowDataType = "dateValue"
		
		return {
			rowEndpointName: rowEndpointName,
			rowUnits: rowUnits,
			rowDataType: rowDataType
		}

	getFilteredExperimentTable: (rowData) =>
		rowEndpointName =  rowData.rowEndpointName
		rowUnits = rowData.rowUnits
		rowDataType =  rowData.rowDataType
		protocolCode = @model.escape('codeName')

		#hide previously shown warnings/success text associated w/ previous table
		@$(".bv_downloadSuccess").hide()
		@$(".bv_downloadWarning").hide()

		filtered_experiments = [] #keep track of the filtered experiments
		#we'll need to filter out experiments that don't contain the endpoint
		for experiment in @protocolExperiments.models
			dataColumnOrderStates = experiment.get("lsStates").getStatesByTypeAndKind "metadata", "data column order"

			for lsState in dataColumnOrderStates
				# if the endpoint doesn't have a value for it, don't filter by it (automatically match)
				# we need to reset the match before we check each "for" round or the result from the last round will carry over...
				if rowEndpointName == "Select Column Name"
					endpointRowValueMatch = true
					displayRowEndpointName = "any column name"
				else
					endpointRowValueMatch = false
					displayRowEndpointName = rowEndpointName
				
				if rowUnits == "(unitless)"
					endpointRowUnitsMatch = true
					displayRowUnits = "any units"
				else
					endpointRowUnitsMatch = false
					displayRowUnits = rowUnits

				if rowDataType == "Select Column Type"
					endpointRowDataTypeMatch = true
					displayRowDataType = "any data type"
				else
					endpointRowDataTypeMatch = false	
					displayRowDataType = rowDataType
				
				# get experiment values
				experimentColumnNameValues = lsState.getValuesByTypeAndKind "codeValue", "column name"
				experimentColumnUnitValues = lsState.getValuesByTypeAndKind "codeValue", "column units"
				experimentColumnTypeValues = lsState.getValuesByTypeAndKind "codeValue", "column type"
				
				# check if the row value is in the experiment values
				if @rowValueInExperimentValues(rowEndpointName, experimentColumnNameValues, "codeValue")
					endpointRowValueMatch = true

				if @rowValueInExperimentValues(rowUnits, experimentColumnUnitValues, "codeValue")
					endpointRowUnitsMatch = true

				if @rowValueInExperimentValues(rowDataType, experimentColumnTypeValues, "codeValue")
					endpointRowDataTypeMatch = true

				#if all the criteria pass, record the experiment, end the loop early & move on to the next one
				if endpointRowValueMatch == true && endpointRowUnitsMatch == true && endpointRowDataTypeMatch == true
					filtered_experiments.push experiment
					break

		@$(".bv_experimentTableController").empty() #remove the last experimentTableController

		if window.conf.experiment?.mainControllerClassName? and window.conf.experiment.mainControllerClassName is "EnhancedExperimentBaseController"
			@setupExperimentSummaryTable new EnhancedExperimentList filtered_experiments
		else
			@setupExperimentSummaryTable new ExperimentList filtered_experiments
		
		#generate a title for the experiment table controller 
		@$(".bv_experimentTableControllerTitle").html "Experiments using " + protocolCode + " containing '" + displayRowEndpointName + " (" + displayRowUnits + " , " + displayRowDataType + ")' data:"
				
	rowValueInExperimentValues: (endpointValue, experimentLsValues, lsType) =>
		if experimentLsValues.length > 0
			for experimentLsValue in experimentLsValues
				if experimentLsValue.get('ignored') == false 
					if experimentLsValue.get(lsType) == endpointValue
						return true
		return false 

	handleEndpointRowPressed: =>
		#disable logic if endpoint list controller is read only (since there won't be an experiment controller)
		#disable logic if the endpoint list is for a new protocol too
		if @options.readOnly == true || @options.newProtocol == true
			return @
		
		#Otherwise, when an endpoint row is pressed, we want to filter the experiment summary table so it only displays the experiments...
		#...with protocols that contain the endpoint, so we'll need to find the row's endpoint name and regenerate the table

		#since any element within the row could be clicked on, we want to find find the parent row div
		tr = $(event.target).closest("tr")

		#First, reset the background color of all the rows before highlighting a new row
		@resetBackgroundColor(tr)

		#we need to detect if the element we have clicked on is the previously selected element
		if "selectedEndpointRow" in tr[0].classList
			previouslySelectedRow = true
		else
			previouslySelectedRow = false
		
		#remove class marking whether a row was previously selected
		$(".selectedEndpointRow").removeClass "selectedEndpointRow"

		#if the row was previously selected, load table for just experiments associated with protocol, no filtering by endpoint
		if previouslySelectedRow == true
			@getExperimentSummaryTable()
	
		#if the row was not previously selected, load table with associated experiments filtered by endpoint and highlight endpoint row
		else
			#mark the selected row (this is part of unhighlighting/unselecting a row if it is clicked twice)
			tr.addClass('selectedEndpointRow')

			#apply highlighting to the selected rows
			@setBackgroundColor(tr)

			#extract the endpoint values from the selected row
			rowData = @getRowData(tr)

			#get table with matching experiments given the endpoint data and the protocolCode
			@getFilteredExperimentTable(rowData)

			@

	addOne: (state) =>

		# need to figure out if the "Remove" button should be disabled or not
		# If the endpoint is being used by other experiments - it should be disabled 
		if @options.view == "protocol"
			rowEndpointData = @getCurrentEndpoint(state)

			# if the endpoint is being used in an experiment, we need to set it to readOnly so that it can't be edited or removed
			if @options.readOnly == true | @isEndpointInEndpoints(rowEndpointData, @experimentEndpoints)
				rowReadOnly = true
			else
				rowReadOnly = false
		else
			rowReadOnly = true
		
		
		# create a new table row
		tr = document.createElement('tr')
		# Add that row into the table
		@$('.bv_endpointRows').append tr
		@$('.bv_endpointRows tr' ).addClass('bv_endpointRow')
		# Create a new EndpointController, which manages a row
		# We get the row number from the state which was passed in
		rowNumber = @getRowNumberForState(state)
		# Start tracking the controllers based on their row numbers
		if @endpointControllers[rowNumber]?
			@endpointControllers[rowNumber].remove()
			@endpointControllers[rowNumber].unbind()
		rowController = new EndpointController
			el: tr
			thingRef: @model
			valueDefs: EndpointsValuesConf
			stateType: 'metadata'
			stateKind: 'data column order'
			rowNumber: rowNumber
			rowNumberKind: @rowNumberKind
			readOnly: rowReadOnly
		# Add this controller to our tracking dictionary so we can access it later
		@endpointControllers[rowNumber] = rowController

		#check whether or not to display time and concentration cells in the row
		@showTimeAndConcentration()
	
	getRowNumberForState: (state) =>
		rowValues = state.getValuesByTypeAndKind 'numericValue', @rowNumberKind
		if rowValues.length == 1
			return rowValues[0].get('numericValue')
		else
			return 0
	
	getNextRowNumber: =>
		row_nums = @collection.map @.getRowNumberForState
		if row_nums.length > 0
			return Math.max(...row_nums) + 1
		else
			return 1

	handleAddEndpointPressed: =>
		# Create a new LsState
		lsState = @model.get("lsStates").createStateByTypeAndKind "metadata", "data column order"
		# Set column order value
		rowNum = @.getNextRowNumber()
		rowNumValue = lsState.getOrCreateValueByTypeAndKind 'numericValue', @rowNumberKind
		rowNumValue.set("numericValue", rowNum)
		# Add the state to the collection
		@collection.push lsState
		@.addOne(lsState)
	
	handleRowRemoved: (rowNumber) =>
		if @endpointControllers[rowNumber]?
			@endpointControllers[rowNumber].remove()
			@endpointControllers[rowNumber].unbind()
			@endpointControllers[rowNumber].el.remove()

	#Function brought over from experiment.coffee 
	setupExperimentSummaryTable: (experiments) =>
		#@$(".bv_searchStatusIndicator").addClass "hide"
		@$(".bv_experimentTableController").removeClass "hide"

		@experimentSummaryTable = new ExperimentSummaryTableController
			el: @$(".bv_experimentTableController")
			collection: experiments

		@experimentSummaryTable.on "selectedRowUpdated", @selectedExperimentUpdated

		@experimentSummaryTable.render()
		
		if experiments.length == 0
			@$(".bv_experimentTableController").empty() 
			@$(".bv_experimentTableController").append "There are no matching experiments using this protocol and endpoint."
			@$(".bv_downloadFiles").hide()
		else
			@$(".bv_downloadFiles").show()
	
	downloadFiles: => 
		#copied from downloadFiles in ExperimentBrowser.coffee

		#extract the experiment data from the summary table
		experimentMetadata = @experimentSummaryTable.collection.models

		#collect the codes of the experiments that are currently shown
		table = $(".bv_experimentTableController .dataTables_wrapper .table").dataTable()
		filteredExperimentCodes = []
		for filteredExperiments in table._('tr', {'filter': 'applied'})
			filteredExperimentCodes.push filteredExperiments[0]

		#create an array to store all the experiment's files
		experimentFiles = []
		for experimentData in experimentMetadata
			#if the experiment code is in the filtered codes, search for associated files
			if experimentData.attributes.codeName in filteredExperimentCodes
				for experimentLsState in experimentData.attributes.lsStates.models
					if experimentLsState.attributes.lsKind == "experiment metadata"
						for experimentLsValue in experimentLsState.attributes.lsValues.models
							if experimentLsValue.attributes.fileValue
								#add files to experimentFiles
								experimentFiles.push "dataFiles/" + experimentLsValue.attributes.fileValue

		#Get today's date to timestamp any experiment file exports
		today = new Date
		dd = today.getDate()
		mm = today.getMonth() + 1
		yyyy = today.getFullYear()
		if dd < 10
			dd = '0' + dd
		if mm < 10
			mm = '0' + mm
		today = '_' + mm + '_' + dd + '_' + yyyy

		#construct request
		dataToPost =
			fileName: "experiment_files" + today
			mappings: JSON.parse(JSON.stringify(experimentFiles))
			userName: window.AppLaunchParams.loginUser.username 

		#send all experiment filenames to backend to zip up
		$.ajax
			type: 'POST'
			url: "/api/exportExperimentFiles"
			data: dataToPost
			timeout: 6000000
			success: (response) =>
				#Since we can't directly send the .zip file to download it...
				#...we create a hidden link with the download path and automatically click on it
				a = document.createElement('a');
				a.style.display = 'none';
				a.href = "/dataFiles/" + response;
				a.setAttribute('target', '_blank')
				document.body.appendChild(a);
				a.click();

				#Update GUI to indicate succesful download
				@$(".bv_downloadWarning").hide()
				@$(".bv_downloadSuccess").show()

			error: (err) =>
				console.log "Could not download files" + err

				#Update GUI to indicate files could not be downloaded
				@$(".bv_downloadSuccess").hide()
				@$(".bv_downloadWarning").show()
				@serviceReturn = null
			dataType: 'json'

	getEndpointValueFromState: (lsState, lsType, lsKind) =>
		lsValues = lsState.getValuesByTypeAndKind lsType, lsKind

		if lsValues.length > 0
			for lsValue in lsValues
				if lsValue.get('ignored') == false 
					return lsValue.get(lsType)
						
		return "NA"

	getCurrentEndpoint: (lsState) => 
		endpointName = @getEndpointValueFromState(lsState, "codeValue", "column name")
		endpointUnits = @getEndpointValueFromState(lsState, "codeValue", "column units")
		endpointDataType = @getEndpointValueFromState(lsState,"codeValue",  "column type")
		endpointConc = @getEndpointValueFromState(lsState, "numericValue", "column concentration")
		endpointConcUnits = @getEndpointValueFromState(lsState, "codeValue",  "column conc units")
		endpointTime = @getEndpointValueFromState(lsState, "numericValue", "column time")
		endpointTimeUnits = @getEndpointValueFromState(lsState, "codeValue", "column time units")
		endpointHidden = @getEndpointValueFromState(lsState, "codeValue", "hide column")
			
		endpointStr = endpointName + endpointUnits + endpointDataType + String(endpointConc) + endpointConcUnits + String(endpointTime) + endpointTimeUnits + endpointHidden
		
		endpointData = 
			endpointName: endpointName
			endpointUnits: endpointUnits
			endpointDataType: endpointDataType
			endpointConc: endpointConc
			endpointConcUnits: endpointConcUnits
			endpointTime: endpointTime
			endpointTimeUnits: endpointTimeUnits
			endpointHidden: endpointHidden
			endpointStr: endpointStr
		
		return endpointData

	getCurrentEndpoints: (lsStates) => 
		# get the current endpoints and their values for the protocol from a collection of lsStates

		# create holders for each one we want to collect 
		endpointNames = []
		endpointUnits = []
		endpointDataTypes = []
		endpointConc = []
		endpointConcUnits = []
		endpointTime = []
		endpointTimeUnits = []
		endpointHidden = []
		endpointStr = []

		for lsState in lsStates 
			rowEndpointData = @getCurrentEndpoint(lsState)
				
			# record the endpoint data
			endpointNames.push rowEndpointData.endpointName
			endpointUnits.push rowEndpointData.endpointUnits
			endpointDataTypes.push rowEndpointData.endpointDataType
			endpointConc.push rowEndpointData.endpointConc
			endpointConcUnits.push rowEndpointData.endpointConcUnits
			endpointTime.push rowEndpointData.endpointTime
			endpointTimeUnits.push rowEndpointData.endpointTimeUnits
			endpointHidden.push rowEndpointData.endpointHidden
			endpointStr.push rowEndpointData.endpointStr
		
		# create object to return 
		multipleEndpointData = 
			endpointNames: endpointNames
			endpointUnits: endpointUnits
			endpointDataTypes: endpointDataTypes
			endpointConc: endpointConc
			endpointConcUnits: endpointConcUnits
			endpointTime: endpointTime
			endpointTimeUnits: endpointTimeUnits
			endpointHidden: endpointHidden
			endpointStr: endpointStr
		

		return multipleEndpointData 

	downloadSELFile: =>	
		# Get the protocol project		
		protocolProject = ""
		for lsState in @model.attributes.lsStates.models
			if lsState.attributes.lsKind == "protocol metadata"
				for lsValue in lsState.attributes.lsValues.models
					if lsValue.attributes.lsKind == "project" && lsValue.attributes.ignored == false 
						if lsValue.attributes.codeValue != "unassigned" # we leave it as an empty string instead of recording "unassigned"
							protocolProject = lsValue.attributes.codeValue
		
		#construct request
		todayDate = new Date()

		dataToPost =
			protocolCode: @model.escape('codeName')

		$.ajax
			type: 'POST'
			url: "/api/getTemplateSELFile"
			data: dataToPost
			timeout: 6000000
			dataType: 'json'
			success: (response) =>
				#Since we can't directly send the .csv file to download it...
				#...we create a hidden link with the download path and automatically click on it
				# exporting and downloading the file to the user

				# create a Blob object from the CSV string in response
				csvBlob = new Blob([response], { type: 'text/csv;charset=utf-8;' })

				# create a temporary URL for the Blob object
				csvUrl = URL.createObjectURL(csvBlob)

				# create a temporary link element to trigger the download
				downloadLink = document.createElement('a')
				downloadLink.href = csvUrl
				downloadLink.download = @model.escape('codeName') + "_template.csv"

				# trigger the download by programmatically clicking the link
				document.body.appendChild(downloadLink)
				downloadLink.click()

				# clean up by revoking the URL and removing the link element
				URL.revokeObjectURL(csvUrl)
				document.body.removeChild(downloadLink)

				#Update GUI to indicate succesful download
				$(".bv_downloadTemplateWarning").hide()
				$(".bv_downloadTemplateSuccess").show()

			error: (err) =>
				console.log "getTemplateSELFile() error:" + err
				
				#Update GUI to indicate files could not be downloaded
				$(".bv_downloadTemplateSuccess").hide()
				$(".bv_downloadTemplateWarning").show()
				


	getEndpointsFromExperiments: =>
		# get a collection of all the endpoints from the protocols associated experiments
		endpointNames = []
		endpointUnits = []
		endpointDataTypes = []
		endpointConc = []
		endpointConcUnits = []
		endpointTime = []
		endpointTimeUnits = []
		endpointHidden = []
		endpointStr = []

		for experiment in @protocolExperiments.models
			dataColumnOrderStates = experiment.get("lsStates").getStatesByTypeAndKind "metadata", "data column order"

			for lsState in dataColumnOrderStates
				experimentEndpoints = @getCurrentEndpoint(lsState)

				# create a string of all the different endpoint variables to see if one already has been recorded
				endpointStrEntry = experimentEndpoints.endpointName + 
				experimentEndpoints.endpointUnits + experimentEndpoints.endpointDataType + 
				String(experimentEndpoints.endpointConc) + experimentEndpoints.endpointConcUnits + 
				String(experimentEndpoints.endpointTime) + experimentEndpoints.endpointTimeUnits +
				experimentEndpoints.endpointHidden

				if endpointStrEntry not in endpointStr

					# record the endpoint data
					endpointNames.push experimentEndpoints.endpointName
					endpointUnits.push experimentEndpoints.endpointUnits
					endpointDataTypes.push experimentEndpoints.endpointDataType
					endpointConc.push experimentEndpoints.endpointConc
					endpointConcUnits.push experimentEndpoints.endpointConcUnits
					endpointTime.push experimentEndpoints.endpointTime
					endpointTimeUnits.push experimentEndpoints.endpointTimeUnits
					endpointHidden.push experimentEndpoints.endpointHidden
					endpointStr.push endpointStrEntry # record the string to make sure there are no duplicates 
		
		# create object to return 
		multipleEndpointData = 
			endpointNames: endpointNames
			endpointUnits: endpointUnits
			endpointDataTypes: endpointDataTypes
			endpointConc: endpointConc
			endpointConcUnits: endpointConcUnits
			endpointTime: endpointTime
			endpointTimeUnits: endpointTimeUnits
			endpointHidden: endpointHidden
			endpointStr: endpointStr

		return multipleEndpointData 									

	isEndpointInEndpoints: (endpointData, multipleEndpointData) =>
		# Helper function that checks if a single endpoint is in a collection of endpoints

		# if all the endpoint values are NA, it does not pass or fresh values will automatically be locked
		if endpointData.endpointName == "NA" & endpointData.endpointUnits == "NA" & endpointData.endpointDataType == "NA" & endpointData.endpointConc == "NA" & endpointData.endpointConcUnits == "NA" & endpointData.endpointTime == "NA" & endpointData.endpointTimeUnits == "NA" 
			return false 

		for indexNum in [0..multipleEndpointData.endpointNames.length-1]
			endpointNamesMatch = false
			endpointUnitsMatch = false
			endpointDataTypesMatch = false
			endpointConcMatch = false
			endpointConcUnitsMatch = false
			endpointTimeMatch = false
			endpointTimeUnitsMatch = false

			# if the experiment value or protocol value is NA, we automatically pass 
			if endpointData.endpointName == multipleEndpointData.endpointNames[indexNum] | multipleEndpointData.endpointNames[indexNum] == "NA" | endpointData.endpointName == "NA"
				endpointNamesMatch = true 
			if endpointData.endpointUnits == multipleEndpointData.endpointUnits[indexNum]  | multipleEndpointData.endpointUnits[indexNum] == "NA" | endpointData.endpointUnits == "NA"
				endpointUnitsMatch = true 
			if endpointData.endpointDataType == multipleEndpointData.endpointDataTypes[indexNum] | multipleEndpointData.endpointDataTypes[indexNum] == "NA" | endpointData.endpointDataType == "NA"
				endpointDataTypesMatch = true 
			if endpointData.endpointConc == multipleEndpointData.endpointConc[indexNum]  | multipleEndpointData.endpointConc[indexNum] == "NA" | endpointData.endpointConc == "NA"
				endpointConcMatch = true 
			if endpointData.endpointConcUnits == multipleEndpointData.endpointConcUnits[indexNum]  | multipleEndpointData.endpointConcUnits[indexNum] == "NA" | endpointData.endpointConcUnits == "NA"
				endpointConcUnitsMatch = true 
			if endpointData.endpointTime == multipleEndpointData.endpointTime[indexNum]  | multipleEndpointData.endpointTime[indexNum] == "NA" | endpointData.endpointTime == "NA"
				endpointTimeMatch = true 
			if endpointData.endpointTimeUnits == multipleEndpointData.endpointTimeUnits[indexNum]  | multipleEndpointData.endpointTimeUnits[indexNum] == "NA" | endpointData.endpointTimeUnits == "NA"
				endpointTimeUnitsMatch = true 
			
			if endpointNamesMatch && endpointUnitsMatch && endpointDataTypesMatch && endpointConcMatch && endpointTimeMatch && endpointTimeUnitsMatch 
				return true
				 
		# if no match is found, return false (no match)
		return false 	
		


