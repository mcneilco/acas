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
			key: 'molecular weight'
			stateType: 'metadata'
			stateKind: 'cationic block parent'
			type: 'numericValue' #used to set the lsValue subclass of the object
			kind: 'molecular weight'
			unitType: 'molecular weight'
			unitKind: 'g/mol'
		]

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
				attribute: 'parentName'
				message: "Name must be set"
		if _.isNaN(attrs.recordedDate)
			errors.push
				attribute: 'recordedDate'
				message: "Recorded date must be set"
		#		unless attrs.codeName is undefined
		unless @isNew()
			if attrs.recordedBy is "" or attrs.recordedBy is "unassigned"
				errors.push
					attribute: 'recordedBy'
					message: "Scientist must be set"
			if attrs["completion date"]?
				cDate = attrs["completion date"].get('value')
				if cDate is undefined or cDate is "" then cDate = "fred"
				if isNaN(cDate)
					errors.push
						attribute: 'completionDate'
						message: "Date must be set"
			if attrs.notebook?
				notebook = attrs.notebook.get('value')
				if notebook is "" or notebook is undefined
					errors.push
						attribute: 'notebook'
						message: "Notebook must be set"
		if attrs["molecular weight"]?
			mw = attrs["molecular weight"].get('value')
			if mw is "" or mw is undefined or isNaN(mw)
				errors.push
					attribute: 'molecularWeight'
					message: "Molecular weight must be set"

		if errors.length > 0
			return errors
		else
			return null


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
			key: 'amount'
			stateType: 'metadata'
			stateKind: 'inventory'
			type: 'numericValue' #used to set the lsValue subclass of the object
			kind: 'amount'
			unitType: 'mass'
			unitKind: 'g'
		,
			key: 'location'
			stateType: 'metadata'
			stateKind: 'inventory'
			type: 'stringValue'
			kind: 'location'
		]

class window.CationicBlockParentController extends AbstractBaseComponentParentController
	additionalParentAttributesTemplate: _.template($("#CationicBlockParentView").html())

	events: ->
		_(super()).extend(
			"change .bv_molecularWeight": "attributeChanged"
		)

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
		@$('.bv_molecularWeight').val(@model.get('molecular weight').get('value'))

	updateModel: =>
		@model.get("cationic block name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_parentName'))
		@model.get("molecular weight").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_molecularWeight')))
		super()


class window.CationicBlockBatchController extends AbstractBaseComponentBatchController

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

class window.CationicBlockBatchSelectController extends AbstractBaseComponentBatchSelectController

	setupBatchRegForm: (batch) =>
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

