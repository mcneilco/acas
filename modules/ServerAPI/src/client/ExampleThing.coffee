ExampleThingConf =
	formFieldDefinitions:
		labels: [
			key: 'example thing name'
			modelDefaults:
				type: 'name'
				kind: 'example thing'
				preferred: true
			fieldSettings:
				fieldType: 'label'
				required: true
				inputClass: ""
				formLabel: "*Name"
				placeholder: "name"
				fieldWrapper: "bv_thingName"
		,
			key: 'alias_'
			multiple: true
			modelDefaults:
				type: 'name'
				kind: 'alias'
				preferred: false
			fieldSettings:
				fieldType: 'label'
				required: false
				inputClass: ""
				formLabel: "Alias"
				placeholder: "alias"
				fieldWrapper: "bv_aliasWrapper"
		]
		values: [
			key: 'scientist'
			modelDefaults:
				stateType: 'metadata'
				stateKind: 'example thing parent'
				type: 'codeValue'
				kind: 'scientist'
				codeOrigin: window.conf.scientistCodeOrigin
				value: "unassigned"
			fieldSettings:
				fieldType: 'codeValue'
				required: true
				formLabel: "*Scientist"
				fieldWrapper: "bv_scientist_date"
				url: "/api/authors"
		,
			key: 'completion date'
			modelDefaults:
				stateType: 'metadata'
				stateKind: 'example thing parent'
				type: 'dateValue'
				kind: 'completion date'
				value: null
			fieldSettings:
				fieldType: 'dateValue'
				formLabel: "*Date"
				fieldWrapper: "bv_scientist_date"
				placeholder: "yyyy-mm-dd"
				required: true
		,
			key: 'color'
			modelDefaults:
				stateType: 'metadata'
				stateKind: 'example thing parent'
				type: 'codeValue'
				kind: 'color'
				codeType: 'metadata'
				codeKind: "color"
				codeOrigin: 'ACAS DDict'
				value: null
			fieldSettings:
				fieldType: 'codeValue'
				required: false
				formLabel: "Color"
				fieldWrapper: "bv_scientist_date"
		,
			key: 'notebook'
			modelDefaults:
				stateType: 'metadata'
				stateKind: 'example thing parent'
				type: 'stringValue'
				kind: 'notebook'
				value: ""
			fieldSettings:
				fieldType: 'stringValue'
				formLabel: "Notebook"
				fieldWrapper: "bv_notebook"
				placeholder: "notebook and page"
				required: false
		,
			key: 'exampleFile'
			modelDefaults:
				stateType: 'metadata'
				stateKind: 'example thing parent'
				type: 'fileValue'
				kind: 'example file'
				value: ""
			fieldSettings:
				fieldType: 'fileValue'
				formLabel: "Example File"
				fieldWrapper: "bv_notebook"
				required: false
		]


		stateTables: [
			key: 'exampleThingTable'
			stateType: 'metadata'
			stateKind: 'example thing data'
			tableWrapper: "bv_dataTable"
			tableLabel: "Example Thing Data Table"
			values: [
				modelDefaults:
					type: 'stringValue'
					kind: 'media component'
					value: ""
				fieldSettings:
					fieldType: 'stringValue'
					formLabel: "Media Component"
					required: true
					unique: true
					width: 215
			,
				modelDefaults:
					type: 'numericValue'
					kind: 'volume'
					value: null
					unitType: 'volume'
					unitKind: 'mL'
				fieldSettings:
					fieldType: 'numericValue'
					formLabel: "Volume"
					format: "0.00"
					required: false
			,
				modelDefaults:
					type: 'codeValue'
					kind: 'category'
					codeType: 'metadata'
					codeKind: "category"
					codeOrigin: 'ACAS DDict'
					value: null
				fieldSettings:
					fieldType: 'codeValue'
					required: false
					formLabel: "Category"
					required: true
					width:150
			,
				modelDefaults:
					type: 'codeValue'
					kind: 'performed by'
					value: ""
				fieldSettings:
					fieldType: 'stringValue'
					formLabel: "Performed By"
					required: true
					width: 150
			,
				modelDefaults:
					type: 'dateValue'
					kind: 'performed time'
					value: null
					codeOrigin: window.conf.scientistCodeOrigin
				fieldSettings:
					fieldType: 'dateValue'
					formLabel: "Added date"
					required: true
					width: 150
			]
		]
		firstLsThingItxs: []
		secondLsThingItxs: []

