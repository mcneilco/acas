beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe 'Abstract Base Component testing', ->
	describe "Abstract Base Component Batch model testing", ->
		it "Class should exist", ->
			expect(window.AbstractBaseComponentBatch).toBeDefined()

	describe "Base Component Batch Controller testing", ->
		describe "basic existence tests", ->
			it "Class should exist", ->
				expect(window.AbstractBaseComponentBatchController).toBeDefined()
