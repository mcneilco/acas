###
This suite of services provides CRUD operations on Analysis Group Objects

###

describe 'AnalysisGroup CRUD testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe "AnalysisGroupState model testing", ->
		describe "when created empty", ->
			beforeEach ->
				@ags = new AnalysisGroupState()
			it "Class should exist", ->
				expect(@ags).toBeDefined()
			it "should have defaults", ->
				expect(@ags.get('analysisGroupValues') instanceof AnalysisGroupValueList).toBeTruthy()
		describe "When loaded from state json", ->
			beforeEach ->
				@ags = new AnalysisGroupState window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup.analysisGroups[0].analysisGroupStates[0]
			describe "after initial load", ->
				it "state should have kind ", ->
					expect(@ags.get('stateKind')).toEqual "Document for Batch"
				it "state should have values", ->
					expect(@ags.get('analysisGroupValues') instanceof AnalysisGroupValueList).toBeTruthy()
					expect(@ags.get('analysisGroupValues').length).toEqual 3
				it "state should have populated value", ->
					expect(@ags.get('analysisGroupValues').at(0).get('valueKind')).toEqual "annotation"
				it "should return requested value", ->
					values = @ags.getValuesByTypeAndKind("codeValue", "batch code")
					expect(values.length).toEqual 1
					expect(values[0].get('codeValue')).toEqual "CMPD_1112"

	describe "AnalysisGroup model testing", ->
		describe "when created empty", ->
			beforeEach ->
				@ag = new AnalysisGroup()
			describe "defaults", ->
				it 'Should have an empty label list', ->
					expect(@ag.get('analysisGroupLabels').length).toEqual 0
					expect(@ag.get('analysisGroupLabels') instanceof LabelList).toBeTruthy()
				it 'Should have an empty state list', ->
					expect(@ag.get('analysisGroupStates').length).toEqual 0
					expect(@ag.get('analysisGroupStates') instanceof AnalysisGroupStateList).toBeTruthy()
				it 'Should have an empty scientist', ->
					expect(@ag.get('recordedBy')).toEqual ""
				it 'Should have an empty recordedDate', ->
					expect(@ag.get('recordedDate')).toBeNull()
				it 'Should have an empty kind', ->
					expect(@ag.get('kind')).toEqual ""
		describe "when loaded from existing", ->
			beforeEach ->
				@ag = new AnalysisGroup window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup.analysisGroups[0]
			describe "after initial load", ->
				it "should have a kind", ->
					expect(@ag.get('kind')).toEqual "ACAS doc for batches"
				it "should have a code ", ->
					expect(@ag.get('codeName')).toEqual "AG-00037424"
				it "should have labels", ->
					expect(@ag.get('analysisGroupLabels').length).toEqual 0
				it "should have states ", ->
					expect(@ag.get('analysisGroupStates').length).toEqual 3
				it "should have states with kind ", ->
					expect(@ag.get('analysisGroupStates').at(0).get('stateKind')).toEqual "Document for Batch"
				it "states should have values", ->
					expect(@ag.get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('valueKind')).toEqual "annotation"
				it "states should have ignored to be false", ->
					expect(@ag.get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('ignored')).toBeFalsy()
