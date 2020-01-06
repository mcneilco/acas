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
		@formWrapper = @options.formWrapper
		@tableSetupComplete = false
		@callWhenSetupComplete = null
		@stateTableFormControllersCollection = []

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
		anyValuesHaveFieldWrapper = _.some @tableDef.values, (v) -> 
			_.has v.fieldSettings, 'fieldWrapper'
		if @formWrapper? and anyValuesHaveFieldWrapper
			@hasFormWrapper = true
		@tableReadOnly = if @tableDef.tableReadOnly? then @tableDef.tableReadOnly else false


		if @tableDef?.showUnits? == true then @showUnits = true else @showUnits = false

	setTableLabel: (value) ->
		@$('.bv_tableLabel').html value

	addTableLabelClass: (value) ->
		@$('.bv_tableLabel').addClass value

	removeTableLabelClass: (value) ->
		@$('.bv_tableLabel').removeClass value

	addFormWrapper: (formEl) ->
		@$('.bv_formWrapper').html formEl

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
		unless @formValueDefs?
			@formValueDefs = []
		unless @unitKeyValueMap?
			#keeps track of which values unit keys are for
			@unitKeyValueMap = {}

		for val in @tableDef.values
			isTableValue = !val.fieldSettings.fieldWrapper?
			displayName = val.fieldSettings.formLabel
			if @showUnits
				if val.modelDefaults.unitKind?
					displayName += "<br />(#{val.modelDefaults.unitKind})"
			if isTableValue
				@colHeaders.push
					displayName: displayName
					keyName: val.modelDefaults.kind
					width: if val.fieldSettings.width? then val.fieldSettings.width else 75

			colOpts = data: val.modelDefaults.kind
			colOpts.readOnly = if val.fieldSettings.readOnly? then val.fieldSettings.readOnly else false
			colOpts.wordWrap = true

			# put a value or placeholder in place
			if val.fieldSettings.placeholder?
				colOpts.placeholder = if _.isFunction(val.fieldSettings.placeholder) then val.fieldSettings.placeholder() else val.fieldSettings.placeholder
				
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

			if isTableValue
				@colDefs.push colOpts
			else
				@formValueDefs.push val

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
			afterSelection: @handleSelection
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
			currentRowClassName: 'bv_stateDisplayCurrentRow',
  			currentColClassName: 'bv_stateDisplayCurrentColumn'
			cells: (row, col, prop) =>
				cellProperties = {}
				if @tableReadOnly
					cellProperties.readOnly = true
				return cellProperties;

		# Select the first row on start
		if @$('.bv_tableWrapper').is ":visible"
			@hot.selectCell(0,0,0,0)

		@hot.addHook 'afterChange', @validateRequiredAndUniqueness

	addRow: (values, callback) ->
		# when we update the handsontable cell data directly we don't know when the "afterChange" function
		# will complete, so we lock the table, count the number of triggers to the number of completions of the
		# afterChange function, when it equals the number of changes we expect, we reset the table back to its
		# original settings, and trigger the callback function
		@hotPseudoTransaction(callback, values.length)
		lastRow = @getLastRow()		
		for value, index in values
			@hot.setDataAtCell(lastRow, index, value)

	hotPseudoTransaction: (callback, changeCount) ->
		# Get the current settings related to the lock
		originalSettings = @getCurrentLockSettings()
		@lockTable()
		@changeCount = 0
		@.off "cellChangeComplete"
		@.on "cellChangeComplete", =>
			@changeCount = @changeCount + 1
			if @changeCount == changeCount
				@hot.updateSettings(originalSettings)
				callback changeCount

	getCurrentLockSettings: ->
		settings  = @hot.getSettings()
		currentLockSettings = 
			readOnly: settings.readOnly, # make table cells read-only
			contextMenu: settings.contextMenu, # disable context menu to change things
			disableVisualSelection: settings.disableVisualSelection, # prevent user from visually selecting
			manualColumnResize: settings.manualColumnResize, # prevent dragging to resize columns
			manualRowResize: settings.manualRowResize, # prevent dragging to resize rows
			comments: settings.comments #3 prevent editing of comments

	lockTable: ->
		@hot.updateSettings({
			readOnly: true, # make table cells read-only
			contextMenu: false, # disable context menu to change things
			disableVisualSelection: true, # prevent user from visually selecting
			manualColumnResize: false, # prevent dragging to resize columns
			manualRowResize: false, # prevent dragging to resize rows
			comments: false #3 prevent editing of comments
		})

	readOnlyRenderer: (instance, td, row, col, prop, value, cellProperties) =>
		Handsontable.renderers.TextRenderer.apply(this, arguments)
		td.style.background = '#EEE'
		td.style.color = 'black';
		cellProperties.readOnly = true;

	getLastRow: ->
		lastRow = @getCurrentStates().length
		return lastRow

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
			newValue = newState.createValueByTypeAndKind valueDef.modelDefaults.type, valueDef.modelDefaults.kind, valueDef.modelDefaults.value
			if valueDef.modelDefaults.unitType?
				newValue.set unitType: valueDef.modelDefaults.unitType
			if valueDef.modelDefaults.unitKind?
				newValue.set unitKind: valueDef.modelDefaults.unitKind
			if valueDef.modelDefaults.codeType?
				newValue.set codeType: valueDef.modelDefaults.codeType
			if valueDef.modelDefaults.codeKind?
				newValue.set codeKind: valueDef.modelDefaults.codeKind
				
		if @hasFormWrapper
			@setupFormForNewState newState
		@hot.selectCell(row,0,row,0)
		return newState

	show: =>
		$(@el).show()
		@hot.render()

	hide: ->
		$(@el).hide()

	getCurrentStates: ->
		@thingRef.get('lsStates').getStatesByTypeAndKind @tableDef.stateType, @tableDef.stateKind

	setupFormForNewState: (state) ->
		if @stateTableFormControllersCollection[rowNumber]?
			@stateTableFormControllersCollection[rowNumber].remove()
			@stateTableFormControllersCollection[rowNumber].unbind()
			
		fDiv = @formWrapper.clone()
		@$('.bv_formWrapper').append fDiv
		rowNumber = @getRowNumberForState(state)
		formController = new ACASFormStateTableFormController
			el: fDiv
			thingRef: @thingRef
			valueDefs: @formValueDefs
			stateType: @tableDef.stateType
			stateKind: @tableDef.stateKind
			rowNumber: rowNumber
			rowNumberKind: @rowNumberKind
		@stateTableFormControllersCollection[rowNumber] = formController
		formController.hide()

	renderState: (state) ->
		rowNum = @getRowNumberForState(state)
		if rowNum? #should always be true
			cols = []
			for valDef in @tableDef.values
				cellInfo = []
				value = state.getOrCreateValueByTypeAndKind valDef.modelDefaults.type, valDef.modelDefaults.kind, valDef.modelDefaults.value
				if valDef.modelDefaults.type == 'codeValue'
					if valDef.fieldSettings.fieldType == 'stringValue'
						displayVal = value.get 'codeValue'
					else
						displayVal = @getNameForCode value, value.get 'codeValue'
				else if valDef.modelDefaults.type == 'dateValue'
					if value.get('dateValue')?
						displayVal = new Date(value.get('dateValue')).toISOString().split('T')[0]
					else
						displayVal = null
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
			if @hasFormWrapper
				@setupFormForNewState state


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
					value = state.getOrCreateValueByTypeAndKind valueDef.modelDefaults.type, valueDef.modelDefaults.kind, valueDef.modelDefaults.value
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
							when 'urlValue'
								value.set urlValue: if cellContent? then cellContent else ""
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
			@trigger 'cellChangeComplete', state


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

			# This happens before the table is rendered and the row really removed
			if @hasFormWrapper
				# First destroy the form controller we are removing
				controllerToRemove = @stateTableFormControllersCollection[rowNum]
				controllerToRemove.remove()
				controllerToRemove.unbind()
			
				# Remove the controller from the list
				@stateTableFormControllersCollection.splice rowNum, 1

				# After controller removal we want to select the row that took its place if it exists
				# which should be the conroller below it if it exists
				if @stateTableFormControllersCollection[rowNum]?
					@hot.selectCell(rowNum,0,rowNum,0)
				# If it doesn't exist then the row below it doesn't have a controller yet
				# This means that we just deleted the last row in the table with a controller
				# so we select the row above it if it exists
				else if rowNum-1 > -1
					@hot.selectCell(rowNum-1,0,rowNum-1,0)


		nextRow = index+amount
		nRows = @hot.countRows() + amount #to get number of rows before removing
		if nextRow < nRows-1
			for rowNum in [nextRow..(nRows-2)]
				state = @getStateForRow rowNum, false
				rowValues = state.getValuesByTypeAndKind 'numericValue', @rowNumberKind
				if rowValues.length == 1
					rowValues[0].set numericValue: rowNum - amount

	handleSelection: (row, column, row2, column2, preventScrolling, selectionLayerLevel) => 
		if @hasFormWrapper?
			$(@el).find(".bv_moreDetails").show()
			for cont, index in @stateTableFormControllersCollection
				if index == row
					$(@el).find(".bv_moreDetails").hide()
					cont.show()
				else 
					cont.hide()
				  

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
		if @hot?
			@hot.updateSettings
				readOnly: true
				contextMenu: false
				comments: false
				cells: (row, col, prop) =>
					cellProperties = {readOnly: true}
					return cellProperties;
