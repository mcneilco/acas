class window.LinkerSmallMoleculeParent extends AbstractBaseComponentParent
	urlRoot: "/api/linkerSmallMoleculeParents"

	initialize: ->
		@.set
			lsType: "parent"
			lsKind: "linker small molecule"
		super()

	lsProperties:
		defaultLabels: [
			key: 'linker small molecule name'
			type: 'name'
			kind: 'linker small molecule'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'scientist'
			stateType: 'metadata'
			stateKind: 'linker small molecule parent'
			type: 'codeValue'
			kind: 'scientist'
			codeOrigin: window.conf.scientistCodeOrigin
		,
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'linker small molecule parent'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'linker small molecule parent'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'molecular weight'
			stateType: 'metadata'
			stateKind: 'linker small molecule parent'
			type: 'numericValue' #used to set the lsValue subclass of the object
			kind: 'molecular weight'
			unitType: 'molecular weight'
			unitKind: 'g/mol'
		,
			key: 'structural file'
			stateType: 'metadata'
			stateKind: 'linker small molecule parent'
			type: 'fileValue'
			kind: 'structural file'
		]

	validate: (attrs) ->
		console.log "validate parent"
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

		console.log "parent errors"
		console.log errors
		if errors.length > 0
			return errors
		else
			return null


