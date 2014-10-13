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

		if errors.length > 0
			return errors
		else
			return null

	getCustomerMolecularTargetCodeOrigin: ->
	#returns true if molecular target's codeOrigin is not acas ddict
		molecularTarget = @getOrCreateValueByTypeAndKind "codeValue", "molecular target"
		console.log molecularTarget.get('codeOrigin')
		if molecularTarget.get('codeOrigin') is "customer ddict"
			console.log "getCustomerMolecularTargetCodeOrigin and is customer ddict"
			return true
		else
			return false

	setCustomerMolecularTargetCodeOrigin: (customerCodeOrigin) ->
	# customerCodeOrigin is boolean. If true, codeOrigin for molecular target is not acas ddict
		console.log @
		console.log "setting customer target List"
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

	getPrimaryScreenProtocolParameters: ->
		pspp = @get('lsStates').getOrCreateStateByTypeAndKind "metadata", "screening assay"

		new PrimaryScreenProtocolParameters pspp.attributes


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
		console.log "setting up assay activity select"
		console.log @model
		console.log @model.getPrimaryScreenProtocolParameterCodeValue('assay activity')
		@assayActivityList = new PickListList()
		@assayActivityList.url = "/api/dataDict/protocolMetadata/assay activity"
		@assayActivityListController = new EditablePickListSelectController
			el: @$('.bv_assayActivity')
			collection: @assayActivityList
#			insertFirstOption: new PickList
#				code: "unassigned"
#				name: "Select Assay Activity"
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')
			parameter: "assayActivity"
			roles: ["admin"]
		@assayActivityListController.render()
		console.log @assayActivityListController

	setupMolecularTargetSelect: ->
		console.log "setting up molecular target select"
		console.log @model
		console.log @model.getPrimaryScreenProtocolParameterCodeValue('molecular target')
		@molecularTargetList = new PickListList()
		@molecularTargetList.url = "/api/dataDict/protocolMetadata/molecular target"
		@molecularTargetListController = new EditablePickListSelectController
			el: @$('.bv_molecularTarget')
			collection: @molecularTargetList
#			insertFirstOption: new PickList
#				code: "unassigned"
#				name: "Select Molecular Target"
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')
			parameter: "molecularTarget"
			roles: ["admin"]
		@molecularTargetListController.render()
		console.log @molecularTargetListController

	setupTargetOriginSelect: ->
		@targetOriginList = new PickListList()
		@targetOriginList.url = "/api/dataDict/protocolMetadata/target origin"
		@targetOriginListController = new EditablePickListSelectController
			el: @$('.bv_targetOrigin')
			collection: @targetOriginList
#			insertFirstOption: new PickList
#				code: "unassigned"
#				name: "Select Target Origin"
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')
			parameter: "targetOrigin"
			roles: ["admin"]
		@targetOriginListController.render()

	setupAssayTypeSelect: ->
		@assayTypeList = new PickListList()
		@assayTypeList.url = "/api/dataDict/protocolMetadata/assay type"
		@assayTypeListController = new EditablePickListSelectController
			el: @$('.bv_assayType')
			collection: @assayTypeList
#			insertFirstOption: new PickList
#				code: "unassigned"
#				name: "Select Assay Type"
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')
			parameter: "assayType"
			roles: ["admin"]
		@assayTypeListController.render()

	setupAssayTechnologySelect: ->
		@assayTechnologyList = new PickListList()
		@assayTechnologyList.url = "/api/dataDict/protocolMetadata/assay technology"
		@assayTechnologyListController = new EditablePickListSelectController
			el: @$('.bv_assayTechnology')
			collection: @assayTechnologyList
#			insertFirstOption: new PickList
#				code: "unassigned"
#				name: "Select Assay Technology"
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')
			parameter: "assayTechnology"
			roles: ["admin"]
		@assayTechnologyListController.render()

	setupCellLineSelect: ->
		@cellLineList = new PickListList()
		@cellLineList.url = "/api/dataDict/protocolMetadata/cell line"
		@cellLineListController = new EditablePickListSelectController
			el: @$('.bv_cellLine')
			collection: @cellLineList
