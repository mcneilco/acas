beforeEach ->
	@fixture = $("#fixture")

afterEach ->
	$("#fixture").remove()
	$("body").append '<div id="fixture"></div>'

describe "Dose Response Fit Module Testing", ->
	describe 'DoseResponseDataParserController', ->
		beforeEach ->
			@drdpc = new DoseResponseDataParserController
				el: $('#fixture')
			@drdpc.render()
		describe "Basic existance", ->
			it "should be defined", ->
				expect(@drdpc).toBeDefined()
			it "should load", ->
				expect(@drdpc.$('.bv_parseFile').length).toEqual 1

	describe 'DoseResponseFitController', ->
		beforeEach ->
			@drfc = new DoseResponseFitController
				experimentCode: "EXPT-0000012"
				el: $('#fixture')
			@drfc.render()
		describe "Basic existance", ->
			it "should be defined", ->
				expect(@drfc).toBeDefined()


	describe 'DoseResponseFitWorkflowController', ->
		beforeEach ->
			@drfwc = new DoseResponseFitWorkflowController
				el: $('#fixture')
			@drfwc.render()
		describe "Basic existance", ->
			it "should be defined", ->
				expect(@drfwc).toBeDefined()
			it "should load the template", ->
				expect(@drfwc.$('.bv_dataParser').length).toEqual 1
			it "should load the parser", ->
				expect(@drfwc.$('.bv_parseFile').length).toEqual 1

