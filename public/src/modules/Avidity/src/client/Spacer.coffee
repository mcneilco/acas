class window.SpacerParent extends AbstractBaseComponentParent
	urlRoot: "/api/spacerParents"

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


class window.SpacerBatch extends AbstractBaseComponentBatch
	urlRoot: "/api/spacerBatches"

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
			console.log "create new model in initialize"
			@model=new SpacerParent()
		@errorOwnerName = 'SpacerParentController'
		super()
	#TODO: add additional values

	render: =>
		unless @model?
			@model = new SpacerParent()
		super()
		@$('.bv_molecularWeight').val(@model.get('molecular weight').get('value'))
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
			console.log "create new model in initialize"
			@model=new SpacerBatch()
		@errorOwnerName = 'SpacerBatchController'
		super()

	render: =>
		unless @model?
			console.log "create new model"
			@model = new SpacerBatch()
		super()
		@$('.bv_purity').val(@model.get('purity').get('value'))

	updateModel: =>
		@model.get("purity").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_purity')))
		super()

class window.SpacerBatchSelectController extends AbstractBaseComponentBatchSelectController

	setupBatchRegForm: (batch)->
		if batch?
			model = batch
		else
			model = new SpacerBatch()
		@batchController = new SpacerBatchController
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
					@batchController.model = new SpacerBatch()
				success: (json) =>
					if json.length == 0
						alert 'Could not get selected batch, creating new one'
					else
						#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
						#								exp = new SpacerBatch json
						pb = new SpacerBatch json
						pb.set pb.parse(pb.attributes)
						@setupBatchRegForm(pb)

class window.SpacerController extends AbstractBaseComponentController
	moduleLaunchName: "spacer"

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/spacerParents/codeName/"+window.AppLaunchParams.moduleLaunchParams.code
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
								cbp = new SpacerParent json
								cbp.set cbp.parse(cbp.attributes)
								@model = cbp
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

	setupParentController: ->
		console.log "set up spacer parent controller"
		console.log @model
		@parentController = new SpacerParentController
			model: @model
			el: @$('.bv_parent')
		super()

	setupBatchSelectController: ->
		@batchSelectController = new SpacerBatchSelectController
			el: @$('.bv_batch')
			parentCodeName: @model.get('codeName')
		super()

