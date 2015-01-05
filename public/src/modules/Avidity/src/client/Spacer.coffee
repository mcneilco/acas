class window.SpacerParent extends AbstractBaseComponentParent
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
			cDate = attrs["completion date"].get('value')
			if cDate is undefined or cDate is "" then cDate = "fred"
			if isNaN(cDate)
				errors.push
					attribute: 'completionDate'
					message: "Date must be set"
			notebook = attrs.notebook.get('value')
			if notebook is "" or notebook is undefined
				errors.push
					attribute: 'notebook'
					message: "Notebook must be set"
		mw = attrs["molecular weight"].get('value')
		if mw is "" or mw is undefined or isNaN(mw)
			errors.push
				attribute: 'molecularWeight'
				message: "Molecular weight must be set"

		if errors.length > 0
			return errors
		else
			return null


class window.SpacerBatch extends AbstractBaseComponentBatch

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

class window.SpacerParentController extends AbstractBaseComponentParentController
	additionalParentAttributesTemplate: _.template($("#SpacerParentView").html())

	events: ->
		_(super()).extend(
			"change .bv_molecularWeight": "attributeChanged"
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

	updateModel: =>
		@model.get("spacer name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_parentName'))
		@model.get("molecular weight").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_molecularWeight')))
		super()


class window.SpacerBatchController extends AbstractBaseComponentBatchController

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
								cbp = new SpacerParent json[0]
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

