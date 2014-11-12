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
	describe "ProtocolRowSummaryController testing", ->
		beforeEach ->
			@prsc = new ProtocolRowSummaryController
				model: new Protocol window.protocolServiceTestJSON.fullSavedProtocol
				el: @fixture
			@prsc.render()
		describe "Basic existence and rendering", ->
			it "should be defined", ->
				expect(@prsc).toBeDefined()
			it "should render the template", ->
				expect(@prsc.$('.bv_protocolName').length).toEqual 1
		describe "It should show protocol values", ->
			it "should show the protocol name", ->
				expect(@prsc.$('.bv_protocolName').html()).toEqual "FLIPR target A biochemical"
			it "should show the protocol code", ->
				expect(@prsc.$('.bv_protocolCode').html()).toEqual "PROT-00000001"
			it "should show the protocol kind", ->
				expect(@prsc.$('.bv_protocolKind').html()).toEqual "default"
			it "should show the scientist", ->
				expect(@prsc.$('.bv_recordedBy').html()).toEqual "nxm7557"
			it "should show the status", ->
				expect(@prsc.$('.bv_status').html()).toEqual "created"
			it "should show the assay stage", ->
				expect(@prsc.$('.bv_assayStage').html()).toEqual "assay development"
			it "should show the number of experiments", ->
				expect(@prsc.$('.bv_experimentCount').html()).toEqual "12"
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

	describe "ProtocolSummaryTableController", ->
		beforeEach ->
			@pstc = new ProtocolSummaryTableController
				collection: new ProtocolList [window.protocolServiceTestJSON.fullSavedProtocol]
				el: @fixture
			@pstc.render()
		describe "Basic existence and rendering", ->
			it "should be defined", ->
				expect(@pstc).toBeDefined()
			it "should render the template", ->
				expect(@pstc.$('tbody').length).toEqual 1
		describe "It should render a summary row for each protocol record", ->
			it "should show the protocol name", ->
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

			it "should display a message alerting the user that no matching protocols were found if the search returns no protocols", ->
				@searchReturned = false
				@searchController = new ProtocolSimpleSearchController
					model: new ProtocolSearch()
					el: @fixture
				@searchController.on "searchReturned", =>
					@searchReturned = true
				$(".bv_ProtocolSearchTerm").val "no-match"
				runs =>
					@searchController.doSearch("no-match")
				#$(".bv_doSearch").click()
				waitsFor ->
					@searchReturned
				, 300
				runs ->
					expect($(".bv_noMatchesFoundMessage").hasClass("hide")).toBeFalsy()

	describe "ProtocolBrowserController tests", ->
		beforeEach ->
			@pbc = new ProtocolBrowserController
				el: @fixture
			@pbc.render()
		describe "Basic existence and rendering tests", ->
			it "should be defined", ->
				expect(ProtocolBrowserController).toBeDefined()
			it "should have a search controller div", ->
				expect(@pbc.$('.bv_protocolSearchController').length).toEqual 1
		describe "Startup", ->
			it "should initialize the search controller", ->
				expect(@pbc.$('.bv_protocolSearchTerm').length).toEqual 1
				expect(@pbc.searchController).toBeDefined()
		describe "Search actions", ->
			beforeEach ->
				$(".bv_ProtocolSearchTerm").val "protocol"
				runs =>
					@pbc.searchController.doSearch("protocol")
			it "should show the protocol summary table after search is entered", ->
				expect($('tbody tr').length).toBeGreaterThan 0







