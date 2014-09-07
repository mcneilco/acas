beforeEach ->
	#$("#fixture") = $.clone($("#fixture").get(0))
	#$("#fixture") = $("#fixture")

afterEach ->
	$("#fixture").remove()
	$("body").append '<div id = "#fixture"></div>'

describe "Curve Curator Module testing", ->
	describe "Curve Model testing", ->
		beforeEach ->
			@curve = new Curve()
		describe "basic plumbing tests", ->
			it "should have model defined", ->
				expect(Curve).toBeDefined()

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
				el: $("#fixture")
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
				expect(@csc.$('.bv_pass')).toBeVisible()
				expect(@csc.$('.bv_fail')).toBeHidden()
			it "should show not approved when algorithm not approved", ->
				@csc.model.set algorithmApproved: false
				@csc.render()
				expect(@csc.$('.bv_pass')).toBeHidden()
				expect(@csc.$('.bv_fail')).toBeVisible()
		xdescribe "user approved display", ->
			#TODO these tests don't work, but implimentation does
			it "should show thumbs up when user approved", ->
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
				el: $("#fixture")
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
			it "should only show Sigmoid when requested", ->
				@cslc.filter 'Sigmoid'
				expect(@cslc.$('.bv_curveSummary').length).toEqual 3
			it "should show all when requested", ->
				@cslc.filter 'Sigmoid'
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

	describe "Dose Response Plot Controller tests", ->
		beforeEach ->
			@drpc = new DoseResponsePlotController
				el: $("#fixture")
			@drpc.render()
		describe "basic plumbing", ->
			it "should have controller defined", ->
				expect(DoseResponsePlotController).toBeDefined()
			it "should show plot details not loaded when model is missing", ->
				expect($(@drpc.el).html()).toContain "Plot data not loaded"
		describe "when a model is set", ->
			beforeEach ->
				@drpc = new DoseResponsePlotController
					model: new Backbone.Model window.curveCuratorTestJSON.curveDetail.plotData
					el: $("#fixture")
				@drpc.render()
			describe "basic plot rendering", ->
				it "should load the template", ->
					expect(@drpc.$('.bv_plotWindow').length).toEqual 1
				it "should set the div id to a unique cid", ->
					expect(@drpc.$('.bv_plotWindow').attr('id')).toEqual "bvID_plotWindow_" + @drpc.model.cid
				it "should have rendered an svg", ->
					expect(@drpc.$('#bvID_plotWindow_' + @drpc.model.cid)[0].innerHTML).toContain('<svg')
					window.blah = @drpc.$('#bvID_plotWindow_' + @drpc.model.cid)
				it "should have a populated point list", ->
					expect(@drpc.pointList.length).toBeGreaterThan(0)

	describe "Dose Response Knockout Panel Controller", ->
		beforeEach ->
			@kpc = new DoseResponseKnockoutPanelController
				el: $("#fixture")
			@kpc.render()
		describe "basic plumbing", ->
			it "should have controller defined", ->
				expect(DoseResponseKnockoutPanelController).toBeDefined()
			it "should setup a reason pick list list", ->
				expect(@kpc.knockoutReasonList).toBeDefined
			it "should have a set of pick list models", ->
				expect(@kpc.knockoutReasonList.models.length) > 1
		describe "should trigger event when ok button is clicked and return a reason", ->
			beforeEach ->
				runs ->
					@kpc.on 'reasonSelected', (reason) =>
						@reasonSelected = reason
					@kpc.show()
				waitsFor =>
					@kpc.$("option").length > 0
			it "should return a reason when the ok button is clicked", ->
				runs ->
					$('.bv_doseResponseKnockoutPanelOKBtn').click()
				,1000
				waitsFor =>
					@reasonSelected?
				,1000
				runs =>
					expect(@reasonSelected).toEqual 'outlier'
			it "should return a different value if the options is changed", ->
				runs ->
					@kpc.$('.bv_dataDictPicklist').val "crashout"
					@kpc.$('.bv_doseResponseKnockoutPanelOKBtn').click()
				,1000
				waitsFor =>
					@reasonSelected?
				,1000
				runs =>
					expect(@reasonSelected).toEqual 'crashout'

	describe "Curve Editor Controller tests", ->
			beforeEach ->
				@cec = new CurveEditorController
					el: $("#fixture")
				@cec.render()
			describe "basic plumbing", ->
				it "should have controller defined", ->
					expect(CurveEditorController).toBeDefined()
				it "should should show no curve selected when model is missing", ->
					expect($(@cec.el).html()).toContain "No curve selected"
			describe "when a model is set", ->
				beforeEach ->
					@curve = new CurveDetail(window.curveCuratorTestJSON.curveDetail)
					@cec = new CurveEditorController
						el: $("#fixture")
					@cec.setModel @curve
				describe "basic result rendering", ->
					it "should load template", ->
						expect(@cec.$('.bv_reportedValues').length).toEqual 1
					it "should show the reported values", ->
						expect(@cec.$('.bv_reportedValues').html()).toContain "slope"
					it "should show the fitSummary", ->
						expect(@cec.$('.bv_fitSummary').html()).toContain "Model fitted"
					it "should show the parameterStdErrors", ->
						expect(@cec.$('.bv_parameterStdErrors').html()).toContain "stdErr"
					it "should show the curveErrors", ->
						expect(@cec.$('.bv_curveErrors').html()).toContain "SSE"
					it "should show the category", ->
						expect(@cec.$('.bv_category').html()).toContain "sigmoid"
				describe "dose response parameter controller", ->
					it "should have a populated dose response parameter controller", ->
						expect(@cec.$('.bv_analysisParameterForm')).toBeDefined()
					it 'should set the max_value to the number', ->
						expect(@cec.$(".bv_max_value").val()).toEqual "101"
					it 'should show the inverse agonist mode', ->
						expect(@cec.$('.bv_inverseAgonistMode').attr('checked')).toEqual 'checked'
					it 'should show parameter title as Fit Criteria', ->
						expect(@cec.$('.bv_formTitle').html()).toEqual 'Fit Criteria'
				describe "editing curve parameters should update the model", ->
					it "should update curve parameters if the max value is changed", ->
						@cec.$('.bv_max_value').val 200
						@cec.$('.bv_max_value').change()
						expect(@cec.model.get('fitSettings').get('max').get('value')).toEqual 200
				describe "dose response plot", ->
					it "should have a dose response plot controller", ->
						expect(@cec.$('.bv_plotWindow')).toBeDefined()
					it "should have a dose response plot controller", ->
						expect(@cec.$('.bv_plotWindow')).toBeDefined()


	describe "Curve Curator Controller tests", ->
		beforeEach ->
			@ccc = new CurveCuratorController
				el: $("#fixture")
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
				waits 200
			describe "post fetch display", ->
				it "should show the curve summary list", ->
					runs ->
						expect(@ccc.$('.bv_curveSummary').length).toBeGreaterThan 0
				it "should select the first curve in the list", ->
					runs ->
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeTruthy()
				it "should show the curve editor", ->
					waitsFor =>
						@ccc.$('.bv_reportedValues').length > 0
					, 500
					runs ->
						expect(@ccc.$('.bv_reportedValues').length).toBeGreaterThan 0
			describe "sort option select display", ->
				it "sortOption select should populate with options", ->
					runs ->
						expect(@ccc.$('.bv_sortBy option').length).toEqual 5
				it "default sort option should be the first in the list from the server", ->
					runs ->
						expect(@ccc.$('.bv_sortBy option:eq(0)').html()).toEqual "Compound Name"
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual "CMPD-0000001"
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
						waits 200
						expect(@ccc.$('.bv_sortBy').val()).toEqual "none"
				it "should disable sortDirection radio buttons if 'none' sortBy option is selected", ->
					runs ->
						@ccc.model.set sortOptions: new Backbone.Collection()
						@ccc.render()
						waits 200
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
				it "should only show Sigmoid thumbnails when Sigmoid selected", ->
					runs ->
						@ccc.$('.bv_filterBy').val 'Sigmoid'
						@ccc.$('.bv_filterBy').change()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary').length).toEqual 3
			describe "When new thumbnail selected", ->
				beforeEach ->
					runs ->
						@ccc.$('.bv_curveSummaries .bv_curveSummary').eq(0).click()
				it "should show the selected curve details", ->
					waitsFor =>
						@ccc.$('.bv_reportedValues').length > 0
					, 500
					waits 200
					runs ->
						expect(@ccc.$('.bv_reportedValues').html()).toContain "slope"
