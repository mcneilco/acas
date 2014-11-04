class window.Thing extends Backbone.Model
	defaultLabels: []
	defaultValues: []
	defaultValueArrays: []

	defaults: () =>
		#attrs =
		@set lsType: "thing"
		@set lsKind: 'class of instance' #TODO figure out instance classname and replace
		@set corpName: ""
		@set recordedBy: ""
		@set recordedDate: null
		@set shortDescription: " "
		@set lsLabels: new LabelList() # will be converted into a new LabelList()
		@set lsStates: new StateList() # will be converted into a new StateList()

		@createDefaultLabels() # attrs
		@createDefaultStates() # attrs

		#return attrs

	initialize: ->
		#@set @parse(@.attributes)
		#Problem, if new() overwrites defaults, I will lose my nested value attribute defaults
		#solution, save labels and values as base attributes. Only use new and fetch, don't use new, passing in attributes
		#Or, I will have a hamdle on the value pointer both as a base attribute and in the alue array.
		# If a new value array is passed in on new or parse, I still have a handle on the old one, I juts need to sub
		# The good thing about making all the defaults is i never need to use getOrCreate, just get becuase I know the value was made at initializtion

	parse: ->


	sync: ->
		#@set
			#recordedDate: new Date().getTime()
			#recordedBy: #logged in user
			#hide all label, value and value array keys from save


	createDefaultLabels: =>
		#loop over defaultLabels
		# getorCreateLabel
		# add key as attribute of model
		for dLabel in @defaultLabels
			newLabel = @get('lsLabels').getOrCreateLabelByTypeAndKind dLabel.type, dLabel.kind
			@set dLabel.key, newLabel


	createDefaultStates: ->
		#loop over defaultValues
		# getOrCreateValue of class speccfied
		# add as attribute of model with key specified
		#loop over defaultValueArrays
		#loop over valueArrays
		# getOrCreateState
		# add array as attribute of model with key specified
		# Do I do something to help add a value to the state of the correct class and defualts

class window.AviditySiRNA extends Thing
	defaultLabels: [
		key: 'name'
		type: 'name'
		kind: 'name'
		preferred: true
		labelText: ""
	,
		key: 'corpName'
		type: 'name'
		kind: 'corpName'
		preferred: false
		labelText: ""
	,
		key: 'barcode'
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
		super()
		@set shortDescription: "awesome"

		#retur attrs

	#nitialize: ->
	#	super()

	someMethod: ->
		@get('corpName').set labelText: "fred"
		@set coprpName: "don't do this"

		@get('massValue').set value: 42.0

		#<%= name.get 'labelText'%>

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