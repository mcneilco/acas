beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Label module testing", ->
	describe "Label model test", ->
		beforeEach ->
			@el = new Label()
		describe "Basic new label", ->
			it "Class should exist", ->
				expect(@el).toBeDefined()
			it "should have defaults", ->
				expect(@el.get 'lsType').toEqual 'name'
				expect(@el.get 'lsKind').toEqual ''
				expect(@el.get 'labelText').toEqual ''
				expect(@el.get 'ignored').toEqual(false)
				expect(@el.get 'preferred').toEqual(false)
				expect(@el.get 'recordedDate').toEqual ''
				expect(@el.get 'recordedBy').toEqual ''
				expect(@el.get 'physicallyLabled').toEqual(false)
				expect(@el.get 'imageFile').toBeNull()
	describe "Label List testing", ->
		describe "label list features when loaded from existing list", ->
			beforeEach ->
				@ell = new LabelList window.experimentServiceTestJSON.experimentLabels
			it "Class should exist", ->
				expect(@ell).toBeDefined()
			it "Class should have labels", ->
				expect(@ell.length).toEqual 4
			it "Should return current (not ignored) labels", ->
				expect(@ell.getCurrent().length).toEqual 3
			it "Should return not ignored name labels", ->
				expect(@ell.getNames().length).toEqual 2
			it "Should return not ignored preferred labels", ->
				expect(@ell.getPreferred().length).toEqual 1
			describe "best label picker", ->
				it "Should select newest preferred label when there are preferred labels", ->
					expect(@ell.pickBestLabel().get('labelText')).toEqual "FLIPR target A biochemical"
				it "Should select newest name when there are no preferred labels but there are names", ->
					@ell2 = new LabelList window.experimentServiceTestJSON.experimentLabelsNoPreferred
					expect(@ell2.pickBestLabel().get('labelText')).toEqual "FLIPR target A biochemical with additional name awesomness"
				it "Should select newest label when there are no preferred labels and no names", ->
					@ell2 = new LabelList window.experimentServiceTestJSON.experimentLabelsNoPreferredNoNames
					expect(@ell2.pickBestLabel().get('labelText')).toEqual "AAABBD13343434"
			describe "best name picker", ->
				it "Should select newest preferred name label", ->
					expect(@ell.pickBestName().get('labelText')).toEqual "FLIPR target A biochemical"
			describe "setBestName functionality", ->
				it "should update existing unsaved label when best name changed", ->
					oldBestId = @ell.pickBestLabel().id
					@ell.setBestName new Label
						labelText: "new best name"
						recordedBy: "fmcneil"
						recordedDate: 3362435677000
					expect(@ell.pickBestLabel().get('labelText')).toEqual "new best name"
					expect(@ell.pickBestLabel().isNew).toBeTruthy()
					expect(@ell.get(oldBestId).get 'ignored').toBeTruthy()
		describe "label list features when new and empty", ->
			beforeEach ->
				@ell = new LabelList()
			it "Class should have labels", ->
				expect(@ell.length).toEqual 0
			describe "setBestName functionality", ->
				beforeEach ->
					@ell.setBestName new Label
						labelText: "best name"
						recordedBy: "jmcneil"
						recordedDate: 2362435677000
				it "should add new label when best name added for first time", ->
					expect(@ell.pickBestLabel().get('labelText')).toEqual "best name"
					expect(@ell.pickBestLabel().get('recordedBy')).toEqual "jmcneil"
					expect(@ell.pickBestLabel().get('recordedDate')).toEqual 2362435677000

				it "should update existing unsaved label when best name changed", ->
					@ell.setBestName new Label
						labelText: "new best name"
						recordedBy: "fmcneil"
						recordedDate: 3362435677000
					expect(@ell.length).toEqual 1
					expect(@ell.pickBestLabel().get('labelText')).toEqual "new best name"
					expect(@ell.pickBestLabel().get('recordedBy')).toEqual "fmcneil"
					expect(@ell.pickBestLabel().get('recordedDate')).toEqual 3362435677000

	describe "Value model testing", ->
		beforeEach ->
			@val = new Value()
		it "Class should exist", ->
			expect(@val).toBeDefined()
			
	describe "Value list testing", ->
		beforeEach ->
			@vl = new ValueList()
		describe "basic existance tests", ->
			it "Class should exist", ->
				expect(@vl).toBeDefined()

	describe "State model testing", ->
		describe "when created empty", ->
			beforeEach ->
				@es = new State()
			describe "basic existance tests", ->
				it "Class should exist", ->
					expect(@es).toBeDefined()
				it "should have defaults", ->
					expect(@es.get('lsValues') instanceof Backbone.Collection).toBeTruthy()
		describe "When loaded from state json", ->
			beforeEach ->
				@es = new State window.experimentServiceTestJSON.fullExperimentFromServer.lsStates[0]
			describe "after initial load", ->
				it "state should have kind ", ->
					expect(@es.get('lsKind')).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.lsStates[0].lsKind
				it "state should have values", ->
					expect(@es.get('lsValues').length).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.lsStates[0].lsValues.length
				it "state should have populated value", ->
					expect(@es.get('lsValues').at(0).get('lsKind')).toEqual "control type"
				it "should return requested value", ->
					values = @es.getValuesByTypeAndKind("stringValue", "control type")
					expect(values.length).toEqual 1
					expect(values[0].get('stringValue')).toEqual "negative control"
				it "should trigger change when value changed in state", ->
					runs ->
						@stateChanged = false
						@es.on 'change', =>
							@stateChanged = true
						@es.get('lsValues').at(0).set(valueKind: 'newkind')
					waitsFor ->
						@stateChanged
					, 500
					runs ->
						expect(@stateChanged).toBeTruthy()

	describe "State List model testing", ->
		describe "when loaded from existing", ->
			beforeEach ->
				@esl = new StateList window.experimentServiceTestJSON.fullExperimentFromServer.lsStates
			describe "after initial load with test data", ->
				it "Class should exist", ->
					expect(@esl).toBeDefined()
				it "should have states ", ->
					expect(@esl.length).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.lsStates.length
				it "first state should have kind ", ->
					expect(@esl.at(0).get('lsKind')).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.lsStates[0].lsKind
				it "states should have values", ->
					expect(@esl.at(0).get('lsValues').length).toEqual window.experimentServiceTestJSON.fullExperimentFromServer.lsStates[0].lsValues.length
				it "first state should have populated value", ->
					expect(@esl.at(0).get('lsValues').at(0).get('lsKind')).toEqual "control type"
			describe "Get states by type and kind", ->
				it "should return requested state", ->
					values = @esl.getStatesByTypeAndKind "metadata", "experiment metadata"
					expect(values.length).toEqual 1
					expect(values[0].get('lsTypeAndKind')).toEqual "metadata_experiment metadata"
			describe "Get value by type and kind", ->
				it "should return requested value", ->
					value = @esl.getStateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "notebook"
					expect(value.get('stringValue')).toEqual "911"
			describe "get or create a state or value", ->
				it "should return an existing state", ->
					st = @esl.getOrCreateStateByTypeAndKind "metadata", "experiment metadata"
					expect(st.get('lsType')).toEqual "metadata"
				it "return an existing value", ->
					val = @esl.getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "stringValue", "notebook"
					expect(val.get('stringValue')).toEqual "911"
		describe "when created empty", ->
			beforeEach ->
				@esl = new StateList()
			describe "get or create a state or value", ->
				it "should create a new state if a specific one is requested that doesn't exist", ->
					expect(@esl.getStatesByTypeAndKind("stateType", "stateKind").length).toEqual 0
					@esl.getOrCreateStateByTypeAndKind "stateType", "stateKind"
					expect(@esl.getStatesByTypeAndKind("stateType", "stateKind").length).toEqual 1
				it "should create a new state and value if a specific value is requested that doesn't exist", ->
					expect(@esl.getStatesByTypeAndKind("stateType", "stateKind").length).toEqual 0
					expect(@esl.getStateValueByTypeAndKind("stateType", "stateKind", "valType", "valKind")).toBeNull
					@esl.getOrCreateValueByTypeAndKind "stateType", "stateKind", "valType", "valKind"
					expect(@esl.getStatesByTypeAndKind("stateType", "stateKind").length).toEqual 1
					expect(@esl.getStateValueByTypeAndKind("stateType", "stateKind", "valType", "valKind").get('lsKind')).toEqual "valKind"

