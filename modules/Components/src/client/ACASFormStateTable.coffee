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
		@defineColumnsAndSetupHOT()

		@

#Subclass to extend
	renderModelContent: =>
		for state in @getCurrentStates()
			console.log "rendering state id: "+state.id
			@renderState state

	applyOptions: ->
		if @tableDef?.tableLabel?
			@setTableLabel @tableDef.tableLabel
		if @tableDef?.tableLabelClass?
			@addFormLabelClass @options.tableDef.tableLabelClass
		@tableReadOnly = if @tableDef.tableReadOnly? then @tableDef.tableReadOnly else false

	setTableLabel: (value) ->
		@$('.bv_tableLabel').html value

	addTableLabelClass: (value) ->
		@$('.bv_tableLabel').addClass value

	removeTableLabelClass: (value) ->
		@$('.bv_tableLabel').removeClass value

	defineColumnsAndSetupHOT: ->
			@fetchPickLists =>
				@defineColumns()
				@setupHot()

	fetchPickLists: (callback) =>
		@pickLists = {}
		listCount = 0

		for val in @tableDef.values
			if val.modelDefaults.type == 'codeValue' and val.fieldSettings.fieldType == 'codeValue'
				listCount++

		doneYet = =>
			listCount--
			if listCount == 0
				callback()

		if listCount == 0
			callback()

		for val in @tableDef.values
			if val.modelDefaults.type == 'codeValue' and val.fieldSettings.fieldType == "codeValue"
				if val.fieldSettings.optionURL?
					url = val.fieldSettings.optionURL
				else
					url = "/api/codetables/#{val.modelDefaults.codeType}/#{val.modelDefaults.codeKind}"
				kind = val.modelDefaults.kind

				$.ajax
					type: 'GET'
					url: url
					json: true
					self: @
					kind: kind
#					success: makeRetFunct()
					success: (response) ->
						this.self.pickLists[this.kind] = new PickListList response
						doneYet()


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
			else if val.modelDefaults.type == 'codeValue' and val.fieldSettings.fieldType == 'codeValue'
				colOpts.type = 'autocomplete'
				colOpts.strict = true
				colOpts.source = @pickLists[val.modelDefaults.kind].pluck 'name'
			if val.validator?
				colOpts.validator = val.validator

			@colDefs.push colOpts

	setupHot: ->
		@hot = new Handsontable @$('.bv_tableWrapper')[0],
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
			afterRemoveRow: @handleRowRemoved
			columns: @colDefs
			search: @tableDef.search
			cells: (row, col, prop) =>
				cellProperties = {}
				if @tableReadOnly
					cellProperties.readOnly = true
				return cellProperties;

	readOnlyRenderer: (instance, td, row, col, prop, value, cellProperties) =>
		Handsontable.renderers.TextRenderer.apply(this, arguments)
		td.style.background = '#EEE'
		td.style.color = 'black';
		cellProperties.readOnly = true;

	getStateForRow: (row, forceNew) ->
		currentStates = @getCurrentStates()
		for state in currentStates
			if @getRowNumberForState(state) == row
				unless forceNew #TODO: check to see if need "...and !state.isNew()"
					return state

		#if we get to here without returning, we need a new state
		newState = @thingRef.get('lsStates').createStateByTypeAndKind @tableDef.stateType, @tableDef.stateKind
		rowValue = newState.createValueByTypeAndKind 'numericValue', @rowNumberKind
		rowValue.set numericValue: row
		for valueDef in @tableDef.values
			newValue = newState.createValueByTypeAndKind valueDef.modelDefaults.type, valueDef.modelDefaults.kind
			if valueDef.modelDefaults.unitType?
				newValue.set unitType: valueDef.modelDefaults.unitType
			if valueDef.modelDefaults.unitKind?
				newValue.set unitKind: valueDef.modelDefaults.unitKind
		return newState

	getCurrentStates: ->
		@thingRef.get('lsStates').getStatesByTypeAndKind @tableDef.stateType, @tableDef.stateKind

	renderState: (state) ->
		rowNum = @getRowNumberForState(state)
		if rowNum? #should always be true
			cols = []
			for valDef in @tableDef.values
				cellInfo = []
				value = state.getOrCreateValueByTypeAndKind valDef.modelDefaults.type, valDef.modelDefaults.kind
				if valDef.modelDefaults.type == 'codeValue'
					if valDef.fieldSettings.fieldType == "stringValue"
						displayVal = value.get 'codeValue'
					else
						displayVal = @getNameForCode value, value.get 'codeValue'
				else
					displayVal = value.get valDef.modelDefaults.type

				cellInfo[0] = rowNum
				cellInfo[1] = valDef.modelDefaults.kind
				cellInfo[2] = displayVal
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
				unless change[2] == change[3] or source == "autofill"
					console.dir change
					attr = change[1]
					changeRow = change[0]
					state = @getStateForRow changeRow, false
					#TODO ignore old value if not newconta
					valueDefs = _.filter @tableDef.values, (def) ->
						def.modelDefaults.kind == attr
					valueDef = valueDefs[0]
					value = state.getOrCreateValueByTypeAndKind valueDef.modelDefaults.type, valueDef.modelDefaults.kind
					unless value.isNew()
						value = @cloneValueAndIgnoreOld state, value
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
						when 'codeValue'
							if valueDef.fieldSettings.fieldType is "stringValue"
								value.set codeValue: if cellContent? then cellContent else ""
							else #fieldType is 'codeValue'
								@setCodeForName(value, cellContent)
					rowNumValue = state.getOrCreateValueByTypeAndKind 'numericValue', @rowNumberKind
					rowNumValue.set numericValue: changeRow


	handleRowRemoved: (index, amount) =>
		for rowNum in [index..(index+amount-1)]
			state = @getStateForRow rowNum, false
			console.log "ignoring row #{rowNum} in state id: #{state.id}"
			state.set ignored: true
		nextRow = index+amount
		nRows = @hot.countRows()
		if nextRow < nRows
			for rowNum in [nextRow..(nRows-1)]
				state = @getStateForRow rowNum, false
				rowValues = state.getValuesByTypeAndKind 'numericValue', @rowNumberKind
				if rowValues.length == 1
					rowValues[0].set numericValue: rowNum

	setCodeForName: (value, nameToLookup) ->
		if @pickLists[value.get('lsKind')]?
			code = @pickLists[value.get('lsKind')].findWhere({name: nameToLookup})
			valCode = if code? then code.get 'code' else null
			value.set codeValue: valCode
		else
			console.log "can't find entry in pickLists hash for: "+value.get('lsKind')
			console.dir @pickLists

	getNameForCode: (value, codeToLookup) ->
		if @pickLists[value.get('lsKind')]?
			code = @pickLists[value.get('lsKind')].findWhere({code: codeToLookup})
			name = if code? then code.get 'name' else "not found"
			return name
		else
			console.log "can't find entry in pickLists hash for: "+value.get('lsKind')
			console.dir @pickLists

	cloneValueAndIgnoreOld: (state, oldValue) =>
		newValue = state.createValueByTypeAndKind oldValue.get('lsType'), oldValue.get('lsKind')
		newValue.set
			unitKind: oldValue.get('unitKind')
			unitType: oldValue.get('unitType')
			codeKind: oldValue.get('codeKind')
			codeType: oldValue.get('codeType')
			codeOrigin: oldValue.get('codeOrigin')

		oldValue.set
			ignored: true
			modifiedBy: window.AppLaunchParams.loginUser.username
			modifiedDate: new Date().getTime()
			isDirty: true

		return newValue

