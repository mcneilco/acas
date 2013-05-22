beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Curve Curator Module testing", ->
	describe "Curve Model testing", ->
		beforeEach ->
			@curve = new Curve()
		describe "basic plumbing tests", ->
			it "should have model defined", ->
				expect(Curve).toBeDefined()
			it "should have defaults", ->
				expect(@curve.get("curveid")).toEqual ""
				expect(@curve.get("status")).toEqual "pass"
				expect(@curve.get("category")).toEqual "sigmoid"

	describe "Curve List Model testing", ->
		beforeEach ->
			@curveList = new CurveList()
			@curvesFetched = false
		describe "basic plumbing tests", ->
			it "should have model defined", ->
				expect(CurveList).toBeDefined()
		describe "get data from server", ->
			it "should return the curves", ->
				runs ->
					@curveList.setExperimentCode "EXPT-00000018"
					@curveList.fetch
						success: =>
							@curvesFetched = true
				waitsFor =>
					@curvesFetched
				, 200
				runs ->
					expect(@curveList.length).toBeGreaterThan 0

	describe "Curve Summary Controller tests", ->
		beforeEach ->
			@curve = new Curve(window.curveCuratorTestJSON.curveStubs[0])
			@csc = new CurveSummaryController
				el: @fixture
				model: @curve
			@csc.render()
		describe "basic plumbing", ->
			it "should have controller defined", ->
				expect(CurveSummaryController).toBeDefined()
			it "should load template", ->
				expect(@csc.$('.bv_thumbnail').length).toEqual 1
			it " should have a default tag name", ->
				expect(@csc.tagName).toEqual 'div'
		describe "rendering thumbnail", ->
			it "should have img src attribute set", ->
				expect(@csc.$('.bv_thumbnail').attr('src')).toContain "90807_AG-00000026"
		describe "selection", ->
			it "should show selected when clicked", ->
				@csc.$el.click()
				expect(@csc.$el.hasClass('selected')).toBeTruthy()

	describe "Curve Summary List Controller tests", ->
		beforeEach ->
			@curves = new CurveList(window.curveCuratorTestJSON.curveStubs)
			@cslc = new CurveSummaryListController
				el: @fixture
				collection: @curves
			@cslc.render()
		describe "basic plumbing", ->
			it "should have controller defined", ->
				expect(CurveSummaryListController).toBeDefined()
			it "should load template", ->
				expect(@cslc.$('.bv_curveSummaries').length).toEqual 1
		describe "summary rendering", ->
			it "should create summary divs", ->
				expect(@cslc.$('.bv_curveSummary').length).toBeGreaterThan 0
		describe "user thumbnail selection", ->
			beforeEach ->
				@cslc.$('.bv_curveSummaries .bv_curveSummary').eq(0).click()
			it "should highlight selected row", ->
				expect(@cslc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeTruthy()
			it "should select other row when other row is selected", ->
				@cslc.$('.bv_curveSummaries .bv_curveSummary').eq(1).click()
				expect(@cslc.$('.bv_curveSummaries .bv_curveSummary').eq(1).hasClass('selected')).toBeTruthy()
			it "should clear selected when another row is selected", ->
				@cslc.$('.bv_curveSummaries .bv_curveSummary').eq(1).click()
				expect(@cslc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeFalsy()

	describe "Curve Editor Controller tests", ->
		describe "when created with no model", ->
			beforeEach ->
				@cec = new CurveEditorController
					el: @fixture
				@cec.render()
			describe "basic plumbing", ->
				it "should have controller defined", ->
					expect(CurveEditorController).toBeDefined()
				it "should load template", ->
					expect(@cec.$('.bv_shinyContainer').length).toEqual 1
				it "should show no curve selected", ->
					expect(@cec.$('.bv_shinyContainer').html()).toContain "No Curve Selected"
			describe "when new model set", ->
				it "should set the iframe src", ->
					mdl = new Curve(window.curveCuratorTestJSON.curveStubs[0])
					@cec.setModel(mdl)
					expect(@cec.$('.bv_shinyContainer').attr('src')).toContain "90807_AG-00000026"

		describe "when created with populated model", ->
			beforeEach ->
				@curve = new Curve(window.curveCuratorTestJSON.curveStubs[0])
				@cec = new CurveEditorController
					el: @fixture
					model: @curve
				@cec.render()
			describe "rendering editor", ->
				it "should have iframe src attribute set", ->
					expect(@cec.$('.bv_shinyContainer').attr('src')).toContain "90807_AG-00000026"

	describe "Curve Curator Controller tests", ->
		beforeEach ->
			@ccc = new CurveCuratorController
				el: @fixture
			@ccc.render()
		describe "basic plumbing", ->
			it "should have controller defined", ->
				expect(CurveCuratorController).toBeDefined()
			it "should load template", ->
				expect(@ccc.$('.bv_curveList').length).toEqual 1
			it "should load template", ->
				expect(@ccc.$('.bv_curveEditor').length).toEqual 1
		describe "curve fetching", ->
			it "should fetch curves from expt code", ->
				runs ->
					@ccc.getCurvesFromExperimentCode("EXPT-00000018")
				waits(200)
				runs ->
					expect(@ccc.collection.length).toBeGreaterThan 0
		describe "should initialize and render sub controllers", ->
			beforeEach ->
				runs ->
					@ccc.getCurvesFromExperimentCode("EXPT-00000018")
				waitsFor ->
					@ccc.collection.length > 0
			it "should show the curve summary list", ->
				runs ->
					expect(@ccc.$('.bv_curveSummary').length).toBeGreaterThan 0
			it "should select the first curve in the list", ->
				runs ->
					expect(@ccc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeTruthy()
			it "should show the curve editor", ->
				runs ->
					expect(@ccc.$('.bv_shinyContainer').length).toBeGreaterThan 0
			describe "When new thumbnail selected", ->
				beforeEach ->
					runs ->
						@ccc.$('.bv_curveSummaries .bv_curveSummary').eq(0).click()
				it "should set the curve editor iframe src", ->
					runs ->
						expect(@ccc.$('.bv_shinyContainer').attr('src')).toContain "90807_AG-00000026"

