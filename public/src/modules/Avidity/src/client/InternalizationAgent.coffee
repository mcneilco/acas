class window.InternalizationAgentParent extends AbstractBaseComponentParent
	urlRoot: "/api/internalizationAgentParents"

	initialize: ->
		@.set
			lsType: "parent"
			lsKind: "internalization agent"
		super()

	lsProperties:
		defaultLabels: [
			key: 'internalization agent name'
			type: 'name'
			kind: 'internalization agent'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'internalization agent parent'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'internalization agent parent'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'conjugation type'
			stateType: 'metadata'
			stateKind: 'internalization agent parent'
			type: 'codeValue'
			kind: 'conjugation type'
			codeType: 'internalization agent'
			codeKind: 'conjugation type'
			codeOrigin: 'ACAS DDICT'
		,
			key: 'conjugation site'
			stateType: 'metadata'
			stateKind: 'internalization agent parent'
			type: 'codeValue'
			kind: 'conjugation site'
			codeType: 'internalization agent'
			codeKind: 'conjugation site'
			codeOrigin: 'ACAS DDICT'
		]

	validate: (attrs) ->
		errors = []
		errors.push super(attrs)...
		if attrs["conjugation type"]?
			conjugationType = attrs["conjugation type"].get('value')
			if conjugationType is "unassigned" or conjugationType is "" or conjugationType is undefined
				errors.push
					attribute: 'conjugationType'
					message: "Conjugation type must be set"
		if attrs["conjugation site"]?
			conjugationSite = attrs["conjugation site"].get('value')
			if conjugationSite is "unassigned" or conjugationSite is "" or conjugationSite is undefined
				errors.push
					attribute: 'conjugationSite'
					message: "Conjugation site must be set"

		if errors.length > 0
			return errors
		else
			return null


