beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Component Builder testing", ->
	describe "AddComponent model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@ac = new AddComponent()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@ac).toBeDefined()
				it "should have defaults", ->
					expect(@ac.get('componentType')).toEqual "unassigned"
