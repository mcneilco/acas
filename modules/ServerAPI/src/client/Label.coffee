class window.Label extends Backbone.Model
	defaults:
		lsType: "name"
		lsKind: ''
		labelText: ''
		ignored: false
		preferred: false
		recordedDate: null
		recordedBy: ""
		physicallyLabled: false
		imageFile: null

	initialize: ->
		@.on "change:labelText": @handleLabelTextChanged

	handleLabelTextChanged: =>
		unless @isNew()
			console.log "replace old label"
			newText = @get 'labelText'
			@set
				ignored: true
				modifiedBy: window.AppLaunchParams.loginUser.username
				modifiedDate: new Date().getTime()
				isDirty: true
				labelText: @previous 'labelText'
			, silent: true
			@trigger 'createNewLabel', @get('lsKind'), newText, @get('key')

	changeLabelText: (options) ->
		@set labelText: options

class window.LabelList extends Backbone.Collection
	model: Label

	getCurrent: ->
		@filter (lab) ->
			!lab.get('ignored') #&& (lab.get('labelText') != "")

	getNames: ->
		_.filter @getCurrent(), (lab) ->
			lab.get('lsType').toLowerCase() == "name"

	getPreferred: ->
		_.filter @getCurrent(), (lab) ->
			lab.get 'preferred'

	getACASLsThingCorpName: ->
		corpName = _.filter @getCurrent(), (lab) ->
			lab.get('lsType') == "corpName" and lab.get('lsKind') == 'ACAS LsThing'
		corpName[0]

	pickBestLabel: ->
		preferred = @getPreferred()
		if preferred.length > 0
			bestLabel =  _.max preferred, (lab) ->
				rd = lab.get 'recordedDate'
				(if (rd is "") then rd else -1)
		else
			names = @getNames()
			if names.length > 0
				bestLabel = _.max names, (lab) ->
					rd = lab.get 'recordedDate'
					(if (rd is "") then rd else -1)
			else
				current = @getCurrent()
				bestLabel = _.max current, (lab) ->
					rd = lab.get 'recordedDate'
					(if (rd is "") then rd else -1)
		return bestLabel

	pickBestName: ->
		preferredNames = _.filter @getCurrent(), (lab) ->
			lab.get('preferred') && (lab.get('lsType') == "name")
		bestLabel = _.max preferredNames, (lab) ->
			rd = lab.get 'recordedDate'
			(if (rd is "") then Infinity else rd)
		return bestLabel

	getNonPreferredName: (lsKind) ->
		nonPreferredName = _.filter @getCurrent(), (lab) ->
			(lab.get('preferred') is false) && (lab.get('lsType') == "name")
		nonPreferredName[0]

	setName: (label, currentName) ->
		if currentName?
			if currentName.isNew()
				currentName.set
					labelText: label.get 'labelText'
					lsKind: label.get 'lsKind'
					recordedBy: label.get 'recordedBy'
					recordedDate: label.get 'recordedDate'
			else
				currentName.set ignored: true
				@add label
		else
			@add label

	setBestName: (label) ->
		label.set
			lsType: 'name'
			preferred: true
			ignored: false
		currentName = @pickBestName()
		@setName(label, currentName)

	setNonPreferredName: (label) ->
		label.set
			lsType: 'name'
			preferred: false
			ignored: false
		nonPreferredName = @getNonPreferredName()
		@setName(label, nonPreferredName)

	getLabelByTypeAndKind: (type, kind) ->
		@filter (label) ->
			(not label.get('ignored')) and (label.get('lsType')==type) and (label.get('lsKind')==kind)

	getOrCreateLabelByTypeAndKind: (type, kind) ->
		labels = @getLabelByTypeAndKind type, kind
		label = labels[0] #TODO should do something smart if there are more than one
		unless label?
			label = new Label
				lsType: type
				lsKind: kind
			@.add label
			label.on 'change', =>
				@trigger('change')
		return label

	getLabelHistory: (preferredKind) ->
		preferred = @filter (lab) ->
			lab.get 'preferred'
		_.filter preferred, (lab) ->
			lab.get('lsKind') == preferredKind

class window.Value extends Backbone.Model
	defaults:
		ignored: false
		recordedDate: null
		recordedBy: ""

	initialize: ->
		@.on "change:value": @setValueType

	setValueType: ->
		oldVal = @get(@get('lsType'))
		newVal = @get('value')
		unless oldVal == newVal #or (Number.isNaN(oldVal) and Number.isNaN(newVal))
			if @isNew()
				@.set @get('lsType'), @get('value')
			else
				@set
					ignored: true
					modifiedBy: window.AppLaunchParams.loginUser.username
					modifiedDate: new Date().getTime()
					isDirty: true
				@trigger 'createNewValue', @get('lsKind'), newVal

