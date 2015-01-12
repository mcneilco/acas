beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Components testing", ->
	describe "Component model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@comp = new Component()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@comp).toBeDefined()
				it "should have defaults", ->
					expect(@comp.get('transformationRule')).toEqual "unassigned"
