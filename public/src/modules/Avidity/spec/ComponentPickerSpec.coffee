beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Component Picker testing", ->
	describe "AddComponent model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@ac = new AddComponent()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@ac).toBeDefined()
				it "should have defaults", ->
					expect(@ac.get('componentType')).toEqual "unassigned"

	describe "ComponentCodeName model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@ccn = new ComponentCodeName()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@ccn).toBeDefined()
				it "should have defaults", ->
					expect(@ccn.get('componentCodeName')).toEqual "unassigned"
					expect(@ccn.get('componentType')).toEqual ""
		describe "model validation tests", ->
			beforeEach ->
				@ccn = new ComponentCodeName window.componentPickerTestJSON.componentCodeNamesList[0]
			it "should be valid as initialized", ->
				expect(@ccn.isValid()).toBeTruthy()
			it "should be invalid when component codeName is unassigned", ->
				@ccn.set componentCodeName: "unassigned"
				expect(@ccn.isValid()).toBeFalsy()
				filtErrors = _.filter @ccn.validationError, (err) ->
					err.attribute=='componentCodeName'
				expect(filtErrors.length).toBeGreaterThan 0

	describe "ComponentCodeNamesList testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@ccnl = new ComponentCodeNamesList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@ccnl).toBeDefined()
		describe "When loaded form existing", ->
			beforeEach ->
				@ccnl = new ComponentCodeNamesList window.componentPickerTestJSON.componentCodeNamesList
			it "should have three components", ->
				expect(@ccnl.length).toEqual 3
			it "should have the correct info for the first component", ->
				ruleone = @ccnl.at(0)
				expect(ruleone.get('componentType')).toEqual "Protein"
				expect(ruleone.get('componentCodeName')).toEqual "PROT000001"
			it "should have the correct info for the second component", ->
				ruletwo = @ccnl.at(1)
				expect(ruletwo.get('componentType')).toEqual "Spacer"
				expect(ruletwo.get('componentCodeName')).toEqual "SP000002"
			it "should have the correct read info for the third read", ->
				rulethree = @ccnl.at(2)
				expect(rulethree.get('componentType')).toEqual "Cationic Block"
				expect(rulethree.get('componentCodeName')).toEqual "CB000003"

	describe "AddComponentController", ->
		describe "when instantiated", ->
			beforeEach ->
				@acc = new AddComponentController
					model: new AddComponent()
					el: $('#fixture')
				@acc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@acc).toBeDefined()
				it "should load a template", ->
					expect(@acc.$('.bv_addComponentSelect').length).toEqual 1
			describe "rendering", ->
				it "should show add component select", ->
					waitsFor ->
						@acc.$('.bv_addComponentSelect option').length > 0
					, 1000
					runs ->
						expect(@acc.$('.bv_addComponentSelect').val()).toEqual "unassigned"
			describe "model updates", ->
				it "should update the component type", ->
					waitsFor ->
						@acc.$('.bv_addComponentSelect option').length > 0
					, 1000
					runs ->
						@acc.$('.bv_addComponentSelect').val('Protein')
						@acc.$('.bv_addComponentSelect').change()
						expect(@acc.model.get('componentType')).toEqual "Protein"

	describe "ComponentCodeNameController", ->
		describe "when instantiated", ->
			beforeEach ->
				@ccnc = new ComponentCodeNameController
					model: new ComponentCodeName()
					el: $('#fixture')
				@ccnc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@ccnc).toBeDefined()
				it "should load a template", ->
					expect(@ccnc.$('.bv_componentCodeName').length).toEqual 1
			describe "rendering", ->
				it "should show component codeName select", ->
					expect(@ccnc.$('.bv_componentCodeName').length).toEqual 1
				it "should show a label for the component", ->
					expect(@ccnc.$('.bv_componentType').html()).toEqual ""
		describe "when instantiated from existing", ->
			beforeEach ->
				@ccnc = new ComponentCodeNameController
					model: new ComponentCodeName window.componentPickerTestJSON.componentCodeNamesList[0]
					el: $('#fixture')
				@ccnc.render()
			describe "rendering existing parameters", ->
				it "should show component codeName select", ->
					waitsFor ->
						@ccnc.$('.bv_componentCodeName option').length > 0
					, 1000
					runs ->
						expect(@ccnc.$('.bv_componentCodeName').val()).toEqual "PROT000001"
				it "should show a label for the component", ->
					expect(@ccnc.$('.bv_componentType').html()).toEqual "Protein"

			describe "model updates", ->
				it "should update the component codeName", ->
					waitsFor ->
						@ccnc.$('.bv_componentCodeName option').length > 0
					, 1000
					runs ->
						@ccnc.$('.bv_componentCodeName').val('PROT000001')
						@ccnc.$('.bv_componentCodeName').change()
						expect(@ccnc.model.get('componentCodeName')).toEqual "PROT000001"
		describe "validation testing", ->
			beforeEach ->
				@ccnc = new ComponentCodeNameController
					model: new ComponentCodeName()
					el: $('#fixture')
				@ccnc.render()
