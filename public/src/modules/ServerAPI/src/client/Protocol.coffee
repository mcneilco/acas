class window.Protocol extends BaseEntity
	urlRoot: "/api/protocols"

	defaults: ->
		_(super()).extend(
			assayTreeRule: null
			dnsTargetList: false
			assayActivity: "unassigned"
			molecularTarget: "unassigned"
			targetOrigin: "unassigned"
			assayType: "unassigned"
			assayTechnology: "unassigned"
			cellLine: "unassigned"
			assayStage: "unassigned"
			maxY: 100
			minY: 0
#			assayPrinciple:
#			attachFiles: new AttachFilesList()
		)

	initialize: ->
		@.set subclass: "protocol"
		super()

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
		if cDate is undefined or cDate is "" then cDate = "fred"
		if isNaN(cDate)
			errors.push
				attribute: 'completionDate'
				message: "Assay completion date must be set"
		notebook = @getNotebook().get('stringValue')
		if notebook is "" or notebook is "unassigned" or notebook is undefined
			errors.push
				attribute: 'notebook'
				message: "Notebook must be set"
		if _.isNaN(attrs.maxY)
			errors.push
				attribute: 'maxY'
				message: "maxY must be a number"
		if _.isNaN(attrs.minY)
			errors.push
				attribute: 'minY'
				message: "minY must be a number"

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

	events: ->
		_(super()).extend(
			"change .bv_protocolName": "handleNameChanged"
			"change .bv_assayTreeRule": "attributeChanged"
			"click .bv_dnsTargetList": "handleTargetListChanged"
			"change .bv_assayActivity": "attributeChanged"
			"click .bv_addNewAssayActivity": "addNewAssayActivity"
			"change .bv_molecularTarget": "attributeChanged"
			"click .bv_addNewMolecularTarget": "addNewMolecularTarget"
			"change .bv_targetOrigin": "attributeChanged"
			"click .bv_addNewTargetOrigin": "addNewTargetOrigin"
			"change .bv_assayType": "attributeChanged"
			"click .bv_addNewAssayType": "addNewAssayType"
			"change .bv_assayTechnology": "attributeChanged"
			"click .bv_addNewAssayTechnology": "addNewAssayTechnology"
			"change .bv_cellLine": "attributeChanged"
			"click .bv_addNewCellLine": "addNewCellLine"
			"change .bv_assayStage": "attributeChanged"
			"change .bv_maxY": "attributeChanged"
			"change .bv_minY": "attributeChanged"
		)

	initialize: ->
		unless @model?
			@model = new Protocol()
		@model.on 'sync', =>
			@trigger 'amClean'
			@$('.bv_saving').hide()
			@$('.bv_updateComplete').show()
			@render()
		@model.on 'change', =>
			@trigger 'amDirty'
			@$('.bv_updateComplete').hide()
		@errorOwnerName = 'ProtocolBaseController'
		@setBindings()
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@$('.bv_save').attr('disabled', 'disabled')
		@setupStatusSelect()
		@setupTagList()
		@model.getStatus().on 'change', @updateEditable
		@setUpAssayActivitySelect()
		@setUpMolecularTargetSelect()
		@setUpTargetOriginSelect()
		@setUpAssayTypeSelect()
		@setUpAssayTechnologySelect()
		@setUpCellLineSelect()
		@setUpAssayStageSelect()
