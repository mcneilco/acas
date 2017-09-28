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
		@tableSetupComplete = false
		@callWhenSetupComplete = null

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
		if @tableSetupComplete
			@completeRenderModelContent()
		else
			@callWhenSetupComplete = @completeRenderModelContent

	completeRenderModelContent: ->
		for state in @getCurrentStates()
			@renderState state

	applyOptions: ->
		if @tableDef?.tableLabel?
			@setTableLabel @tableDef.tableLabel
		if @tableDef?.tableLabelClass?
			@addFormLabelClass @options.tableDef.tableLabelClass
		@tableReadOnly = if @tableDef.tableReadOnly? then @tableDef.tableReadOnly else false


		if @tableDef?.showUnits? == true then @showUnits = true else @showUnits = false

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
				@tableSetupComplete = true
				if @callWhenSetupComplete?
					@callWhenSetupComplete.call @
					@callWhenSetupComplete = null

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
					success: (response) ->
						this.self.pickLists[this.kind] = new PickListList response
						doneYet()

	defineColumns: ->
		unless @colHeaders?
			@colHeaders = []
		unless @colDefs?
			@colDefs = []
		unless @unitKeyValueMap?
			#keeps track of which values unit keys are for
			@unitKeyValueMap = {}

		for val in @tableDef.values
			displayName = val.fieldSettings.formLabel
			if @showUnits
				if val.modelDefaults.unitKind?
					displayName += "<br />(#{val.modelDefaults.unitKind})"
			@colHeaders.push
				displayName: displayName
				keyName: val.modelDefaults.kind
				width: if val.fieldSettings.width? then val.fieldSettings.width else 75

			colOpts = data: val.modelDefaults.kind
			colOpts.readOnly = if val.fieldSettings.readOnly? then val.fieldSettings.readOnly else false
			colOpts.wordWrap = true
			if val.modelDefaults.type == 'numericValue'
				colOpts.type = 'numeric'
				if val.fieldSettings.fieldFormat?
					colOpts.format = val.fieldSettings.fieldFormat
				else
					colOpts.format = '0.[00]'
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

			if val.fieldSettings.unitColumnKey?
				@colHeaders.push
					displayName: val.fieldSettings.unitColumnLabel
					keyName: val.fieldSettings.unitColumnKey
					width: if val.fieldSettings.unitColumnWidth? then val.fieldSettings.width else 75
				colOpts = data: val.fieldSettings.unitColumnKey
				colOpts.type = 'autocomplete'
				colOpts.strict = true
				colOpts.source = ['mg', 'g', 'kg', 'µL', 'mL', 'L']

				@colDefs.push colOpts

				@unitKeyValueMap[val.fieldSettings.unitColumnKey] = val.modelDefaults.kind

		if @tableDef.handleAfterValidate?
			@handleAfterValidate = @tableDef.handleAfterValidate

	setupHot: ->
		if @tableDef.contextMenu?
			contextMenu = @tableDef.contextMenu
		else
			contextMenu = true
		@hot = new Handsontable @$('.bv_tableWrapper')[0],
			beforeChange: @handleBeforeChange
			beforeValidate: @handleBeforeValidate
			afterChange: @handleCellChanged
			afterValidate: @handleAfterValidate
			afterCreateRow: @handleRowCreated
			minSpareRows: 1,
			allowInsertRow: true
			contextMenu: contextMenu
			comments: true
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
		@hot.addHook 'afterChange', @validateUniqueness

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
					if valDef.fieldSettings.fieldType == 'stringValue'
						displayVal = value.get 'codeValue'
					else
						displayVal = @getNameForCode value, value.get 'codeValue'
				else if valDef.modelDefaults.type == 'dateValue'
					if value.get('dateValue')?
						displayVal = new Date(value.get('dateValue')).toISOString().split('T')[0]
				else
					displayVal = value.get valDef.modelDefaults.type

				cellInfo[0] = rowNum
				cellInfo[1] = valDef.modelDefaults.kind
				cellInfo[2] = displayVal
				cols.push cellInfo

				if valDef.fieldSettings.unitColumnKey?
					unitCellInfo = []
					unitDisplayVal = value.get 'unitKind'
					unitCellInfo[0] = rowNum
					unitCellInfo[1] = valDef.fieldSettings.unitColumnKey
					unitCellInfo[2] = unitDisplayVal
					cols.push unitCellInfo

			@hot.setDataAtRowProp cols, "autofill"

	getRowNumberForState: (state) ->
		rowValues = state.getValuesByTypeAndKind 'numericValue', @rowNumberKind
		if rowValues.length == 1
			return rowValues[0].get('numericValue')
		else
			return null

	handleBeforeChange: (changes, source) =>
		prop = changes[0][1]
		newVal = changes[0][3]
		dateDef = _.filter @tableDef.values, (def) ->
			def.modelDefaults.type == 'dateValue' and def.modelDefaults.kind == prop
		if dateDef.length == 1 and value?
			parsedDate = newVal.split(/([ ,./-])\w/g)
			if parsedDate.length < 5
				currentYear = new Date().getFullYear()
				newVal = currentYear+"-"+newVal
				changes[0][3] = newVal

	handleBeforeValidate: (value, row, prop, sources) =>
		dateDef = _.filter @tableDef.values, (def) ->
			def.modelDefaults.type == 'dateValue' and def.modelDefaults.kind == prop
		if dateDef.length == 1 and value?
			parsedDate = value.split(/([ ,./-])\w/g)
			if parsedDate.length < 5
				currentYear = new Date().getFullYear()
				value = currentYear+"-"+value

	handleCellChanged: (changes, source) =>
		if changes?
			for change in changes
				unless change[2] == change[3] or source == "autofill"
					attr = change[1]
					changeRow = change[0]
					state = @getStateForRow changeRow, false
					unitsChanged = false
					if @unitKeyValueMap[attr]?
						#units column changed
						attr = @unitKeyValueMap[attr]
						unitsChanged = true
					valueDefs = _.filter @tableDef.values, (def) ->
						def.modelDefaults.kind == attr
					valueDef = valueDefs[0]
					value = state.getOrCreateValueByTypeAndKind valueDef.modelDefaults.type, valueDef.modelDefaults.kind
					unless value.isNew()
						oldValueAttr = value.get(valueDef.modelDefaults.type)
						value = @cloneValueAndIgnoreOld state, value
						if unitsChanged
							value.set valueDef.modelDefaults.type, oldValueAttr #so the number value gets copied over too
					if change[3] is undefined or change[3] is null
						cellContent is null
					else
						cellContent = $.trim change[3]
					if unitsChanged
						value.set unitKind: cellContent
					else
						switch valueDef.modelDefaults.type
							when 'stringValue'
								value.set stringValue: if cellContent? then cellContent else ""
							when 'clobValue'
								value.set clobValue: if cellContent? then cellContent else ""
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

	handleRowCreated: (index, amount) =>
		#TODO: if update handsontable version, can add source input to only do something when row created via context menu
		nRows = @hot.countRows()
		#check row numbers for states
		nextRow = index + amount
		if nextRow < nRows
			for rowNum in [index..nRows-amount-2]
				state = @getStateForRow rowNum, false
				rowValues = state.getValuesByTypeAndKind 'numericValue', @rowNumberKind
				if rowValues.length == 1
					rowValues[0].set numericValue: rowNum + amount

	handleRowRemoved: (index, amount) =>
		for rowNum in [index..(index+amount-1)]
			state = @getStateForRow rowNum, false
			console.log "ignoring row #{rowNum} in state id: #{state.id}"
			if state.isNew()
				state.destroy()
			else
				state.set ignored: true
				@trigger 'removedRow', state
		nextRow = index+amount
		nRows = @hot.countRows() + amount #to get number of rows before removing
		if nextRow < nRows-1
			for rowNum in [nextRow..(nRows-2)]
				state = @getStateForRow rowNum, false
				rowValues = state.getValuesByTypeAndKind 'numericValue', @rowNumberKind
				if rowValues.length == 1
					rowValues[0].set numericValue: rowNum - amount

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

	disableInput: ->
		@hot.updateSettings
			readOnly: true
			contextMenu: false
			comments: false
