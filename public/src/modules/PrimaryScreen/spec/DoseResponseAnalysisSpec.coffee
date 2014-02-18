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
					expect(@drap.get('inactiveThreshold')).toEqual 20
					expect(@drap.get('inverseAgonistMode')).toBeFalsy
					expect(@drap.get('max') instanceof Backbone.Model).toBeTruthy()
					expect(@drap.get('min') instanceof Backbone.Model).toBeTruthy()
					expect(@drap.get('slope') instanceof Backbone.Model).toBeTruthy()
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

	describe 'DoseResponseAnalysisParameters Controller', ->
		describe 'when instantiated', ->
			beforeEach ->
				@drapc = new DoseResponseAnalysisParametersController
					model: new DoseResponseAnalysisParameters window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions
					el: $('#fixture')
				@drapc.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@drapc).toBeDefined()
				it 'should load autofill template', ->
					expect(@drapc.$('.bv_autofillSection').length).toEqual 1
				it 'should load a template', ->
					expect(@drapc.$('.bv_inverseAgonistMode').length).toEqual 1
			describe "render existing parameters", ->
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
				it 'should set the min_value to the number', ->
					expect(@drapc.$(".bv_min_value").val()).toEqual ""
				it 'should set the slope_value to the number', ->
					expect(@drapc.$(".bv_slope_value").val()).toEqual "1.5"
			describe "model update", ->
				it 'should update the inverse agonist mode', ->
					expect(@drapc.model.get('inverseAgonistMode')).toBeTruthy()
					@drapc.$('.bv_inverseAgonistMode').click()
					expect(@drapc.model.get('inverseAgonistMode')).toBeFalsy()
				it 'should update the max_limitType radio to none', ->
					@drapc.$(".bv_max_limitType_none").click()
					expect(@drapc.model.get('max').get('limitType')).toEqual 'none'
				it 'should update the max_limitType radio to pin', ->
					@drapc.$(".bv_max_limitType_pin").click()
					expect(@drapc.model.get('max').get('limitType')).toEqual 'pin'
				it 'should update the max_limitType radio to limit', ->
					@drapc.$(".bv_max_limitType_limit").click()
					expect(@drapc.model.get('max').get('limitType')).toEqual 'limit'
				it 'should update the min_limitType radio to none', ->
					@drapc.model.get('min').set limitType: 'pin'
					@drapc.$(".bv_min_limitType_none").click()
					expect(@drapc.model.get('min').get('limitType')).toEqual 'none'
				it 'should update the min_limitType radio to pin', ->
					@drapc.$(".bv_min_limitType_pin").click()
					expect(@drapc.model.get('min').get('limitType')).toEqual 'pin'
				it 'should update the min_limitType radio to limit', ->
					@drapc.$(".bv_min_limitType_limit").click()
					expect(@drapc.model.get('min').get('limitType')).toEqual 'limit'
				it 'should update the slope_limitType radio to none', ->
					@drapc.$(".bv_slope_limitType_none").click()
					expect(@drapc.model.get('slope').get('limitType')).toEqual 'none'
				it 'should update the slope_limitType radio to pin', ->
					@drapc.$(".bv_slope_limitType_pin").click()
					expect(@drapc.model.get('slope').get('limitType')).toEqual 'pin'
				it 'should update the slope_limitType radio to limit', ->
					@drapc.model.get('slope').set limitType: 'pin'
					@drapc.$(".bv_slope_limitType_limit").click()
					expect(@drapc.model.get('slope').get('limitType')).toEqual 'limit'
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
					@drapc.$('.bv_inactiveTreshold').val(" 30 ")
					@drapc.$('.bv_inactiveTreshold').change()
					expect(@drapc.model.get('inactiveThreshold').get('value')).toEqual 30
				describe "behavior and validation", ->
#					it "should disable the inactive threshold if inverse agonist mode is not selected", ->
#						@drapc.$('.bv_inverseAgonistMode').click()
#						expect(@drapc.$('.bv_inactiveTreshold').attr("disabled")).toBeUndefined()
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
