beforeEach ->
	@fixture = $("#fixture")

afterEach ->
	$("#fixture").remove()
	$("body").append '<div id="fixture"></div>'

describe "Reagent Reg Module Testing", ->
	describe "Reagent model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@reagent = new Reagent()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@reagent).toBeDefined()
				it "should have defaults", ->
					expect(@reagent.get('cas')).toBeNull()
					expect(@reagent.get('barcode')).toBeNull()
					expect(@reagent.get('vendor')).toBeNull()
					expect(@reagent.get('hazardCategory')).toBeNull()
		describe "When loaded from existing", ->
			beforeEach ->
				@reagent = new Reagent window.reagentRegTestJSON.savedReagent
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@reagent).toBeDefined()
				it "should have defaults", ->
					expect(@reagent.get('cas')).toEqual 123456
					expect(@reagent.get('barcode')).toEqual "RR123345"
					expect(@reagent.get('vendor')).toEqual "vendor1"
					expect(@reagent.get('hazardCategory')).toEqual "flammable"
			describe "model validation tests", ->
				it "should be valid as initialized", ->
					expect(@reagent.isValid()).toBeTruthy()
				it "should be invalid when positive control batch is empty", ->
					@reagent.set barcode: ""
					expect(@reagent.isValid()).toBeFalsy()
					filtErrors = _.filter(@reagent.validationError, (err) ->
						err.attribute=='barcode'
					)
					expect(filtErrors.length).toBeGreaterThan 0


	describe "Reagent Controller", ->
		describe 'when instantiated with new reagent', ->
			beforeEach ->
				@rc = new ReagentController
					model: new Reagent()
					el: $('#fixture')
				@rc.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@rc).toBeDefined()
				it 'should load a template', ->
					expect(@rc.$('.bv_barcode').length).toEqual 1
			describe "basic rendering", ->
				it "should show a populated hazard category select", ->
					waitsFor ->
						@rc.$('.bv_hazardCategory option').length > 0
					, 200
					runs ->
						expect(@rc.$('.bv_hazardCategory option:eq(0)').val()).toEqual "unassigned"

		describe 'when instantiated with existing reagent', ->
			beforeEach ->
				@rc = new ReagentController
					model: new Reagent window.reagentRegTestJSON.savedReagent
					el: $('#fixture')
				@rc.render()
			describe "should show current values", ->
				it 'should fill the cas field', ->
					expect(@rc.$('.bv_cas').val()).toEqual '123456'
				it 'should fill the barcode field', ->
					expect(@rc.$('.bv_barcode').val()).toEqual "RR123345"
			describe "should update model", ->
				it "should update cas when changed", ->
					@rc.$('.bv_cas').val 2222
					@rc.$('.bv_cas').change()
					expect(@rc.model.get('cas')).toEqual 2222
				it "should update cas when changed", ->
					@rc.$('.bv_barcode').val "newBarcode"
					@rc.$('.bv_barcode').change()
					expect(@rc.model.get('barcode')).toEqual "newBarcode"
				it "should show the correct hazard category", ->
					waitsFor ->
						@rc.$('.bv_hazardCategory option').length > 0
					, 200
					runs ->
						expect(@rc.$('.bv_hazardCategory').val()).toEqual "flammable"
			describe "validation testing", ->
				it "should show an error if barcode not filled", ->
					@rc.$('.bv_barcode').val ""
					@rc.$('.bv_barcode').change()
					expect(@rc.$('.bv_group_barcode').hasClass("error")).toBeTruthy()



