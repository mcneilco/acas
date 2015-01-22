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

	getCustomerMolecularTargetCodeOrigin: =>
	#returns true if molecular target's codeOrigin is not acas ddict
		molecularTarget = @getMolecularTarget()
		if molecularTarget.get('codeOrigin') is "customer ddict"
			return true
		else
			return false

	setCustomerMolecularTargetCodeOrigin: (customerCodeOrigin) ->
	# customerCodeOrigin is boolean. If true, codeOrigin for molecular target is not acas ddict
		molecularTarget = @getMolecularTarget()
		if customerCodeOrigin
			molecularTarget.set codeOrigin: "customer ddict"
		else
			molecularTarget.set codeOrigin: "ACAS DDICT"

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

	validate: (attrs) ->
		errors = []
		psProtocolParameters = @getPrimaryScreenProtocolParameters()
		psProtocolParametersErrors = psProtocolParameters.validate()
		errors.push psProtocolParametersErrors...
		psAnalysisParameters = @getAnalysisParameters()
		psAnalysisParametersErrors = psAnalysisParameters.validate(psAnalysisParameters.attributes)
		errors.push psAnalysisParametersErrors...
		psModelFitParameters = new DoseResponseAnalysisParameters @getModelFitParameters()
		psModelFitParametersErrors = psModelFitParameters.validate(psModelFitParameters.attributes)
		errors.push psModelFitParametersErrors...

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
		if attrs.subclass?
			cDate = @getCreationDate().get('dateValue')
			if cDate is undefined or cDate is "" or cDate is null then cDate = "fred"
			if isNaN(cDate)
				errors.push
					attribute: 'creationDate'
					message: "Assay creation date must be set"
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
		@setupTargetOriginSelect()
		@setupAssayTypeSelect()
		@setupAssayTechnologySelect()
		@setupCellLineSelect()



	render: =>
		@$el.empty()
		@$el.html @autofillTemplate(@model.attributes)
		@$('.bv_maxY').val(@model.getCurveDisplayMax().get('numericValue'))
		@$('.bv_minY').val(@model.getCurveDisplayMin().get('numericValue'))
		@setupAssayActivitySelect()
		@setupTargetOriginSelect()
		@setupAssayTypeSelect()
		@setupAssayTechnologySelect()
		@setupCellLineSelect()
		@setupCustomerMolecularTargetDDictChkbx()
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
		@cellLineListController.render()


	setupCustomerMolecularTargetDDictChkbx: ->
		@molecularTargetList = new PickListList()
		checked = @model.getCustomerMolecularTargetCodeOrigin()
		if checked
			@$('.bv_customerMolecularTargetDDictChkbx').attr("checked", "checked")
			@molecularTargetList.url = "/api/customerMolecularTargetCodeTable"
		else
			@molecularTargetList.url = "/api/codetables/assay/molecular target"
		@molecularTargetListController = new EditablePickListSelectController
			el: @$('.bv_molecularTarget')
			collection: @molecularTargetList
			selectedCode: @model.getMolecularTarget().get('codeValue')
			parameter: "molecularTarget"
			codeType: "assay"
			codeKind: "molecular target"
			roles: ["admin"]
		@molecularTargetListController.render()
		if checked
			@molecularTargetListController.hideAddOptionButton()
		else
			@molecularTargetListController.showAddOptionButton()

	updateModel: =>
		@model.getAssayActivity().set
			codeValue: @assayActivityListController.getSelectedCode()
		@model.getMolecularTarget().set
			codeValue: @molecularTargetListController.getSelectedCode()
		@model.getTargetOrigin().set
			codeValue: @targetOriginListController.getSelectedCode()
		@model.getAssayType().set
			codeValue: @assayTypeListController.getSelectedCode()
		@model.getAssayTechnology().set
			codeValue: @assayTechnologyListController.getSelectedCode()
		@model.getCellLine().set
			codeValue: @cellLineListController.getSelectedCode()
		@model.getCurveDisplayMax().set
			numericValue: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_maxY'))
		@model.getCurveDisplayMin().set
			numericValue: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_minY'))


	handleMolecularTargetDDictChanged: =>
		customerDDict = @$('.bv_customerMolecularTargetDDictChkbx').is(":checked")
		@model.setCustomerMolecularTargetCodeOrigin(customerDDict)
		if customerDDict
			@molecularTargetList.url = "/api/customerMolecularTargetCodeTable"
			@molecularTargetListController.render()
			@molecularTargetListController.hideAddOptionButton()
		else
			@molecularTargetList.url = "/api/codetables/assay/molecular target"
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



	setupProtocolBaseController: =>
		@protocolBaseController = new ProtocolBaseController
			model: @model
			el: @el
		@protocolBaseController.on 'amDirty', =>
			@trigger 'amDirty'
		@protocolBaseController.on 'amClean', =>
			@trigger 'amClean'
		@protocolBaseController.on "noEditablePickLists", =>
			@trigger 'prepareToSaveToDatabase'
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

