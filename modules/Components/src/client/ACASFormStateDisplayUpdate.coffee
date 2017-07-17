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
			if val.get('lsType') == 'dateValue'
				content = UtilityFunctions::convertMSToYMDDate val.get('dateValue')

		$(@el).html content
		$(@el).addClass if @collection.length > 1 then "valueWasEdited" else ""
		if @options.cellDef.editable? and !@options.cellDef.editable
			$(@el).addClass 'valueNotEditable'
		else
			$(@el).addClass 'valueEditable'

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
		unless @headerController?
			@headerController = new ACASFormStateDisplayUpdateHeaderRowController
				tableDef: @options.tableDef
				showUnits: @options.showUnits
			@$("thead").append @headerController.render().el

		@$("tbody").empty()
		@getCurrentStates().each (state) =>
			rowController = new ACASFormStateDisplayUpdateRowController
				collection: state.get 'lsValues'
				tableDef: @options.tableDef
			@$("tbody").append rowController.render().el

			rowController.on 'cellClicked', (values) =>
				if @currentCellEditor?
					@currentCellEditor.undelegateEvents()
				@currentCellEditor = new ACASFormStateDisplayValueEditController
					collection: values
					el: @$('.bv_valueEditor')
					tableDef: @tableDef
					stateID: state.id
				@currentCellEditor.render()
				@currentCellEditor.on 'saveNewValue', @handleCellUpdate

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

	handleCellUpdate: (valInfo) =>
		stateToUpdate = @getCurrentStates().findWhere id: valInfo.stateID
		if !stateToUpdate?
			window.alert "internal problem finding state to update"
			return

		oldValue = stateToUpdate.getValuesByTypeAndKind valInfo.newValue.get('lsType'), valInfo.newValue.get('lsKind')
		if oldValue.length != 1
			window.alert "internal problem finding value to update"
			return
		oldValue[0].set
			ignored: true
			modifiedBy: window.AppLaunchParams.loginUser.username
			modifiedDate: new Date().getTime()
			isDirty: true
		valInfo.newValue.set
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()

		stateToUpdate.get('lsValues').add valInfo.newValue
		@trigger 'thingSaveRequested', valInfo.comment

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
		"click .bv_cancelBtn": "handleCancelClicked"
		"click .bv_saveBtn": "handleSaveClicked"

	initialize: ->
		@tableDef = @options.tableDef
		for valDef in @tableDef.values
			if valDef.modelDefaults.kind == @collection.at(0).get('lsKind')
				@valueDef = valDef
		unless @valueDef?
			console.log "There is a configuration problem with ACASFormStateDisplayValueEditController. Trying to edit a value whose kind does not have a matching definition"
		@moduleName = if @tableDef.moduleName then @tableDef.moduleName else "State Editor"
		@commentPrefix = @moduleName+":"
		@allowedCommentLength = 250 - @commentPrefix.length

	render: =>
		$(@el).empty()

		#only display editor if value is editable
		if !@valueDef.editable? or (@valueDef.editable? and @valueDef.editable)
			$(@el).html @template()

			@$('.bv_header').html "\"#{@valueDef.fieldSettings.formLabel}\" Value History and Edit"
			@collection.comparator = 'id'
			@collection.sort()
			@collection.each (val) =>
				oldRow = new ACASFormStateDisplayOldValueController
					model: val
				@$("tbody").append oldRow.render().el
			@setupEditor()
			@$('.bv_aCASFormStateDisplayValueEdit').modal
				backdrop: "static"
			@$('.bv_aCASFormStateDisplayValueEdit').modal "show"

	reasonForUpdateChanged: ->
		@comment = @commentPrefix + @$('.bv_reasonForUpdate').val()
		labelText =  @allowedCommentLength-@comment.length + " characters remaining"
		@$('.bv_charactersRemaining').text(labelText)
		@formUpdated()

	formUpdated: =>
		if @comment == @commentPrefix or @newField.isEmpty()
			@$('.bv_saveBtn').attr('disabled','disabled')
		else
			@$('.bv_saveBtn').removeAttr('disabled')

	handleCancelClicked: =>
		@$('.bv_aCASFormStateDisplayValueEdit').modal "hide"
		$(@el).empty()

	handleSaveClicked: =>
		@trigger 'saveNewValue',
			newValue: @newValue
			comment: @comment
			stateID: @options.stateID

		@$('.bv_aCASFormStateDisplayValueEdit').modal "hide"
		$(@el).empty()


	setupEditor: ->
		currentValue = @collection.findWhere ignored: false

		@newValue = new Value
			lsType: @valueDef.modelDefaults.type
			lsKind: @valueDef.modelDefaults.kind
			unitType: @valueDef.modelDefaults.unitType
			unitKind: @valueDef.modelDefaults.unitKind
			codeType: @valueDef.modelDefaults.codeType
			codeKind: @valueDef.modelDefaults.codeKind
			codeOrigin: @valueDef.modelDefaults.codeOrigin
		@newValue.set 'value', currentValue.get(currentValue.get('lsType'))
		if currentValue?
			opts =
				modelKey: @valueDef.modelDefaults.kind
				inputClass: @valueDef.fieldSettings.inputClass
				formLabel: @valueDef.fieldSettings.formLabel
				required: true
				url: @valueDef.fieldSettings.url
				thingRef: @newValue

			switch @valueDef.fieldSettings.fieldType
				when 'numericValue' then @newField = new ACASFormLSNumericValueFieldController opts
				when 'codeValue' then @newField = new ACASFormLSCodeValueFieldController opts
				when 'stringValue' then @newField = new ACASFormLSStringValueFieldController opts
				when 'dateValue' then @newField = new ACASFormLSDateValueFieldController opts

			@$('.bv_valueField').append @newField.render().el
			@newField.afterRender()
			@newField.on 'formFieldChanged', @formUpdated




#TODO value editor:
# - maybe show transaction creator as modified by and date?
# - add new value where none existed?
# show human readable codevalue instead of code

