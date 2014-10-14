class window.PrimaryScreenProtocolParameters extends State

	validate: (attrs) ->
		errors =[]
		maxY = @getCurveDisplayMax().get('numericValue')
		if isNaN(maxY)
			errors.push
				attribute: 'maxY'
				message: "maxY must be a number"
		minY = @getCurveDisplayMin().get('numericValue')
		if isNaN(minY)
			errors.push
				attribute: 'minY'
				message: "minY must be a number"
		if maxY<minY
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

	getCustomerMolecularTargetCodeOrigin: ->
	#returns true if molecular target's codeOrigin is not acas ddict
		molecularTarget = @getOrCreateValueByTypeAndKind "codeValue", "molecular target"
		if molecularTarget.get('codeOrigin') is "customer ddict"
			return true
		else
			return false

	setCustomerMolecularTargetCodeOrigin: (customerCodeOrigin) ->
	# customerCodeOrigin is boolean. If true, codeOrigin for molecular target is not acas ddict
		molecularTarget = @getOrCreateValueByTypeAndKind "codeValue", "molecular target"
		if customerCodeOrigin
#		molecularTarget = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "screening assay", "codeValue", "molecular target"
			molecularTarget.set codeOrigin: "customer ddict"
		else
			molecularTarget.set codeOrigin: "acas ddict"

	getCurveDisplayMin: ->
#		minY = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "screening assay", "numericValue", "curve display min"
		minY = @.getOrCreateValueByTypeAndKind "numericValue", "curve display min"
		if minY.get('numericValue') is undefined or minY.get('numericValue') is ""
			minY.set numericValue: 0.0

		minY

	getCurveDisplayMax: ->
#		maxY = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "screening assay", "numericValue", "curve display max"
		maxY = @.getOrCreateValueByTypeAndKind "numericValue", "curve display max"
		if maxY.get('numericValue') is undefined or maxY.get('numericValue') is ""
			maxY.set numericValue: 100.0

		maxY

	getPrimaryScreenProtocolParameterCodeValue: (parameterName) ->
#		parameter = @.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "screening assay", "codeValue", parameterName
		parameter = @.getOrCreateValueByTypeAndKind "codeValue", parameterName
		parameter.set codeType: "protocolMetadata"
		if parameter.get('codeValue') is undefined or parameter.get('codeValue') is ""
			parameter.set codeValue: "unassigned"
		if parameter.get('codeOrigin') is undefined or parameter.get('codeOrigin') is ""
			parameter.set codeOrigin: "acas ddict"

		parameter

	getOrCreateValueByTypeAndKind: (vType, vKind) ->
#		metaState = @getOrCreateStateByTypeAndKind sType, sKind
		descVals = @getValuesByTypeAndKind vType, vKind
		descVal = descVals[0] #TODO should do something smart if there are more than one
		unless descVal?
			descVal = new Value
				lsType: vType
				lsKind: vKind
			@get('lsValues').add descVal
			descVal.on 'change', =>
				@trigger('change')

		descVal



class window.PrimaryScreenProtocol extends Protocol

	validate: (attrs) ->
		errors = []
		psProtocolParameters = @getPrimaryScreenProtocolParameters()
		psProtocolParametersErrors = psProtocolParameters.validate()
		errors.push psProtocolParametersErrors...
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

		if errors.length > 0
			return errors
		else
			return null


	getPrimaryScreenProtocolParameters: ->
		pspp = @get('lsStates').getOrCreateStateByTypeAndKind "metadata", "screening assay"

		new PrimaryScreenProtocolParameters pspp.attributes

	checkForNewPickListOptions: ->
		@trigger "checkForNewPickListOptions"


class window.PrimaryScreenProtocolParametersController extends AbstractFormController
	template: _.template($("#PrimaryScreenProtocolParametersView").html())
	autofillTemplate: _.template($("#PrimaryScreenProtocolParametersAutofillView").html())

	events:
		"click .bv_customerMolecularTargetDDictChkbx": "handleMolecularTargetDDictChanged"
		"change .bv_assayStage": "attributeChanged"
		"change .bv_maxY": "attributeChanged"
		"change .bv_minY": "attributeChanged"
		"change .bv_assayActivity": "attributeChanged"
		"change .bv_molecularTarget": "attributeChanged"
		"change .bv_targetOrigin": "attributeChanged"
		"change .bv_assayType": "attributeChanged"
		"change .bv_assayTechnology": "attributeChanged"
		"change .bv_cellLine": "attributeChanged"


	initialize: ->
		@errorOwnerName = 'PrimaryScreenProtocolParametersController'
		@setBindings()
		super()
		@setupAssayActivitySelect()
		@setupMolecularTargetSelect()
		@setupTargetOriginSelect()
		@setupAssayTypeSelect()
		@setupAssayTechnologySelect()
		@setupCellLineSelect()
		@setUpAssayStageSelect()



	render: =>
		@$el.empty()
		@$el.html @autofillTemplate(@model.attributes)
