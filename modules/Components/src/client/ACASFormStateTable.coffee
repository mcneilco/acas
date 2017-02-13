class window.ACASFormStateTableController extends Backbone.View
	###
		Launching controller must:
		- Initialize the model the correct object type
		- Call render then append this controller's new el to the launching controllers DOM

		Launching controller may:
		- Supply the table's label text as an option tableLabel, or call setTableLabel()
		- add a label class with addTableLabelClass() or set tableLabelClass as an option

		General:
		- All addXXXCLass() methods also have a removeXXXClass() method

	###

	tagName: "DIV"
	className: "control-group"
	template: _.template($("#ACASFormStateTableView").html())
	rowNumberKind: 'row number'
	showRuwNumbers: true

	initialize: ->
		@thingRef = @options.thingRef
		@tableDef = @options.tableDef

	getCollection: ->
		#TODO get states by type and kind

	handleInputChanged: =>


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@applyOptions()
		@setupHot()

		@

#Subclass to extend
	renderModelContent: =>

	applyOptions: ->
		if @options.tableLabel?
			@setTableLabel @options.tableLabel
		if @options.tableLabelClass?
			@addFormLabelClass @options.tableLabelClass
		@tableReadOnly = if @options.tableReadOnly? then @options.tableReadOnly else false
		@defineColumns()

	setTableLabel: (value) ->
		@$('.bv_tableLabel').html value

	addTableLabelClass: (value) ->
		@$('.bv_tableLabel').addClass value

	removeTableLabelClass: (value) ->
		@$('.bv_tableLabel').removeClass value

	defineColumns: ->
		unless @colHeaders?
			@colHeaders = []
		unless @colDefs?
			@colDefs = []

		if @showRuwNumbers
			@tableDef.values.push
				modelDefaults:
					type: 'numericValue'
					kind: @rowNumberKind
					value: null
				fieldSettings:
					fieldType: 'numericValue'
					formLabel: "Row"
					required: true

		for val in @tableDef.values
			@colHeaders.push
				displayName: val.fieldSettings.formLabel
				keyName: val.modelDefaults.kind
				width: if val.fieldSettings.width? then val.fieldSettings.width else 75
			colOpts = data: val.modelDefaults.kind
			if val.modelDefaults.type == 'numericValue'
				colOpts.type = 'numeric'
			if val.modelDefaults.kind == @rowNumberKind
				colOpts.readOnly = true
			@colDefs.push colOpts

	setupHot: ->
		@hot = new Handsontable @$('.bv_tableWrapper')[0],
#			afterInit: @getAllSubjects
#			afterChange: @handleCellChanged
			afterCreateRow: @handleRowCreated
			minSpareRows: 0,
			startRows: 1,
			className: "htCenter",
			colHeaders: _.pluck @colHeaders, 'displayName'
			colWidths: _.pluck @colHeaders, 'width'
			allowInsertColumn: false
			allowRemoveColumn: false
#			afterRender: @handleAfterRender
			columns: @colDefs
			cells: (row, col, prop) =>
				cellProperties = {}
				if @tableReadOnly
					cellProperties.readOnly = true
				return cellProperties;

		@

	readOnlyRenderer: (instance, td, row, col, prop, value, cellProperties) =>
		Handsontable.renderers.TextRenderer.apply(this, arguments)
		td.style.background = '#EEE'
		td.style.color = 'black';
		cellProperties.readOnly = true;

	getStateForRow: (row) ->
		currentStates = @getCurrentStates()
		for state in currentStates
			if @getRowNumberForState(state) == row
				return state

		#if we get to here without returning, we need a new state
		newState = @thingRef.get('lsStates').createStateByTypeAndKind @tableDef.stateType, @tableDef.stateKind
		rowValue = newState.createValueByTypeAndKind 'numericValue', @rowNumberKind
		rowValue.set numericValue: row
		return newState

	getCurrentStates: ->
		@thingRef.get('lsStates').getStatesByTypeAndKind @tableDef.stateType, @tableDef.StateKind

	handleRowCreated: (index, amount, source) =>
		for newRow in [index .. index+amount]
			rowState = @getStateForRow index
			@renderState rowState

	renderState: (state) ->
		rowNum = @getRowNumberForState(state)
		if rowNum? #shoul always be true
			cols = []
			for valDef in @tableDef.values
				cellInfo = []
				value = state.getOrCreateValueByTypeAndKind valDef.modelDefaults.type, valDef.modelDefaults.kind
				cellInfo[0] = rowNum
				cellInfo[1] = valDef.modelDefaults.kind
				cellInfo[2] = value.get valDef.modelDefaults.type
				cols.push cellInfo

			@hot.setDataAtRowProp cols, "autofill"

	getRowNumberForState: (state) ->
		rowValues = state.getValuesByTypeAndKind 'numericValue', @rowNumberKind
		if rowValues.length == 1
			return rowValues[0].get('numericValue')
		else
			return null