#Other options I decided not to use
#			disableVisualSelection: true
#			manualColumnResize: false
#			manualRowResize: false
		if @hasFormWrapper?
			for cont, index in @stateTableFormControllersCollection
				cont.disableAllInputs()

	enableInput: ->
		if @tableDef.contextMenu?
			contextMenu = @tableDef.contextMenu
		else
			contextMenu = true
		if @hot?
			@hot.updateSettings
				readOnly: false
				contextMenu: contextMenu
				comments: true
				cells: (row, col, prop) =>
					cellProperties = {}
					return cellProperties;
#Other options I decided not to use
#			disableVisualSelection: false
#			manualColumnResize: true
#			manualRowResize: true
		if @hasFormWrapper?
			for cont, index in @stateTableFormControllersCollection
				cont.disableAllInputs()

	validateRequiredAndUniqueness: (changes, source) =>
		@validateRequired changes, source
		@validateUniqueness changes, source

	validateRequired: (changes, source) =>
		console.log "validateRequired"
		requiredColumnIndices = @tableDef.values.map (value, idx) ->
			if value.fieldSettings.required? and value.fieldSettings.required
				idx
			else
				null
		requiredColumnIndices = requiredColumnIndices.filter (idx) ->
			idx?
		_.each requiredColumnIndices, (columnIndex) =>
			column = @hot.getDataAtCol columnIndex
			column.forEach (value, row) =>
				cell = @hot.getCellMeta row, columnIndex
				rowData = @hot.getDataAtRow row
				nonEmptyValues = _.filter rowData, (data) =>
					data? and data != ""
				if nonEmptyValues.length > 0
					isRowEmpty = false
				else
					isRowEmpty = true
				if (!value? or value is "") and !isRowEmpty #if cell is empty and the entire row is empty
					cell.valid = false
					cell.comment = 'required'
				else
					cell.valid = true
					cell.comment = ''
				@hot.render()

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
				else if !(@tableDef.values[columnIndex].fieldSettings.required? and @tableDef.values[columnIndex].fieldSettings.required)
					#only set cell to valid if value is not required or else this will overwrite validateRequired
					cell.valid = true
					cell.comment = ''
		@hot.render()