#			describe "error notification", ->
#				it "should show error if component codeName is not selected", ->
#					waitsFor ->
#						@ccnc.$('.bv_componentCodeName option').length > 0
#					, 1000
#					runs ->
#						@ccnc.$('.bv_componentCodeName').val "unassigned"
#						@ccnc.$('.bv_componentCodeName').change()
#						expect(@ccnc.$('.bv_group_componentCodeName').hasClass("error")).toBeTruthy()
#						expect(@ccnc.$('.bv_group_componentCodeName').attr('data-toggle')).toEqual "tooltip"

	describe "ComponentCodeNameListController testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@ccnlc= new ComponentCodeNamesListController
					el: $('#fixture')
					collection: new ComponentCodeNamesList()
				@ccnlc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@ccnlc).toBeDefined()
				it "should load a template", ->
					expect(@ccnlc.$('.bv_componentInfo').length).toEqual 1
			describe "rendering", ->
				it "should not show anything", ->
					expect(@ccnlc.$('.bv_componentInfo').val()).toEqual ""
		describe "when instantiated with data", ->
			beforeEach ->
				@ccnlc= new ComponentCodeNamesListController
					el: $('#fixture')
					collection: new ComponentCodeNamesList window.componentPickerTestJSON.componentCodeNamesList
				@ccnlc.render()
			it "should have three reads", ->
				expect(@ccnlc.collection.length).toEqual 3
			it "should have the correct info for the first component", ->
				waitsFor ->
					@ccnlc.$('.bv_componentCodeName option').length > 0
				, 1000
				runs ->
					expect(@ccnlc.$('.bv_componentType:eq(0)').html()).toEqual "Protein"
					expect(@ccnlc.$('.bv_componentCodeName:eq(0)').val()).toEqual "PROT000001"
			it "should have the correct info for the second component", ->
				waitsFor ->
					@ccnlc.$('.bv_componentCodeName option').length > 0
				, 1000
				runs ->
					expect(@ccnlc.$('.bv_componentType:eq(1)').html()).toEqual "Spacer"
					expect(@ccnlc.$('.bv_componentCodeName:eq(1)').val()).toEqual "SP000002"
			it "should have the correct info for the third component", ->
				waitsFor ->
					@ccnlc.$('.bv_componentCodeName option').length > 0
				, 1000
				runs ->
					expect(@ccnlc.$('.bv_componentType:eq(2)').html()).toEqual "Cationic Block"
					expect(@ccnlc.$('.bv_componentCodeName:eq(2)').val()).toEqual "CB000003"
			describe "adding and removing", ->
				it "should have two components when the x is clicked", ->
					@ccnlc.$('.bv_deleteComponent:eq(0)').click()
					expect(@ccnlc.$('.bv_componentInfo .bv_componentCodeName').length).toEqual 2
					expect(@ccnlc.collection.length).toEqual 2
