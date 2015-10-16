###
This suite of services provides CRUD operations on Analysis Group Objects

###

describe 'AnalysisGroup CRUD testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe "AnalysisGroup model testing", ->
		describe "when created empty", ->
			beforeEach ->
				@ag = new AnalysisGroup()
			describe "defaults", ->
				it 'Should have an empty label list', ->
					expect(@ag.get('lsLabels').length).toEqual 0
					expect(@ag.get('lsLabels') instanceof LabelList).toBeTruthy()
				it 'Should have an empty state list', ->
					expect(@ag.get('lsStates').length).toEqual 0
					expect(@ag.get('lsStates') instanceof StateList).toBeTruthy()
				it 'Should have an empty scientist', ->
					expect(@ag.get('recordedBy')).toEqual ""
				it 'Should have an empty recordedDate', ->
					expect(@ag.get('recordedDate')).toBeNull()
				it 'Should have an empty kind', ->
					expect(@ag.get('kind')).toEqual ""
		describe "when loaded from existing", ->
			beforeEach ->
				@ag = new AnalysisGroup window.experimentServiceTestJSON.savedExperimentWithAnalysisGroups.analysisGroups[0]
			describe "after initial load", ->
				it "should have a kind", ->
					expect(@ag.get('lsKind')).toEqual "ACAS doc for batches"
				it "should have a code ", ->
					expect(@ag.get('codeName')).toEqual "AG-00037424"
				it "should have labels", ->
					expect(@ag.get('lsLabels').length).toEqual 0
				it "should have states ", ->
					expect(@ag.get('lsStates').length).toEqual 3
				it "should have states with kind ", ->
					expect(@ag.get('lsStates').at(0).get('lsKind')).toEqual "Document for Batch"
				it "states should have values", ->
					expect(@ag.get('lsStates').at(0).get('lsValues').at(0).get('lsKind')).toEqual "annotation"
				it "states should have ignored to be false", ->
					expect(@ag.get('lsStates').at(0).get('lsValues').at(0).get('ignored')).toBeFalsy()

