beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Dose Response Analysis Module Testing", ->
	describe "basic plumbing checks with new experiment", ->
		beforeEach ->
			@exp = new Experiment()
			@exp.copyProtocolAttributes new Protocol(window.protocolServiceTestJSON.fullSavedProtocol)
			@drac = new DoseResponseAnalysisController
				model: @exp
				el: $('#fixture')
			@drac.render()
		describe "Basic loading", ->
			it "Class should exist", ->
				expect(@drac).toBeDefined()
			it "Should load the template", ->
				expect(@drac.$('.bv_fixCurveMin').length).toNotEqual 0
				expect(@drac.$('.bv_fixCurveMax').length).toNotEqual 0
		describe "should populate fields", ->
			it "should show the curve min", ->
				expect(@drac.$('.bv_curveMin').val()).toEqual '0'
			it "should show the curve max", ->
				expect(@drac.$('.bv_curveMax').val()).toEqual '100'
		describe "parameter editing", ->
			it "should update the model when the curve min is changed", ->
				@drac.$('.bv_curveMin').val('7.0')
				@drac.$('.bv_curveMin').change()
				value = @drac.model.get('lsStates').getStateValueByTypeAndKind "metadata", "experiment analysis parameters", "numericValue", "curve min"
				expect(value.get('numericValue')).toEqual 7.0
		describe "parameter editing", ->
			it "should update the model when the curve max is changed", ->
				@drac.$('.bv_curveMax').val('100.0')
				@drac.$('.bv_curveMax').change()
				value = @drac.model.get('lsStates').getStateValueByTypeAndKind "metadata", "experiment analysis parameters", "numericValue", "curve max"
				expect(value.get('numericValue')).toEqual 100.0


