class window.PrimaryScreenProtocolParameters extends State

	validate: (attrs) =>
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
		molecularTarget = @getMolecularTarget().get('codeValue')
		if molecularTarget is "required"
			errors.push
				attribute: 'molecularTarget'
				message: "The target for the clone must be selected"
		if molecularTarget is "invalid"
			errors.push
				attribute: 'molecularTarget'
				message: "This target is not associated with the clone below"
		cloneName = @getCloneName().get('stringValue')
		if cloneName is "invalid"
			errors.push
				attribute: 'cloneName'
				message: "This clone does not exist"

		if errors.length > 0
			return errors
		else
			return null


	getCurveDisplayMin: ->
		minY = @.getOrCreateValueByTypeAndKind "numericValue", "curve display min"
		if minY.get('numericValue') is undefined or minY.get('numericValue') is ""
			minY.set numericValue: 0.0

		minY

	getCurveDisplayMax: ->
		maxY = @.getOrCreateValueByTypeAndKind "numericValue", "curve display max"
		if maxY.get('numericValue') is undefined or maxY.get('numericValue') is ""
			maxY.set numericValue: 100.0

		maxY

	getAssayActivity: ->
		aa = @.getOrCreateValueByTypeAndKind "codeValue", "assay activity"
		if aa.get('codeValue') is undefined or aa.get('codeValue') is "" or aa.get('codeValue') is null
			aa.set codeValue: "unassigned"
			aa.set codeType: "assay"
			aa.set codeKind: "activity"
			aa.set codeOrigin: "ACAS DDICT"

		aa

	getMolecularTarget: ->
		mt = @.getOrCreateValueByTypeAndKind "codeValue", "molecular target"
		if mt.get('codeValue') is undefined or mt.get('codeValue') is "" or mt.get('codeValue') is null
			mt.set codeValue: "unassigned"
			mt.set codeType: "assay"
			mt.set codeKind: "molecular target"
			mt.set codeOrigin: "ACAS DDICT"

		mt

	getCloneName: ->
		cloneName = @.getOrCreateValueByTypeAndKind "stringValue", "clone name"
		if cloneName.get('stringValue') is undefined or cloneName.get('stringValue') is null
			cloneName.set stringValue: ""

		cloneName

	getTargetOrigin: ->
		to = @.getOrCreateValueByTypeAndKind "codeValue", "target origin"
		if to.get('codeValue') is undefined or to.get('codeValue') is "" or to.get('codeValue') is null
			to.set codeValue: "unassigned"
			to.set codeType: "target"
			to.set codeKind: "origin"
			to.set codeOrigin: "ACAS DDICT"

		to

	getAssayType: ->
		at = @.getOrCreateValueByTypeAndKind "codeValue", "assay type"
		if at.get('codeValue') is undefined or at.get('codeValue') is "" or at.get('codeValue') is null
			at.set codeValue: "unassigned"
			at.set codeType: "assay"
			at.set codeKind: "type"
			at.set codeOrigin: "ACAS DDICT"

		at

	getAssayTechnology: ->
		at = @.getOrCreateValueByTypeAndKind "codeValue", "assay technology"
		if at.get('codeValue') is undefined or at.get('codeValue') is "" or at.get('codeValue') is null
			at.set codeValue: "unassigned"
			at.set codeType: "assay"
			at.set codeKind: "technology"
			at.set codeOrigin: "ACAS DDICT"

		at

	getCellLine: ->
		cl = @.getOrCreateValueByTypeAndKind "codeValue", "cell line"
		if cl.get('codeValue') is undefined or cl.get('codeValue') is "" or cl.get('codeValue') is null
			cl.set codeValue: "unassigned"
			cl.set codeType: "reagent"
			cl.set codeKind: "cell line"
			cl.set codeOrigin: "ACAS DDICT"

		cl


	getOrCreateValueByTypeAndKind: (vType, vKind) ->
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
	initialize: ->
		super()
		@.set lsType: "Biology"
		@.set lsKind: "Bio Activity"

	validate: (attrs) =>
		errors = []
		errors.push super(attrs)...
		psProtocolParameters = @getPrimaryScreenProtocolParameters()
		psProtocolParametersErrors = psProtocolParameters.validate()
		errors.push psProtocolParametersErrors...
		psAnalysisParameters = @getAnalysisParameters()
		psAnalysisParametersErrors = psAnalysisParameters.validate(psAnalysisParameters.attributes)
		errors.push psAnalysisParametersErrors...
		psModelFitParameters = new DoseResponseAnalysisParameters @getModelFitParameters()
		psModelFitParametersErrors = psModelFitParameters.validate(psModelFitParameters.attributes)
		errors.push psModelFitParametersErrors...

		if errors.length > 0
			return errors
		else
			return null


	getPrimaryScreenProtocolParameters: ->
		pspp = @get('lsStates').getOrCreateStateByTypeAndKind "metadata", "screening assay"

		new PrimaryScreenProtocolParameters pspp.attributes

	checkForNewPickListOptions: ->
		@trigger "checkForNewPickListOptions"

	getModelFitType: ->
		type = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "codeValue", "model fit type"
		if !type.has('codeValue')
			type.set codeValue: "unassigned"
			type.set codeType: "model fit"
			type.set codeKind: "type"
			type.set codeOrigin: "ACAS DDICT"

		type

