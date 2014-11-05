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
		describe "basic plumbing tests", ->
			it "should have model defined", ->
				expect(CurveList).toBeDefined()
		describe "making category list", ->
			it "should return a list of categories", ->
				categories = @curveList.getCategories()
				expect(categories.length).toEqual 5
				expect(categories instanceof Backbone.Collection).toBeTruthy()
		describe "getting curve by curveid", ->
			it "should return a curve", ->
				curve = @curveList.getCurveByID("AG-00344446_1680")
				expect(curve instanceof Curve)
		describe "getting curve index by curveid", ->
			it "should return a curve", ->
				curveIndex = @curveList.getIndexByCurveID("AG-00344446_1680")
				expect(curveIndex).toEqual 8
		describe "updating a curve summary", ->
			it "should update curve summary", ->
				originalCurve = @curveList.models[0]
				oldCurveID = originalCurve.get 'curveid'
				newCurveID = originalCurve.get 'curveid' + " test"
				dirty = !originalCurve.get 'dirty'
				category = originalCurve.get 'category' + " test"
				flagUser = originalCurve.get 'flagUser' + " test"
				flagAlgorithm = originalCurve.get 'flagAlgorithm' + " test"
				@curveList.updateCurveSummary(oldCurveID,newCurveID,dirty,category,flagUser,flagAlgorithm)
				updatedCurve = @curveList.models[0]
				expect(updatedCurve.get 'curveid').toEqual(newCurveID)
				expect(updatedCurve.get 'dirty').toEqual(dirty)
				expect(updatedCurve.get 'category').toEqual(category)
				expect(updatedCurve.get 'flagUser').toEqual(flagUser)
				expect(updatedCurve.get 'flagAlgorithm').toEqual(flagAlgorithm)
		describe "updating dirty flag", ->
			it "should update dirty flag", ->
				originalCurve = @curveList.models[0]
				dirty = !originalCurve.get 'dirty'
				@curveList.updateDirtyFlag(originalCurve.get('curveid'), dirty)
				updatedCurve = @curveList.models[0]
				expect(updatedCurve.get 'dirty').toEqual(dirty)
		describe "updating flag user", ->
			it "should update flag user", ->
				originalCurve = @curveList.models[0]
				flagUser = originalCurve.get 'flagUser' + " test"
				@curveList.updateFlagUser(originalCurve.get('curveid'), flagUser)
				updatedCurve = @curveList.models[0]
				expect(updatedCurve.get 'flagUser').toEqual(flagUser)


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
				expect(@csc.$('.bv_thumbnail').attr('src')).toContain "AG-00344443_1680"
			it "should show the compound code", ->
				expect(@csc.$('.bv_compoundCode').html()).toEqual "CMPD-0000007-01A"
		describe "selection", ->
			it "should show selected when clicked", ->
				@csc.$('.bv_flagUser').click()
				@csc.$el.hasClass('selected')
		describe "algorithm approved display", ->
			it "should show not approved when algorithm flagged", ->
				@csc.model.set flagAlgorithm: "no fit"
				expect(@csc.$('.bv_fail')).toBeVisible()
				expect(@csc.$('.bv_pass')).toBeHidden()
			it "should show approved when algorithm not flagged ", ->
				@csc.model.set flagAlgorithm: "NA"
				@csc.render()
				expect(@csc.$('.bv_pass')).toBeVisible()
				expect(@csc.$('.bv_fail')).toBeHidden()
		describe "user flagged display", ->
			it "should show thumbs up when user approved", ->
				@csc.model.set flagUser: "approved"
				expect(@csc.$('.bv_thumbsUp')).toBeVisible()
				expect(@csc.$('.bv_thumbsDown')).toBeHidden()
			it "should show thumbs down when not user approved", ->
				@csc.model.set flagUser: "rejected"
				@csc.render()
				expect(@csc.$('.bv_thumbsDown')).toBeVisible()
				expect(@csc.$('.bv_thumbsUp')).toBeHidden()
			it "should hide thumbs up and thumbs down when no user input", ->
				@csc.model.set flagUser: "NA"
				@csc.render()
				expect(@csc.$('.bv_thumbsUp')).toBeHidden()
				expect(@csc.$('.bv_thumbsDown')).toBeHidden()
				expect(@csc.$('.bv_na')).toBeVisible()
		describe "user flagged curation", ->
			it "should show flag user menu moused over", ->
				@csc.$('.bv_flagUser').mouseover()
				expect(@csc.$('.bv_contextMenu')).toBeVisible()
			it "should hide flag user menu moused mouse leave", ->
				@csc.$('.bv_thumbnail').mouseover()
				expect(@csc.$('.bv_contextMenu')).toBeHidden()
			it "should hide flag user user mousewheels", ->
				@csc.$('.bv_flagUser').mouseover()
				expect(@csc.$('.bv_contextMenu')).toBeVisible()
				#some scroll
				e = jQuery.Event("mousewheel",delta: -650)
				# trigger an artificial DOMMouseScroll event with delta -650
				@csc.$('.bv_contextMenu').trigger e
				expect(@csc.$('.bv_contextMenu')).toBeHidden()
			it "should hide context menu when user mousewheels", ->
				@csc.$('.bv_flagUser').mouseover()
				expect(@csc.$('.bv_contextMenu')).toBeVisible()
				#some scroll
				e = jQuery.Event("mousewheel",delta: -650)
				# trigger an artificial DOMMouseScroll event with delta -650
				@csc.$('.bv_contextMenu').trigger e
				expect(@csc.$('.bv_contextMenu')).toBeHidden()
			it "should update user flag when user selects reject context menu item", ->
				@csc.model.set
					flagUser: 'NA'
				@csc.$('.bv_flagUser').mouseover()
				@csc.$('.bv_userReject').click()
				waitsFor =>
					@csc.model.get('flagUser') == "rejected"
				, 200
				runs =>
					expect(@csc.model.get('flagUser')).toEqual("rejected")
			it "should update user flag when user selects approve context menu item", ->
				@csc.model.set
					flagUser: 'NA'
				@csc.$('.bv_flagUser').mouseover()
				@csc.$('.bv_userApprove').click()
				waitsFor =>
					@csc.model.get('flagUser') == "approved"
				, 200
				runs =>
					expect(@csc.model.get('flagUser')).toEqual("approved")
			it "should update user flag when user selects NA context menu item", ->
				@csc.model.set
					flagUser: 'approved'
				@csc.$('.bv_flagUser').mouseover()
				@csc.$('.bv_userNA').click()
				waitsFor =>
					@csc.model.get('flagUser') == "NA"
				, 200
				runs =>
					expect(@csc.model.get('flagUser')).toEqual("NA")

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
				expect(@cslc.$('.bv_curveSummary').length).toEqual 16
		describe "user thumbnail selection", ->
			beforeEach ->
				@cslc.$('.bv_curveSummaries .bv_curveSummary .bv_group_thumbnail')[0].click()
			it "should highlight selected row", ->
				expect(@cslc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeTruthy()
			it "should select other row when other row is selected", ->
				@cslc.$('.bv_curveSummaries .bv_curveSummary .bv_group_thumbnail')[1].click()
				expect(@cslc.$('.bv_curveSummaries .bv_curveSummary').eq(1).hasClass('selected')).toBeTruthy()
			it "should clear selected when another row is selected", ->
				@cslc.$('.bv_curveSummaries .bv_curveSummary .bv_group_thumbnail')[1].click()
				expect(@cslc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeFalsy()
		describe "filtering", ->
			it "should only show Sigmoid when requested", ->
				@cslc.filter 'sigmoid'
				expect(@cslc.$('.bv_curveSummary').length).toEqual 10
			it "should show all when requested", ->
				@cslc.filter 'sigmoid'
				@cslc.filter 'all'
				expect(@cslc.$('.bv_curveSummary').length).toEqual 16
		describe "sorting", ->
			it "should show the lowest EC50 when requested", ->
				@cslc.sort 'EC50', true
				expect(@cslc.$('.bv_curveSummary:eq(0) .bv_compoundCode').html()).toEqual "CMPD-0000009-01A"
			it "should show the highest EC50 when requested", ->
				@cslc.sort 'EC50', false
				expect(@cslc.$('.bv_curveSummary:eq(0) .bv_compoundCode').html()).toEqual "CMPD-0000007-01A"
			it "should show the first one when no sorting is requested", ->
				@cslc.sort 'none'
				expect(@cslc.$('.bv_curveSummary:eq(0) .bv_compoundCode').html()).toEqual "CMPD-0000007-01A"

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
					expect(@cec).toBeDefined()
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
						expect(@cec.$('.bv_fitSummary').html()).toContain "Model&nbsp;fitted"
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
				describe "when a curve fails to update from service", ->
					it "should show an error", ->
					describe "editing curve parameters should update the model", ->
					it "should update curve parameters if the max value is changed", ->
						@cec.$('.bv_max_value').val 200
						@cec.$('.bv_max_value').change()
						expect(@cec.model.get('fitSettings').get('max').get('value')).toEqual 200

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
						expect(@ccc.$('.bv_sortBy option').length).toEqual 7
				it "default sort option should be the first in the list from the server", ->
					runs ->
						expect(@ccc.$('.bv_sortBy option:eq(0)').html()).toEqual "Compound Code"
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual "CMPD-0000001-01A"
				it "should sort by ascending", ->
					runs ->
						@ccc.$('.bv_sortDirection_descending').prop("checked", false)
						@ccc.$('.bv_sortDirection_ascending').prop("checked", true)
						@ccc.$('.bv_sortDirection_ascending').click()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual "CMPD-0000001-01A"
				it "should sort by descending", ->
					runs ->
						@ccc.$('.bv_sortBy').val 'EC50'
						@ccc.$('.bv_sortDirection_descending').prop("checked", true)
						@ccc.$('.bv_sortDirection_ascending').prop("checked", false)
						@ccc.$('.bv_sortDirection_descending').click()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual "CMPD-0000007-01A"
				it "should update sort when ascending/descending is changed", ->
					runs ->
						@ccc.$('.bv_sortBy').val 'EC50'
						@ccc.$('.bv_sortBy').change()
						@ccc.$('.bv_sortDirection_descending').prop("checked", false)
						@ccc.$('.bv_sortDirection_ascending').prop("checked", true)
						@ccc.$('.bv_sortDirection_ascending').click()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual "CMPD-0000009-01A"
						@ccc.$('.bv_sortDirection_descending').prop("checked", true)
						@ccc.$('.bv_sortDirection_ascending').prop("checked", false)
						@ccc.$('.bv_sortDirection_descending').click()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual "CMPD-0000007-01A"
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
						expect(@ccc.$('.bv_filterBy option').length).toEqual 6
				it "sortOption select should make first option all", ->
					runs ->
						expect(@ccc.$('.bv_filterBy option:eq(0)').html()).toEqual "Show All"
				it "should only show sigmoid thumbnails when sigmoid selected", ->
					runs ->
						@ccc.$('.bv_filterBy').val 'sigmoid'
						@ccc.$('.bv_filterBy').change()
						expect(@ccc.$('.bv_curveSummaries .bv_curveSummary').length).toEqual 10
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
		describe "should show error when experiment code does not exist", ->
			beforeEach ->
				runs ->
					@ccc.getCurvesFromExperimentCode("EXPT-ERROR")
				waits 500
			it "should show error message", ->
				expect(@ccc.$('.bv_badExperimentCode')).toBeVisible()
		describe "should show error when curve id service returns no results", ->
			beforeEach ->
				runs ->
					@ccc.getCurvesFromExperimentCode("EXPT-0000018","CURVE-ERROR")
				waits 500
			it "should show error message", ->
				expect(@ccc.$('.bv_badCurveID')).toBeVisible()
