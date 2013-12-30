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
				expect(@esc.$('.bv_protocolCode').length).toEqual 1
		describe "After render", ->
			it "should populate the protocol select", ->
				waitsFor ->
					@esc.$('.bv_protocolCode option').length > 0
				, 1000
				runs ->
					expect(@esc.$('.bv_protocolCode').val()).toEqual "any"
		describe "Model updates", ->
			beforeEach ->
				waitsFor ->
					@esc.$('.bv_protocolCode option').length > 0
				, 1000
			it "should update the protocol val", ->
				runs ->
					console.log @esc.$('.bv_protocolCode')
					@esc.$('.bv_protocolCode').val "PROT-00000008"
					@esc.$('.bv_protocolCode').change()
					expect(@esc.model.get('protocolCode')).toEqual "PROT-00000008"
			it "should update the expt code val", ->
				@esc.$('.bv_experimentCode').val " EXPT-00000003 "
				@esc.$('.bv_experimentCode').change()
				expect(@esc.model.get('experimentCode')).toEqual "EXPT-00000003"
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

	xdescribe "ExperimentRowSummaryController testing", ->
		beforeEach ->
			@ersc = new ExperimentRowSummaryController
				model: new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
				el: @fixture
			@ersc.render()
		describe "Basic existance and rendering", ->
			it "should be denifed", ->
				expect(@ersc).toBeDefined()
			it "should render the template", ->
				expect(@ersc.$('.bv_experimentName').length).toEqual 1
		describe "It should show experiment values", ->
			it "should show the experiment name", ->
				expect(@ersc.$('.bv_experimentName').html()).toEqual "Test Experiment 1"
			it "should show the experiment code", ->
				expect(@ersc.$('.bv_experimentCode').html()).toEqual "EXPT-00000001"
			it "should show the protocolName", ->
				expect(@ersc.$('.bv_protocolName').html()).toEqual "protocol name"
			it "should show the scientist", ->
				expect(@ersc.$('.bv_recordedBy').html()).toEqual "jmcneil"

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
				expect(@ebc.$('.bv_find').length).toEqual 1


#TODO add search field that filters protocols in protocol select
#TODO make protocol select a multi-select and search on list of protocols