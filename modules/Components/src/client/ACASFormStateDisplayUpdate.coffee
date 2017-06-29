# This component displays states with the same value kinds in a table based on the supplied configuration
# Clickin a cell shows the value (editing) history of that cell
# This can be configured to allow editing of individual values
# This ignores ignored states, and neither shows them, nor allows them to be edited


class window.ACASFormStateDisplayUpdateHeaderRowController extends Backbone.View
	tagName: 'tr'

	render: =>
		for val in @options.tableDef.values
			displayName = val.fieldSettings.formLabel
			if @options.showUnits
				if val.modelDefaults.unitKind?
					displayName += "<br />(#{val.modelDefaults.unitKind})"
			$(@el).append "<td>#{displayName}</td>"

		@

class window.ACASFormStateDisplayUpdateCellController extends Backbone.View
	tagName: 'td'

	events: ->
		"click": "handleCellClicked"

	render: =>
		$(@el).empty()
		if @collection.length == 0
			content = "NA"
		else
			val = @collection.findWhere ignored: false
			content = val.get(val.get('lsType'))
		$(@el).html content
		$(@el).addClass if @collection.length > 1 then "valueWasEdited" else ""


		@

	handleCellClicked: =>
		@trigger 'cellClicked', @collection

class window.ACASFormStateDisplayUpdateRowController extends Backbone.View
	tagName: 'tr'

	render: =>
		for valDef in @options.tableDef.values
			vals = @collection.where lsKind: valDef.modelDefaults.kind
			cellController = new ACASFormStateDisplayUpdateCellController
				collection: new ValueList vals
				cellDef: valDef
			$(@el).append cellController.render().el
			cellController.on 'cellClicked', (values) =>
				@trigger 'cellClicked', values

		@

class window.ACASFormStateDisplayUpdateController extends Backbone.View
	rowNumberKind: 'row number'
	template: _.template($("#ACASFormStateDisplayUpdateView").html())

	initialize: ->
		@thingRef = @options.thingRef
		@tableDef = @options.tableDef
		@tableSetupComplete = false
		@callWhenSetupComplete = null

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@applyOptions()
		@tableSetupComplete = true

		@

	renderModelContent: =>
		if @tableSetupComplete
			@completeRenderModelContent()
		else
			@callWhenSetupComplete = @completeRenderModelContent

	completeRenderModelContent: ->
		@headerController = new ACASFormStateDisplayUpdateHeaderRowController
			tableDef: @options.tableDef
			showUnits: @options.showUnits
		@$("thead").append @headerController.render().el

		@getCurrentStates().each (state) =>
			rowController = new ACASFormStateDisplayUpdateRowController
				collection: state.get 'lsValues'
				tableDef: @options.tableDef
			@$("tbody").append rowController.render().el

			rowController.on 'cellClicked', (values) =>
				@currentCellEditor = new ACASFormStateDisplayValueEditController
					collection: values
					el: @$('.bv_valueEditor')
				@currentCellEditor.render()

	applyOptions: ->
		if @tableDef?.tableLabel?
			@setTableLabel @tableDef.tableLabel
		if @tableDef?.tableLabelClass?
			@addFormLabelClass @options.tableDef.tableLabelClass
		if @tableDef?.sortKind?
			@sortKind = @tableDef?.sortKind

	setTableLabel: (value) ->
		@$('.bv_tableLabel').html value

	addTableLabelClass: (value) ->
		@$('.bv_tableLabel').addClass value

	removeTableLabelClass: (value) ->
		@$('.bv_tableLabel').removeClass value

	getCurrentStates: ->
		states = new StateList(@thingRef.get('lsStates').getStatesByTypeAndKind(@tableDef.stateType, @tableDef.stateKind))

		sortKindCount = 0
		rowKindCount = 0
		states.each (state) =>
			if @sortKind?
				if state.getFirstValueOfKind(@sortKind)? then sortKindCount++
			if state.getFirstValueOfKind(@rowNumberKind)? then rowKindCount++

		if sortKindCount == states.length then kindToSort = @sortKind
		else if rowKindCount == states.length then kindToSort = @rowNumberKind
		else kindToSort = 'id'

		states.comparator = (state) =>
				if kindToSort == 'id'
					return state.id
				else
					val = state.getFirstValueOfKind(kindToSort)
					return val.get (val.get('lsType'))
		states.sort()
		return states

class window.ACASFormStateDisplayOldValueController extends Backbone.View
	tagName: 'tr'
	template: _.template($("#ACASFormStateDisplayOldValueView").html())

	render: =>
		attrs =
			value: @model.get(@model.get('lsType'))
		attrs.valueClass = if @model.get 'ignored' then "valueWasEdited" else ""

		if @model.has('modifiedBy') &&  @model.get('modifiedBy')!=""
			attrs.changedBy = @model.get('modifiedBy')
		else
			attrs.changedBy = @model.get('recordedBy')

		if @model.has('modifiedDate') &&  !isNaN(@model.get('modifiedBy'))
			attrs.changedDate = UtilityFunctions::convertMSToYMDDate @model.get('modifiedDate')
		else
			attrs.changedDate = UtilityFunctions::convertMSToYMDDate @model.get('recordedDate')
		attrs.reason = "current value"

		$(@el).empty()
		$(@el).html @template(attrs)

		if @model.get 'ignored'
			$.ajax
				type: 'GET'
				url: "/api/transaction/"+@model.get 'lsTransaction'
				json: true
				success: (response) =>
					@$('.bv_reason').html response.comments

		@

class window.ACASFormStateDisplayValueEditController extends Backbone.View
	template: _.template($("#ACASFormStateDisplayValueEditView").html())

	events: ->
		"keyup .bv_reasonForUpdate": "reasonForUpdateChanged"

	initialize: ->

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@collection.comparator = 'id'
		@collection.sort()
		@collection.each (val) =>
			oldRow = new ACASFormStateDisplayOldValueController
				model: val
			@$("tbody").append oldRow.render().el

		@

	setupEditor: ->
		

#TODO value editor:
# - maybe show transaction creator as modified by and date?
# - style value editor so it floats or slides down from top of table or something. It should be modal
# - trigger save at thing level, wait for success to close
# - pass reason to thing to add to transaction
# - add new value where none existed?

