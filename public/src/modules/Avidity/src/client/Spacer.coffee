class window.SpacerParent extends AbstractBaseComponentParent
	urlRoot: "/api/things/parent/spacer"
	className: "SpacerParent"

	initialize: ->
		@.set
			lsType: "parent"
			lsKind: "spacer"
		super()

	lsProperties:
		defaultLabels: [
			key: 'spacer name'
			type: 'name'
			kind: 'spacer'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'scientist'
			stateType: 'metadata'
			stateKind: 'spacer parent'
			type: 'codeValue'
			kind: 'scientist'
			codeOrigin: window.conf.scientistCodeOrigin
		,
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'spacer parent'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'spacer parent'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'molecular weight'
			stateType: 'metadata'
			stateKind: 'spacer parent'
			type: 'numericValue' #used to set the lsValue subclass of the object
			kind: 'molecular weight'
			unitType: 'molecular weight'
			unitKind: 'g/mol'
		,
			key: 'structural file'
			stateType: 'metadata'
			stateKind: 'spacer parent'
			type: 'fileValue'
			kind: 'structural file'
		,
			key: 'batch number'
			stateType: 'metadata'
			stateKind: 'spacer parent'
			type: 'numericValue'
			kind: 'batch number'
			value: 0
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

		if errors.length > 0
			return errors
		else
			return null

	duplicate: =>
		copiedThing = super()
		copiedThing.get("spacer name").set "labelText", ""
		copiedThing

class window.SpacerBatch extends AbstractBaseComponentBatch
	urlRoot: "/api/things/batch/spacer"

	initialize: ->
		@.set
			lsType: "batch"
			lsKind: "spacer"
		#			analyticalFileType: "unassigned"
		#			analyticalFileValue: ""
		super()

	lsProperties:
		defaultLabels: [
		]
		defaultValues: [
			key: 'scientist'
			stateType: 'metadata'
			stateKind: 'spacer batch'
			type: 'codeValue'
			kind: 'scientist'
			codeOrigin: window.conf.scientistCodeOrigin
		,
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'spacer batch'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'spacer batch'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'source'
			stateType: 'metadata'
			stateKind: 'spacer batch'
			type: 'codeValue'
			kind: 'source'
			value: 'Avidity'
			codeType: 'component'
			codeKind: 'source'
			codeOrigin: 'ACAS DDICT'
		,
			key: 'source id'
			stateType: 'metadata'
			stateKind: 'spacer batch'
			type: 'stringValue'
			kind: 'source id'
		,
			key: 'purity'
			stateType: 'metadata'
			stateKind: 'spacer batch'
			type: 'numericValue'
			kind: 'purity'
			unitType: 'percentage'
			unitKind: '% purity'
		,
			key: 'amount made'
			stateType: 'metadata'
			stateKind: 'inventory'
			type: 'numericValue' #used to set the lsValue subclass of the object
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

class window.SpacerParentController extends AbstractBaseComponentParentController
	additionalParentAttributesTemplate: _.template($("#SpacerParentView").html())

	events: ->
		_(super()).extend(
			"keyup .bv_molecularWeight": "attributeChanged"
		)

	initialize: ->
		unless @model?
			@model=new SpacerParent()
		@errorOwnerName = 'SpacerParentController'
		super()
	#TODO: add additional values

	render: =>
		unless @model?
			@model = new SpacerParent()
		@$('.bv_molecularWeight').val(@model.get('molecular weight').get('value'))
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
		@model.get("structural file").set("value", null)

	updateModel: =>
		@model.get("spacer name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_parentName'))
		@model.get("molecular weight").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_molecularWeight')))
		super()


class window.SpacerBatchController extends AbstractBaseComponentBatchController
	additionalBatchAttributesTemplate: _.template($("#SpacerBatchView").html())

	events: ->
		_(super()).extend(
			"keyup .bv_purity": "attributeChanged"
		)

	initialize: ->
		unless @model?
			@model=new SpacerBatch()
		@errorOwnerName = 'SpacerBatchController'
		super()

	render: =>
		unless @model?
			@model = new SpacerBatch()
		@$('.bv_purity').val(@model.get('purity').get('value'))
		super()

	updateModel: =>
		@model.get("purity").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_purity')))
		super()

class window.SpacerBatchSelectController extends AbstractBaseComponentBatchSelectController

	setupBatchRegForm: =>
		if @batchModel is undefined or @batchModel is "new batch" or @batchModel is null
			@batchModel = new SpacerBatch()
		super()

	handleSelectedBatchChanged: =>
		@batchCodeName = @batchListController.getSelectedCode()
		@batchModel = @batchList.findWhere {codeName:@batchCodeName}
		@setupBatchRegForm()

class window.SpacerController extends AbstractBaseComponentController
	moduleLaunchName: "spacer"

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
						url: "/api/things/parent/spacer/codename/"+launchCode
						dataType: 'json'
						error: (err) ->
							alert 'Could not get parent for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get parent for code in this URL, creating new one'
							else
								#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
#								sp = new SpacerParent json
								sp = new SpacerParent json
								sp.set sp.parse(sp.attributes)
								if window.AppLaunchParams.moduleLaunchParams.copy
									@model = sp.duplicate()
								else
									@model = sp
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new SpacerParent()
		super()
		@$('.bv_registrationTitle').html("Spacer Parent/Batch Registration")

	setupParentController: =>
		@parentController = new SpacerParentController
			model: @model
			el: @$('.bv_parent')
			readOnly: @readOnly
		super()

	setupBatchSelectController: =>
		@batchSelectController = new SpacerBatchSelectController
			el: @$('.bv_batch')
			parentCodeName: @model.get('codeName')
			batchCodeName: @batchCodeName
			batchModel: @batchModel
			readOnly: @readOnly
			lsKind: "spacer"
		super()