class window.ExampleThingParent extends Thing
	urlRoot: "/api/things/parent/example thing"
	url: ->
		if @isNew() and !@has('codeName')
			return "/api/things/Material/example thing?nestedstub=true"
		else
			return "/api/things/parent/thing/#{@get 'codeName'}?nestedstub=true"
	className: "ExampleThingParent"

	initialize: ->
		@.set
			lsType: "parent"
			lsKind: "Example Thing"
		for label in ExampleThingConf.formFieldDefinitions.labels
			label.modelDefaults.key = label.key
			label.modelDefaults.multiple = label.multiple
			@lsProperties.defaultLabels.push label.modelDefaults
		for value in ExampleThingConf.formFieldDefinitions.values
			value.modelDefaults.key = value.key
			@lsProperties.defaultValues.push value.modelDefaults
		for itx in ExampleThingConf.formFieldDefinitions.firstLsThingItxs
			itx.modelDefaults.key = itx.key
			@lsProperties.defaultFirstLsThingItx.push itx.modelDefaults
		for itx in ExampleThingConf.formFieldDefinitions.secondLsThingItxs
			itx.modelDefaults.key = itx.key
			@lsProperties.defaultSecondLsThingItx.push itx.modelDefaults
		super()

	lsProperties:
		defaultLabels: [
		]
		defaultValues: [
		]

		defaultFirstLsThingItx: [

		]

		defaultSecondLsThingItx: [

		]

	validate: (attrs) ->
		errors = []

		if errors.length > 0
			return errors
		else
			return null

	duplicate: =>
		copiedThing = super()
		copiedThing

class window.ExampleThingController extends AbstractThingFormController
	template: _.template($("#ExampleThingView").html())
	moduleLaunchName: "example_thing"

	events: ->
		"click .bv_saveThing": "handleUpdateThing"

	initialize: =>
		@lockEditingForSessionKey = 'codeName'

		@hasRendered = false
		if window.AppLaunchParams.moduleLaunchParams?
			if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
				launchCode = window.AppLaunchParams.moduleLaunchParams.code
				@model = new ExampleThingParent {codeName: launchCode}
				@model.fetch()

		unless @model?
			@model = new ExampleThingParent()
			@modelSaveCallback()

		@errorOwnerName = 'ExampleThingController'
		@setBindings()
		if @options.readOnly?
			@readOnly = @options.readOnly
		else
			@readOnly = false
		@listenTo @model, 'sync', @modelSaveCallback

	render: =>
		unless @hasRendered
			$(@el).empty()
			$(@el).html @template(@model.attributes)
			@setupFormFields(ExampleThingConf.formFieldDefinitions)
			@hasRendered = true

		@

	renderModelContent: ->
		@socket.emit 'editLockEntity', @errorOwnerName, @model.get(@lockEditingForSessionKey)

		codeName = @model.get('codeName')
		@$('.bv_thingCode').val(codeName)
		@$('.bv_thingCode').html(codeName)
		if @readOnly is true
			@displayInReadOnlyMode()
		@$('.bv_saveThing').attr('disabled','disabled')
		if @model.isNew()
			@$('.bv_saveThing').html("Save")
		else
			@$('.bv_saveThing').html("Update")

	modelSaveCallback: (method, model) =>
		console.log "got model save callback"
		if @model.isNew() # model not found
			@model.set codeName: null
			return

		@fillFieldsFromModels()
		@$('.bv_saveThing').show()
		@$('.bv_saveThing').attr('disabled', 'disabled')
		@$('.bv_saveThingComplete').show()
		@$('.bv_updatingThing').hide()
		@trigger 'amClean'
		@trigger 'thingSaved'
		@renderModelContent()

		@auditTableController = new ExampleTableAuditController
			el: @$('.bv_exampleTableAudit')
			thingCode: @model.get 'codeName'
		@auditTableController.render()

	modelChangeCallback: (method, model) =>
		@trigger 'amDirty'
		@$('.bv_saveThingComplete').hide()

	updateModel: =>

	validationError: =>
		super()
		@$('.bv_saveThing').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_saveThing').removeAttr('disabled')

	handleUpdateThing: =>
		@model.prepareToSave()
		@model.reformatBeforeSaving()
		@$('.bv_updatingThing').show()
		@$('.bv_saveThingComplete').html('Update Complete.')
		@$('.bv_saveThing').attr('disabled', 'disabled')
		@model.save()

	displayInReadOnlyMode: =>
		@$(".bv_saveThing").hide()
		@$('button').attr 'disabled', 'disabled'
		@$(".bv_completionDateIcon").addClass "uneditable-input"
		@$(".bv_completionDateIcon").on "click", ->
			return false
		@disableAllInputs()


