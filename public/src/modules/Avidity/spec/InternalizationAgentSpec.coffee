beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe 'Internalization Agent testing', ->
	describe "Internalization Agent Parent model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@iap = new InternalizationAgentParent()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@iap).toBeDefined()
				it "should have a type", ->
					expect(@iap.get('lsType')).toEqual "thing"
				it "should have a kind", ->
					expect(@iap.get('lsKind')).toEqual "InternalizationAgentParent"
				it "should have an empty scientist", ->
					expect(@iap.get('recordedBy')).toEqual ""
				it "should have a recordedDate set to now", ->
					expect(new Date(@iap.get('recordedDate')).getHours()).toEqual new Date().getHours()
				it "Should have an empty short description with a space as an oracle work-around", ->
					expect(@iap.get('shortDescription')).toEqual " "
				it "Should have a lsLabels with one label", ->
					expect(@iap.get('lsLabels')).toBeDefined()
					expect(@iap.get("lsLabels").length).toEqual 1
					expect(@iap.get("lsLabels").getLabelByTypeAndKind("name", "internalization agent name").length).toEqual 1
				it "Should have a model attribute for the label in defaultLabels", ->
					expect(@iap.get("internalization agent name")).toBeDefined()
				it "Should have a lsStates with the states in defaultStates", ->
					expect(@iap.get('lsStates')).toBeDefined()
					expect(@iap.get("lsStates").length).toEqual 1
					expect(@iap.get("lsStates").getStatesByTypeAndKind("parent attributes", "internalization agent parent attributes").length).toEqual 1
				describe "model attributes for each value in defaultValues", ->
					it "Should have a model attribute for internalization agent type", ->
						expect(@iap.get("internalization agent type")).toBeDefined()
					it "Should have a model attribute for conjugation type", ->
						expect(@iap.get("conjugation type")).toBeDefined()
					it "Should have a model attribute for conjugation site", ->
						expect(@iap.get("conjugation site")).toBeDefined()
					it "Should have a model attribute for protein aa sequence", ->
						expect(@iap.get("protein aa sequence")).toBeDefined()
					it "Should have a model attribute for scientist", ->
						expect(@iap.get("scientist")).toBeDefined()
					it "Should have a model attribute for notebook", ->
						expect(@iap.get("notebook")).toBeDefined()
					it "Should have a model attribute for completion date", ->
						expect(@iap.get("completion date")).toBeDefined()

	describe "When created from existing", ->
		beforeEach ->
			@iap = new InternalizationAgentParent JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentParent))
		describe "after initial load", ->
			it "should be defined", ->
				expect(@iap).toBeDefined()
			it "should have a type", ->
				expect(@iap.get('lsType')).toEqual "thing"
			it "should have a kind", ->
				expect(@iap.get('lsKind')).toEqual "InternalizationAgentParent"
			it "should have a scientist set", ->
				expect(@iap.get('recordedBy')).toEqual "egao"
			it "should have a recordedDate set", ->
				expect(@iap.get('recordedDate')).toEqual 1375141508000
			it "Should have a short description set", ->
				expect(@iap.get('shortDescription')).toEqual "example short description"
			it "Should have the label set", ->
				console.log @iap
				expect(@iap.get("internalization agent name")).toEqual "IA Example 1"
				label = (@iap.get("lsLabels").getLabelByTypeAndKind("name", "internalization agent name"))
				expect(label.get('labelText')).toEqual "IA Example 1"
			it "Should have a model attribute for the label in defaultLabels", ->
				expect(@iap.get("internalization agent name")).toBeDefined()
			it "Should have a lsStates with the states in defaultStates", ->
				expect(@iap.get('lsStates')).toBeDefined()
				expect(@iap.get("lsStates").length).toEqual 1
				expect(@iap.get("lsStates").getStatesByTypeAndKind("parent attributes", "internalization agent parent attributes").length).toEqual 1
			describe "model attributes for each value in defaultValues", ->
				it "Should have a model attribute for internalization agent type", ->
					expect(@iap.get("internalization agent type")).toBeDefined()
				it "Should have a model attribute for conjugation type", ->
					expect(@iap.get("conjugation type")).toBeDefined()
				it "Should have a model attribute for conjugation site", ->
					expect(@iap.get("conjugation site")).toBeDefined()
				it "Should have a model attribute for protein aa sequence", ->
					expect(@iap.get("protein aa sequence")).toBeDefined()
				it "Should have a model attribute for scientist", ->
					expect(@iap.get("scientist")).toBeDefined()
				it "Should have a model attribute for notebook", ->
					expect(@iap.get("notebook")).toBeDefined()
				it "Should have a model attribute for completion date", ->
					expect(@iap.get("completion date")).toBeDefined()
