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
					model: new ExperimentSearch()
					el: @fixture
				@esc.render()
		describe "Basic existence and rendering tests", ->
			it "should be defined", ->
				expect(ExperimentSearchController).toBeDefined()
			it "should have a protocol code select", ->
				expect(@esc.$('.bv_protocolKind').length).toEqual 1
		describe "After render", ->
			it "should populate the protocol select", ->
				waitsFor ->
					@esc.$('.bv_protocolKind option').length > 0
				, 1000
				runs ->
					expect(@esc.$('.bv_protocolKind').val()).toEqual "any"
		describe "Model updates", ->
			beforeEach ->
				waitsFor ->
					@esc.$('.bv_protocolKind option').length > 0
				, 1000
			it "should update the protocol name", ->
				runs ->
					console.log @esc.$('.bv_protocolKind')
					@esc.$('.bv_protocolName').val "PROT-00000008"
					@esc.$('.bv_protocolName').change()
					expect(@esc.model.get('protocolCode')).toEqual "PROT-00000008"
			it "should update the expt code val", ->
				@esc.$('.bv_experimentCode').val " EXPT-00000003 "
				@esc.$('.bv_experimentCode').change()
				expect(@esc.model.get('experimentCode')).toEqual "EXPT-00000003"
		describe "field behavior", ->
			describe "when any value is entered in the experiment code field", ->
				it "should disable the protocol kind and protocol name select lists ", ->
					@esc.$(".bv_experimentCode").val "EXPT-0000000"
					keyup = $.Event('keyup')
					@esc.$('.bv_experimentCode').trigger keyup
					expect(@esc.$(".bv_protocolKind").prop("disabled")).toBeTruthy()
					expect(@esc.$(".bv_protocolName").prop("disabled")).toBeTruthy()

			describe "when the experiment code field is empty", ->
				it "should enable the protocol kind and protocol name select lists ", ->
					@esc.$(".bv_experimentCode").val "EXPT-0000000"
					keyup = $.Event('keyup')
					@esc.$('.bv_experimentCode').trigger keyup
					expect(@esc.$(".bv_protocolKind").prop("disabled")).toBeTruthy()
					expect(@esc.$(".bv_protocolName").prop("disabled")).toBeTruthy()
					@esc.$(".bv_experimentCode").val ""
					keyup = $.Event('keyup')
					@esc.$('.bv_experimentCode').trigger keyup
					expect(@esc.$(".bv_protocolKind").prop("disabled")).toBeFalsy()
					expect(@esc.$(".bv_protocolName").prop("disabled")).toBeFalsy()

		describe "search trigger", ->
			it "should trigger find when find pushed", ->
				@findTriggered = false
				@esc.on 'find', =>
					@findTriggered = true
				runs ->
					@esc.$('.bv_find').click()
				waitsFor ->
					@findTriggered
				, 300
				runs ->
					expect(@findTriggered).toBeTruthy()

	describe "ExperimentRowSummaryController testing", ->
		beforeEach ->
			@ersc = new ExperimentRowSummaryController
				model: new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
				el: @fixture
			@ersc.render()
		xdescribe "Basic existence and rendering", ->
			it "should be defined", ->
				expect(@ersc).toBeDefined()
			it "should render the template", ->
				expect(@ersc.$('.bv_experimentName').length).toEqual 1
		xdescribe "It should show experiment values", ->
			it "should show the experiment name", ->
				expect(@ersc.$('.bv_experimentName').html()).toEqual "Test Experiment 1"
			it "should show the experiment code", ->
				expect(@ersc.$('.bv_experimentCode').html()).toEqual "EXPT-00000001"
			it "should show the protocolName", ->
				expect(@ersc.$('.bv_protocolName').html()).toEqual "protocol name"
			it "should show the scientist", ->
				expect(@ersc.$('.bv_recordedBy').html()).toEqual "jmcneil"
		describe "basic behavior", ->
			it "should trigger gotClick when the row is clicked", ->
				@clickTriggered = false
				@ersc.on 'gotClick', =>
					@clickTriggered = true
				runs ->
					$(@ersc.el).click()
				waitsFor ->
					@clickTriggered
				, 300
				runs ->
					expect(@clickTriggered).toBeTruthy()

	describe "ExperimentSummaryTableController", ->
		beforeEach ->
			@estc = new ExperimentSummaryTableController
				collection: new ExperimentList [window.experimentServiceTestJSON.fullExperimentFromServer]
				el: @fixture
			@estc.render()
		describe "Basic existence and rendering", ->
			it "should be defined", ->
				expect(@estc).toBeDefined()
			it "should render the template", ->
				expect(@estc.$('tbody').length).toEqual 1
		describe "It should render a summary row for each experiment record", ->
			it "should show the experiment name", ->
				expect(@estc.$('tbody tr').length).toBeGreaterThan 0
		describe "basic behavior", ->
			it "should listen for gotClick row event and trigger selectedRowUpdated event", ->
				@clickTriggered = false
				@estc.on 'selectedRowUpdated', =>
					@clickTriggered = true
				runs ->
					@estc.$("tr").click()
				waitsFor ->
					@clickTriggered
				, 300
				runs ->
					expect(@clickTriggered).toBeTruthy()

			it "should display a message alerting the user that no matching experiments were found if the search returns no experiments", ->
				estc = new ExperimentBrowserController()
				$("#fixture").html estc.render().el

				estc.setupExperimentSummaryTable([])
				#waits(1000)
				console.log '$(".bv_noMatchesFoundMessage").html()'
				console.log $(".bv_noMatchesFoundMessage").html()
				expect($(".bv_noMatchesFoundMessage").hasClass("hide")).toBeFalsy()
				expect($(".bv_noMatchesFoundMessage").html()).toContain("No Matching Experiments Found")


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
		describe "Startup", ->
			it "should initialize the search controller", ->
				expect(@ebc.$('.bv_doSearch').length).toEqual 1

	describe "Experiment Browser Services", ->
		beforeEach ->
			@waitForServiceReturn = ->
				typeof @serviceReturn != 'undefined'

		describe "Generic Search Node Proxy", ->
			it "should exist and return an OK status", ->
				searchTerm = "some experiment"
				runs ->
					$.ajax
						type: 'GET'
						url: "/api/experiments/genericSearch/#{searchTerm}"
						dataType: "json"
						data:
							testMode: true
							fullObject: false
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null

				waitsFor( @waitForServiceReturn, 'service did not return', 10000)
				runs ->
					expect(@serviceReturn).toBeTruthy()

		describe "Edit Experiment redirect proxy", ->
			it "should exist and return an OK status", ->
				experimentCodeName = "EXPT-00000001"
				runs ->
					$.ajax
						type: 'GET'
						url: "/api/experiments/edit/#{experimentCodeName}"
						dataType: "json"
						data:
							testMode: true
							fullObject: false
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null

				waitsFor( @waitForServiceReturn, 'service did not return', 10000)
				runs ->
					expect(@serviceReturn).toBeTruthy()

#TODO add search field that filters protocols in protocol select
#TODO make protocol select a multi-select and search on list of protocols