class window.PrimaryScreenProtocolParametersController extends AbstractFormController
	template: _.template($("#PrimaryScreenProtocolParametersView").html())
	autofillTemplate: _.template($("#PrimaryScreenProtocolParametersAutofillView").html())

	events:
		"change .bv_maxY": "handleCurveDisplayMaxChanged"
		"change .bv_minY": "handleCurveDisplayMinChanged"
		"change .bv_assayActivity": "handleAssayActivityChanged"
		"change .bv_molecularTarget": "handleMolecularTargetChanged"
		"change .bv_targetOrigin": "handleTargetOriginChanged"
		"change .bv_assayType": "handleAssayTypeChanged"
		"change .bv_assayTechnology": "handleAssayTechnologyChanged"
		"change .bv_cellLine": "handleCellLineChanged"
		"change .bv_cloneName": "handleCloneNameChanged"


	initialize: ->
		@errorOwnerName = 'PrimaryScreenProtocolParametersController'
		@setBindings()
		super()
		@setupAssayActivitySelect()
		@setupTargetOriginSelect()
		@setupAssayTypeSelect()
		@setupAssayTechnologySelect()
		@setupCellLineSelect()



	render: =>
		@$el.empty()
		@$el.html @autofillTemplate(@model.attributes)
		@$('.bv_maxY').val(@model.getCurveDisplayMax().get('numericValue'))
		@$('.bv_minY').val(@model.getCurveDisplayMin().get('numericValue'))
		@$('.bv_cloneName').val(@model.getCloneName().get('stringValue'))
		@setupAssayActivitySelect()
		@setupMolecularTargetSelect()
		@setupTargetOriginSelect()
		@setupAssayTypeSelect()
		@setupAssayTechnologySelect()
		@setupCellLineSelect()
		super()

		@

	setupAssayActivitySelect: ->
		@assayActivityList = new PickListList()
		@assayActivityList.url = "/api/codetables/assay/activity"
		@assayActivityListController = new EditablePickListSelectController
			el: @$('.bv_assayActivity')
			collection: @assayActivityList
			selectedCode: @model.getAssayActivity().get('codeValue')
			parameter: "assayActivity"
			codeType: "assay"
			codeKind: "activity"
			roles: ["admin"]
		@assayActivityListController.on 'change', @handleAssayActivityChanged
		@assayActivityListController.render()

	setupTargetOriginSelect: ->
		@targetOriginList = new PickListList()
		@targetOriginList.url = "/api/codetables/target/origin"
		@targetOriginListController = new EditablePickListSelectController
			el: @$('.bv_targetOrigin')
			collection: @targetOriginList
			selectedCode: @model.getTargetOrigin().get('codeValue')
			parameter: "targetOrigin"
			codeType: "target"
			codeKind: "origin"
			roles: ["admin"]
		@targetOriginListController.on 'change', @handleTargetOriginChanged
		@targetOriginListController.render()

	setupAssayTypeSelect: ->
		@assayTypeList = new PickListList()
		@assayTypeList.url = "/api/codetables/assay/type"
		@assayTypeListController = new EditablePickListSelectController
			el: @$('.bv_assayType')
			collection: @assayTypeList
			selectedCode: @model.getAssayType().get('codeValue')
			parameter: "assayType"
			codeType: "assay"
			codeKind: "type"
			roles: ["admin"]
		@assayTypeListController.on 'change', @handleAssayTypeChanged
		@assayTypeListController.render()

	setupAssayTechnologySelect: ->
		@assayTechnologyList = new PickListList()
		@assayTechnologyList.url = "/api/codetables/assay/technology"
		@assayTechnologyListController = new EditablePickListSelectController
			el: @$('.bv_assayTechnology')
			collection: @assayTechnologyList
			selectedCode: @model.getAssayTechnology().get('codeValue')
			parameter: "assayTechnology"
			codeType: "assay"
			codeKind: "technology"
			roles: ["admin"]
		@assayTechnologyListController.on 'change', @handleAssayTechnologyChanged
		@assayTechnologyListController.render()

	setupCellLineSelect: ->
		@cellLineList = new PickListList()
		@cellLineList.url = "/api/codetables/reagent/cell line"
		@cellLineListController = new EditablePickListSelectController
			el: @$('.bv_cellLine')
			collection: @cellLineList
			selectedCode: @model.getCellLine().get('codeValue')
			parameter: "cellLine"
			codeType: "reagent"
			codeKind: "cell line"
			roles: ["admin"]
		@cellLineListController.on 'change', @handleCellLineChanged
		@cellLineListController.render()


	setupMolecularTargetSelect: ->
		@molecularTargetList = new PickListList()
		@molecularTargetList.url = "/api/customerMolecularTargetCodeTable"
		@molecularTargetListController = new PickListSelectController
			el: @$('.bv_molecularTarget')
			collection: @molecularTargetList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Target"
			selectedCode: @model.getMolecularTarget().get('codeValue')

	handleAssayActivityChanged: =>
		@model.getAssayActivity().set
			codeValue: @assayActivityListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	handleMolecularTargetChanged: =>
		@model.getMolecularTarget().set
			codeValue: @molecularTargetListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		@handleCloneNameChanged()

	handleCloneNameChanged: =>
		cloneName = UtilityFunctions::getTrimmedInput @$('.bv_cloneName')
		@model.getCloneName().set
			stringValue: cloneName
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
		if cloneName is ""
			@model.getMolecularTarget().set
				codeValue: @molecularTargetListController.getSelectedCode()
				recordedBy: window.AppLaunchParams.loginUser.username
				recordedDate: new Date().getTime()
		else
			@validateClone(cloneName)

	validateClone: (cloneName) =>
		$.ajax
			type: 'GET'
			url: "/api/cloneValidation/"+cloneName
			success: (json) =>
				@handleCloneValidationReturn(json)
			error: (err) =>
				alert 'got error validating clone'

	handleCloneValidationReturn: (json) =>
		if json.length is 0
			@model.getCloneName().set stringValue: 'invalid'
		else
			cloneTarget = json[0]
			@checkCloneTarget(cloneTarget)

	checkCloneTarget: (cloneTarget) =>
		selectedTarget = @model.getMolecularTarget().get('codeValue')
		unless selectedTarget == cloneTarget
			if @model.getMolecularTarget().get('codeValue') is "unassigned"
				@model.getMolecularTarget().set codeValue: 'required'
			else
				@model.getMolecularTarget().set codeValue: 'invalid'

	handleTargetOriginChanged: =>
		@model.getTargetOrigin().set
			codeValue: @targetOriginListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	handleAssayTypeChanged: =>
		@model.getAssayType().set
			codeValue: @assayTypeListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	handleAssayTechnologyChanged: =>
		@model.getAssayTechnology().set
			codeValue: @assayTechnologyListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	handleCellLineChanged: =>
		@model.getCellLine().set
			codeValue: @cellLineListController.getSelectedCode()
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	handleCurveDisplayMaxChanged: =>
		@model.getCurveDisplayMax().set
			numericValue: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_maxY'))
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	handleCurveDisplayMinChanged: =>
		@model.getCurveDisplayMin().set
			numericValue: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_minY'))
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	saveNewPickListOptions: (callback) =>
		@assayActivityListController.saveNewOption =>
			@targetOriginListController.saveNewOption =>
				@assayTypeListController.saveNewOption =>
					@assayTechnologyListController.saveNewOption =>
						@cellLineListController.saveNewOption =>
							callback.call()


