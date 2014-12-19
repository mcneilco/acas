class window.CationicBlockParent extends Thing
#	className: "Cationic block parent"

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
		console.log "validate"
		console.log attrs

		errors = []
		bestName = attrs.lsLabels.pickBestName()
		nameError = true
		if bestName?
			nameError = true
			if bestName.get('labelText') != ""
				nameError = false
		if nameError
			errors.push
				attribute: 'cationicBlockName'
				message: "Name must be set"
		if _.isNaN(attrs.recordedDate)
			errors.push
				attribute: 'recordedDate'
				message: "Recorded date must be set"
		if attrs.recordedBy is ""
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
				message: "Notebook must be set"

		console.log errors

		if errors.length > 0
			return errors
		else
			return null

class window.CationicBlockParentController extends AbstractFormController
	template: _.template($("#CationicBlockParentView").html())

	initialize: ->
		unless @model?
			@model=new CationicBlockParent()
		@errorOwnerName = 'BaseEntityController'
		@setBindings()

	render: =>
		unless @model?
			@model = new CationicBlockParent()
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_cationicBlockParentCode').val(@model.get('codeName'))
		@$('.bv_molecularWeight').val(@model.get('molecular weight').get("value"))
		@$('.bv_recordedBy').val(@model.get('recordedBy'))

