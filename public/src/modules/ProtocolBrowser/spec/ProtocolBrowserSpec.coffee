beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Protocol Browser module testing", ->
	describe "Protocol Search Model controller", ->
		beforeEach ->
			@psm = new ProtocolSearch()
		describe "Basic existence tests", ->
			it "should be defined", ->
				expect(@psm).toBeDefined()
			it "should have defaults", ->
				expect(@psm.get('protocolCode')).toBeNull()
	describe "Protocol Simple Search Controller", ->
		describe "when instantiated", ->
			beforeEach ->
				@pssc = new ProtocolSimpleSearchController
					model: new ProtocolSearch()
					el: $('#fixture')
				@pssc.render()
			describe "basic existance tests", ->
				it "should exist", ->
					expect(@pssc).toBeDefined()
				it "should load a template", ->
					expect(@pssc.$('.bv_protocolSearchTerm').length).toEqual 1





