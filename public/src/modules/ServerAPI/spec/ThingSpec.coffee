
describe 'Thing testing', ->
	beforeEach ->

		# Here is example usage
		class window.siRNA extends Thing
			className: "siRNA"
			lsProperties:
				defaultLabels: [
					key: 'name'
					type: 'name'
					kind: 'name'
					preferred: true
#					labelText: ""
				,
					key: 'corpName'
					type: 'name'
					kind: 'corpName'
					preferred: false
#					labelText: ""
				,
					key: 'barcode'
					type: 'barcode'
					kind: 'barcode'
					preferred: false
#					labelText: ""
				]
				defaultValues: [
					key: 'sequenceValue'
					stateType: 'descriptors'
					stateKind: 'unique attributes'
					type: 'stringValue' #used to set the lsValue subclass of the object
					kind: 'sequence'
					value: "test"
				,
					key: 'massValue'
					stateType: 'descriptors'
					stateKind: 'other attributes'
					type: 'numberValue'
					kind: 'mass'
					units: 'mg'
#					value: 42.34
				,
					key: 'analysisParameters'
					stateType: 'meta'
					stateKind: 'experiment meta'
					type: 'compositeObjectClob'
					kind: 'AnalysisParameters'
				]
				defaultValueArrays: [
					key: 'temperatureValueArray'
					stateType: 'measurements'
					stateKind: 'stateVsTime'
					type: 'numberValue'
					kind: 'temperature'
					units: 'C'
#					value: null
				,
					key: 'timeValueArray'
					stateType: 'measurements'
					stateKind: 'stateVsTime'
					type: 'dateValue'
					kind: 'time'
#					value: null
				]

		@siRNA = new siRNA()

	describe 'Instantiation - defaultLabels', ->
		it 'should create a list of lsLabels based on the defaultLabels defined in Child Object', ->
			lsLabels = @siRNA.get("lsLabels")
			expect(lsLabels).toBeDefined()
			expect(lsLabels.length).toEqual 3

		it 'should create model attributes for each element in defaultLabels', ->
			expect(@siRNA.get("corpName")).toBeDefined()

		it 'should reference the lsLabel model objects stored in lsLabels as top level model attributes', ->
			@siRNA.get("corpName").set("labelText", "newCorpName")
			corpNameLabel = @siRNA.get("lsLabels").getLabelByTypeAndKind("name", "corpName")[0]
			expect(corpNameLabel.get("labelText")).toEqual @siRNA.get("corpName").get("labelText")

		it 'should remove the top level label references when sync() is called', ->
			expect(@siRNA.get("corpName")).toBeDefined()
			@siRNA.sync()
			expect(@siRNA.get("corpName")).toBeUndefined()

		it 'should create top level label references when parse() is called / when the object is re-hyrdrated', ->
			newLabelText = "this is a new label"
			@siRNA.get("corpName").set("labelText", newLabelText)
			expect(@siRNA.get("corpName")).toBeDefined()

			@siRNA.sync()
			expect(@siRNA.get("corpName")).toBeUndefined()
			@siRNA.parse()
			expect(@siRNA.get("corpName")).toBeDefined()
			expect(@siRNA.get("corpName").get("labelText")).toEqual newLabelText
			console.log @siRNA

	describe 'Instantiation - defaultStates', ->
		it 'should create a list of lsStates based on the defaultValues defined in Child Object', ->
			lsStates = @siRNA.get("lsStates")
			expect(lsStates).toBeDefined()
			expect(lsStates.length).toEqual 3

		it 'should create a list of lsValues in the appropriate state based on the defaultValues', ->
			lsStates = @siRNA.get('lsStates').getStatesByTypeAndKind "descriptors", "unique attributes" #, "stringValue", "sequence"
			lsValues = lsStates[0].get('lsValues')
			expect(lsValues).toBeDefined()
			expect(lsValues.length).toEqual 1

		it 'should create model attributes for each element in defaultValues', ->
			expect(@siRNA.get("sequenceValue")).toBeDefined()

		it 'should reference the lsStates model objects stored in lsStates as top level model attributes', ->
			console.log "sequence value before change"
			console.log @siRNA.get("sequenceValue")
			@siRNA.get("sequenceValue").set("value", "newSequenceValue")
			console.log "after changing sequence value"
			console.log @siRNA.get('lsStates').getStatesByTypeAndKind("descriptors", "unique attributes")
			console.log @siRNA.get("lsStates").getStatesByTypeAndKind("descriptors", "unique attributes")
#			sequenceValueState = @siRNA.get("lsStates").getStatesByTypeAndKind("descriptors", "unique attributes")[0]
#			console.log "sequnce value state"
#			console.log sequenceValueState
#			console.log sequenceValueState.get('value')
#			console.log @siRNA.get('sequenceValue')
			sequenceStateValue = @siRNA.get('lsStates').getStateValueByTypeAndKind "descriptors", "unique attributes", "stringValue", "sequence"
			console.log "sequenceStateValue"
			console.log sequenceStateValue

			expect(sequenceStateValue.get("stringValue")).toEqual @siRNA.get("sequenceValue").get("value")
			console.log @siRNA
			console.log @siRNA.get("sequenceValue").get("stringValue")

		it 'should remove the top level lsStates model object references when sync() is called', ->
			expect(@siRNA.get("sequenceValue")).toBeDefined()
			@siRNA.sync()
			expect(@siRNA.get("sequenceValue")).toBeUndefined()
#
		it 'should create top level lsStates model object references when parse() is called / when the object is re-hyrdrated', ->
			newSequenceValue = "this is a new sequence value"
			@siRNA.get("sequenceValue").set("value", newSequenceValue)
			expect(@siRNA.get("sequenceValue")).toBeDefined()

			@siRNA.sync()
			expect(@siRNA.get("sequenceValue")).toBeUndefined()
			@siRNA.parse()
			expect(@siRNA.get("sequenceValue")).toBeDefined()
			expect(@siRNA.get("sequenceValue").get("value")).toEqual newSequenceValue
			console.log @siRNA

#	describe "When created from existing"