class window.InternalizationAgentBatch extends AbstractBaseComponentBatch
	urlRoot: "/api/internalizationAgentBatches"

	initialize: ->
		@.set
			lsType: "batch"
			lsKind: "internalization agent"
		#			analyticalFileType: "unassigned"
		#			analyticalFileValue: ""
		super()

	lsProperties:
		defaultLabels: [
		]
		defaultValues: [
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'internalization agent batch'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'internalization agent batch'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'source'
			stateType: 'metadata'
			stateKind: 'internalization agent batch'
			type: 'codeValue'
			kind: 'source'
			value: 'Avidity'
			codeType: 'component'
			codeKind: 'source'
			codeOrigin: 'ACAS DDICT'
		,
			key: 'source id'
			stateType: 'metadata'
			stateKind: 'internalization agent batch'
			type: 'stringValue'
			kind: 'source id'
		,
			key: 'molecular weight'
			stateType: 'metadata'
			stateKind: 'internalization agent batch'
			type: 'numericValue' #used to set the lsValue subclass of the object
			kind: 'molecular weight'
			unitType: 'molecular weight'
			unitKind: 'kDa'
		,
			key: 'purity'
			stateType: 'metadata'
			stateKind: 'internalization agent batch'
			type: 'numericValue' #used to set the lsValue subclass of the object
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
		if attrs["molecular weight"]?
			mw = attrs["molecular weight"].get('value')
			if mw is "" or mw is undefined or isNaN(mw)
				errors.push
					attribute: 'molecularWeight'
					message: "Molecular weight must be set"
		if attrs.purity?
			purity = attrs.purity.get('value')
			if purity is "" or purity is undefined or isNaN(purity)
				errors.push
					attribute: 'purity'
					message: "Purity must be set"

		if errors.length > 0
			return errors
		else
			return null


class window.InternalizationAgentParentController extends AbstractBaseComponentParentController
	componentPickerTemplate: _.template($("#ComponentPickerView").html())
	additionalParentAttributesTemplate: _.template($("#InternalizationAgentParentView").html())

	events: ->
		_(super()).extend(
			"change .bv_conjugationType": "attributeChanged"
			"change .bv_conjugationSite": "attributeChanged"
		)

	initialize: ->
		unless @model?
			console.log "create new model in initialize"
			@model=new InternalizationAgentParent()
		@errorOwnerName = 'InternalizationAgentParentController'
		super()
		@setupConjugationType()
		@setupConjugationSite()
		@$('.bv_parentName').attr('placeholder', 'Autofilled')
		@$('.bv_parentName').attr('disabled','disabled')

	render: =>
		unless @model?
			@model = new InternalizationAgentParent()
		super()
		@$('.bv_conjugationType').val(@model.get('conjugation type').get('value'))
		@$('.bv_conjugationSite').val(@model.get('conjugation site').get('value'))
		console.log "render model"
		console.log @model

	updateModel: =>
		@model.get("internalization agent name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_parentName'))
		@model.get("conjugation type").set("value", @conjugationTypeListController.getSelectedCode())
		@model.get("conjugation site").set("value", @conjugationSiteListController.getSelectedCode())
		super()

	setupConjugationType: ->
		console.log "setup type"
		@conjugationTypeList = new PickListList()
		@conjugationTypeList.url = "/api/dataDict/internalization agent/conjugation type"
		@conjugationTypeListController = new PickListSelectController
			el: @$('.bv_conjugationType')
			collection: @conjugationTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Conjugation Type"
			selectedCode: @model.get('conjugation type').get('value')
		console.log @model.get('conjugation type').get('value')

	setupConjugationSite: ->
		console.log "setup site"
		@conjugationSiteList = new PickListList()
		@conjugationSiteList.url = "/api/dataDict/internalization agent/conjugation site"
		@conjugationSiteListController = new PickListSelectController
			el: @$('.bv_conjugationSite')
			collection: @conjugationSiteList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Conjugation Site"
			selectedCode: @model.get('conjugation site').get('value')
		console.log @model.get('conjugation site').get('value')

class window.InternalizationAgentBatchController extends AbstractBaseComponentBatchController
	additionalBatchAttributesTemplate: _.template($("#InternalizationAgentBatchView").html())

	events: ->
		_(super()).extend(
			"keyup .bv_molecularWeight": "attributeChanged"
			"keyup .bv_purity": "attributeChanged"
		)
	initialize: ->
		unless @model?
			console.log "create new model in initialize"
			@model=new InternalizationAgentBatch()
		@errorOwnerName = 'InternalizationAgentBatchController'
		super()

	render: =>
		unless @model?
			console.log "create new model"
			@model = new InternalizationAgentBatch()
		super()
		@$('.bv_molecularWeight').val(@model.get('molecular weight').get('value'))
		@$('.bv_purity').val(@model.get('purity').get('value'))

	updateModel: =>
		@model.get("molecular weight").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_molecularWeight')))
		@model.get("purity").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_purity')))
		super()

class window.InternalizationAgentBatchSelectController extends AbstractBaseComponentBatchSelectController

	setupBatchRegForm: (batch)->
		if batch?
			model = batch
		else
			model = new InternalizationAgentBatch()
		@batchController = new InternalizationAgentBatchController
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
					@batchController.model = new InternalizationAgentBatch()
				success: (json) =>
					if json.length == 0
						alert 'Could not get selected batch, creating new one'
					else
						#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
						#								exp = new InternalizationAgentBatch json
						pb = new InternalizationAgentBatch json
						pb.set pb.parse(pb.attributes)
						@setupBatchRegForm(pb)

class window.InternalizationAgentController extends AbstractBaseComponentController
	moduleLaunchName: "internalization_agent"

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/internalizationAgentParents/codeName/"+window.AppLaunchParams.moduleLaunchParams.code
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
								cbp = new InternalizationAgentParent json[0]
								cbp.set cbp.parse(cbp.attributes)
								@model = cbp
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new InternalizationAgentParent()
		super()
		@$('.bv_registrationTitle').html("InternalizationAgent Parent/Batch Registration")

	setupParentController: ->
		console.log "set up internalization agent parent controller"
		console.log @model
		@parentController = new InternalizationAgentParentController
			model: @model
			el: @$('.bv_parent')
		super()

	setupBatchSelectController: ->
		@batchSelectController = new InternalizationAgentBatchSelectController
			el: @$('.bv_batch')
			parentCodeName: @model.get('codeName')
		super()