#			insertFirstOption: new PickList
#				code: "unassigned"
#				name: "Select Cell Line"
			selectedCode: @model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')
			parameter: "cellLine"
			roles: ["admin"]
		@cellLineListController.render()


	setUpAssayStageSelect: ->
		@assayStageList = new PickListList()
		@assayStageList.url = "/api/dataDict/protocolMetadata/assay stage"
		console.log "about to set up assay stage"
		console.log @model
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
			console.log "code origin is customer specific"
			@$('.bv_customerMolecularTargetDDictChkbx').attr("checked", "checked")

	updateModel: =>
		console.log "update model"
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
		console.log @model


	handleMolecularTargetDDictChanged: =>
		customerDDict = @$('.bv_customerMolecularTargetDDictChkbx').is(":checked")
		console.log "handle molec traget ddict changed"
		console.log customerDDict
		@model.setCustomerMolecularTargetCodeOrigin(customerDDict)
		if customerDDict
			@molecularTargetListController.hideAddOptionButton()
			targetListurl = "http://imapp01-d:8080/DNS/codes/v1/Codes/SB_Variant_Construct"
			# TODO: repopulate Molecular Target Select list with DNS Target List.
		else
			@molecularTargetListController.showAddOptionButton()
			targetListurl = "/api/dataDict/protocolMetadata/molecular target"
		@attributeChanged()

	saveNewPickListOptions: =>
		console.log "save new pick list options"
		@assayActivityListController.saveNewOption()
		@molecularTargetListController.saveNewOption()
		@targetOriginListController.saveNewOption()
		@assayTypeListController.saveNewOption()
		@assayTechnologyListController.saveNewOption()
		@cellLineListController.saveNewOption()



# controller for the primary screen protocol general information tab
class window.PrimaryScreenProtocolController extends Backbone.View

	initialize: ->
		@setupProtocolBaseController()
		@setupPrimaryScreenProtocolParametersController()
		@protocolBaseController.model.on "checkForNewPickListOption", @handleCheckForNewPickListOption



	setupProtocolBaseController: ->
		console.log @model
		@protocolBaseController = new ProtocolBaseController
			model: @model
			el: @el
		@protocolBaseController.on 'amDirty', =>
			@trigger 'amDirty'
		@protocolBaseController.on 'amClean', =>
			@trigger 'amClean'
		@protocolBaseController.render()
		console.log "set up protocol base controller"

	setupPrimaryScreenProtocolParametersController: ->
		console.log "SETTING UP PRIMARY SCREEN PROTOCOL PARAMETERS CONTROLLER"
		#		console.log @model.get('primaryScreenProtocolParameters')
		@primaryScreenProtocolParametersController= new PrimaryScreenProtocolParametersController
			model: @model.getPrimaryScreenProtocolParameters()
#			model: @model.get('primaryScreenProtocolParameters')
			el: @$('.bv_primaryScreenProtocolAutofillSection')
		@primaryScreenProtocolParametersController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenProtocolParametersController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenProtocolParametersController.render()
		console.log "set up ps protocol parameters controller"


	handleCheckForNewPickListOption: =>
		console.log "triggered save new picklist option"
		@primaryScreenProtocolParametersController.saveNewPickListOptions()



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


#		@analysisController = new PrimaryScreenAnalysisController
#			model: @model
#			el: @$('.bv_primaryScreenDataAnalysis')
#			uploadAndRunControllerName: @uploadAndRunControllerName
#		@analysisController.on 'amDirty', =>
#			@trigger 'amDirty'
#		@analysisController.on 'amClean', =>
#			@trigger 'amClean'
#		@setupModelFitController(@modelFitControllerName)
#		@analysisController.on 'analysis-completed', =>
#			@modelFitController.primaryAnalysisCompleted()
#		@analysisController.render()
#		@modelFitController.render()


#	setupModelFitController: (modelFitControllerName) ->
#		newArgs =
#			model: @model
#			el: @$('.bv_doseResponseAnalysis')
#		@modelFitController = new window[modelFitControllerName](newArgs)
#		@modelFitController.on 'amDirty', =>
#			@trigger 'amDirty'
#		@modelFitController.on 'amClean', =>
#			@trigger 'amClean'

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
		console.log @primaryScreenAnalysisParametersController


class window.PrimaryScreenProtocolModuleController extends AbstractPrimaryScreenProtocolModuleController
#	uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
#	modelFitControllerName: "DoseResponseAnalysisController"
	moduleLaunchName: "primary_screen_protocol"