#		@$('.bv_customerTargetListChkbx').val(@model.get('customerTargetList'))
		@$('.bv_maxY').val(@model.getCurveDisplayMax().get('numericValue'))
		@$('.bv_minY').val(@model.getCurveDisplayMin().get('numericValue'))
		@setupAssayActivitySelect()
		@setupMolecularTargetSelect()
		@setupTargetOriginSelect()
		@setUpAssayStageSelect()
		@setupAssayTypeSelect()
		@setupAssayTechnologySelect()
		@setupCellLineSelect()
		@setupCustomerMolecularTargetDDictChkbx()
		super()

		@

	setupAssayActivitySelect: ->
		@assayActivityList = new PickListList()
		@assayActivityList.url = "/api/dataDict/protocolMetadata/assay activity"
		@assayActivityListController = new EditablePickListSelectController
			el: @$('.bv_assayActivity')
			collection: @assayActivityList
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')
			parameter: "assayActivity"
			codeType: "protocolMetadata"
			roles: ["admin"]
		@assayActivityListController.render()

	setupMolecularTargetSelect: ->
		@molecularTargetList = new PickListList()
		@molecularTargetList.url = "/api/dataDict/protocolMetadata/molecular target"
		@molecularTargetListController = new EditablePickListSelectController
			el: @$('.bv_molecularTarget')
			collection: @molecularTargetList
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')
			parameter: "molecularTarget"
			codeType: "protocolMetadata"
			roles: ["admin"]
		@molecularTargetListController.render()

	setupTargetOriginSelect: ->
		@targetOriginList = new PickListList()
		@targetOriginList.url = "/api/dataDict/protocolMetadata/target origin"
		@targetOriginListController = new EditablePickListSelectController
			el: @$('.bv_targetOrigin')
			collection: @targetOriginList
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')
			parameter: "targetOrigin"
			codeType: "protocolMetadata"
			roles: ["admin"]
		@targetOriginListController.render()

	setupAssayTypeSelect: ->
		@assayTypeList = new PickListList()
		@assayTypeList.url = "/api/dataDict/protocolMetadata/assay type"
		@assayTypeListController = new EditablePickListSelectController
			el: @$('.bv_assayType')
			collection: @assayTypeList
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')
			parameter: "assayType"
			codeType: "protocolMetadata"
			roles: ["admin"]
		@assayTypeListController.render()

	setupAssayTechnologySelect: ->
		@assayTechnologyList = new PickListList()
		@assayTechnologyList.url = "/api/dataDict/protocolMetadata/assay technology"
		@assayTechnologyListController = new EditablePickListSelectController
			el: @$('.bv_assayTechnology')
			collection: @assayTechnologyList
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')
			parameter: "assayTechnology"
			codeType: "protocolMetadata"
			roles: ["admin"]
		@assayTechnologyListController.render()

	setupCellLineSelect: ->
		@cellLineList = new PickListList()
		@cellLineList.url = "/api/dataDict/protocolMetadata/cell line"
		@cellLineListController = new EditablePickListSelectController
			el: @$('.bv_cellLine')
			collection: @cellLineList
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')
			parameter: "cellLine"
			codeType: "protocolMetadata"
			roles: ["admin"]
		@cellLineListController.render()


	setUpAssayStageSelect: ->
		@assayStageList = new PickListList()
		@assayStageList.url = "/api/dataDict/protocolMetadata/assay stage"
		@assayStageListController = new PickListSelectController
			el: @$('.bv_assayStage')
			collection: @assayStageList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select assay stage"
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')

	setupCustomerMolecularTargetDDictChkbx: ->
		checked = @model.getCustomerMolecularTargetCodeOrigin()
		if checked
			@$('.bv_customerMolecularTargetDDictChkbx').attr("checked", "checked")

	updateModel: =>
		@model.getPrimaryScreenProtocolParameterCodeValue('assay activity').set
			codeValue: @assayActivityListController.getSelectedCode()
		@model.getPrimaryScreenProtocolParameterCodeValue('molecular target').set
			codeValue: @molecularTargetListController.getSelectedCode()
		@model.getPrimaryScreenProtocolParameterCodeValue('target origin').set
			codeValue: @targetOriginListController.getSelectedCode()
		@model.getPrimaryScreenProtocolParameterCodeValue('assay type').set
			codeValue: @assayTypeListController.getSelectedCode()
		@model.getPrimaryScreenProtocolParameterCodeValue('assay technology').set
			codeValue: @assayTechnologyListController.getSelectedCode()
		@model.getPrimaryScreenProtocolParameterCodeValue('cell line').set
			codeValue: @cellLineListController.getSelectedCode()
		@model.getPrimaryScreenProtocolParameterCodeValue('assay stage').set
			codeValue: @assayStageListController.getSelectedCode()
		@model.getCurveDisplayMax().set
			numericValue: parseFloat(@getTrimmedInput('.bv_maxY')) #TODO: trim - will do after merge so can use utility function
		@model.getCurveDisplayMin().set
			numericValue: parseFloat(@getTrimmedInput('.bv_minY'))


	handleMolecularTargetDDictChanged: =>
		customerDDict = @$('.bv_customerMolecularTargetDDictChkbx').is(":checked")
		@model.setCustomerMolecularTargetCodeOrigin(customerDDict)
		if customerDDict
			@molecularTargetList.url = "/api/customerMolecularTargetCodeTable"
			@molecularTargetListController.render()
			@molecularTargetListController.hideAddOptionButton()
		else
			@molecularTargetList.url = "/api/dataDict/protocolMetadata/molecular target"
			@molecularTargetListController.render()
			@molecularTargetListController.showAddOptionButton()


		@attributeChanged()

	saveNewPickListOptions: (callback) =>
		@assayActivityListController.saveNewOption =>
			@molecularTargetListController.saveNewOption =>
				@targetOriginListController.saveNewOption =>
					@assayTypeListController.saveNewOption =>
						@assayTechnologyListController.saveNewOption =>
							@cellLineListController.saveNewOption =>
								callback.call()



