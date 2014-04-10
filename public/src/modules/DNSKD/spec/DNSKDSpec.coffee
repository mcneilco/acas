beforeEach ->
	@fixture = $("#fixture")

afterEach ->
	$("#fixture").remove()
	$("body").append '<div id="fixture"></div>'

describe "DNS KD Module Testing", ->
	describe 'DNSKDPrimaryScreenAnalysisParameters Controller', ->
		#This will just display any paramteters progated from the Protocol, it is not interactive
		describe 'when instantiated', ->
			beforeEach ->
				@psapc = new DNSKDPrimaryScreenAnalysisParametersController
					model: new Backbone.Model()
					el: $('#fixture')
				@psapc.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@psapc).toBeDefined()
				it 'should load a template', ->
					expect(@psapc.$('.bv_autofillSection').length).toEqual 1
			describe "render existing parameters", ->
				it 'should show a non-parameter', ->
					expect(@psapc.$('.bv_nothingToSeeHere').html()).toContain "No"


	describe "DNS KD Upload and Run Primary Analysis Controller testing", ->
		beforeEach ->
			@exp = new PrimaryScreenExperiment()
			@uarpac = new DNSKDUploadAndRunPrimaryAnalsysisController
				el: $('#fixture')
				paramsFromExperiment:	@exp.getAnalysisParameters()
			@uarpac.render()

		describe "Basic loading", ->
			it "Class should exist", ->
				expect(@uarpac).toBeDefined()
			it "Should load the template", ->
				expect(@uarpac.$('.bv_parseFile').length).toNotEqual 0

	describe "DNS KD Primary Screen Experiment Controller testing", ->
		describe "basic plumbing checks with new experiment", ->
			beforeEach ->
				runs ->
					@psec = new DNSKDPrimaryScreenExperimentController
						model: new PrimaryScreenExperiment()
						el: $('#fixture')
					@psec.render()
				waitsFor ->
					@psec.$('.bv_protocolCode option').length > 0
				, 500
			describe "Basic loading", ->
				it "Class should exist", ->
					runs ->
						expect(@psec).toBeDefined()
				it "Should load the template", ->
					runs ->
						expect(@psec.$('.bv_experimentBase').length).toNotEqual 0
				it "Should show protocol options for KD", ->
					runs ->
						expect(@psec.$('.bv_protocolCode option:eq(1)').html()).toContain "KD"