#TODO add thing interaction to project with field


ExampleTableAuditConf =
	formFieldDefinitions:
		stateTables: []
		stateDisplayTables: [
			key: 'exampleThingTable'
			stateType: 'metadata'
			stateKind: 'example thing data'
			tableWrapper: "bv_dataTable"
			tableLabel: "Example Thing Data Table - Edit Mode"
			allowEdit: true
			moduleName: "ExampleThing"
#			sortKind: 'media component'
			values: [
				modelDefaults:
					type: 'stringValue'
					kind: 'media component'
					value: ""
				fieldSettings:
					fieldType: 'stringValue'
					formLabel: "Media Component"
					required: true
					width: 215
			,
				modelDefaults:
					type: 'numericValue'
					kind: 'volume'
					value: null
					unitType: 'volume'
					unitKind: 'mL'
				fieldSettings:
					fieldType: 'numericValue'
					formLabel: "Volume"
					required: false
			,
				modelDefaults:
					type: 'codeValue'
					kind: 'category'
					codeType: 'metadata'
					codeKind: "category"
					codeOrigin: 'ACAS DDict'
					value: null
				fieldSettings:
					fieldType: 'codeValue'
					required: false
					formLabel: "Category"
					required: true
					width:150
			,
				modelDefaults:
					type: 'codeValue'
					kind: 'performed by'
					value: ""
				fieldSettings:
					fieldType: 'stringValue'
					formLabel: "Performed By"
					required: true
					width: 150
			,
				modelDefaults:
					type: 'dateValue'
					kind: 'performed time'
					value: null
					codeOrigin: window.conf.scientistCodeOrigin
				fieldSettings:
					fieldType: 'dateValue'
					formLabel: "Added date"
					required: true
					width: 150
			]
		]
		firstLsThingItxs: []
		secondLsThingItxs: []


class window.ExampleTableAuditController extends AbstractThingFormController
	template: _.template($("#ExampleTableAuditView").html())

	events: ->

	initialize: =>
		@hasRendered = false
		@model = new ExampleThingParent codeName: @options.thingCode
		@model.fetch()

		@errorOwnerName = 'ExampleTableAuditController'
		@setBindings()
		@listenTo @model, 'sync', @modelSaveCallback

	render: =>
		unless @hasRendered
			$(@el).empty()
			$(@el).html @template()
			@setupFormFields(ExampleTableAuditConf.formFieldDefinitions)
			@formDisplayTables['exampleThingTable'].on 'thingSaveRequested', @handleUpdateThing
			@hasRendered = true

		@

	renderModelContent: ->
		codeName = @model.get('codeName')
		@$('.bv_thingCode').html(codeName)

	modelSaveCallback: (method, model) =>
		console.log "got model save callback"
		if @model.isNew() # model not found
			@model.set codeName: null
			return

		@fillFieldsFromModels()
		@trigger 'amClean'
		@trigger 'thingSaved'
		@renderModelContent()

	modelChangeCallback: (method, model) =>
		@trigger 'amDirty'

	updateModel: =>

	handleUpdateThing: (transactionComment) =>
		@model.set 'transactionOptions', comments: transactionComment
		@model.prepareToSave()
		@model.reformatBeforeSaving()
		@model.save()
