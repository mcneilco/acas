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
				expect(@curve.get('curveid')).toEqual ""
				expect(@curve.get('algorithmApproved')).toBeNull()
				expect(@curve.get('userApproved')).toBeNull()
				expect(@curve.get('category')).toEqual ""

	describe "Curve List Model testing", ->
		beforeEach ->
			@curveList = new CurveList window.curveCuratorTestJSON.curveCuratorThumbs.curves
			@curvesFetched = false
		describe "basic plumbing tests", ->
			it "should have model defined", ->
				expect(CurveList).toBeDefined()
		describe "making category list", ->
			it "should return a list of categories", ->
				categories = @curveList.getCategories()
				expect(categories.length).toEqual 3
				expect(categories instanceof Backbone.Collection).toBeTruthy()

	describe "CurveCurationSetModel testing", ->
		beforeEach ->
			@ccs = new CurveCurationSet()
			@fetchReturn = false
		describe "basic plumbing tests", ->
			it "should have model defined", ->
				expect(CurveCurationSet).toBeDefined()
			it "should have defaults", ->
				expect(@ccs.get('sortOptions') instanceof Backbone.Collection).toBeTruthy()
				expect(@ccs.get('curves') instanceof CurveList).toBeTruthy()
		describe "curve fetching", ->
			beforeEach ->
				runs ->
					@ccs.on 'sync', =>
						@fetchReturn = true
					@ccs.setExperimentCode("EXPT-00000018")
					@ccs.fetch()
				waitsFor =>
					@fetchReturn
				, 200

			it "should fetch curves set from expt code", ->
				runs ->
					expect(@ccs.get('curves').length).toBeGreaterThan 0
			it "curves should be converted to CurveList", ->
				runs ->
					expect(@ccs.get('curves') instanceof CurveList).toBeTruthy()
			it "sortOptions should be converted to Collection", ->
				runs ->
					expect(@ccs.get('sortOptions') instanceof Backbone.Collection).toBeTruthy()


	describe "Curve Summary Controller tests", ->
		beforeEach ->
			@curve = new Curve(window.curveCuratorTestJSON.curveCuratorThumbs.curves[0])
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
			it "should show the compound code", ->
				expect(@csc.$('.bv_compoundCode').html()).toEqual "CMPD-0000008"
		describe "selection", ->
			it "should show selected when clicked", ->
				@csc.$el.click()
				expect(@csc.$el.hasClass('selected')).toBeTruthy()
		describe "algorithm approved display", ->
			it "should show approved when algorithm approved", ->
				expect(@csc.$('.bv_thumbnail').hasClass('algorithmApproved')).toBeTruthy()
				expect(@csc.$('.bv_thumbnail').hasClass('algorithmNotApproved')).toBeFalsy()
			it "should show not approved when algorithm not approved", ->
				@csc.model.set algorithmApproved: false
				@csc.render()
				expect(@csc.$('.bv_thumbnail').hasClass('algorithmNotApproved')).toBeTruthy()
				expect(@csc.$('.bv_thumbnail').hasClass('algorithmApproved')).toBeFalsy()
		xdescribe "user approved display", ->
			#TODO these tests don't work, but implimentation does
			it "should show thumbs up when user approved", ->
				console.log @csc.$('.bv_thumbsUp')
				expect(@csc.$('.bv_thumbsUp')).toBeVisible()
				expect(@csc.$('.bv_thumbsDown')).toBeHidden()
			it "should show thumbs down when not user approved", ->
				@csc.model.set userApproved: false
				@csc.render()
				expect(@csc.$('.bv_thumbsDown')).toBeVisible()
				expect(@csc.$('.bv_thumbsUp')).toBeHidden()
			it "should hide thumbs up and thumbs down when no user input", ->
				@csc.model.set userApproved: null
				@csc.render()
				expect(@csc.$('.bv_thumbsUp')).toBeHidden()
				expect(@csc.$('.bv_thumbsDown')).toBeHidden()

	describe "Curve Summary List Controller tests", ->
		beforeEach ->
			@curves = new CurveList(window.curveCuratorTestJSON.curveCuratorThumbs.curves)
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
				expect(@cslc.$('.bv_curveSummary').length).toEqual 9
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
		describe "filtering", ->
			it "should only show sigmoid when requested", ->
				@cslc.filter 'sigmoid'
				expect(@cslc.$('.bv_curveSummary').length).toEqual 3
			it "should show all when requested", ->
				@cslc.filter 'sigmoid'
				@cslc.filter 'all'
				expect(@cslc.$('.bv_curveSummary').length).toEqual 9
		describe "sorting", ->
			it "should show the lowest EC50 when requested", ->
				@cslc.sort 'EC50', true
				expect(@cslc.$('.bv_curveSummary:eq(0) .bv_compoundCode').html()).toEqual "CMPD-0000009"
			it "should show the highest EC50 when requested", ->
				@cslc.sort 'EC50', false
				expect(@cslc.$('.bv_curveSummary:eq(0) .bv_compoundCode').html()).toEqual "CMPD-0000004"
			it "should show the first one when no sorting is requested", ->
				@cslc.sort 'none'
				expect(@cslc.$('.bv_curveSummary:eq(0) .bv_compoundCode').html()).toEqual "CMPD-0000008"

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
					mdl = new Curve(window.curveCuratorTestJSON.curveCuratorThumbs.curves[0])
					@cec.setModel(mdl)
					expect(@cec.$('.bv_shinyContainer').attr('src')).toContain "90807_AG-00000026"

		describe "when created with populated model", ->
			beforeEach ->
				@curve = new Curve(window.curveCuratorTestJSON.curveCuratorThumbs.curves[0])
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
		describe "should initialize and render sub controllers", ->
			beforeEach ->
				runs ->
					@ccc.getCurvesFromExperimentCode("EXPT-00000018")
				waitsFor ->
					@ccc.model.get('curves').length > 0
			describe "post fetch display", ->
				it "should show the curve summary list", ->
					runs ->
						expect(@ccc.$('.bv_curveSummary').length).toBeGreaterThan 0
				it "should select the first curve in the list", ->
					runs ->
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeTruthy()
				it "should show the curve editor", ->
					runs ->
						expect(@ccc.$('.bv_shinyContainer').length).toBeGreaterThan 0
			describe "sort option select display", ->
				it "sortOption select should populate with options", ->
					runs ->
						expect(@ccc.$('.bv_sortBy option').length).toEqual 5
				it "sortOptions should make the first sortOption the default", ->
					runs ->
						expect(@ccc.$('.bv_sortBy option:eq(0)').html()).toEqual "Compound Name"
				it "should sort by ascending", ->
					runs ->
						@ccc.$('.bv_sortDirection_descending').prop("checked", false)
						@ccc.$('.bv_sortDirection_ascending').prop("checked", true)
						@ccc.$('.bv_sortDirection_ascending').click()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual "CMPD-0000001"
				it "should sort by descending", ->
					runs ->
						@ccc.$('.bv_sortBy').val 'EC50'
						@ccc.$('.bv_sortDirection_descending').prop("checked", true)
						@ccc.$('.bv_sortDirection_ascending').prop("checked", false)
						@ccc.$('.bv_sortDirection_descending').click()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual "CMPD-0000004"
				it "should update sort when ascending/descending is changed", ->
					runs ->
						@ccc.$('.bv_sortBy').val 'EC50'
						@ccc.$('.bv_sortBy').change()
						@ccc.$('.bv_sortDirection_descending').prop("checked", true)
						@ccc.$('.bv_sortDirection_ascending').prop("checked", false)
						@ccc.$('.bv_sortDirection_descending').click()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual "CMPD-0000004"
						@ccc.$('.bv_sortDirection_ascending').prop("checked", true)
						@ccc.$('.bv_sortDirection_descending').prop("checked", false)
						@ccc.$('.bv_sortDirection_ascending').click()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual "CMPD-0000009"
				it "should add the 'none' option if no sortBy options are received from the server", ->
					runs ->
						@ccc.model.set sortOptions: new Backbone.Collection()
						@ccc.render()
						expect(@ccc.$('.bv_sortBy').val()).toEqual "none"
				it "should disable sortDirection radio buttons if 'none' sortBy option is selected", ->
					runs ->
						@ccc.model.set sortOptions: new Backbone.Collection()
						@ccc.render()
						expect(@ccc.$('.bv_sortBy').val()).toEqual "none"
						expect(@ccc.$(".bv_sortDirection_ascending").prop("disabled")).toEqual true
						expect(@ccc.$(".bv_sortDirection_descending").prop("disabled")).toEqual true
			describe "filter option select display", ->
				it "filterOption select should populate with options", ->
					runs ->
						expect(@ccc.$('.bv_filterBy option').length).toEqual 4
				it "sortOption select should make first option all", ->
					runs ->
						expect(@ccc.$('.bv_filterBy option:eq(0)').html()).toEqual "Show All"
				it "should only show sigmoid thumbnails when sigmoid selected", ->
					runs ->
						@ccc.$('.bv_filterBy').val 'sigmoid'
						@ccc.$('.bv_filterBy').change()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary').length).toEqual 3

			describe "When new thumbnail selected", ->
				beforeEach ->
					runs ->
						@ccc.$('.bv_curveSummaries .bv_curveSummary').eq(0).click()
				it "should set the curve editor iframe src", ->
					runs ->
						expect(@ccc.$('.bv_shinyContainer').attr('src')).toContain "126907_AG-00000236"

#TODO add sample attributes SSE, SST, R^2, EC50 to thumb stubs
#TODO add ascending/descending controls for filter
#TODO implement sort
#TODO stub curation/refit service. First stube new service to get curve details refactor to fetch full curve from other service
#TODO implement curation panel