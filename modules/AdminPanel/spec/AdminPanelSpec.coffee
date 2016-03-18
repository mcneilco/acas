beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Admin Panel testing", ->

	describe "Admin Panel model testing", ->
		describe "when loaded from new", ->
			beforeEach ->
				@ap = new AdminPanel()
			describe "existence and defaults", ->
				it "should be defined", ->
					expect(@ap).toBeDefined()
				it "should have defaults", ->

	describe "Admin Panel controller", ->
		describe "when instantiated from new", ->
			beforeEach ->
				@apc = new AdminPanelController
					model: new AdminPanel()
					el: $('#fixture')
				@apc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@apc).toBeDefined()
				it "should load the template", ->
					expect(@apc.$('.bv_adminPanelWrapper').length).toEqual 1