#	using the code above, triggers amDirty whenever the module is clicked. is this ok?

	render: =>
		@$('.bv_assayTreeRule').val(@model.get('assayTreeRule'))
		@$('.bv_dnsTargetList').val(@model.get('dnsTargetList'))
		@$('.bv_maxY').val(@model.get('maxY'))
		@$('.bv_minY').val(@model.get('minY'))
		@setUpAssayActivitySelect()
		@setUpMolecularTargetSelect()
		@setUpTargetOriginSelect()
		@setUpAssayTypeSelect()
		@setUpAssayTechnologySelect()
		@setUpCellLineSelect()
		@setUpAssayStageSelect()
		@handleTargetListChanged()
		super()
		@

	setUpAssayActivitySelect: ->
		@assayActivityList = new PickListList()
		@assayActivityList.url = "/api/dataDict/assayActivityCodes"
		@assayActivityList = new PickListSelectController
			el: @$('.bv_assayActivity')
			collection: @assayActivityList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Assay Activity"
			selectedCode: @model.get('assayActivity')

	setUpMolecularTargetSelect: ->
		@molecularTargetList = new PickListList()
		@molecularTargetList.url = "/api/dataDict/molecularTargetCodes"
		@molecularTargetList = new PickListSelectController
			el: @$('.bv_molecularTarget')
			collection: @molecularTargetList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Molecular Target"
			selectedCode: @model.get('molecularTarget')

	setUpTargetOriginSelect: ->
		@targetOriginList = new PickListList()
		@targetOriginList.url = "/api/dataDict/targetOriginCodes"
		@targetOriginList = new PickListSelectController
			el: @$('.bv_targetOrigin')
			collection: @targetOriginList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Target Origin"
			selectedCode: @model.get('targetOrigin')

	setUpAssayTypeSelect: ->
		@assayTypeList = new PickListList()
		@assayTypeList.url = "/api/dataDict/assayTypeCodes"
		@assayTypeList = new PickListSelectController
			el: @$('.bv_assayType')
			collection: @assayTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Assay Type"
			selectedCode: @model.get('assayType')

	setUpAssayTechnologySelect: ->
		@assayTechnologyList = new PickListList()
		@assayTechnologyList.url = "/api/dataDict/assayTechnologyCodes"
		@assayTechnologyList = new PickListSelectController
			el: @$('.bv_assayTechnology')
			collection: @assayTechnologyList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Assay Technology"
			selectedCode: @model.get('assayTechnology')

	setUpCellLineSelect: ->
		@cellLineList = new PickListList()
		@cellLineList.url = "/api/dataDict/cellLineCodes"
		@cellLineList = new PickListSelectController
			el: @$('.bv_cellLine')
			collection: @cellLineList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Cell Line"
			selectedCode: @model.get('cellLine')

	setUpAssayStageSelect: ->
		@assayStageList = new PickListList()
		@assayStageList.url = "/api/dataDict/assayStageCodes"
		@assayStageListController = new PickListSelectController
			el: @$('.bv_assayStage')
			collection: @assayStageList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select assay stage"
			selectedCode: @model.get('assayStage')

	updateModel: =>
		@model.set
			assayTreeRule: @getTrimmedInput('.bv_assayTreeRule')
			assayActivity: @$('.bv_assayActivity').val()
			molecularTarget: @$('.bv_molecularTarget').val()
			targetOrigin: @$('.bv_targetOrigin').val()
			assayType: @$('.bv_assayType').val()
			assayTechnology: @$('.bv_assayTechnology').val()
			cellLine: @$('.bv_cellLine').val()
			assayStage: @$('.bv_assayStage').val()
			maxY: parseFloat(@getTrimmedInput('.bv_maxY'))
			minY: parseFloat(@getTrimmedInput('.bv_minY'))

	handleTargetListChanged: =>
		dnsTargetList = @$('.bv_dnsTargetList').is(":checked")
		@model.set dnsTargetList: dnsTargetList
		if dnsTargetList
			@$('.bv_molecularTargetModal').hide()
		else
			@$('.bv_molecularTargetModal').show()
		@attributeChanged()


	addNewAssayActivity: ->
		console.log "add new activity clicked"
		parameter = 'assayActivity'
		pascalCaseParameterName = 'AssayActivity'
		@.addNewParameter(parameter,pascalCaseParameterName)

	addNewMolecularTarget: ->
		console.log "add new activity clicked"
		parameter = 'molecularTarget'
		pascalCaseParameterName = 'MolecularTarget'
		@.addNewParameter(parameter,pascalCaseParameterName)

	addNewTargetOrigin: ->
		console.log "add new target origin clicked"
		parameter = 'targetOrigin'
		pascalCaseParameterName = 'TargetOrigin'
		@.addNewParameter(parameter,pascalCaseParameterName)


	addNewParameter: (parameter,pascalCaseParameterName) ->
		console.log "add new parameter clicked"
		console.log pascalCaseParameterName
		# make new short name. for now, use label text as new name
		newOptionName = @$('.bv_new'+pascalCaseParameterName).val()
		console.log newOptionName
		if @.validNewOption(newOptionName,parameter)
			console.log "will add new option"
			#add new option to code table. for now just append to html
			#			protocolCodeTableTestJSON = require ''
			@$('.bv_'+parameter).append('<option value='+ newOptionName+'>'+newOptionName+'</option>')
			@$('#add'+pascalCaseParameterName+'Modal').modal('hide')
		else
			console.log "option already exists"
		# clear previous values in form so that if add is clicked again, it will be empty
		@$('.bv_new'+pascalCaseParameterName).val("")
		@$('.bv_new'+pascalCaseParameterName+'Description').val("")
		@$('.bv_new'+pascalCaseParameterName+'Comments').val("")


	validNewOption: (newOptionName,parameter) ->
		console.log "validating new option"
		#checks to see if assay activity option already exists
		console.log newOptionName
		console.log @$('.bv_'+parameter+' option[value='+newOptionName+']').length > 0
		if @$('.bv_'+parameter+' option[value='+newOptionName+']').length > 0
			return false
		else
			return true