class window.ValueList extends Backbone.Collection
	model: Value

class window.State extends Backbone.Model
	defaults: ->
		lsValues: new ValueList()
		ignored: false
		recordedDate: null
		recordedBy: ""

	initialize: ->
		if @has('lsValues')
			if @get('lsValues') not instanceof ValueList
				@set lsValues: new ValueList(@get('lsValues'))
		@get('lsValues').on 'change', =>
			@trigger 'change'

	parse: (resp) ->
		if resp.lsValues?
			if resp.lsValues not instanceof ValueList
				resp.lsValues = new ValueList(resp.lsValues)
				resp.lsValues.on 'change', =>
					@trigger 'change'
		resp

	getValuesByTypeAndKind: (type, kind) ->
		@get('lsValues').filter (value) ->
			(!value.get('ignored')) and (value.get('lsType')==type) and (value.get('lsKind')==kind)

	getValueById: (id) ->
		value = @get('lsValues').filter (val) ->
			val.id == id
		value

	getLsValues: ->
		@get('lsValues')

	resetLsValues: (vals) =>
		@attributes.lsValues.reset(vals)

	setLsValues: (vals) =>
		@attributes.lsValues.add(vals)

	getValueHistory: (type, kind) ->
		@get('lsValues').filter (value) ->
			(value.get('lsType')==type) and (value.get('lsKind')==kind)

	getOrCreateValueByTypeAndKind: (vType, vKind) ->
		descVals = @getValuesByTypeAndKind vType, vKind
		descVal = descVals[0] #TODO should do something smart if there are more than one
		unless descVal?
			descVal = @createValueByTypeAndKind(vType, vKind)
		return descVal

	createValueByTypeAndKind: (vType, vKind) ->
		descVal = new Value
			lsType: vType
			lsKind: vKind
		@get('lsValues').add descVal
		descVal.on 'change', =>
			@trigger('change')
		descVal

class window.StateList extends Backbone.Collection
	model: State

	getStatesByTypeAndKind: (type, kind) ->
		@filter (state) ->
			(not state.get('ignored')) and (state.get('lsType')==type) and (state.get('lsKind')==kind)

	getStateValueByTypeAndKind: (stype, skind, vtype, vkind) ->
		value = null
		states = @getStatesByTypeAndKind stype, skind
		if states.length > 0
#TODO get most recent state and value if more than 1 or throw error
			values = states[0].getValuesByTypeAndKind(vtype, vkind)
			if values.length > 0
				value = values[0]
		value

	getOrCreateStateByTypeAndKind: (sType, sKind) ->
		mStates = @getStatesByTypeAndKind sType, sKind
		mState = mStates[0] #TODO should do something smart if there are more than one
		unless mState?
			mState = @createStateByTypeAndKind sType, sKind
		return mState

	getOrCreateValueByTypeAndKind: (sType, sKind, vType, vKind) ->
		metaState = @getOrCreateStateByTypeAndKind sType, sKind
		descVals = metaState.getValuesByTypeAndKind vType, vKind
		descVal = descVals[0] #TODO should do something smart if there are more than one
		unless descVal?
			descVal = @createValueByTypeAndKind(sType, sKind, vType, vKind)
		return descVal

	createStateByTypeAndKind: (sType, sKind) ->
		mState = new State
			lsType: sType
			lsKind: sKind
		@.add mState
		mState.on 'change', =>
			@trigger('change')

		return mState

	createValueByTypeAndKind: (sType, sKind, vType, vKind) ->
		descVal = new Value
			lsType: vType
			lsKind: vKind
		metaState = @getOrCreateStateByTypeAndKind sType, sKind
		metaState.get('lsValues').add descVal
		descVal.on 'change', =>
			@trigger('change')
		descVal

	getValueById: (sType, sKind, id) ->
		state = (@getStatesByTypeAndKind(sType, sKind))[0]
		value = state.get('lsValues').filter (val) ->
			val.id == id
		value

	getStateValueHistory: (sType, sKind, vType, vKind) ->
		valueHistory = []
		states = @getStatesByTypeAndKind sType, sKind
		if states.length > 0
			values = states[0].getValueHistory(vType, vKind)
			if values.length > 0
				valueHistory = values
		valueHistory