# controller for the primary screen protocol general information tab
class window.PrimaryScreenProtocolController extends Backbone.View

	initialize: ->
		@setupProtocolBaseController()
		@setupPrimaryScreenProtocolParametersController()
		@protocolBaseController.model.on "checkForNewPickListOptions", @handleCheckForNewPickListOptions



	setupProtocolBaseController: ->
		@protocolBaseController = new ProtocolBaseController
			model: @model
			el: @el
		@protocolBaseController.on 'amDirty', =>
			@trigger 'amDirty'
		@protocolBaseController.on 'amClean', =>
			@trigger 'amClean'
		@protocolBaseController.render()

	setupPrimaryScreenProtocolParametersController: ->
		@primaryScreenProtocolParametersController= new PrimaryScreenProtocolParametersController
			model: @model.getPrimaryScreenProtocolParameters()
#			model: @model.get('primaryScreenProtocolParameters')
			el: @$('.bv_primaryScreenProtocolAutofillSection')
		@primaryScreenProtocolParametersController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenProtocolParametersController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenProtocolParametersController.render()


	handleCheckForNewPickListOptions: =>
		@primaryScreenProtocolParametersController.saveNewPickListOptions =>
			@protocolBaseController.model.prepareToSave()



# This wraps all the tabs
class window.AbstractPrimaryScreenProtocolModuleController extends Backbone.View
	template: _.template($("#PrimaryScreenProtocolModuleView").html())

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
								prot = new PrimaryScreenProtocol json
								prot.fixCompositeClasses()
								@model = prot
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()


	completeInitialization: ->
		unless @model?
			@model = new PrimaryScreenProtocol()
		$(@el).html @template()
		@model.on 'sync', @handleProtocolSaved

		@setupPrimaryScreenProtocolController()
		@setupPrimaryScreenAnalysisParametersController()
		@setupPrimaryScreenModelFitParametersController()


	handleProtocolSaved: =>
		@primaryScreenAnalysisParametersController.render()


	setupPrimaryScreenProtocolController: ->
		@primaryScreenProtocolController = new PrimaryScreenProtocolController
			model: @model
			el: @$('.bv_primaryScreenProtocolGeneralInfoWrapper')
		@primaryScreenProtocolController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenProtocolController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenProtocolController.render()

	setupPrimaryScreenAnalysisParametersController: ->
		@primaryScreenAnalysisParametersController = new PrimaryScreenAnalysisParametersController
			model: @model.getAnalysisParameters()
			el: @$('.bv_primaryScreenAnalysisParameters')
		@primaryScreenAnalysisParametersController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenAnalysisParametersController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenAnalysisParametersController.render()

	setupPrimaryScreenModelFitParametersController: ->
		@primaryScreenModelFitParametersController = new DoseResponseAnalysisParametersController
			model: new DoseResponseAnalysisParameters @model.getModelFitParameters()
			el: @$('.bv_doseResponseAnalysisParameters')
		@primaryScreenModelFitParametersController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenModelFitParametersController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenModelFitParametersController.render()


class window.PrimaryScreenProtocolModuleController extends AbstractPrimaryScreenProtocolModuleController
#	uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
#	modelFitControllerName: "DoseResponseAnalysisController"
	moduleLaunchName: "primary_screen_protocol"