class window.LinkerSmallMoleculeBatch extends AbstractBaseComponentBatch
	urlRoot: "/api/linkerSmallMoleculeBatches"

	initialize: ->
		@.set
			lsType: "batch"
			lsKind: "linker small molecule"
		#			analyticalFileType: "unassigned"
		#			analyticalFileValue: ""
		super()

	lsProperties:
		defaultLabels: [
		]
		defaultValues: [
			key: 'scientist'
			stateType: 'metadata'
			stateKind: 'linker small molecule batch'
			type: 'codeValue'
			kind: 'scientist'
			codeOrigin: window.conf.scientistCodeOrigin
		,
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'linker small molecule batch'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'linker small molecule batch'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'source'
			stateType: 'metadata'
			stateKind: 'linker small molecule batch'
			type: 'codeValue'
			kind: 'source'
			value: 'Avidity'
			codeType: 'component'
			codeKind: 'source'
			codeOrigin: 'ACAS DDICT'
		,
			key: 'source id'
			stateType: 'metadata'
			stateKind: 'linker small molecule batch'
			type: 'stringValue'
			kind: 'source id'
		,
			key: 'purity'
			stateType: 'metadata'
			stateKind: 'linker small molecule batch'
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
		console.log "validate batch"
		errors = []
		errors.push super(attrs)...
		if attrs.purity?
			console.log "purity"
			purity = attrs.purity.get('value')
			console.log purity
			if purity is "" or purity is undefined
				errors.push
					attribute: 'purity'
					message: "Purity must be set"
			if isNaN(purity)
				errors.push
					attribute: 'purity'
					message: "Purity must be a number"

		console.log "batch errors"
		console.log errors
		if errors.length > 0
			return errors
		else
			return null

class window.LinkerSmallMoleculeParentController extends AbstractBaseComponentParentController
	additionalParentAttributesTemplate: _.template($("#LinkerSmallMoleculeParentView").html())

	events: ->
		_(super()).extend(
			"keyup .bv_molecularWeight": "attributeChanged"
		)

	initialize: ->
		unless @model?
			console.log "create new model in initialize"
			@model=new LinkerSmallMoleculeParent()
		@errorOwnerName = 'LinkerSmallMoleculeParentController'
		super()
	#TODO: add additional values

	render: =>
		unless @model?
			@model = new LinkerSmallMoleculeParent()
		super()
		@$('.bv_molecularWeight').val(@model.get('molecular weight').get('value'))
		@setupStructuralFileController()
		@

	setupStructuralFileController: ->
		@structuralFileController = new LSFileChooserController
			el: @$('.bv_structuralFile')
			formId: 'fieldBlah',
			maxNumberOfFiles: 1,
			requiresValidation: false
			url: UtilityFunctions::getFileServiceURL()
			allowedFileTypes: ['sdf', 'mol', 'xlsx']
			hideDelete: false
		@structuralFileController.on 'amDirty', =>
			@trigger 'amDirty'
		@structuralFileController.on 'amClean', =>
			@trigger 'amClean'
		@structuralFileController.render()
		@structuralFileController.on('fileUploader:uploadComplete', @handleFileUpload) #update model with filename
		@structuralFileController.on('fileDeleted', @handleFileRemoved) #update model with filename

	handleFileUpload: (nameOnServer) =>
		console.log "file uploaded"
		@model.get("structural file").set("value", nameOnServer)
		console.log @model
		@trigger 'amDirty'

	handleFileRemoved: =>
		console.log "file removed"
		@model.get("structural file").set("value", "")
		console.log @model

	updateModel: =>
		@model.get("linker small molecule name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_parentName'))
		@model.get("molecular weight").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_molecularWeight')))
		super()


class window.LinkerSmallMoleculeBatchController extends AbstractBaseComponentBatchController
	additionalBatchAttributesTemplate: _.template($("#LinkerSmallMoleculeBatchView").html())

	events: ->
		_(super()).extend(
			"keyup .bv_purity": "attributeChanged"
		)


	initialize: ->
		unless @model?
			console.log "create new model in initialize"
			@model=new LinkerSmallMoleculeBatch()
		@errorOwnerName = 'LinkerSmallMoleculeBatchController'
		super()

	render: =>
		unless @model?
			console.log "create new model"
			@model = new LinkerSmallMoleculeBatch()
		super()
		@$('.bv_purity').val(@model.get('purity').get('value'))

	updateModel: =>
		@model.get("purity").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_purity')))
		super()

class window.LinkerSmallMoleculeBatchSelectController extends AbstractBaseComponentBatchSelectController

	setupBatchRegForm: (batch)->
		if batch?
			model = batch
		else
			model = new LinkerSmallMoleculeBatch()
		@batchController = new LinkerSmallMoleculeBatchController
			model: model
			el: @$('.bv_batchRegForm')
		super()

	handleSelectedBatchChanged: =>
		console.log "handle selected batch changed"
		selectedBatch = @batchListController.getSelectedCode()
		if selectedBatch is "new batch" or selectedBatch is null or selectedBatch is undefined
			@setupBatchRegForm()
		else
			$.ajax
				type: 'GET'
				url: "/api/batches/codename/"+selectedBatch
				dataType: 'json'
				error: (err) ->
					alert 'Could not get selected batch, creating new one'
					@batchController.model = new LinkerSmallMoleculeBatch()
				success: (json) =>
					if json.length == 0
						alert 'Could not get selected batch, creating new one'
					else
						#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
						#								exp = new LinkerSmallMoleculeBatch json
						pb = new LinkerSmallMoleculeBatch json
						pb.set pb.parse(pb.attributes)
						@setupBatchRegForm(pb)

class window.LinkerSmallMoleculeController extends AbstractBaseComponentController
	moduleLaunchName: "linker_small_molecule"

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/linkerSmallMoleculeParents/codeName/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) ->
							alert 'Could not get parent for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get parent for code in this URL, creating new one'
							else
								#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
								lsmp = new LinkerSmallMoleculeParent json
								lsmp.set lsmp.parse(lsmp.attributes)
								@model = lsmp
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new LinkerSmallMoleculeParent()
		super()
		@$('.bv_registrationTitle').html("Linker Small Molecule Parent/Batch Registration")

	setupParentController: ->
		console.log "set up linker small molecule parent controller"
		console.log @model
		@parentController = new LinkerSmallMoleculeParentController
			model: @model
			el: @$('.bv_parent')
		super()

	setupBatchSelectController: ->
		@batchSelectController = new LinkerSmallMoleculeBatchSelectController
			el: @$('.bv_batch')
			parentCodeName: @model.get('codeName')
		super()

