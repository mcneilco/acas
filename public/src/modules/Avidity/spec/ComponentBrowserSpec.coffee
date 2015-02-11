beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Component Browser module testing", ->
	describe "Component Search Model controller", ->
		beforeEach ->
			@psm = new ComponentSearch()
		describe "Basic existence tests", ->
			it "should be defined", ->
				expect(@psm).toBeDefined()
			it "should have defaults", ->
				expect(@psm.get('componentCode')).toBeNull()
	describe "Component Simple Search Controller", ->
		describe "when instantiated", ->
			beforeEach ->
				@pssc = new ComponentSimpleSearchController
					model: new ComponentSearch()
					el: $('#fixture')
				@pssc.render()
			describe "basic existance tests", ->
				it "should exist", ->
					expect(@pssc).toBeDefined()
				it "should load a template", ->
					expect(@pssc.$('.bv_componentSearchTerm').length).toEqual 1
	describe "ComponentRowSummaryController testing", ->
		beforeEach ->
			@prsc = new ComponentRowSummaryController
				model: new CationicBlockBatch window.componentBrowserServiceTestJSON.cationicBlockBatch
				el: @fixture
			@prsc.render()
		describe "Basic existence and rendering", ->
			it "should be defined", ->
				expect(@prsc).toBeDefined()
			it "should render the template", ->
				expect(@prsc.$('.bv_componentName').length).toEqual 1
		describe "It should show component values", ->
			it "should show the component name", ->
				expect(@prsc.$('.bv_componentName').html()).toEqual "cMAP10"
			it "should show the component code", ->
				expect(@prsc.$('.bv_componentCode').html()).toEqual "CB000001"
			it "should show the component kind", ->
				expect(@prsc.$('.bv_componentKind').html()).toEqual "cationic block"
			it "should show the scientist", ->
				expect(@prsc.$('.bv_scientist').html()).toEqual "2012-07-12"
			it "should show the completion date", ->
				expect(@prsc.$('.bv_completionDate').html()).toEqual "john"
		describe "basic behavior", ->
			it "should trigger gotClick when the row is clicked", ->
				@clickTriggered = false
				@prsc.on 'gotClick', =>
					@clickTriggered = true
				runs ->
					$(@prsc.el).click()
				waitsFor ->
					@clickTriggered
				, 300
				runs ->
					expect(@clickTriggered).toBeTruthy()

	describe "ComponentSummaryTableController", ->
		beforeEach ->
			@pstc = new ComponentSummaryTableController
				collection: new ComponentList [window.componentBrowserServiceTestJSON.cationicBlockBatch]
				el: @fixture
			@pstc.render()
		describe "Basic existence and rendering", ->
			it "should be defined", ->
				expect(@pstc).toBeDefined()
			it "should render the template", ->
				expect(@pstc.$('tbody').length).toEqual 1
		describe "It should render a summary row for each component record", ->
			it "should show the component name", ->
				expect(@pstc.$('tbody tr').length).toBeGreaterThan 0
		describe "basic behavior", ->
			it "should listen for gotClick row event and trigger selectedRowUpdated event", ->
				@clickTriggered = false
				@pstc.on 'selectedRowUpdated', =>
					@clickTriggered = true
				runs ->
					@pstc.$("tr").click()
				waitsFor ->
					@clickTriggered
				, 300
				runs ->
					expect(@clickTriggered).toBeTruthy()

			it "should display a message alerting the user that no matching components were found if the search returns no components", ->
				@searchReturned = false
				@searchController = new ComponentSimpleSearchController
					model: new ComponentSearch()
					el: @fixture
				@searchController.on "searchReturned", =>
					@searchReturned = true
				$(".bv_ComponentSearchTerm").val "no-match"
				runs =>
					@searchController.doSearch("no-match")
				#$(".bv_doSearch").click()
				waitsFor ->
					@searchReturned
				, 300
				runs ->
					expect($(".bv_noMatchesFoundMessage").hasClass("hide")).toBeFalsy()

	describe "ComponentBrowserController tests", ->
		beforeEach ->
			@pbc = new ComponentBrowserController
				el: @fixture
			@pbc.render()
		describe "Basic existence and rendering tests", ->
			it "should be defined", ->
				expect(ComponentBrowserController).toBeDefined()
			it "should have a search controller div", ->
				expect(@pbc.$('.bv_componentSearchController').length).toEqual 1
		describe "Startup", ->
			it "should initialize the search controller", ->
				expect(@pbc.$('.bv_componentSearchTerm').length).toEqual 1
				expect(@pbc.searchController).toBeDefined()
		describe "Search actions", ->
			beforeEach ->
				$(".bv_ComponentSearchTerm").val "component"
				runs =>
					@pbc.searchController.doSearch("component")
			it "should show the component summary table after search is entered", ->
				expect($('tbody tr').length).toBeGreaterThan 0






