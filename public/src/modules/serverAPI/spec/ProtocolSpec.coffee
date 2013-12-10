beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Protocol module testing", ->
	describe "Protocol model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@prot = new Protocol()
			describe "Defaults", ->
				it 'Should have an empty label list', ->
					expect(@prot.get('lsLabels').length).toEqual 0
				it 'Should have an empty state list', ->
					expect(@prot.get('lsStates').length).toEqual 0
				it 'Should have an empty scientist', ->
					expect(@prot.get('recordedBy')).toEqual ""
				it 'Should have an empty short description', ->
					expect(@prot.get('shortDescription')).toEqual ""
		describe "when loaded from existing", ->
			beforeEach ->
				@prot = new Protocol window.protocolServiceTestJSON.fullSavedProtocol
			describe "after initial load", ->
				it "should have a kind", ->
					expect(@prot.get('lsKind')).toEqual "default"
				it "should have a code ", ->
					expect(@prot.get('codeName')).toEqual "PROT-00000001"
				it "should have the shortDescription set", ->
					expect(@prot.get('shortDescription')).toEqual window.protocolServiceTestJSON.fullSavedProtocol.shortDescription
				it "should have labels", ->
					expect(@prot.get('lsLabels').length).toEqual window.protocolServiceTestJSON.fullSavedProtocol.lsLabels.length
				it "should have labels", ->
					expect(@prot.get('lsLabels').at(0).get('lsKind')).toEqual "protocol name"
				it "should have states ", ->
					expect(@prot.get('lsStates').length).toEqual window.protocolServiceTestJSON.fullSavedProtocol.lsStates.length
				it "should have states with kind ", ->
					expect(@prot.get('lsStates').at(0).get('lsKind')).toEqual "experiment controls"
				it "states should have values", ->
					expect(@prot.get('lsStates').at(0).get('lsValues').at(0).get('lsKind')).toEqual "data analysis parameters"
		describe "when loaded from stub", ->
			beforeEach ->
				@prot = new Protocol window.protocolServiceTestJSON.stubSavedProtocol[0]
				runs ->
					@fetchReturned = false
					@prot.fetch success: =>
						@fetchReturned = true
			describe "utility functions", ->
				it "should know it's a stub", ->
					expect(@prot.isStub()).toBeTruthy()
			describe "get full object", ->
				it "should have raw labels when fetched", ->
					waitsFor ->
						@fetchReturned
					runs ->
						expect(@prot.has('lsLabels')).toBeTruthy()
				it "should have raw labels converted to LabelList when fetched", ->
					waitsFor ->
						@fetchReturned
					runs ->
						expect(@prot.get('lsLabels') instanceof LabelList).toBeTruthy()
		describe "model composite component conversion", ->
			beforeEach ->
				runs ->
					@saveSucessful = false
					@saveComplete = false
					@prot = new Protocol window.protocolServiceTestJSON
					@prot.set shortDescription: "new description"
					@prot.on 'sync', =>
						@saveSucessful = true
						@saveComplete = true
					@prot.on 'invalid', =>
						@saveComplete = true
					@prot.save()
				waitsFor ->
					@saveComplete == true
				, 500
			it "should return from sync, not invalid", ->
				runs ->
					expect(@saveSucessful).toBeTruthy()
			it "should convert labels array to label list", ->
				runs ->
					expect(@prot.get('lsLabels')  instanceof LabelList).toBeTruthy()
					expect(@prot.get('lsLabels').length).toBeGreaterThan 0
			it "should convert state array to state list", ->
				runs ->
					expect(@prot.get('lsStates')  instanceof StateList).toBeTruthy()
					expect(@prot.get('lsStates').length).toBeGreaterThan 0
		describe "model change propogation", ->
			it "should trigger change when label changed", ->
				runs ->
					@prot = new Protocol()
					@protocolChanged = false
					@prot.get('lsLabels').setBestName new Label
						labelKind: "protocol name"
						labelText: "test label"
						recordedBy: @prot.get 'recordedBy'
						recordedDate: @prot.get 'recordedDate'
					@prot.on 'change', =>
						@protocolChanged = true
					@protocolChanged = false
					@prot.get('lsLabels').setBestName new Label
						labelKind: "protocol name"
						labelText: "new label"
						recordedBy: @prot.get 'recordedBy'
						recordedDate: @prot.get 'recordedDate'
				waitsFor ->
					@protocolChanged
				, 500
				runs ->
					expect(@protocolChanged).toBeTruthy()
			it "should trigger change when value changed in state", ->
				runs ->
					@prot = new Protocol window.protocolServiceTestJSON.fullSavedProtocol
					@protocolChanged = false
					@prot.on 'change', =>
						@protocolChanged = true
					@prot.get('lsStates').at(0).get('lsValues').at(0).set(lsKind: 'fred')
				waitsFor ->
					@protocolChanged
				, 500
				runs ->
					expect(@protocolChanged).toBeTruthy()