# controller for the primary screen protocol general information tab
class window.PrimaryScreenProtocolController extends Backbone.View

	initialize: ->
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		@setupProtocolBaseController()
		@setupPrimaryScreenProtocolParametersController()
		@protocolBaseController.model.on "checkForNewPickListOptions", @handleCheckForNewPickListOptions



	setupProtocolBaseController: =>
		@protocolBaseController = new ProtocolBaseController
			model: @model
			el: @el
			readOnly: @readOnly
		@protocolBaseController.on 'amDirty', =>
			@trigger 'amDirty'
		@protocolBaseController.on 'amClean', =>
			@trigger 'amClean'
		@protocolBaseController.on "noEditablePickLists", =>
			@trigger 'prepareToSaveToDatabase'
		@protocolBaseController.on 'reinitialize', =>
			@trigger 'reinitialize'
		@protocolBaseController.render()

	setupPrimaryScreenProtocolParametersController: =>
		@primaryScreenProtocolParametersController= new PrimaryScreenProtocolParametersController
			model: @model.getPrimaryScreenProtocolParameters()
			el: @$('.bv_primaryScreenProtocolAutofillSection')
		@primaryScreenProtocolParametersController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenProtocolParametersController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenProtocolParametersController.render()

	handleSaveClicked: =>
		@protocolBaseController.beginSave()

	handleCheckForNewPickListOptions: =>
		@primaryScreenProtocolParametersController.saveNewPickListOptions =>
			@trigger "prepareToSaveToDatabase"

	displayInReadOnlyMode: =>
		@protocolBaseController.displayInReadOnlyMode()

	attachFilesAreValid: =>
		@protocolBaseController.isValid()

