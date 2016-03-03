beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Generic Data Parser Controller testing", ->
	beforeEach ->
		@gdpc = new GenericDataParserController
			el: $('#fixture')
		@gdpc.render()

	describe "Basic loading", ->
		it "Class should exist", ->
			expect(@gdpc).toBeDefined()
		it "Should load the template", ->
			expect($('.bv_parseFile')).not.toBeNull()

