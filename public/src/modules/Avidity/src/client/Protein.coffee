class window.ProteinParent extends AbstractBaseComponentParent
	urlRoot: "/api/proteinParents"

	initialize: ->
		@.set
			lsType: "parent"
			lsKind: "protein"
		super()

	lsProperties:
		defaultLabels: [
			key: 'protein name'
			type: 'name'
			kind: 'protein'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'protein parent'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'protein parent'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'type'
			stateType: 'metadata'
			stateKind: 'protein parent'
			type: 'codeValue'
			kind: 'type'
		,
			key: 'aa sequence'
			stateType: 'metadata'
			stateKind: 'protein parent'
			type: 'stringValue'
			kind: 'aa sequence'
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
		if attrs.type?
			type = attrs.type.get('value')
			if type is "unassigned" or type is "" or type is undefined
				errors.push
					attribute: 'type'
					message: "Type must be set"
		if attrs["aa sequence"]?
			aaSeq = attrs["aa sequence"].get('value')
			if aaSeq is "" or aaSeq is undefined
				errors.push
					attribute: 'sequence'
					message: "Protein aa sequence must be set"

		if errors.length > 0
			return errors
		else
			return null


class window.ProteinBatch extends AbstractBaseComponentBatch
	urlRoot: "/api/proteinBatches"

	initialize: ->
		@.set
			lsType: "batch"
			lsKind: "protein"
#			analyticalFileType: "unassigned"
#			analyticalFileValue: ""
		super()

	lsProperties:
		defaultLabels: [
		]
		defaultValues: [
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'protein batch'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'protein batch'
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

class window.ProteinParentController extends AbstractBaseComponentParentController
	additionalParentAttributesTemplate: _.template($("#ProteinParentView").html())

	events: ->
		_(super()).extend(
			"change .bv_type": "attributeChanged"
			"change .bv_sequence": "attributeChanged"
		)

	initialize: ->
		unless @model?
			console.log "create new model in initialize"
			@model=new ProteinParent()
		@errorOwnerName = 'ProteinParentController'
		super()
		@setupType()
			#TODO: add additional values

	render: =>
		unless @model?
			@model = new ProteinParent()
		super()
		@$('.bv_type').val(@model.get('type').get('value'))
		@$('.bv_sequence').val(@model.get('aa sequence').get('value'))
		console.log "render model"
		console.log @model

	updateModel: =>
		@model.get("protein name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_parentName'))
		@model.get("type").set("value", @typeListController.getSelectedCode())
		@model.get("aa sequence").set("value", UtilityFunctions::getTrimmedInput @$('.bv_sequence'))
		super()

	setupType: ->
		console.log "setup type"
		@typeList = new PickListList()
		@typeList.url = "/api/dataDict/protein/type"
		@typeListController = new PickListSelectController
			el: @$('.bv_type')
			collection: @typeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select type"
			selectedCode: @model.get('type').get('value')
		console.log @model.get('type').get('value')

class window.ProteinBatchController extends AbstractBaseComponentBatchController

	initialize: ->
		unless @model?
			console.log "create new model in initialize"
			@model=new ProteinBatch()
		@errorOwnerName = 'ProteinBatchController'
		super()

	render: =>
		unless @model?
			console.log "create new model"
			@model = new ProteinBatch()
		super()

class window.ProteinBatchSelectController extends AbstractBaseComponentBatchSelectController

	setupBatchRegForm: (batch)->
		if batch?
			model = batch
		else
			model = new ProteinBatch()
		@batchController = new ProteinBatchController
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
					@batchController.model = new ProteinBatch()
				success: (json) =>
					if json.length == 0
						alert 'Could not get selected batch, creating new one'
					else
						#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
						#								exp = new ProteinBatch json
						pb = new ProteinBatch json
						pb.set pb.parse(pb.attributes)
						@setupBatchRegForm(pb)

class window.ProteinController extends AbstractBaseComponentController
	moduleLaunchName: "protein"

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/proteinParents/codeName/"+window.AppLaunchParams.moduleLaunchParams.code
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
								cbp = new ProteinParent json[0]
								cbp.set cbp.parse(cbp.attributes)
								@model = cbp
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new ProteinParent()
		super()
		@$('.bv_registrationTitle').html("Protein Parent/Batch Registration")

	setupParentController: ->
		console.log "set up protein parent controller"
		console.log @model
		@parentController = new ProteinParentController
			model: @model
			el: @$('.bv_parent')
		super()

	setupBatchSelectController: ->
		@batchSelectController = new ProteinBatchSelectController
			el: @$('.bv_batch')
			parentCodeName: @model.get('codeName')
		super()

