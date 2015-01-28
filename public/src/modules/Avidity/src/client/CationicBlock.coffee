class window.CationicBlockParent extends AbstractBaseComponentParent
	urlRoot: "/api/cationicBlockParents"

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
		]


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
			console.log "create new model in initialize"
			@model=new CationicBlockParent()
		@errorOwnerName = 'CationicBlockParentController'
		super()
	#TODO: add additional values

	render: =>
		unless @model?
			@model = new CationicBlockParent()
		super()
		@setupStructuralFileController()

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
			console.log "create new model in initialize"
			@model=new CationicBlockBatch()
		@errorOwnerName = 'CationicBlockBatchController'
		super()

	render: =>
		unless @model?
			console.log "create new model"
			@model = new CationicBlockBatch()
		super()
		@$('.bv_molecularWeight').val(@model.get('molecular weight').get('value'))
		@$('.bv_purity').val(@model.get('purity').get('value'))

	updateModel: =>
		@model.get("molecular weight").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_molecularWeight')))
		@model.get("purity").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_purity')))
		super()

class window.CationicBlockBatchSelectController extends AbstractBaseComponentBatchSelectController

	setupBatchRegForm: (batch) ->
		if batch?
			console.log "batch exists"
			model = batch
		else
			console.log "batch doesn't exist"
			model = new CationicBlockBatch()
		@batchController = new CationicBlockBatchController
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
					@batchController.model = new CationicBlockBatch()
				success: (json) =>
					if json.length == 0
						alert 'Could not get selected batch, creating new one'
					else
						#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
						#								exp = new CationicBlockBatch json
						pb = new CationicBlockBatch json
						pb.set pb.parse(pb.attributes)

						@setupBatchRegForm(pb)

class window.CationicBlockController extends AbstractBaseComponentController
	moduleLaunchName: "cationic_block"

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/cationicBlockParents/codeName/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) ->
							alert 'Could not get parent for code in this URL, creating new one'
							console.log "ci 1"
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								console.log "ci 2"
								alert 'Could not get parent for code in this URL, creating new one'
							else
								#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
#								cbp = new CationicBlockParent json
								cbp = new CationicBlockParent json
								cbp.set cbp.parse(cbp.attributes)
								@model = cbp
								console.log "ci 3"
							@completeInitialization()
				else
					console.log "ci 4"
					@completeInitialization()
			else
				console.log "ci 5"
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new CationicBlockParent()
		super()
		@$('.bv_registrationTitle').html("Cationic Block Parent/Batch Registration")

	setupParentController: ->
		console.log "set up cationic block parent controller"
		console.log @model
		@parentController = new CationicBlockParentController
			model: @model
			el: @$('.bv_parent')
		super()

	setupBatchSelectController: ->
		@batchSelectController = new CationicBlockBatchSelectController
			el: @$('.bv_batch')
			parentCodeName: @model.get('codeName')
		super()

