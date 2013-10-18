beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Experiment Browser module testing", ->
	describe "Experiment Search Model controller", ->
		beforeEach ->
			@esm = new ExperimentSearch()
		describe "Basic existence tests", ->
			it "should be defined", ->
				expect(ExperimentSearch).toBeDefined()
			it "should have defaults", ->
				expect(@esm.get('protocolCode')).toBeNull()
				expect(@esm.get('experimentCode')).toBeNull()

	describe "Experiment Search Controller tests", ->
		beforeEach ->
			runs ->
				@esc = new ExperimentSearchController
					el: @fixture
				@esc.render()
		describe "Basic existence and rendering tests", ->
			it "should be defined", ->
				expect(ExperimentSearchController).toBeDefined()
			it "should have a protocol code select", ->
				expect(@esc.$('.bv_protocolCode').length).toEqual 1
		describe "After render", ->
			it "should populate the protocol select", ->
				waitsFor ->
					@esc.$('.bv_protocolCode option').length > 0
				, 1000
				runs ->
					expect(@esc.$('.bv_protocolCode').val()).toEqual "any"


	describe "ExperimentBrowserController tests", ->
		beforeEach ->
			@ebc = new ExperimentBrowserController
				el: @fixture
			@ebc.render()
		describe "Basic existence and rendering tests", ->
			it "should be defined", ->
				expect(ExperimentBrowserController).toBeDefined()
			it "should have a search controller div", ->
				expect(@ebc.$('.bv_experimentSearchController').length).toEqual 1

