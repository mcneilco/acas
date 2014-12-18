
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
					preferred: false
#					labelText: ""
				,
					key: 'corpName'
					type: 'name'
					kind: 'corpName'
					preferred: true
#					labelText: ""
				,
					key: 'barcode'
					type: 'barcode'
					kind: 'barcode'
					preferred: false
#					labelText: ""
				]
				defaultValues: [
					key: 'sequence'
					stateType: 'descriptors'
					stateKind: 'unique attributes'
					type: 'stringValue' #used to set the lsValue subclass of the object
					kind: 'sequence'
#					value: "test"
				,
					key: 'mass'
					stateType: 'descriptors'
					stateKind: 'other attributes'
					type: 'numericValue'
					kind: 'mass'
					unitKind: 'mg'
#					value: 42.34
				,
					key: 'analysis parameters'
					stateType: 'meta'
					stateKind: 'experiment meta'
					type: 'clobValue'
					kind: 'analysis parameters'
				]
				defaultValueArrays: [
					key: 'temperatureValueArray'
					stateType: 'measurements'
					stateKind: 'stateVsTime'
					type: 'numberValue'
					kind: 'temperature'
					unitKind: 'C'
#					value: null
				,
					key: 'timeValueArray'
					stateType: 'measurements'
					stateKind: 'stateVsTime'
					type: 'dateValue'
					kind: 'time'
#					value: null
				]

	describe 'When created from new', ->
		beforeEach ->
			@siRNA = new siRNA()

		describe "Existence and Defaults", ->
			it "should be defined", ->
				expect(@siRNA).toBeDefined()
			it "should have a type", ->
				expect(@siRNA.get('lsType')).toEqual "thing"
			it "should have a kind", ->
				expect(@siRNA.get('lsKind')).toEqual "siRNA"
			it "should have an empty scientist", ->
				expect(@siRNA.get('recordedBy')).toEqual ""
			it "should have a recordedDate set to now", ->
				expect(new Date(@siRNA.get('recordedDate')).getHours()).toEqual new Date().getHours()
			it 'Should have an empty short description with a space as an oracle work-around', ->
				expect(@siRNA.get('shortDescription')).toEqual " "

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
				expect(corpNameLabel.get("labelText")).toEqual "newCorpName"

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
				expect(@siRNA.get("sequence")).toBeDefined()

			it 'should reference the lsStates model objects stored in lsStates as top level model attributes', ->
				@siRNA.get("sequence").set("value", "newsequence")
				sequenceStateValue = @siRNA.get('lsStates').getStateValueByTypeAndKind "descriptors", "unique attributes", "stringValue", "sequence"
				expect(sequenceStateValue.get("stringValue")).toEqual @siRNA.get("sequence").get("value")
				expect(sequenceStateValue.get("stringValue")).toEqual "newsequence"
				expect(@siRNA.get("sequence").get("value")).toEqual "newsequence"
				console.log "this"
				console.log @siRNA

			it 'should remove the top level lsStates model object references when sync() is called', ->
				expect(@siRNA.get("sequence")).toBeDefined()
				@siRNA.sync()
				expect(@siRNA.get("sequence")).toBeUndefined()

			it 'should create top level lsStates model object references when parse() is called / when the object is re-hyrdrated', ->
				newsequence = "this is a new sequence value"
				@siRNA.get("sequence").set("value", newsequence)
				expect(@siRNA.get("sequence")).toBeDefined()

				@siRNA.sync()
				expect(@siRNA.get("sequence")).toBeUndefined()
				@siRNA.parse()
				expect(@siRNA.get("sequence")).toBeDefined()
				expect(@siRNA.get("sequence").get("value")).toEqual newsequence


	describe "When created from existing", ->
		beforeEach ->
			@testsiRNA = new siRNA JSON.parse(JSON.stringify(window.thingTestJSON.siRNA))
		describe "after initial load", ->
			it "should be defined", ->
				expect(@testsiRNA).toBeDefined()
			it "should have a type", ->
				expect(@testsiRNA.get('lsType')).toEqual "thing"
			it "should have a kind", ->
				expect(@testsiRNA.get('lsKind')).toEqual "siRNA"
			it "should have a scientist set", ->
				expect(@testsiRNA.get('recordedBy')).toEqual "egao"
			it "should have a recordedDate set", ->
				expect(@testsiRNA.get('recordedDate')).toEqual 1375889487000
			it 'Should have a short description set', ->
				expect(@testsiRNA.get('shortDescription')).toEqual "thing created by egao"
