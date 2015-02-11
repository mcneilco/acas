class window.CationicBlockParent extends AbstractBaseComponentParent
	urlRoot: "/api/cationicBlockParents"
	className: "CationicBlockParent"

	initialize: ->
		@.set
			lsType: "parent"
			lsKind: "cationic block"
		super()

	lsProperties:
		defaultLabels: [
			key: 'cationic block name'
			type: 'name'
			kind: 'cationic block'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'scientist'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'codeValue'
			kind: 'scientist'
			codeOrigin: window.conf.scientistCodeOrigin
		,
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'structural file'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'fileValue'
			kind: 'structural file'
		,
			key: 'batch number'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'numericValue'
			kind: 'batch number'
			value: 0
		]

	duplicate: =>
		copiedThing = super()
		copiedThing.get("cationic block name").set "labelText", ""
		copiedThing

class window.CationicBlockBatch extends AbstractBaseComponentBatch
	urlRoot: "/api/cationicBlockBatches"

	initialize: ->
		@.set
			lsType: "batch"
			lsKind: "cationic block"
		#			analyticalFileType: "unassigned"
		#			analyticalFileValue: ""
		super()

	lsProperties:
		defaultLabels: [
		]
		defaultValues: [
			key: 'scientist'
			stateType: 'metadata'
			stateKind: 'cationic block batch'
			type: 'codeValue'
			kind: 'scientist'
			codeOrigin: window.conf.scientistCodeOrigin
		,
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'cationic block batch'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'cationic block batch'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'source'
			stateType: 'metadata'
			stateKind: 'cationic block batch'
			type: 'codeValue'
			kind: 'source'
			value: 'Avidity'
			codeType: 'component'
			codeKind: 'source'
			codeOrigin: 'ACAS DDICT'
		,
			key: 'source id'
			stateType: 'metadata'
			stateKind: 'cationic block batch'
			type: 'stringValue'
			kind: 'source id'
		,
			key: 'molecular weight'
			stateType: 'metadata'
			stateKind: 'cationic block batch'
			type: 'numericValue'
			kind: 'molecular weight'
			unitType: 'molecular weight'
			unitKind: 'g/mol'
		,
			key: 'purity'
			stateType: 'metadata'
			stateKind: 'cationic block batch'
			type: 'numericValue'
			kind: 'purity'
			unitType: 'percentage'
			unitKind: '% purity'
		,
			key: 'amount made'
			stateType: 'metadata'
			stateKind: 'inventory'
			type: 'numericValue'
			kind: 'amount made'
			unitType: 'mass'
			unitKind: 'g'
		,
			key: 'location'
			stateType: 'metadata'
			stateKind: 'inventory'
			type: 'stringValue'
			kind: 'location'
		]

	validate: (attrs) ->
		errors = []
		errors.push super(attrs)...
		if attrs["molecular weight"]?
			mw = attrs["molecular weight"].get('value')
			if mw is "" or mw is undefined
				errors.push
					attribute: 'molecularWeight'
					message: "Molecular weight must be set"
			if isNaN(mw)
				errors.push
					attribute: 'molecularWeight'
					message: "Molecular weight must be a number"
		if attrs.purity?
			purity = attrs.purity.get('value')
			if purity is "" or purity is undefined
				errors.push
					attribute: 'purity'
					message: "Purity must be set"
			if isNaN(purity)
				errors.push
					attribute: 'purity'
					message: "Purity must be a number"

		if errors.length > 0
			return errors
		else
			return null

class window.CationicBlockParentController extends AbstractBaseComponentParentController
	additionalParentAttributesTemplate: _.template($("#CationicBlockParentView").html())

	initialize: ->
		unless @model?
			@model=new CationicBlockParent()
		@errorOwnerName = 'CationicBlockParentController'
		super()
	#TODO: add additional values

	render: =>
		unless @model?
			@model = new CationicBlockParent()
		@setupStructuralFileController()
		super()

	setupStructuralFileController: ->
		@structuralFileController = new LSFileChooserController
			el: @$('.bv_structuralFile')
			formId: 'fieldBlah',
			maxNumberOfFiles: 1,
			requiresValidation: false
			url: UtilityFunctions::getFileServiceURL()
			allowedFileTypes: ['sdf', 'mol']
			hideDelete: false
		@structuralFileController.on 'amDirty', =>
			@trigger 'amDirty'
		@structuralFileController.on 'amClean', =>
			@trigger 'amClean'
		@structuralFileController.render()
		@structuralFileController.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename
		@structuralFileController.on('fileDeleted', @handleFileRemoved) #update model with filename

	handleFileUpload: (nameOnServer) =>
		@model.get("structural file").set("value", nameOnServer)
		@trigger 'amDirty'

	handleFileRemoved: =>
		@model.get("structural file").set("value", "")

	updateModel: =>
		@model.get("cationic block name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_parentName'))
		super()


class window.CationicBlockBatchController extends AbstractBaseComponentBatchController
	additionalBatchAttributesTemplate: _.template($("#CationicBlockBatchView").html())

	events: ->
		_(super()).extend(
			"keyup .bv_molecularWeight": "attributeChanged"
			"keyup .bv_purity": "attributeChanged"
		)

	initialize: ->
		unless @model?
			@model=new CationicBlockBatch()
		@errorOwnerName = 'CationicBlockBatchController'
		super()

	render: =>
		unless @model?
			@model = new CationicBlockBatch()
		@$('.bv_molecularWeight').val(@model.get('molecular weight').get('value'))
		@$('.bv_purity').val(@model.get('purity').get('value'))
		super()

	updateModel: =>
		@model.get("molecular weight").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_molecularWeight')))
		@model.get("purity").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_purity')))
		super()

class window.CationicBlockBatchSelectController extends AbstractBaseComponentBatchSelectController

	setupBatchRegForm: =>
		if @batchModel is undefined or @batchModel is "new batch" or @batchModel is null
			@batchModel = new CationicBlockBatch()
		super()

	handleSelectedBatchChanged: =>
		@batchCodeName = @batchListController.getSelectedCode()
		@batchModel = @batchList.findWhere {codeName:@batchCodeName}
		@setupBatchRegForm()

class window.CationicBlockController extends AbstractBaseComponentController
	moduleLaunchName: "cationic_block"

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					launchCode = window.AppLaunchParams.moduleLaunchParams.code
					if launchCode.indexOf("-") == -1
						@batchCodeName = "new batch"
					else
						@batchCodeName = launchCode
						launchCode =launchCode.split("-")[0]
					$.ajax
						type: 'GET'
						url: "/api/cationicBlockParents/codename/"+launchCode
						dataType: 'json'
						error: (err) ->
							alert 'Could not get parent for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get parent for code in this URL, creating new one'
							else
								#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
#								cbp = new CationicBlockParent json
								cbp = new CationicBlockParent json
								cbp.set cbp.parse(cbp.attributes)
								if window.AppLaunchParams.moduleLaunchParams.copy
									@model = cbp.duplicate()
								else
									@model = cbp
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new CationicBlockParent()
		super()
		@$('.bv_registrationTitle').html("Cationic Block Parent/Batch Registration")

	setupParentController: =>
		@parentController = new CationicBlockParentController
			model: @model
			el: @$('.bv_parent')
			readOnly: @readOnly
		super()

	setupBatchSelectController: =>
		@batchSelectController = new CationicBlockBatchSelectController
			el: @$('.bv_batch')
			parentCodeName: @model.get('codeName')
			batchCodeName: @batchCodeName
			batchModel: @batchModel
			readOnly: @readOnly
			lsKind: "cationic block"
		super()

