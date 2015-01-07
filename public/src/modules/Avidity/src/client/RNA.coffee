class window.RNAParent extends AbstractBaseComponentParent
	urlRoot: "/api/rnaParents"

	initialize: ->
		@.set
			lsType: "parent"
			lsKind: "rna"
		super()

	lsProperties:
		defaultLabels: [
			key: 'rna name'
			type: 'name'
			kind: 'rna'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'rna parent'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'rna parent'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'target transcript'
			stateType: 'metadata'
			stateKind: 'rna parent'
			type: 'codeValue'
			kind: 'target transcript'
			codeType: 'rna'
			codeKind: 'target transcript'
			codeOrigin: 'ACAS DDICT'
		,
			key: 'gene position'
			stateType: 'metadata'
			stateKind: 'rna parent'
			type: 'numericValue' #used to set the lsValue subclass of the object
			kind: 'gene position'
		,
			key: 'modification'
			stateType: 'metadata'
			stateKind: 'rna parent'
			type: 'codeValue'
			kind: 'modification'
			codeType: 'rna'
			codeKind: 'modification'
			codeOrigin: 'ACAS DDICT'
		,
			key: 'unmodified sequence'
			stateType: 'metadata'
			stateKind: 'rna parent'
			type: 'stringValue'
			kind: 'unmodified sequence'
		,
			key: 'modified sequence'
			stateType: 'metadata'
			stateKind: 'rna parent'
			type: 'stringValue'
			kind: 'modified sequence'
		,
			key: 'charge density'
			stateType: 'metadata'
			stateKind: 'rna parent'
			type: 'numericValue'
			kind: 'charge density'
#			unitType: ''
#			unitKind: '' #TODO: add units?
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
		if attrs["target transcript"]?
			conjugationType = attrs["target transcript"].get('value')
			if conjugationType is "unassigned" or conjugationType is "" or conjugationType is undefined
				errors.push
					attribute: 'targetTranscript'
					message: "Target transcript must be set"
		if attrs["gene position"]?
			gp = attrs["gene position"].get('value')
			if gp is "" or gp is undefined or isNaN(gp)
				errors.push
					attribute: 'genePosition'
					message: "Gene position must be set"
		if attrs["modification"]?
			modification = attrs["modification"].get('value')
			if modification is "unassigned" or modification is "" or modification is undefined
				errors.push
					attribute: 'modification'
					message: "Modification must be set"
		if attrs["unmodified sequence"]?
			us = attrs["unmodified sequence"].get('value')
			if us is "" or us is undefined
				errors.push
					attribute: 'unmodifiedSequence'
					message: "Unmodified sequence must be set"
		if attrs["modified sequence"]?
			ms = attrs["modified sequence"].get('value')
			if ms is "" or ms is undefined
				errors.push
					attribute: 'modifiedSequence'
					message: "Modified sequence must be set"
		#TODO: validate charge density?

		if errors.length > 0
			return errors
		else
			return null


class window.RNABatch extends AbstractBaseComponentBatch
	urlRoot: "/api/rnaBatches"

	initialize: ->
		@.set
			lsType: "batch"
			lsKind: "rna"
		#			analyticalFileType: "unassigned"
		#			analyticalFileValue: ""
		super()

	lsProperties:
		defaultLabels: [
		]
		defaultValues: [
			key: 'completion date'
			stateType: 'metadata'
			stateKind: 'rna batch'
			type: 'dateValue'
			kind: 'completion date'
		,
			key: 'notebook'
			stateType: 'metadata'
			stateKind: 'rna batch'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'stability'
			stateType: 'metadata'
			stateKind: 'rna batch'
			type: 'numericValue' #used to set the lsValue subclass of the object
			kind: 'stability'
#			unitType: '' #TODO: add units?
#			unitKind: ''
		,
			key: 'single strand purity'
			stateType: 'metadata'
			stateKind: 'rna batch'
			type: 'numericValue' #used to set the lsValue subclass of the object
			kind: 'single strand purity'
			unitType: 'percentage'
			unitKind: '% purity'
		,
			key: 'duplex purity'
			stateType: 'metadata'
			stateKind: 'rna batch'
			type: 'numericValue' #used to set the lsValue subclass of the object
			kind: 'duplex purity'
			unitType: 'percentage'
			unitKind: '% purity'
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

	validate: (attrs) ->
		errors = []
		if _.isNaN(attrs.recordedDate)
			errors.push
				attribute: 'recordedDate'
				message: "Recorded date must be set"
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
		if attrs["stability"]?
			stability = attrs["stability"].get('value')
			if stability is "" or stability is undefined or isNaN(stability)
				errors.push
					attribute: 'stability'
					message: "Stability must be set"
		if attrs["single strand purity"]?
			ssp = attrs["single strand purity"].get('value')
			if ssp is "" or ssp is undefined or isNaN(ssp)
				errors.push
					attribute: 'singleStrandPurity'
					message: "singleStrandPurity must be set"
		if attrs["duplex purity"]?
			dp = attrs["duplex purity"].get('value')
			if dp is "" or dp is undefined or isNaN(dp)
				errors.push
					attribute: 'duplexPurity'
					message: "duplexPurity must be set"
		if attrs.amount?
			amount = attrs.amount.get('value')
			if amount is "" or amount is undefined or isNaN(amount)
				errors.push
					attribute: 'amount'
					message: "Amount must be set"
		if attrs.location?
			location = attrs.location.get('value')
			if location is "" or location is undefined
				errors.push
					attribute: 'location'
					message: "Location must be set"

		if errors.length > 0
			return errors
		else
			return null


#class window.RNAParentController extends AbstractBaseComponentParentController
#	additionalParentAttributesTemplate: _.template($("#RNAParentView").html())
#
#	events: ->
#		_(super()).extend(
#			"change .bv_conjugationType": "attributeChanged"
#			"change .bv_conjugationSite": "attributeChanged"
#		)
#
#	initialize: ->
#		unless @model?
#			console.log "create new model in initialize"
#			@model=new RNAParent()
#		@errorOwnerName = 'RNAParentController'
#		super()
#		@setupConjugationType()
#		@setupConjugationSite()
#	#TODO: add additional values
#
#	render: =>
#		unless @model?
#			@model = new RNAParent()
#		super()
#		@$('.bv_conjugationType').val(@model.get('conjugation type').get('value'))
#		@$('.bv_conjugationSite').val(@model.get('conjugation site').get('value'))
#		console.log "render model"
#		console.log @model
#
#	updateModel: =>
#		@model.get("rna name").set("labelText", UtilityFunctions::getTrimmedInput @$('.bv_parentName'))
#		@model.get("conjugation type").set("value", @conjugationTypeListController.getSelectedCode())
#		@model.get("conjugation site").set("value", @conjugationSiteListController.getSelectedCode())
#		super()
#
#	setupConjugationType: ->
#		console.log "setup type"
#		@conjugationTypeList = new PickListList()
#		@conjugationTypeList.url = "/api/dataDict/rna/conjugation type"
#		@conjugationTypeListController = new PickListSelectController
#			el: @$('.bv_conjugationType')
#			collection: @conjugationTypeList
#			insertFirstOption: new PickList
#				code: "unassigned"
#				name: "Select Conjugation Type"
#			selectedCode: @model.get('conjugation type').get('value')
#		console.log @model.get('conjugation type').get('value')
#
#	setupConjugationSite: ->
#		console.log "setup site"
#		@conjugationSiteList = new PickListList()
#		@conjugationSiteList.url = "/api/dataDict/rna/conjugation site"
#		@conjugationSiteListController = new PickListSelectController
#			el: @$('.bv_conjugationSite')
#			collection: @conjugationSiteList
#			insertFirstOption: new PickList
#				code: "unassigned"
#				name: "Select Conjugation Site"
#			selectedCode: @model.get('conjugation site').get('value')
#		console.log @model.get('conjugation site').get('value')
#
#class window.RNABatchController extends AbstractBaseComponentBatchController
#	additionalBatchAttributesTemplate: _.template($("#RNABatchView").html())
#
#	events: ->
#		_(super()).extend(
#			"change .bv_molecularWeight": "attributeChanged"
#			"change .bv_purity": "attributeChanged"
#		)
#	initialize: ->
#		unless @model?
#			console.log "create new model in initialize"
#			@model=new RNABatch()
#		@errorOwnerName = 'RNABatchController'
#		super()
#
#	render: =>
#		unless @model?
#			console.log "create new model"
#			@model = new RNABatch()
#		super()
#		@$('.bv_molecularWeight').val(@model.get('molecular weight').get('value'))
#		@$('.bv_purity').val(@model.get('purity').get('value'))
#
#	updateModel: =>
#		@model.get("molecular weight").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_molecularWeight')))
#		@model.get("purity").set("value", parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_purity')))
#		super()
#
#class window.RNABatchSelectController extends AbstractBaseComponentBatchSelectController
#
#	setupBatchRegForm: (batch)->
#		if batch?
#			model = batch
#		else
#			model = new RNABatch()
#		@batchController = new RNABatchController
#			model: model
#			el: @$('.bv_batchRegForm')
#		super()
#
#	handleSelectedBatchChanged: =>
#		console.log "handle selected batch changed"
#		selectedBatch = @batchListController.getSelectedCode()
#		if selectedBatch is "new batch" or selectedBatch is null or selectedBatch is undefined
#			@setupBatchRegForm()
#		else
#			$.ajax
#				type: 'GET'
#				url: "/api/batches/codename/"+selectedBatch
#				dataType: 'json'
#				error: (err) ->
#					alert 'Could not get selected batch, creating new one'
#					@batchController.model = new RNABatch()
#				success: (json) =>
#					if json.length == 0
#						alert 'Could not get selected batch, creating new one'
#					else
#						#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
#						#								exp = new RNABatch json
#						pb = new RNABatch json
#						pb.set pb.parse(pb.attributes)
#						@setupBatchRegForm(pb)
#
#class window.RNAController extends AbstractBaseComponentController
#	moduleLaunchName: "rna"
#
#	initialize: ->
#		if @model?
#			@completeInitialization()
#		else
#			if window.AppLaunchParams.moduleLaunchParams?
#				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
#					$.ajax
#						type: 'GET'
#						url: "/api/rnaParents/codeName/"+window.AppLaunchParams.moduleLaunchParams.code
#						dataType: 'json'
#						error: (err) ->
#							alert 'Could not get parent for code in this URL, creating new one'
#							@completeInitialization()
#						success: (json) =>
#							if json.length == 0
#								alert 'Could not get parent for code in this URL, creating new one'
#							else
#								#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
##								cbp = new CationicBlockParent json
#								cbp = new RNAParent json[0]
#								cbp.set cbp.parse(cbp.attributes)
#								@model = cbp
#							@completeInitialization()
#				else
#					@completeInitialization()
#			else
#				@completeInitialization()
#
#	completeInitialization: =>
#		unless @model?
#			@model = new RNAParent()
#		super()
#		@$('.bv_registrationTitle').html("RNA Parent/Batch Registration")
#
#	setupParentController: ->
#		console.log "set up rna parent controller"
#		console.log @model
#		@parentController = new RNAParentController
#			model: @model
#			el: @$('.bv_parent')
#		super()
#
#	setupBatchSelectController: ->
#		@batchSelectController = new RNABatchSelectController
#			el: @$('.bv_batch')
#			parentCodeName: @model.get('codeName')
#		super()
#
