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

class window.LabelList extends Backbone.Collection
	model: Label

	getCurrent: ->
		console.log "get current"
		@filter (lab) ->
			!(lab.get 'ignored')

	getNames: ->
		_.filter @getCurrent(), (lab) ->
			lab.get('lsType') == "name"

	getPreferred: ->
		_.filter @getCurrent(), (lab) ->
			lab.get 'preferred'

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
		console.log @getCurrent()
		preferredNames = _.filter @getCurrent(), (lab) ->
			lab.get('preferred') && (lab.get('lsType') == "name")
		console.log "preferred names"
		console.log preferredNames
		bestLabel = _.max preferredNames, (lab) ->
			rd = lab.get 'recordedDate'
			console.log rd
			(if (rd is "") then Infinity else rd)
		console.log "best label"
		console.log bestLabel
		return bestLabel

	setBestName: (label) ->
		label.set
			lsType: 'name'
			preferred: true
			ignored: false
		currentName = @pickBestName()
		if currentName?
			if currentName.isNew()
				console.log "current name is new"
				currentName.set
					labelText: label.get 'labelText'
					lsKind: label.get 'lsKind'
					recordedBy: label.get 'recordedBy'
					recordedDate: label.get 'recordedDate'
			else
				console.log "set current name to ignored = true"
				currentName.set ignored: true
				@add label
		else
			console.log "current name doesn't exist"
			@add label

class window.Value extends Backbone.Model
	defaults:
		ignored: false
		recordedDate: null
		recordedBy: ""

class window.ValueList extends Backbone.Collection
	model: Value

class window.State extends Backbone.Model
	defaults: ->
		lsValues: new ValueList()
		ignored: false
		recordedDate: null
		recordedBy: ""

	initialize: ->
		@.set @parse(@.attributes)

	parse: (resp) ->
		if resp.lsValues?
			if resp.lsValues not instanceof ValueList
				resp.lsValues = new ValueList(resp.lsValues)
			resp.lsValues.on 'change', =>
				@trigger 'change'
		resp

	getValuesByTypeAndKind: (type, kind) ->
		@get('lsValues').filter (value) ->
			(not value.get('ignored')) and (value.get('lsType')==type) and (value.get('lsKind')==kind)

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
			mState = new State
				lsType: sType
				lsKind: sKind
			@.add mState
			mState.on 'change', =>
				@trigger('change')
		return mState

	getOrCreateValueByTypeAndKind: (sType, sKind, vType, vKind) ->
		metaState = @getOrCreateStateByTypeAndKind sType, sKind
		descVals = metaState.getValuesByTypeAndKind vType, vKind
		descVal = descVals[0] #TODO should do something smart if there are more than one
		unless descVal?
			descVal = new Value
				lsType: vType
				lsKind: vKind
			metaState.get('lsValues').add descVal
			descVal.on 'change', =>
				@trigger('change')
		return descVal