#Other options I decided not to use
#			disableVisualSelection: true
#			manualColumnResize: false
#			manualRowResize: false

	enableInput: ->
		if @tableDef.contextMenu?
			contextMenu = @tableDef.contextMenu
		else
			contextMenu = true
		@hot.updateSettings
			readOnly: false
			contextMenu: contextMenu
			comments: true
#Other options I decided not to use
#			disableVisualSelection: false
#			manualColumnResize: true
#			manualRowResize: true

	validateUniqueness: (changes, source) =>
		uniqueColumnIndices = @tableDef.values.map (value, idx) ->
			if value.fieldSettings.unique? and value.fieldSettings.unique
				idx
			else
				null
		uniqueColumnIndices = uniqueColumnIndices.filter (idx) ->
			idx?
		_.each uniqueColumnIndices, (columnIndex) =>
			column = @hot.getDataAtCol columnIndex
			column.forEach (value, row) =>
				data = extend [], column
				idx = data.indexOf value
				data.splice idx, 1
				secondIdx = data.indexOf value
				cell = @hot.getCellMeta row, columnIndex
				if idx > -1 and secondIdx > -1 and value? and value != ''
					cell.valid = false
					cell.comment = 'Error: Duplicates not allowed'
				else
					cell.valid = true
					cell.comment = ''
		@hot.render()



