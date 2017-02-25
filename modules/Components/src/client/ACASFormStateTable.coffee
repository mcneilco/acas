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

	initialize: ->
		@thingRef = @options.thingRef
		@tableDef = @options.tableDef

	getCollection: ->
		#TODO get states by type and kind

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@applyOptions()
		@setupHot()

		@

#Subclass to extend
	renderModelContent: =>
#		console.dir @getCurrentStates()
#		for state in @getCurrentStates()
#			@renderState state

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

		for val in @tableDef.values
			@colHeaders.push
				displayName: val.fieldSettings.formLabel
				keyName: val.modelDefaults.kind
				width: if val.fieldSettings.width? then val.fieldSettings.width else 75

			colOpts = data: val.modelDefaults.kind
			if val.modelDefaults.type == 'numericValue'
				colOpts.type = 'numeric'
			else if val.modelDefaults.type == 'dateValue'
				colOpts.type = 'date'
				colOpts.dateFormat = 'YYYY-MM-DD'
				colOpts.correctFormat = true
#				colOpts.validator: @validateDate
			@colDefs.push colOpts

	setupHot: ->
		@hot = new Handsontable @$('.bv_tableWrapper')[0],
#			afterInit: @handleAfterInit
#			afterRender: @handleAfterRender
#			afterCreateRow: @handleRowCreated
			afterChange: @handleCellChanged
			minSpareRows: 1,
			allowInsertRow: true
			contextMenu: true
			startRows: 1,
			className: "htCenter",
			colHeaders: _.pluck @colHeaders, 'displayName'
			colWidths: _.pluck @colHeaders, 'width'
			allowInsertColumn: false
			allowRemoveColumn: false
			columns: @colDefs
			cells: (row, col, prop) =>
				cellProperties = {}
				if @tableReadOnly
					cellProperties.readOnly = true
				return cellProperties;



#	handleAfterInit: =>
#		console.log "after init"
#		@renderState @getStateForRow(0, false)

	readOnlyRenderer: (instance, td, row, col, prop, value, cellProperties) =>
		Handsontable.renderers.TextRenderer.apply(this, arguments)
		td.style.background = '#EEE'
		td.style.color = 'black';
		cellProperties.readOnly = true;

	getStateForRow: (row, forceNew) ->
		currentStates = @getCurrentStates()
		for state in currentStates
			if @getRowNumberForState(state) == row
				console.log "found state " + state.cid
				if !forceNew or state.isNew()
					return state

		#if we get to here without returning, we need a new state
		newState = @thingRef.get('lsStates').createStateByTypeAndKind @tableDef.stateType, @tableDef.stateKind
		rowValue = newState.createValueByTypeAndKind 'numericValue', @rowNumberKind
		rowValue.set numericValue: row
		for valueDef in @tableDef.values
			newState.createValueByTypeAndKind valueDef.modelDefaults.type, valueDef.modelDefaults.kind
		return newState

	getCurrentStates: ->
		@thingRef.get('lsStates').getStatesByTypeAndKind @tableDef.stateType, @tableDef.stateKind

	renderState: (state) ->
		console.dir state.attributes
		rowNum = @getRowNumberForState(state)
		if rowNum? #should always be true
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

	handleCellChanged: (changes, source) =>
		if changes?
			for change in changes
				attr = change[1]
				changeRow = change[0]
				state = @getStateForRow changeRow, true
				valueDefs = _.filter @tableDef.values, (def) ->
					def.modelDefaults.kind == attr
				valueDef = valueDefs[0]
				value = state.getOrCreateValueByTypeAndKind valueDef.modelDefaults.type, valueDef.modelDefaults.kind
				if change[3] is undefined or change[3] is null
					cellContent is null
				else
					cellContent = $.trim change[3]
				switch valueDef.modelDefaults.type
					when 'stringValue'
						value.set stringValue: if cellContent? then cellContent else ""
					when 'numericValue'
						numVal = parseFloat(cellContent)
						if isNaN(numVal) or isNaN(Number(numVal))
							value.set numericValue: null
						else
							value.set numericValue: numVal
					when 'dateValue'
						if cellContent is ""
							value.set dateValue: null
						else
							datems = new Date(cellContent).getTime()
							timezoneOffset = new Date().getTimezoneOffset()*60000 #in milliseconds
							datems += timezoneOffset
							value.set dateValue: datems

				rowNumValue = state.getOrCreateValueByTypeAndKind 'numericValue', @rowNumberKind
				rowNumValue.set numericValue: changeRow
				console.dir state, depth: 3


#TODO support codeValue fields