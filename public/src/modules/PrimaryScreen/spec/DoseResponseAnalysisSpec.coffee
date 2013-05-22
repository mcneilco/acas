beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Dose Response Analysis Module Testing", ->
	describe "basic plumbing checks with new experiment", ->
		beforeEach ->
			@drac = new DoseResponseAnalysisController
				model: new Experiment()
				el: $('#fixture')
			@drac.render()
		describe "Basic loading", ->
			it "Class should exist", ->
				expect(@drac).toBeDefined()
			it "Should load the template", ->
				expect(@drac.$('.bv_fixCurveMin').length).toNotEqual 0










### Design questions:
  - What do we save for the batch grouping option?
  - Where do we store curve status, and what are expected values?

###