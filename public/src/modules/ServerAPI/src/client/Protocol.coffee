class window.Protocol extends BaseEntity
	urlRoot: "/api/protocols"

	initialize: ->
		@.set subclass: "protocol"
		super()

	getAssayTreeRule: ->
		assayTreeRule = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "stringValue", "assay tree rule"
		if assayTreeRule.get('stringValue') is undefined
			assayTreeRule.set stringValue: ""

		assayTreeRule

	getAssayStage: ->
		assayStage = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "codeValue", "assay stage"
		if assayStage.get('codeValue') is undefined or assayStage.get('codeValue') is "" or assayStage.get('codeValue') is null
			assayStage.set codeValue: "unassigned"
			assayStage.set codeType: "protocolMetadata"
			assayStage.set codeKind: "assay stage"
			assayStage.set codeOrigin: "acas ddict"

		assayStage

	getAssayPrinciple: ->
		assayPrinciple = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "protocol metadata", "clobValue", "assay principle"
		if assayPrinciple.get('clobValue') is undefined
			assayPrinciple.set clobValue: ""

		assayPrinciple


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
				attribute: 'protocolName'
				message: attrs.subclass+" name must be set"
		if _.isNaN(attrs.recordedDate)
			errors.push
				attribute: 'recordedDate'
				message: attrs.subclass+" date must be set"
		if attrs.recordedBy is ""
			errors.push
				attribute: 'recordedBy'
				message: "Scientist must be set"
		cDate = @getCompletionDate().get('dateValue')
		if cDate is undefined or cDate is "" or cDate is null then cDate = "fred"
		if isNaN(cDate)
			errors.push
				attribute: 'completionDate'
				message: "Assay completion date must be set"
		notebook = @getNotebook().get('stringValue')
		if notebook is "" or notebook is "unassigned" or notebook is undefined
			errors.push
				attribute: 'notebook'
				message: "Notebook must be set"
		assayTreeRule = @getAssayTreeRule().get('stringValue')
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

class window.ProtocolList extends Backbone.Collection
	model: Protocol

class window.ProtocolBaseController extends BaseEntityController
	template: _.template($("#ProtocolBaseView").html())
	moduleLaunchName: "protocol_base"

	events: ->
		_(super()).extend(
			"change .bv_protocolName": "handleNameChanged"
			"change .bv_assayTreeRule": "handleAssayTreeRuleChanged"
			"change .bv_assayStage": "handleAssayStageChanged"
			"change .bv_assayPrinciple": "handleAssayPrincipleChanged"

		)

	initialize: ->
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
								#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
								lsKind = json[0].lsKind
								if lsKind is "default"
									prot = new Protocol json[0]
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

	completeInitialization: ->
		unless @model?
			@model = new Protocol()
		@errorOwnerName = 'ProtocolBaseController'
		@setBindings()
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@model.on 'sync', =>
			@trigger 'amClean'
			@$('.bv_saving').hide()
			@$('.bv_updateComplete').show()
			@$('.bv_save').attr('disabled', 'disabled')
			@render()
		@model.on 'change', =>
			@trigger 'amDirty'
			@$('.bv_updateComplete').hide()
		@$('.bv_save').attr('disabled', 'disabled')
		@setupStatusSelect()
		@setupTagList()
		@setUpAssayStageSelect()
		@model.getStatus().on 'change', @updateEditable

		@render()
		@trigger 'amClean' #so that module starts off clean when initialized

	render: =>
		unless @model?
			@model = new Protocol()
		@setUpAssayStageSelect()
		@$('.bv_assayTreeRule').val @model.getAssayTreeRule().get('stringValue')
		@$('.bv_assayPrinciple').val @model.getAssayPrinciple().get('clobValue')
		super()
		@

	setUpAssayStageSelect: ->
		@assayStageList = new PickListList()
		@assayStageList.url = "/api/dataDict/protocol metadata/assay stage"
		@assayStageListController = new PickListSelectController
			el: @$('.bv_assayStage')
			collection: @assayStageList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select assay stage"
			selectedCode: @model.getAssayStage().get('codeValue')

	handleAssayStageChanged: =>
		@model.getAssayStage().set
			codeValue: @assayStageListController.getSelectedCode()
		@trigger 'change'

	handleAssayPrincipleChanged: =>
		@model.getAssayPrinciple().set
			clobValue: UtilityFunctions::getTrimmedInput @$('.bv_assayPrinciple')
			recordedBy: @model.get('recordedBy')

	handleAssayTreeRuleChanged: =>
		@model.getAssayTreeRule().set
			stringValue: UtilityFunctions::getTrimmedInput @$('.bv_assayTreeRule')
