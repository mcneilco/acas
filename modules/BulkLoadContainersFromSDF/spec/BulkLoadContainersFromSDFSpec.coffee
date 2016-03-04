beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Bulk Load Containers From SDF Controller testing", ->
	beforeEach ->
		@blcc = new BulkLoadContainersFromSDFController
			el: $('#fixture')
		@blcc.render()

	describe "Basic loading", ->
		it "Class should exist", ->
			expect(@blcc).toBeDefined()
		it "Should load the template", ->
			expect($('.bv_parseFile')).not.toBeNull()