# This wraps all the tabs
class window.AbstractPrimaryScreenProtocolModuleController extends AbstractFormController
	template: _.template($("#PrimaryScreenProtocolModuleView").html())

	events:
		"click .bv_saveModule": "handleSaveModule"
		"click .bv_cancelModule": "handleCancelClicked"
		"click .bv_newModule": "handleNewEntityClicked"
		"click .bv_cancelClearModule": "handleCancelClearClicked"
		"click .bv_confirmModuleClear": "handleConfirmClearClicked"


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
								if lsKind is "Bio Activity"
									prot = new PrimaryScreenProtocol json
									prot.set prot.parse(prot.attributes)
									if window.AppLaunchParams.moduleLaunchParams.copy
										@model = prot.duplicateEntity()
									else
										@model = prot
								else
									alert 'Could not get primary screen protocol for code in this URL. Creating new primary screen protocol'
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new PrimaryScreenProtocol()
		$(@el).html @template()
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'change', @modelChangeCallback
		@model.on 'readyToSave', @handleFinishSave
		@setupPrimaryScreenProtocolController()
		@setupPrimaryScreenAnalysisParametersController()
		@setupModelFitTypeController()

		@errorOwnerName = 'PrimaryScreenProtocolModuleController'
		@setBindings()
		@$('.bv_saveAndCancelButtons').hide()
		@$('.bv_saveModule').attr('disabled', 'disabled')

		if @model.isNew()
			@$('.bv_saveModule').html("Save")
			@$('.bv_saveInstructions').show()
			@$('.bv_newModule').hide()
		else
			@$('.bv_saveModule').html("Update")
			@$('.bv_saveInstructions').hide()
			@$('.bv_newModule').show()
		@$('.bv_cancelModule').attr('disabled','disabled')
		@trigger 'amClean' #so that module starts off clean when initialized

	modelSyncCallback: =>
		unless @model.get('subclass')?
			@model.set subclass: 'protocol'
		@setupPrimaryScreenProtocolController()
		@setupPrimaryScreenAnalysisParametersController()
		@setupModelFitTypeController()
		@$('.bv_savingModule').hide()
		@$('.bv_saveAndCancelButtons').hide()
		if @$('.bv_cancelModuleComplete').is(":visible")
			@$('.bv_updateModuleComplete').hide()
		else
			@$('.bv_updateModuleComplete').show()
		@$('.bv_saveModule').attr('disabled', 'disabled')
		if @model.isNew()
			@$('.bv_saveModule').html("Save")
			@$('.bv_saveInstructions').show()
		else
			@$('.bv_saveModule').html("Update")
			@$('.bv_saveInstructions').hide()
		@$('.bv_cancelModule').attr('disabled', 'disabled')
		@trigger 'amClean'

	modelChangeCallback: =>
		@trigger 'amDirty'
		@$('.bv_updateModuleComplete').hide()
		@$('.bv_cancelModule').removeAttr('disabled')
		@$('.bv_cancelModuleComplete').hide()

	handleProtocolSaved: =>
		@trigger 'amClean'
		@$('.bv_savingModule').hide()
		@$('.bv_updateModuleComplete').show()
		if @model.isNew()
			@$('.bv_saveModule').html("Save")
		else
			@$('.bv_saveModule').html("Update")


	setupPrimaryScreenProtocolController: =>
		if @primaryScreenProtocolController?
			@primaryScreenProtocolController.undelegateEvents()
		@primaryScreenProtocolController = new PrimaryScreenProtocolController
			model: @model
			el: @$('.bv_primaryScreenProtocolGeneralInfoWrapper')
		@primaryScreenProtocolController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenProtocolController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenProtocolController.on 'reinitialize', @reinitialize
		@primaryScreenProtocolController.render()
		@primaryScreenProtocolController.on 'prepareToSaveToDatabase', @prepareToSaveToDatabase

	setupPrimaryScreenAnalysisParametersController: =>
		if @primaryScreenAnalysisParametersController?
			@primaryScreenAnalysisParametersController.undelegateEvents()
		@primaryScreenAnalysisParametersController = new PrimaryScreenAnalysisParametersController
			model: @model.getAnalysisParameters()
			el: @$('.bv_primaryScreenAnalysisParameters')
		@primaryScreenAnalysisParametersController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenAnalysisParametersController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenAnalysisParametersController.on 'updateState', @updateAnalysisClobValue
		@primaryScreenAnalysisParametersController.render()

	setupModelFitTypeController: =>
		if @modelFitTypeController?
			@modelFitTypeController.undelegateEvents()
		@modelFitTypeController = new ModelFitTypeController
			model: @model
			el: @$('.bv_doseResponseAnalysisParameters')
		@modelFitTypeController.on 'amDirty', =>
			@trigger 'amDirty'
		@modelFitTypeController.on 'amClean', =>
			@trigger 'amClean'
		@modelFitTypeController.render()
		@modelFitTypeController.on 'updateState', @updateModelFitClobValue

	updateAnalysisClobValue: =>
		if @primaryScreenAnalysisParametersController.model.get('positiveControl').get('concentration') is Infinity
			@primaryScreenAnalysisParametersController.model.get('positiveControl').set concentration: "Infinity" #JSON doesn't store Infinity as value
		ap = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "data analysis parameters"
		ap.set
			clobValue: JSON.stringify @primaryScreenAnalysisParametersController.model.attributes
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	updateModelFitClobValue: =>
		mfp = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "model fit parameters"
		mfp.set
			clobValue: JSON.stringify @modelFitTypeController.parameterController.model.attributes
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

	handleSaveModule: =>
		@$('.bv_savingModule').show()
		@primaryScreenProtocolController.handleSaveClicked()

	prepareToSaveToDatabase: =>
		@model.prepareToSave()


	handleFinishSave: =>
		if @model.isNew()
			@$('.bv_updateModuleComplete').html "Save Complete"
		else
			@$('.bv_updateModuleComplete').html "Update Complete"

		@$('.bv_saveModule').attr('disabled', 'disabled')
		@model.save()


	validationError: =>
		super()
		@$('.bv_saveModule').attr('disabled', 'disabled')
		@$('.bv_saveInstructions').show()

	clearValidationErrorStyles: =>
		super()
		@$('.bv_saveModule').removeAttr('disabled')
		@$('.bv_saveInstructions').hide()

	isValid: =>
		unless @primaryScreenProtocolController.attachFilesAreValid()
			@$('.bv_saveModule').attr('disabled', 'disabled')

	reinitialize: =>
		@model = null
		@completeInitialization()

	handleCancelClicked: =>
#		@primaryScreenProtocolController.protocolBaseController.handleCancelClicked()
		if @model.isNew()
			@reinitialize()
		else
			@$('.bv_cancelingModule').show()
			@model.fetch
				success: @handleCancelComplete
		@trigger 'amClean'

	handleCancelComplete: =>
		@$('.bv_cancelingModule').hide()
		@$('.bv_cancelModuleComplete').show()

	handleNewEntityClicked: =>
		@primaryScreenProtocolController.protocolBaseController.handleNewEntityClicked()

	handleCancelClearClicked: =>
		@primaryScreenProtocolController.protocolBaseController.handleCancelClearClicked()

	handleConfirmClearClicked: =>
		@primaryScreenProtocolController.protocolBaseController.handleConfirmClearClicked()

class window.PrimaryScreenProtocolModuleController extends AbstractPrimaryScreenProtocolModuleController
	moduleLaunchName: "primary_screen_protocol"
