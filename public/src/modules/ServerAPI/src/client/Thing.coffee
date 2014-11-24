class window.Thing extends Backbone.Model
	lsProperties: {}
	#TODO: need these?
	defaultLabels: []
	defaultValues: []
	defaultValueArrays: []

	defaults: () =>
		#attrs =
		@set lsType: "thing"
		@set lsKind: this.className #TODO figure out instance classname and replace --- here's a hack that does it-ish
		@set corpName: ""
		@set recordedBy: ""
		@set recordedDate: null
		@set shortDescription: " " #TODO: need this?
		@set lsLabels: new LabelList()
		@set lsStates: new StateList()
		console.log "this.className"
		console.log this.className
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
		@createDefaultLabels()
		@createDefaultStates()

	sync: ->
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


	createDefaultStates: =>
		# loop over defaultLabels
		# getorCreateLabel
		# add key as attribute of model
		for dValue in @lsProperties.defaultValues
			#Adding the new state and value to @
			newValue = @get('lsStates').getOrCreateValueByTypeAndKind dValue.stateType, dValue.stateKind, dValue.type, dValue.kind
			#setting stringValue to value
			newValue.set dValue.type, dValue.value
			#setting value key to equal value stored in stringValue
			newValue.set "value", newValue.get dValue.type
			console.log "new newValue"
			console.log newValue
			console.log newValue.get dValue.type
			console.log newValue.get "value"

			#want to set dValue.value to point to the newValue's type (ie stringValue)
			# set newValue's stringValue to equal value - basically @set newValue.(dValue.type),
#			@set dValue.value, newValue.stringValue

			#Setting dValue.key attribute in @ to point to the newValue
			@set dValue.key, newValue
			#Setting dValue.key attribute's value attribute to equal it's stringValue value
			console.log "@get dValue.key"
			console.log @get dValue.key
			console.log @get(dValue.key).get dValue.type
			console.log @get(dValue.key).get "value"
			@get(dValue.key).set dValue.type, @get(dValue.key).get "value"
			@get(dValue.key).set "value", @get(dValue.key).get dValue.type

#			@.on 'change', =>
#				console.log "@ changed"
#				@get(dValue.key).set dValue.type, @get(dValue.key).get "value"
#				@get(dValue.key).set "value", @get(dValue.key).get dValue.type
#

			console.log @get dValue.key
			console.log "THIS"
			console.log @

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