# This wraps all the tabs
class window.AbstractPrimaryScreenProtocolModuleController extends AbstractFormController
	template: _.template($("#PrimaryScreenProtocolModuleView").html())

	events:
		"click .bv_saveModule": "handleSaveModule"


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
								#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
#								prot = new PrimaryScreenProtocol json
								lsKind = json[0].lsKind
								if lsKind is "Bio Activity"
									prot = new PrimaryScreenProtocol json[0]
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
		@model.on 'sync', =>
			@trigger 'amClean'
			unless @model.get('subclass')?
				@model.set subclass: 'protocol'
			@$('.bv_savingModule').hide()
			@$('.bv_updateModuleComplete').show()
			@$('.bv_saveModule').attr('disabled', 'disabled')
			if @model.isNew()
				@$('.bv_saveModule').html("Save")
				@$('.bv_saveInstructions').show()
			else
				@$('.bv_saveModule').html("Update")
				@$('.bv_saveInstructions').hide()

		if @model.isNew()
			@$('.bv_saveModule').html("Save")
		else
			@$('.bv_saveModule').html("Update")


		@model.on 'change', =>
			@trigger 'amDirty'
			@$('.bv_updateModuleComplete').hide()
		@model.on 'readyToSave', @handleFinishSave

		@setupPrimaryScreenProtocolController()
		@setupPrimaryScreenAnalysisParametersController()
		@setupPrimaryScreenModelFitParametersController()

		@errorOwnerName = 'PrimaryScreenProtocolModuleController'
		@setBindings()

		@$('.bv_save').hide()
		@$('.bv_saveModule').attr('disabled', 'disabled')

		if @model.isNew()
			@$('.bv_saveModule').html("Save")
			@$('.bv_saveInstructions').show()
		else
			@$('.bv_saveModule').html("Update")
			@$('.bv_saveInstructions').hide()

		@trigger 'amClean' #so that module starts off clean when initialized

	handleProtocolSaved: =>
		@trigger 'amClean'
		@$('.bv_savingModule').hide()
		@$('.bv_updateModuleComplete').show()
		if @model.isNew()
			@$('.bv_saveModule').html("Save")
		else
			@$('.bv_saveModule').html("Update")


	setupPrimaryScreenProtocolController: =>
		@primaryScreenProtocolController = new PrimaryScreenProtocolController
			model: @model
			el: @$('.bv_primaryScreenProtocolGeneralInfoWrapper')
		@primaryScreenProtocolController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenProtocolController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenProtocolController.render()
		@primaryScreenProtocolController.on 'prepareToSaveToDatabase', @prepareToSaveToDatabase

	setupPrimaryScreenAnalysisParametersController: =>
		@primaryScreenAnalysisParametersController = new PrimaryScreenAnalysisParametersController
			model: @model.getAnalysisParameters()
			el: @$('.bv_primaryScreenAnalysisParameters')
		@primaryScreenAnalysisParametersController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenAnalysisParametersController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenAnalysisParametersController.on 'updateState', @updateAnalysisClobValue
		@primaryScreenAnalysisParametersController.render()

	setupPrimaryScreenModelFitParametersController: =>
		@primaryScreenModelFitParametersController = new DoseResponseAnalysisParametersController
			model: new DoseResponseAnalysisParameters @model.getModelFitParameters()
			el: @$('.bv_doseResponseAnalysisParameters')
		@primaryScreenModelFitParametersController.on 'amDirty', =>
			@trigger 'amDirty'
		@primaryScreenModelFitParametersController.on 'amClean', =>
			@trigger 'amClean'
		@primaryScreenModelFitParametersController.render()
		@updateModelFitClobValue()
		@primaryScreenModelFitParametersController.on 'updateState', @updateModelFitClobValue

	updateAnalysisClobValue: =>
		if @primaryScreenAnalysisParametersController.model.get('positiveControl').get('concentration') is Infinity
			@primaryScreenAnalysisParametersController.model.get('positiveControl').set concentration: "Infinity" #JSON doesn't store Infinity as value
		ap = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "data analysis parameters"
		ap.set clobValue: JSON.stringify @primaryScreenAnalysisParametersController.model.attributes

	updateModelFitClobValue: =>
		mfp = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "model fit parameters"
		mfp.set clobValue: JSON.stringify @primaryScreenModelFitParametersController.model.attributes

	handleSaveModule: =>
		@$('.bv_savingModule').show()
		@primaryScreenProtocolController.handleSaveClicked()

	prepareToSaveToDatabase: =>
		@model.prepareToSave()


	handleFinishSave: =>
		if @model.isNew()
			@$('.bv_updateModuleComplete').html "Save Complete"
		else
			@$('.bv_updateModuleComplete').html "c Complete"

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

class window.PrimaryScreenProtocolModuleController extends AbstractPrimaryScreenProtocolModuleController
	moduleLaunchName: "primary_screen_protocol"
