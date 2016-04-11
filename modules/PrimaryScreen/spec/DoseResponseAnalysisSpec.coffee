beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Dose Response Analysis Module Testing", ->
	describe "Dose Response Analysis Parameter model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@drap = new DoseResponseAnalysisParameters()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@drap).toBeDefined()
				it "should have defaults", ->
					expect(@drap.get('smartMode')).toBeTruthy()
					expect(@drap.get('inactiveThreshold')).toEqual 20
					expect(@drap.get('theoreticalMax')).toEqual ""
					expect(@drap.get('inactiveThresholdMode')).toBeTruthy()
					expect(@drap.get('theoreticalMaxMode')).toBeFalsy()
					expect(@drap.get('inverseAgonistMode')).toBeFalsy()
					expect(@drap.get('max') instanceof Backbone.Model).toBeTruthy()
					expect(@drap.get('min') instanceof Backbone.Model).toBeTruthy()
					expect(@drap.get('slope') instanceof Backbone.Model).toBeTruthy()
					expect(@drap.get('max').get('limitType')).toEqual "none"
					expect(@drap.get('min').get('limitType')).toEqual "none"
					expect(@drap.get('slope').get('limitType')).toEqual "none"
			describe "variable logic", ->
				it "should set inactiveThresholdMode true if inactiveThreshold is set to a number and false otherwise", ->
					@drap.set 'inactiveThreshold': null
					expect(@drap.get 'inactiveThresholdMode').toBeFalsy()
					@drap.set 'inactiveThreshold': 22
					expect(@drap.get 'inactiveThresholdMode').toBeTruthy()
					@drap.set 'inactiveThreshold': NaN
					expect(@drap.get 'inactiveThresholdMode').toBeFalsy()
				it "should set theoreticalMaxMode true if theoreticalMax is set to a number and false otherwise", ->
					@drap.set 'theoreticalMax': null
					expect(@drap.get 'theoreticalMaxMode').toBeFalsy()
					@drap.set 'theoreticalMax': 22
					expect(@drap.get 'theoreticalMaxMode').toBeTruthy()
					@drap.set 'theoreticalMax': NaN
					expect(@drap.get 'theoreticalMaxMode').toBeFalsy()
		describe "model composite class tests", ->
			beforeEach ->
				@drap = new DoseResponseAnalysisParameters window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions
			it "should set objects to backbone models after they have been loaded", ->
				expect(@drap.get('max') instanceof Backbone.Model).toBeTruthy()
				expect(@drap.get('min') instanceof Backbone.Model).toBeTruthy()
				expect(@drap.get('slope') instanceof Backbone.Model).toBeTruthy()
		describe "model validation tests", ->
			beforeEach ->
				@drap = new DoseResponseAnalysisParameters window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions
			it "should be valid as initialized", ->
				expect(@drap.isValid()).toBeTruthy()
			it "should be invalid when min limitType is pin and the value is not a number", ->
				@drap.get('min').set limitType: "pin"
				@drap.get('min').set value: NaN
				expect(@drap.isValid()).toBeFalsy()
				filtErrors = _.filter(@drap.validationError, (err) ->
					err.attribute=='min_value'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when min limitType is limit and the value is not a number", ->
				@drap.get('min').set limitType: "limit"
				@drap.get('min').set value: NaN
				expect(@drap.isValid()).toBeFalsy()
				filtErrors = _.filter(@drap.validationError, (err) ->
					err.attribute=='min_value'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when max limitType is pin and the value is not a number", ->
				@drap.get('max').set limitType: "pin"
				@drap.get('max').set value: NaN
				expect(@drap.isValid()).toBeFalsy()
				filtErrors = _.filter(@drap.validationError, (err) ->
					err.attribute=='max_value'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when max limitType is limit and the value is not a number", ->
				@drap.get('max').set limitType: "limit"
				@drap.get('max').set value: NaN
				expect(@drap.isValid()).toBeFalsy()
				filtErrors = _.filter(@drap.validationError, (err) ->
					err.attribute=='max_value'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when slope limitType is pin and the value is not a number", ->
				@drap.get('slope').set limitType: "pin"
				@drap.get('slope').set value: NaN
				expect(@drap.isValid()).toBeFalsy()
				filtErrors = _.filter(@drap.validationError, (err) ->
					err.attribute=='slope_value'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when slope limitType is limit and the value is not a number", ->
				@drap.get('slope').set limitType: "limit"
				@drap.get('slope').set value: NaN
				expect(@drap.isValid()).toBeFalsy()
				filtErrors = _.filter(@drap.validationError, (err) ->
					err.attribute=='slope_value'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when inactiveThreshold is not a number", ->
				@drap.set inactiveThreshold: NaN
				expect(@drap.isValid()).toBeFalsy()
				filtErrors = _.filter(@drap.validationError, (err) ->
					err.attribute=='inactiveThreshold'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be valid when inactiveThreshold null", ->
				@drap.set inactiveThreshold: null
				expect(@drap.isValid()).toBeTruthy()
			it "should be invalid when theoreticalMax is not a number", ->
				@drap.set theoreticalMax: NaN
				expect(@drap.isValid()).toBeFalsy()
				filtErrors = _.filter(@drap.validationError, (err) ->
					err.attribute=='theoreticalMax'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be valid when theoreticalMax null", ->
				@drap.set theoreticalMax: null
				expect(@drap.isValid()).toBeTruthy()

	describe 'DoseResponseAnalysisParameters Controller', ->
		describe 'when instantiated from new parameters', ->
			beforeEach ->
				@drapc = new DoseResponseAnalysisParametersController
					model: new DoseResponseAnalysisParameters()
					el: $('#fixture')
				@drapc.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@drapc).toBeDefined()
				it 'should load autofill template', ->
					expect(@drapc.$('.bv_autofillSection').length).toEqual 1
				it 'should load a template', ->
					expect(@drapc.$('.bv_inverseAgonistMode').length).toEqual 1
			describe "render default parameters", ->
				it 'should show smart mode mode', ->
					expect(@drapc.$('.bv_smartMode').attr('checked')).toBeTruthy()
				it 'should show the inverse agonist mode', ->
					expect(@drapc.$('.bv_inverseAgonistMode').attr('checked')).toBeFalsy()
				it 'should start with max_limitType radio set', ->
					expect(@drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual 'none'
				it 'should start with min_limitType radio set', ->
					expect(@drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual 'none'
				it 'should start with slope_limitType radio set', ->
					expect(@drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual 'none'
				it 'should show the default inactive threshold', ->
					expect(@drapc.$(".bv_inactiveThreshold").val()).toEqual "20"
			describe "form title change", ->
				it "should allow the form title to be changed", ->
					@drapc.setFormTitle "kilroy fits curves"
					expect(@drapc.$(".bv_formTitle").html()).toEqual "kilroy fits curves"
				it "title should stay changed after render", ->
					@drapc.setFormTitle "kilroy fits curves"
					@drapc.render()
					expect(@drapc.$(".bv_formTitle").html()).toEqual "kilroy fits curves"
		describe 'when instantiated from existing parameters', ->
			beforeEach ->
				@drapc = new DoseResponseAnalysisParametersController
					model: new DoseResponseAnalysisParameters window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions
					el: $('#fixture')
				@drapc.render()
			describe "render existing parameters", ->
				it 'should show the smart mode', ->
					expect(@drapc.$('.bv_smartMode').attr('checked')).toEqual 'checked'
				it 'should show the inverse agonist mode', ->
					expect(@drapc.$('.bv_inverseAgonistMode').attr('checked')).toEqual 'checked'
				it 'should start with max_limitType radio set', ->
					expect(@drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual 'pin'
				it 'should start with min_limitType radio set', ->
					expect(@drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual 'none'
				it 'should start with slope_limitType radio set', ->
					expect(@drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual 'limit'
				it 'should set the max_value to the number', ->
					expect(@drapc.$(".bv_max_value").val()).toEqual "100"
				it 'should start with max_value input enabled', ->
					expect(@drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual 'pin'
					expect(@drapc.$(".bv_max_value").attr("disabled")).toBeUndefined()
				it 'should set the min_value to the number', ->
					expect(@drapc.$(".bv_min_value").val()).toEqual ""
				it 'should start with min_value input disabled', ->
					expect(@drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual 'none'
					expect(@drapc.$(".bv_min_value").attr("disabled")).toEqual "disabled"
				it 'should set the slope_value to the number', ->
					expect(@drapc.$(".bv_slope_value").val()).toEqual "1.5"
				it 'should start with slope_value input enabled', ->
					expect(@drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual 'limit'
					expect(@drapc.$(".bv_slope_value").attr("disabled")).toBeUndefined()
				it 'should show the inactive threshold', ->
					expect(@drapc.$(".bv_inactiveThreshold").val()).toEqual "20"
				it 'should show the theoreticalMax', ->
					expect(@drapc.$(".bv_theoreticalMax").val()).toEqual "120"
			describe "model update", ->
				it 'should update the inverse agonist mode', ->
					expect(@drapc.model.get('inverseAgonistMode')).toBeTruthy()
					@drapc.$('.bv_inverseAgonistMode').click()
					expect(@drapc.model.get('inverseAgonistMode')).toBeFalsy()
					@drapc.$('.bv_inverseAgonistMode').click()
					expect(@drapc.model.get('inverseAgonistMode')).toBeTruthy()
				it 'should update the max_limitType radio to none', ->
					@drapc.$(".bv_max_limitType_pin").click()
					@drapc.$(".bv_max_limitType_none").click()
					@drapc.$(".bv_max_limitType_none").click() #works fine in real life but requires second click in jasmine
					expect(@drapc.model.get('max').get('limitType')).toEqual 'none'
				it 'should update the max_value input to disabled when none', ->
					@drapc.$(".bv_max_limitType_none").click()
					@drapc.$(".bv_max_limitType_none").click()
					expect(@drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual 'none'
					expect(@drapc.$(".bv_max_value").attr("disabled")).toEqual "disabled"
				it 'should update the max_limitType radio to pin', ->
					@drapc.$(".bv_max_limitType_pin").click()
					@drapc.$(".bv_max_limitType_pin").click()
					expect(@drapc.model.get('max').get('limitType')).toEqual 'pin'
				it 'should update the max_value input to enabled when pin', ->
					@drapc.$(".bv_max_limitType_none").click()
					@drapc.$(".bv_max_limitType_none").click()
					expect(@drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual 'none'
					@drapc.$(".bv_max_limitType_pin").click()
					@drapc.$(".bv_max_limitType_pin").click()
					expect(@drapc.model.get('max').get('limitType')).toEqual 'pin'
					expect(@drapc.$(".bv_max_value").attr("disabled")).toBeUndefined()
				it 'should update the max_limitType radio to limit', ->
					@drapc.$(".bv_max_limitType_limit").click()
					@drapc.$(".bv_max_limitType_limit").click()
					expect(@drapc.model.get('max').get('limitType')).toEqual 'limit'
				it 'should update the max_value input to enabled when limit', ->
					@drapc.$(".bv_max_limitType_none").click()
					@drapc.$(".bv_max_limitType_none").click()
					expect(@drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual 'none'
					@drapc.$(".bv_max_limitType_limit").click()
					@drapc.$(".bv_max_limitType_limit").click()
					expect(@drapc.model.get('max').get('limitType')).toEqual 'limit'
					expect(@drapc.$(".bv_max_value").attr("disabled")).toBeUndefined()
				it 'should update the min_limitType radio to none', ->
					@drapc.$(".bv_min_limitType_pin").click()
					@drapc.$(".bv_min_limitType_none").click()
					@drapc.$(".bv_min_limitType_none").click()
					expect(@drapc.model.get('min').get('limitType')).toEqual 'none'
				it 'should update the min_value input to disabled when none', ->
					@drapc.$(".bv_min_limitType_pin").click()
					@drapc.$(".bv_min_limitType_pin").click()
					expect(@drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual 'pin'
					@drapc.$(".bv_min_limitType_none").click()
					@drapc.$(".bv_min_limitType_none").click()
					expect(@drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual 'none'
					expect(@drapc.$(".bv_min_value").attr("disabled")).toEqual "disabled"
				it 'should update the min_limitType radio to pin', ->
					@drapc.$(".bv_min_limitType_pin").click()
					@drapc.$(".bv_min_limitType_pin").click()
					expect(@drapc.model.get('min').get('limitType')).toEqual 'pin'
				it 'should update the min_value input to enabled when pin', ->
					@drapc.$(".bv_min_limitType_none").click()
					@drapc.$(".bv_min_limitType_none").click()
					expect(@drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual 'none'
					@drapc.$(".bv_min_limitType_pin").click()
					@drapc.$(".bv_min_limitType_pin").click()
					expect(@drapc.model.get('min').get('limitType')).toEqual 'pin'
					expect(@drapc.$(".bv_min_value").attr("disabled")).toBeUndefined()
				it 'should update the min_limitType radio to limit', ->
					@drapc.$(".bv_min_limitType_limit").click()
					@drapc.$(".bv_min_limitType_limit").click()
					expect(@drapc.model.get('min').get('limitType')).toEqual 'limit'
				it 'should update the min_value input to enabled when limit', ->
					@drapc.$(".bv_min_limitType_none").click()
					@drapc.$(".bv_min_limitType_none").click()
					expect(@drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual 'none'
					@drapc.$(".bv_min_limitType_limit").click()
					@drapc.$(".bv_min_limitType_limit").click()
					expect(@drapc.model.get('min').get('limitType')).toEqual 'limit'
					expect(@drapc.$(".bv_min_value").attr("disabled")).toBeUndefined()
				it 'should update the slope_limitType radio to none', ->
					@drapc.$(".bv_slope_limitType_none").click()
					@drapc.$(".bv_slope_limitType_none").click()
					expect(@drapc.model.get('slope').get('limitType')).toEqual 'none'
				it 'should update the slope_value input to disabled when none', ->
					@drapc.$(".bv_slope_limitType_none").click()
					@drapc.$(".bv_slope_limitType_none").click()
					expect(@drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual 'none'
					expect(@drapc.$(".bv_slope_value").attr("disabled")).toEqual "disabled"
				it 'should update the slope_limitType radio to pin', ->
					@drapc.$(".bv_slope_limitType_pin").click()
					@drapc.$(".bv_slope_limitType_pin").click()
					expect(@drapc.model.get('slope').get('limitType')).toEqual 'pin'
				it 'should update the slope_value input to enabled when pin', ->
					@drapc.$(".bv_slope_limitType_none").click()
					@drapc.$(".bv_slope_limitType_none").click()
					expect(@drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual 'none'
					@drapc.$(".bv_slope_limitType_pin").click()
					@drapc.$(".bv_slope_limitType_pin").click()
					expect(@drapc.model.get('slope').get('limitType')).toEqual 'pin'
					expect(@drapc.$(".bv_slope_value").attr("disabled")).toBeUndefined()
				it 'should update the slope_limitType radio to limit', ->
					@drapc.$(".bv_slope_limitType_none").click()
					@drapc.$(".bv_slope_limitType_limit").click()
					@drapc.$(".bv_slope_limitType_limit").click()
					expect(@drapc.model.get('slope').get('limitType')).toEqual 'limit'
				it 'should update the slope_value input to enabled when limit', ->
					@drapc.$(".bv_slope_limitType_none").click()
					@drapc.$(".bv_slope_limitType_none").click()
					expect(@drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual 'none'
					@drapc.$(".bv_slope_limitType_limit").click()
					@drapc.$(".bv_slope_limitType_limit").click()
					expect(@drapc.model.get('slope').get('limitType')).toEqual 'limit'
					expect(@drapc.$(".bv_slope_value").attr("disabled")).toBeUndefined()
				it 'should update the max_value', ->
					@drapc.$('.bv_max_value').val(" 7.5 ")
					@drapc.$('.bv_max_value').change()
					expect(@drapc.model.get('max').get('value')).toEqual 7.5
				it 'should update the min_value', ->
					@drapc.$('.bv_min_value').val(" 22.3 ")
					@drapc.$('.bv_min_value').change()
					expect(@drapc.model.get('min').get('value')).toEqual 22.3
				it 'should update the slope_value', ->
					@drapc.$('.bv_slope_value').val(" 16.5 ")
					@drapc.$('.bv_slope_value').change()
					expect(@drapc.model.get('slope').get('value')).toEqual 16.5
				it 'should update the inactiveThreshold', ->
					@drapc.$('.bv_inactiveThreshold').val 44
					@drapc.$('.bv_inactiveThreshold').change()
					expect(@drapc.model.get('inactiveThreshold')).toEqual 44
				it 'should update the theoreticalMax', ->
					@drapc.$('.bv_theoreticalMax').val 43
					@drapc.$('.bv_theoreticalMax').change()
					expect(@drapc.model.get('theoreticalMax')).toEqual 43
			describe "behavior and validation", ->
				it "should enable inactive threshold if smart mode is selected", ->
					@drapc.$('.bv_smartMode').click()
					@drapc.$('.bv_smartMode').trigger('change')
					@drapc.$('.bv_smartMode').click()
					@drapc.$('.bv_smartMode').trigger('change')
					expect(@drapc.$('.bv_inactiveThreshold').attr('disabled')).toBeUndefined()
				it "should disable inactive threshold and clear value if smart mode is not selected", ->
					@drapc.$('.bv_smartMode').click()
					@drapc.$('.bv_smartMode').trigger('change')
					expect(@drapc.$('.bv_inactiveThreshold').attr('disabled')).toEqual 'disabled'
					console.log @drapc.$('.bv_inactiveThreshold').val()
					console.log @drapc.model.get('inactiveThreshold')
					expect(_.isNaN(@drapc.model.get('inactiveThreshold'))).toBeTruthy()
				it "should enable theoretical max if smart mode is selected", ->
					@drapc.$('.bv_smartMode').click()
					@drapc.$('.bv_smartMode').trigger('change')
					@drapc.$('.bv_smartMode').click()
					@drapc.$('.bv_smartMode').trigger('change')
					expect(@drapc.$('.bv_theoreticalMax').attr('disabled')).toBeUndefined()
				it "should disable inactive threshold and clear value if smart mode is not selected", ->
					@drapc.$('.bv_smartMode').click()
					@drapc.$('.bv_smartMode').trigger('change')
					expect(@drapc.$('.bv_theoreticalMax').attr('disabled')).toEqual 'disabled'
					console.log @drapc.$('.bv_theoreticalMax').val()
					console.log @drapc.model.get('theoreticalMax')
					expect(_.isNaN(@drapc.model.get('theoreticalMax'))).toBeTruthy()
			describe "validation testing", ->
				describe "error notification", ->
					it "should show error if max_limitType is set to pin and max_value is not set", ->
						@drapc.model.get('max').set limitType: 'pin'
						@drapc.$('.bv_max_value').val ""
						@drapc.$('.bv_max_value').change()
						expect(@drapc.$('.bv_group_max_value').hasClass("error")).toBeTruthy()
					it "should show error if max_limitType is set to limit and max_value is not set", ->
						@drapc.model.get('max').set limitType: 'limit'
						@drapc.$('.bv_max_value').val ""
						@drapc.$('.bv_max_value').change()
						expect(@drapc.$('.bv_group_max_value').hasClass("error")).toBeTruthy()
					it "should show error if min_limitType is set to pin and min_value is not set", ->
						@drapc.model.get('min').set limitType: 'pin'
						@drapc.$('.bv_min_value').val ""
						@drapc.$('.bv_min_value').change()
						console.log @drapc.model.get('min').get 'limitType'
						expect(@drapc.$('.bv_group_min_value').hasClass("error")).toBeTruthy()
					it "should show error if min_limitType is set to limit and min_value is not set", ->
						@drapc.model.get('min').set limitType: 'limit'
						@drapc.$('.bv_min_value').val ""
						@drapc.$('.bv_min_value').change()
						expect(@drapc.$('.bv_group_min_value').hasClass("error")).toBeTruthy()
					it "should show error if slope_limitType is set to pin and slope_value is not set", ->
						@drapc.model.get('slope').set limitType: 'pin'
						@drapc.$('.bv_slope_value').val ""
						@drapc.$('.bv_slope_value').change()
						expect(@drapc.$('.bv_group_slope_value').hasClass("error")).toBeTruthy()
					it "should show error if slope_limitType is set to limit and slope_value is not set", ->
						@drapc.model.get('slope').set limitType: 'limit'
						@drapc.$('.bv_slope_value').val ""
						@drapc.$('.bv_slope_value').change()
						expect(@drapc.$('.bv_group_slope_value').hasClass("error")).toBeTruthy()

	describe "DoseResponseAnalysisController testing", ->
		describe "basic plumbing checks with experiment copied from template", ->
			beforeEach ->
				@exp = new PrimaryScreenExperiment()
				@exp.copyProtocolAttributes new Protocol(window.protocolServiceTestJSON.fullSavedProtocol)
				@drac = new DoseResponseAnalysisController
					model: @exp
					el: $('#fixture')
				@drac.render()
			describe "Basic loading", ->
				it "Class should exist", ->
					expect(@drac).toBeDefined
				it "Should load the template", ->
					expect(@drac.$('.bv_modelFitStatus').length).toNotEqual 0
			describe "display logic not ready to fit", ->
				it "should show model fit status not started becuase this is a new experiment", ->
					expect(@drac.$('.bv_modelFitStatus').html()).toEqual "not started"
				it "should not show model fit results becuase this is a new experiment", ->
					expect(@drac.$('.bv_modelFitResultsHTML').html()).toEqual ""
					expect(@drac.$('.bv_resultsContainer')).toBeHidden()
				it "should be able to hide model fit controller", ->
					@drac.setNotReadyForFit()
					expect(@drac.$('.bv_fitOptionWrapper')).toBeHidden()
					expect(@drac.$('.bv_analyzeExperimentToFit')).toBeVisible()
			describe "display logic after ready to fit", ->
				beforeEach ->
					@drac.setReadyForFit()
				it "Should load the model fit type select controller", ->
					expect(@drac.$('.bv_modelFitType').length).toEqual 1
				it "should be able to show model controller", ->
					expect(@drac.$('.bv_fitOptionWrapper')).toBeVisible()
					expect(@drac.$('.bv_analyzeExperimentToFit')).toBeHidden()
				it "Should load the fit parameter form after a model fit type is selected", ->
					waitsFor ->
						@drac.$('.bv_modelFitType option').length > 0
					, 1000
					runs ->
						@drac.$('.bv_modelFitType').val('4 parameter D-R')
						@drac.$('.bv_modelFitType').change()
					waitsFor ->
						@drac.$('.bv_max_limitType_none').length > 0
					, 1000
					runs ->
						expect(@drac.$('.bv_max_limitType_none').length).toNotEqual 0

		describe "experiment status locks analysis", ->
			beforeEach ->
				@exp = new PrimaryScreenExperiment window.experimentServiceTestJSON.fullExperimentFromServer
				@drac = new DoseResponseAnalysisController
					model: @exp
					el: $('#fixture')
				@drac.model.getAnalysisStatus().set codeValue: "analsysis complete"
				@drac.model.getModelFitType().set codeValue: "4 parameter D-R"
				@drac.primaryAnalysisCompleted()
				@drac.render()
			describe "experiment status change handling", ->
				it "Should disable model fit parameter editing if status is approved", ->
					@drac.model.getStatus().set codeValue: "approved"
					expect(@drac.$('.bv_max_limitType_none').attr('disabled')).toEqual 'disabled'
				it "Should enable analsyis parameter editing if status is Started", ->
					@drac.model.getStatus().set codeValue: "approved"
					@drac.model.getStatus().set codeValue: "started"
					expect(@drac.$('.bv_max_limitType').attr('disabled')).toBeUndefined()
				it "should show fit button as Re-Fit since status is ' Curves not fit'", ->
					expect(@drac.$('.bv_fitModelButton').html()).toEqual "Re-Fit"
			describe "Form valid change handling", ->
				beforeEach ->
					waitsFor ->
						@drac.$('.bv_modelFitType option').length > 0
					, 1000
					runs ->
						@drac.$('.bv_modelFitType').val('4 parameter D-R')
						@drac.$('.bv_modelFitType').change()
					waitsFor ->
						@drac.$('.bv_max_limitType_none').length > 0
					, 1000
				it "should show button enabled since form loaded with valid values from test fixture", ->
					runs ->
						expect(@drac.$('.bv_fitModelButton').attr('disabled')).toBeUndefined()
				it "should show button disabled when form is invalid", ->
					runs ->
						@drac.$('.bv_max_value').val ""
						@drac.$('.bv_max_value').change()
						expect(@drac.$('.bv_fitModelButton').attr('disabled')).toEqual 'disabled'
		describe "handling re-fit", ->
			beforeEach ->
				@exp = new PrimaryScreenExperiment window.experimentServiceTestJSON.fullExperimentFromServer
				@exp.getAnalysisStatus().set codeValue: "analsysis complete"
				@exp.getModelFitStatus().set codeValue: "model fit complete"
				@drac = new DoseResponseAnalysisController
					model: @exp
					el: $('#fixture')
				@drac.render()
			describe "upon render", ->
				it "should show fit button as re-analyze when fit status is not 'not started'", ->
					expect(@drac.$('.bv_fitModelButton').html()).toEqual "Re-Fit"

#TODO show a button to open curve curator when fit is done
	# (either return from fit with no error, or reload with model fit status = "complete"
#TODO add notification component