class window.ACASFormStateTableFormController extends Backbone.View


	initialize: ->
		@hide()
		@valueDefs = @options.valueDefs
		@stateType = @options.stateType
		@stateKind = @options.stateKind
		@thingRef = @options.thingRef
		@rowNumber = @options.rowNumber
		@rowNumberKind = @options.rowNumberKind
		@formFields = {}
		@setupForm()
		@show()

	render: =>
		@setupForm()

	show: ->
		for modelKey, formField of @formFields
			formField.renderModelContent()
		$(@el).show()

	hide: ->
		$(@el).hide()
		
	setupForm: ->
		state = @getStateForRow()
		
		for field in @valueDefs
			value = state.getOrCreateValueByTypeAndKind field.modelDefaults.type, field.modelDefaults.kind, field.modelDefaults.value
			if field.modelDefaults.codeType?
				value.set 'codeType', field.modelDefaults.codeType
			if field.modelDefaults.codeKind?
				value.set 'codeKind', field.modelDefaults.codeKind
			if field.modelDefaults.codeOrigin?
				value.set 'codeOrigin', field.modelDefaults.codeOrigin
			value.set 'value', value.get(value.get('lsType'))
			keyBase = field.key
			newKey = keyBase + value.cid
			value.set key: newKey
			@thingRef.set newKey, value
			# Deep copy the field modelDefaults and change the key to the newKey
			newField = $.extend( true, {}, field)
			newField.modelDefaults.key = newKey
			# Save the modelDefaults to the Thing's defaultValues with the new key
			# This allows @createNewValue to find the correct modelDefaults when creating a new value should this value be edited
			@thingRef.lsProperties.defaultValues.push newField.modelDefaults
			# Add a new listener to value changes to create a new value in the proper state
			@listenTo value, 'createNewValue', @createNewValue

			opts =
				modelKey: newKey
				inputClass: field.fieldSettings.inputClass
				formLabel: field.fieldSettings.formLabel
				formLabelOrientation: field.fieldSettings.formLabelOrientation
				formLabelTooltip: field.fieldSettings.formLabelTooltip
				placeholder: if _.isFunction(field.fieldSettings.placeholder) then field.fieldSettings.placeholder() else field.fieldSettings.placeholder
				required: field.fieldSettings.required
				url: field.fieldSettings.url
				thingRef: @thingRef
				insertUnassigned: field.fieldSettings.insertUnassigned
				firstSelectText: field.fieldSettings.firstSelectText
				modelDefaults: field.modelDefaults
				allowedFileTypes: field.fieldSettings.allowedFileTypes
				extendedLabel: field.fieldSettings.extendedLabel
				tabIndex: field.fieldSettings.tabIndex
				toFixed: field.fieldSettings.toFixed
				pickList: field.fieldSettings.pickList
				showDescription: field.fieldSettings.showDescription
				rowNumber: @rowNumber
				rowNumberKind: @rowNumberKind
				stateType: @stateType
				stateKind: @stateKind

			#Should refactor this into a function for other places to use when selcting a controller
			switch field.fieldSettings.fieldType
				when 'label'
					if field.multiple? and field.multiple
						newField = new ACASFormMultiLabelListController opts
					else
						newField = new ACASFormLSLabelFieldController opts
				when 'numericValue' then newField = new ACASFormLSNumericValueFieldController opts
				when 'codeValue'
					if field.multiple? and field.multiple
						newField = new ACASFormMultiCodeValueCheckboxController opts
					else
						newField = new ACASFormLSCodeValueFieldController opts
				when 'htmlClobValue'
					opts.rows = field.fieldSettings?.rows
					newField = new ACASFormLSHTMLClobValueFieldController opts
				when 'thingInteractionSelect'
					opts.thingType = field.fieldSettings.thingType
					opts.thingKind = field.fieldSettings.thingKind
					opts.queryUrl = field.fieldSettings.queryUrl
					opts.labelType = field.fieldSettings.labelType
					newField = new ACASFormLSThingInteractionFieldController opts
				when 'stringValue' then newField = new ACASFormLSStringValueFieldController opts
				when 'dateValue' then newField = new ACASFormLSDateValueFieldController opts
				when 'fileValue' then newField = new ACASFormLSFileValueFieldController opts
				when 'locationTree'
					opts.tubeCode = @model.get('tubeCode')
					newField = new ACASFormLocationTreeController opts

			valueDiv = $(@el).find("."+field.fieldSettings.fieldWrapper)
			valueDiv.append newField.render().el
			@formFields[newKey] = newField

	getStateForRow: () ->
		currentStates = @getCurrentStates()
		for state in currentStates
			if @getRowNumberForState(state) == @rowNumber
				return state

	getCurrentStates: ->
		@thingRef.get('lsStates').getStatesByTypeAndKind @stateType, @stateKind

	getRowNumberForState: (state) ->
		rowValues = state.getValuesByTypeAndKind 'numericValue', @rowNumberKind
		if rowValues.length == 1
			return rowValues[0].get('numericValue')
		else
			return null
		
	createNewValue: (vKind, newVal, key) =>
		state = @getStateForRow()
		# Get the modelDefaults for this key that was populated above during setupForm
		valInfo = _.where(@thingRef.lsProperties.defaultValues, {key: key})[0]
		@thingRef.unset(key)
		newValue = state.createValueByTypeAndKind valInfo['type'], valInfo['kind']
		newValue.set valInfo['type'], newVal
		newValue.set
			unitKind: valInfo['unitKind']
			unitType: valInfo['unitType']
			codeKind: valInfo['codeKind']
			codeType: valInfo['codeType']
			codeOrigin: valInfo['codeOrigin']
			value: newVal
		# Replace the Thing's reference to the old ignored value with a reference to the newValue
		@thingRef.set key, newValue
		# Add a listener in case this new value is changed again
		@listenTo newValue, 'createNewValue', @createNewValue
	
	disableAllInputs: ->
		for key, fld of @formFields
			fld.disableInput()

	enableAllInputs: ->
		for key, fld of @formFields
			fld.enableInput()