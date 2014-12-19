class window.Thing extends Backbone.Model
	lsProperties: {}

	defaults: () =>
		#attrs =
		@set lsType: "thing"
		@set lsKind: "thing"
#		@set lsKind: this.className #TODO figure out instance classname and replace --- here's a hack that does it-ish
		@set corpName: "" #TODO: need this?
		@set recordedBy: ""
		@set recordedDate: new Date().getTime()
		@set shortDescription: " "
		@set lsLabels: new LabelList()
		@set lsStates: new StateList()
		@createDefaultLabels() # attrs
		@createDefaultStates() # attrs

		#return attrs

	initialize: ->
		console.log "initialize"
		console.log @
		@.set @parse(@.attributes)
		#Problem, if new() overwrites defaults, I will lose my nested value attribute defaults
		#solution, save labels and values as base attributes. Only use new and fetch, don't use new, passing in attributes
		#Or, I will have a hamdle on the value pointer both as a base attribute and in the alue array.
		# If a new value array is passed in on new or parse, I still have a handle on the old one, I juts need to sub
		# The good thing about making all the defaults is i never need to use getOrCreate, just get becuase I know the value was made at initializtion

	parse: (resp) =>
		console.log "parse"
		if resp?
			if resp.lsLabels?
				console.log "passed resp.labels?"
				if resp.lsLabels not instanceof LabelList
					resp.lsLabels = new LabelList(resp.lsLabels)
				resp.lsLabels.on 'change', =>
					@trigger 'change'

			if resp.lsStates?
				console.log "lsStates exists"
				if resp.lsStates not instanceof StateList
					console.log "resp.lsStates = new StateList"
					resp.lsStates = new StateList(resp.lsStates)
					console.log resp.lsStates
				resp.lsStates.on 'change', =>
					@trigger 'change'
		@createDefaultLabels()
		@createDefaultStates()

	sync: ->
		console.log "sync"
		for dLabel in @lsProperties.defaultLabels
			@unset dLabel.key

		for dValue in @lsProperties.defaultValues
			@unset dValue.key
		#@set
			#recordedDate: new Date().getTime()
			#recordedBy: #logged in user
			#hide all label, value and value array keys from save


	createDefaultLabels: =>
		# loop over defaultLabels
		# getorCreateLabel
		# add key as attribute of model
		for dLabel in @lsProperties.defaultLabels
			newLabel = @get('lsLabels').getOrCreateLabelByTypeAndKind dLabel.type, dLabel.kind
			@set dLabel.key, newLabel
		console.log "created default labels"
		console.log @


	createDefaultStates: =>
		console.log "creating default states function"
		for dValue in @lsProperties.defaultValues
			#Adding the new state and value to @
			newValue = @get('lsStates').getOrCreateValueByTypeAndKind dValue.stateType, dValue.stateKind, dValue.type, dValue.kind

			#setting unitType and unitKind in the state, if units are given
			if dValue.unitKind?
				newValue.set unitKind: dValue.unitKind
			if dValue.unitType?
				newValue.set unitType: dValue.unitType

			#Setting dValue.key attribute in @ to point to the newValue
			@set dValue.key, newValue

			#setting top level model attribute's value to equal valueType's value
			# (ie set "value" to equal value in "stringValue")
			@get(dValue.kind).set("value", newValue.get(dValue.type))



# moved this example to ThingSpec.coffee
#
#class window.AviditySiRNA extends Thing
#	className: "AviditySiRNA"
#	lsProperties:
#		defaultLabels: [
#			key: 'name'
#			type: 'name'
#			kind: 'name'
#			preferred: true
#			labelText: ""
#		,
#			key: 'corpName'
#			type: 'name'
#			kind: 'corpName'
#			preferred: false
#			labelText: ""
#		,
#			key: 'barcode'
#			type: 'barcode'
#			kind: 'barcode'
#			preferred: false
#			labelText: ""
#		]
#		defaultValues: [
#			key: 'sequenceValue'
#			stateType: 'descriptors'
#			stateKind: 'unique attributes'
#			type: 'stringValue' #used to set the lsValue subclass of the object
#			kind: 'sequence'
#			value: ""
#		,
#			key: 'massValue'
#			stateType: 'descriptors'
#			stateKind: 'other attributes'
#			type: 'numberValue'
#			kind: 'mass'
#			units: 'mg'
#			value: 42.34
#		,
#			key: 'analysisParameters'
#			stateType: 'meta'
#			stateKind: 'experiment meta'
#			type: 'compositeObjectClob'
#			kind: 'AnalysisParameters'
#		]
#		defaultValueArrays: [
#			key: 'temperatureValueArray'
#			stateType: 'measurements'
#			stateKind: 'stateVsTime'
#			type: 'numberValue'
#			kind: 'temperature'
#			units: 'C'
#			value: null
#		,
#			key: 'timeValueArray'
#			stateType: 'measurements'
#			stateKind: 'stateVsTime'
#			type: 'dateValue'
#			kind: 'time'
#			value: null
#		]
#
#	defaults: ->
#		super()
#		@set shortDescription: "awesome"
#
#		#retur attrs
#
#	#nitialize: ->
#	#	super()
#
#	someMethod: ->
#		@get('corpName').set labelText: "fred"
#		@set coprpName: "don't do this"
#
#		@get('massValue').set value: 42.0
#
#		#<%= name.get 'labelText'%>

class window.BviditySiRNA extends Thing
	defaultLabels: [
		key: 'somename'
		type: 'name'
		kind: 'name'
		preferred: true
		labelText: ""
	,
		key: 'somecorpName'
		type: 'name'
		kind: 'corpName'
		preferred: false
		labelText: ""
	,
		key: 'somebarcode'
		type: 'barcode'
		kind: 'barcode'
		preferred: false
		labelText: ""
	]
	defaultValues: [
		key: 'sequenceValue'
		stateType: 'descriptors'
		stateKind: 'unique attributes'
		type: 'stringValue' #used to set the lsValue subclass of the object
		kind: 'sequence'
		value: ""
	,
		key: 'massValue'
		stateType: 'descriptors'
		stateKind: 'other attributes'
		type: 'numberValue'
		kind: 'mass'
		units: 'mg'
		value: 42.34
	,
		key: 'analysisParameters'
		stateType: 'meta'
		stateKind: 'experoiment meta'
		type: 'compositeObkectClob'
		kind: 'AnalysisParameters'
	]
	defaultValueArrays: [
		key: 'temperatureValueArray'
		stateType: 'measurements'
		stateKind: 'stateVsTime'
		type: 'numberValue'
		kind: 'temperature'
		units: 'C'
		value: null
	,
		key: 'timeValueArray'
		stateType: 'measurements'
		stateKind: 'stateVsTime'
		type: 'dateValue'
		kind: 'time'
		value: null
	]

	defaults: ->
		attrs = super()
		attrs.shortDescription = "awesome"

		return attrs

	someMethod: ->
		@get('corpName').set labelText: "fred"
		@set coprpName: "don't do this"

		@get('massValue').set value: 42.0

#<%= name.get 'labelText'%>