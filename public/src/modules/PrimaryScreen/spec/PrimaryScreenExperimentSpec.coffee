beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Primary Screen Experiment module testing", ->
	describe "Analysis Parameter model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@psap = new PrimaryScreenAnalysisParameters()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@psap).toBeDefined()
				it "should have defaults", ->
					expect(@psap.get('transformationRule')).toEqual "unassigned"
					expect(@psap.get('normalizationRule')).toEqual "unassigned"
					expect(@psap.get('hitEfficacyThreshold')).toBeNull()
					expect(@psap.get('hitSDThreshold')).toBeNull()
					expect(@psap.get('positiveControl') instanceof Backbone.Model).toBeTruthy()
					expect(@psap.get('negativeControl') instanceof Backbone.Model).toBeTruthy()
					expect(@psap.get('vehicleControl') instanceof Backbone.Model).toBeTruthy()
					expect(@psap.get('agonistControl') instanceof Backbone.Model).toBeTruthy()
					expect(@psap.get('thresholdType')).toEqual "sd"
		describe "model validation tests", ->
			beforeEach ->
				@psap = new PrimaryScreenAnalysisParameters window.primaryScreenTestJSON.primaryScreenAnalysisParameters
			it "should be valid as initialized", ->
				expect(@psap.isValid()).toBeTruthy()
			it "should be invalid when positive control batch is empty", ->
				@psap.get('positiveControl').set
					batchCode: ""
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='positiveControlBatch'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when positive control conc is NaN", ->
				@psap.get('positiveControl').set
					concentration: NaN
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='positiveControlConc'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when negative control batch is empty", ->
				@psap.get('negativeControl').set
					batchCode: ""
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='negativeControlBatch'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when negative control conc is NaN", ->
				@psap.get('negativeControl').set
					concentration: NaN
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='negativeControlConc'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when agonist control batch is empty", ->
				@psap.get('agonistControl').set
					batchCode: ""
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='agonistControlBatch'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when agonist control conc is NaN", ->
				@psap.get('agonistControl').set
					concentration: NaN
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='agonistControlConc'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when vehicle control is empty", ->
				@psap.get('vehicleControl').set
					batchCode: ""
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='vehicleControlBatch'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when transformation rule is unassigned", ->
				@psap.set transformationRule: "unassigned"
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='transformationRule'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when normalization rule is unassigned", ->
				@psap.set normalizationRule: "unassigned"
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='normalizationRule'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when thresholdType is sd and hitSDThreshold is not a number", ->
				@psap.set thresholdType: "sd"
				@psap.set hitSDThreshold: NaN
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='hitSDThreshold'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when thresholdType is efficacy and hitEfficacyThreshold is not a number", ->
				@psap.set thresholdType: "efficacy"
				@psap.set hitEfficacyThreshold: NaN
				expect(@psap.isValid()).toBeFalsy()
				filtErrors = _.filter(@psap.validationError, (err) ->
					err.attribute=='hitEfficacyThreshold'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe "Primary Screen Experiment model testing", ->
		describe "When loaded from existing", ->
			beforeEach ->
				@pse = new PrimaryScreenExperiment window.experimentServiceTestJSON.fullExperimentFromServer
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@pse).toBeDefined()
			describe "special getters", ->
				describe "analysis parameters", ->
					it 'Should be able to get analysis parameters', ->
							expect(@pse.getAnalysisParameters() instanceof PrimaryScreenAnalysisParameters).toBeTruthy()
					it 'Should parse analysis parameters', ->
							expect(@pse.getAnalysisParameters().get('hitSDThreshold')).toEqual 5
					it 'Should parse pos control into backbone models', ->
							expect(@pse.getAnalysisParameters().get('positiveControl').get('batchCode')).toEqual "CMPD-12345678-01"
					it 'Should parse neg control into backbone models', ->
							expect(@pse.getAnalysisParameters().get('negativeControl').get('batchCode')).toEqual "CMPD-87654321-01"
					it 'Should parse veh control into backbone models', ->
							expect(@pse.getAnalysisParameters().get('vehicleControl').get('batchCode')).toEqual "CMPD-00000001-01"
					it 'Should parse agonist control into backbone models', ->
							expect(@pse.getAnalysisParameters().get('agonistControl').get('batchCode')).toEqual "CMPD-87654399-01"
				describe "special states", ->
					it "should be able to get the analysis status", ->
							expect(@pse.getAnalysisStatus().get('stringValue')).toEqual "not started"
					it "should be able to get the analysis result html", ->
							expect(@pse.getAnalysisResultHTML().get('clobValue')).toEqual "<p>Analysis not yet completed</p>"
		describe "When loaded from new", ->
			beforeEach ->
				@pse2 = new PrimaryScreenExperiment()
			describe "special states", ->
				it "should be able to get the analysis status", ->
						expect(@pse2.getAnalysisStatus().get('stringValue')).toEqual "not started"
				it "should be able to get the analysis result html", ->
						expect(@pse2.getAnalysisResultHTML().get('clobValue')).toEqual ""

	describe 'PrimaryScreenAnalysisParameters Controller', ->
		describe 'when instantiated', ->
			beforeEach ->
				@psapc = new PrimaryScreenAnalysisParametersController
					model: new PrimaryScreenAnalysisParameters window.primaryScreenTestJSON.primaryScreenAnalysisParameters
					el: $('#fixture')
				@psapc.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@psapc).toBeDefined()
				it 'should load a template', ->
					expect(@psapc.$('.bv_autofillSection').length).toEqual 1
				it 'should load autofill template', ->
					expect(@psapc.$('.bv_hitSDThreshold').length).toEqual 1
			describe "render existing parameters", ->
				it 'should show the transformation rule', ->
					expect(@psapc.$('.bv_transformationRule').val()).toEqual "(maximum-minimum)/minimum"
				it 'should show the normalization rule', ->
					expect(@psapc.$('.bv_normalizationRule').val()).toEqual "plate order"
				it 'should show the hitSDThreshold', ->
					expect(@psapc.$('.bv_hitSDThreshold').val()).toEqual '5'
				it 'should show the hitEfficacyThreshold', ->
					expect(@psapc.$('.bv_hitEfficacyThreshold').val()).toEqual '42'
				it 'should start with thresholdType radio set', ->
					expect(@psapc.$("input[name='bv_thresholdType']:checked").val()).toEqual 'sd'
				it 'should show the positiveControlBatch', ->
					expect(@psapc.$('.bv_positiveControlBatch').val()).toEqual 'CMPD-12345678-01'
				it 'should show the positiveControlConc', ->
					expect(@psapc.$('.bv_positiveControlConc').val()).toEqual '10'
				it 'should show the negativeControlBatch', ->
					expect(@psapc.$('.bv_negativeControlBatch').val()).toEqual 'CMPD-87654321-01'
				it 'should show the negativeControlConc', ->
					expect(@psapc.$('.bv_negativeControlConc').val()).toEqual '1'
				it 'should show the vehControlBatch', ->
					expect(@psapc.$('.bv_vehicleControlBatch').val()).toEqual 'CMPD-00000001-01'
				it 'should show the agonistControlBatch', ->
					expect(@psapc.$('.bv_agonistControlBatch').val()).toEqual 'CMPD-87654399-01'
				it 'should show the agonistControlConc', ->
					expect(@psapc.$('.bv_agonistControlConc').val()).toEqual '2'
			describe "model updates", ->
				it "should update the transformation rule", ->
					@psapc.$('.bv_transformationRule').val('unassigned')
					@psapc.$('.bv_transformationRule').change()
					expect(@psapc.model.get('transformationRule')).toEqual "unassigned"
				it "should update the normalizationRule rule", ->
					@psapc.$('.bv_normalizationRule').val('unassigned')
					@psapc.$('.bv_normalizationRule').change()
					expect(@psapc.model.get('normalizationRule')).toEqual "unassigned"
				it "should update the hitSDThreshold ", ->
					@psapc.$('.bv_hitSDThreshold').val(' 24 ')
					@psapc.$('.bv_hitSDThreshold').change()
					expect(@psapc.model.get('hitSDThreshold')).toEqual 24
				it "should update the hitEfficacyThreshold ", ->
					@psapc.$('.bv_hitEfficacyThreshold').val(' 25 ')
					@psapc.$('.bv_hitEfficacyThreshold').change()
					expect(@psapc.model.get('hitEfficacyThreshold')).toEqual 25
				it "should update the positiveControl ", ->
					@psapc.$('.bv_positiveControlBatch').val(' pos cont ')
					@psapc.$('.bv_positiveControlBatch').change()
					expect(@psapc.model.get('positiveControl').get('batchCode')).toEqual "pos cont"
				it "should update the positiveControl conc ", ->
					@psapc.$('.bv_positiveControlConc').val(' 61 ')
					@psapc.$('.bv_positiveControlConc').change()
					expect(@psapc.model.get('positiveControl').get('concentration')).toEqual 61
				it "should update the negativeControl ", ->
					@psapc.$('.bv_negativeControlBatch').val(' neg cont ')
					@psapc.$('.bv_negativeControlBatch').change()
					expect(@psapc.model.get('negativeControl').get('batchCode')).toEqual "neg cont"
				it "should update the negativeControl conc ", ->
					@psapc.$('.bv_negativeControlConc').val(' 62 ')
					@psapc.$('.bv_negativeControlConc').change()
					expect(@psapc.model.get('negativeControl').get('concentration')).toEqual 62
				it "should update the vehicleControl ", ->
					@psapc.$('.bv_vehicleControlBatch').val(' veh cont ')
					@psapc.$('.bv_vehicleControlBatch').change()
					expect(@psapc.model.get('vehicleControl').get('batchCode')).toEqual "veh cont"
				it "should update the agonistControl", ->
					@psapc.$('.bv_agonistControlBatch').val(' ag cont ')
					@psapc.$('.bv_agonistControlBatch').change()
					expect(@psapc.model.get('agonistControl').get('batchCode')).toEqual "ag cont"
				it "should update the agonistControl conc", ->
					@psapc.$('bv_agonistControlConc').val(' 2 ')
					@psapc.$('.bv_agonistControlConc').change()
					expect(@psapc.model.get('agonistControl').get('concentration')).toEqual 2
				it "should update the thresholdType ", ->
					@psapc.$('.bv_thresholdTypeEfficacy').click()
					expect(@psapc.model.get('thresholdType')).toEqual "efficacy"
			describe "behavior and validation", ->
				it "should disable sd threshold field if that radio not selected", ->
					@psapc.$('.bv_thresholdTypeEfficacy').click()
					expect(@psapc.$('.bv_hitSDThreshold').attr("disabled")).toEqual "disabled"
					expect(@psapc.$('.bv_hitEfficacyThreshold').attr("disabled")).toBeUndefined()
				it "should disable efficacy threshold field if that radio not selected", ->
					@psapc.$('.bv_thresholdTypeEfficacy').click()
					@psapc.$('.bv_thresholdTypeSD').click()
					expect(@psapc.$('.bv_hitEfficacyThreshold').attr("disabled")).toEqual "disabled"
					expect(@psapc.$('.bv_hitSDThreshold').attr("disabled")).toBeUndefined()
		describe "valiation testing", ->
			beforeEach ->
				@psapc = new PrimaryScreenExperimentController
					model: new PrimaryScreenExperiment window.experimentServiceTestJSON.fullExperimentFromServer
					el: $('#fixture')
				@psapc.render()
			describe "error notification", ->
				it "should show error if positiveControl batch is not set", ->
					@psapc.$('.bv_positiveControlBatch').val ""
					@psapc.$('.bv_positiveControlBatch').change()
					expect(@psapc.$('.bv_group_positiveControlBatch').hasClass("error")).toBeTruthy()
				it "should show error if positiveControl conc is not set", ->
					@psapc.$('.bv_positiveControlConc').val ""
					@psapc.$('.bv_positiveControlConc').change()
					expect(@psapc.$('.bv_group_positiveControlConc').hasClass("error")).toBeTruthy()
				it "should show error if negativeControl batch is not set", ->
					@psapc.$('.bv_negativeControlBatch').val ""
					@psapc.$('.bv_negativeControlBatch').change()
					expect(@psapc.$('.bv_group_negativeControlBatch').hasClass("error")).toBeTruthy()
				it "should show error if negativeControl conc is not set", ->
					@psapc.$('.bv_negativeControlConc').val ""
					@psapc.$('.bv_negativeControlConc').change()
					expect(@psapc.$('.bv_group_negativeControlConc').hasClass("error")).toBeTruthy()
				it "should show error if agonistControl batch is not set", ->
					@psapc.$('.bv_agonistControlBatch').val ""
					@psapc.$('.bv_agonistControlBatch').change()
					expect(@psapc.$('.bv_group_agonistControlBatch').hasClass("error")).toBeTruthy()
				it "should show error if agonistControl conc is not set", ->
					@psapc.$('.bv_agonistControlConc').val ""
					@psapc.$('.bv_agonistControlConc').change()
					expect(@psapc.$('.bv_group_agonistControlConc').hasClass("error")).toBeTruthy()
				it "should show error if vehicleControl is not set", ->
					@psapc.$('.bv_vehicleControlBatch').val ""
					@psapc.$('.bv_vehicleControlBatch').change()
					expect(@psapc.$('.bv_group_vehicleControlBatch').hasClass("error")).toBeTruthy()
				it "should show error if transformationRule is unassigned", ->
					@psapc.$('.bv_transformationRule').val "unassigned"
					@psapc.$('.bv_transformationRule').change()
					expect(@psapc.$('.bv_group_transformationRule').hasClass("error")).toBeTruthy()
				it "should show error if normalizationRule is unassigned", ->
					@psapc.$('.bv_normalizationRule').val "unassigned"
					@psapc.$('.bv_normalizationRule').change()
					expect(@psapc.$('.bv_group_normalizationRule').hasClass("error")).toBeTruthy()
				it "should show error if threshold type is efficacy and efficacy threshold not a number", ->
					@psapc.$('.bv_thresholdTypeEfficacy').click()
					@psapc.$('.bv_hitEfficacyThreshold').val ""
					@psapc.$('.bv_hitEfficacyThreshold').change()
					expect(@psapc.$('.bv_group_hitEfficacyThreshold').hasClass("error")).toBeTruthy()
				it "should show error if threshold type is sd and sd threshold not a number", ->
					@psapc.$('.bv_sdTypeEfficacy').click()
					@psapc.$('.bv_hitSDThreshold').val ""
					@psapc.$('.bv_hitSDThreshold').change()
					expect(@psapc.$('.bv_group_hitSDThreshold').hasClass("error")).toBeTruthy()

	describe "Upload and Run Primary Analysis Controller testing", ->
		beforeEach ->
			@exp = new PrimaryScreenExperiment()
			@uarpac = new UploadAndRunPrimaryAnalsysisController
				el: $('#fixture')
				paramsFromExperiment:	@exp.getAnalysisParameters()
			@uarpac.render()

		describe "Basic loading", ->
			it "Class should exist", ->
				expect(@uarpac).toBeDefined()
			it "Should load the template", ->
				expect(@uarpac.$('.bv_parseFile').length).toNotEqual 0

	describe "Primary Screen Analysis Controller testing", ->
		describe "basic plumbing checks with experiment copied from template", ->
			beforeEach ->
				@exp = new PrimaryScreenExperiment()
				@exp.copyProtocolAttributes new Protocol(window.protocolServiceTestJSON.fullSavedProtocol)
				@psac = new PrimaryScreenAnalysisController
					model: @exp
					el: $('#fixture')
				@psac.render()
			describe "Basic loading", ->
				it "Class should exist", ->
					expect(@psac).toBeDefined
				it "Should load the template", ->
					expect(@psac.$('.bv_analysisStatus').length).toNotEqual 0
			describe "display logic", ->
				it "should show analysis status not started becuase this is a new experiment", ->
					expect(@psac.$('.bv_analysisStatus').html()).toEqual "not started"
				it "should not show analysis results becuase this is a new experiment", ->
					expect(@psac.$('.bv_analysisResultsHTML').html()).toEqual ""
				it "should be able to hide data analysis controller", ->
					@psac.setExperimentNotSaved()
					expect(@psac.$('.bv_fileUploadWrapper')).toBeHidden()
					expect(@psac.$('.bv_saveExperimentToAnalyze')).toBeVisible()
				it "should be able to show data analysis controller", ->
					@psac.setExperimentSaved()
					expect(@psac.$('.bv_fileUploadWrapper')).toBeVisible()
					expect(@psac.$('.bv_saveExperimentToAnalyze')).toBeHidden()
		describe "experiment status locks analysis", ->
			beforeEach ->
				@exp = new PrimaryScreenExperiment window.experimentServiceTestJSON.fullExperimentFromServer
				@psac = new PrimaryScreenAnalysisController
					model: @exp
					el: $('#fixture')
				@psac.render()
			it "Should disable analsyis parameter editing if status is Finalized", ->
				@psac.model.getStatus().set stringValue: "Finalized"
				expect(@psac.$('.bv_normalizationRule').attr('disabled')).toEqual 'disabled'
			it "Should enable analsyis parameter editing if status is Finalized", ->
				@psac.model.getStatus().set stringValue: "Finalized"
				@psac.model.getStatus().set stringValue: "Started"
				expect(@psac.$('.bv_normalizationRule').attr('disabled')).toBeUndefined()
			it "should show upload button as upload data since status is 'not started'", ->
				expect(@psac.$('.bv_save').html()).toEqual "Upload Data"
		describe "handling re-analysis", ->
			beforeEach ->
				@exp = new PrimaryScreenExperiment window.experimentServiceTestJSON.fullExperimentFromServer
				@exp.getAnalysisStatus().set stringValue: "analsysis complete"
				@psac = new PrimaryScreenAnalysisController
					model: @exp
					el: $('#fixture')
				@psac.render()
			it "should show upload button as re-analyze since status is not 'not started'", ->
				expect(@psac.$('.bv_save').html()).toEqual "Re-Analyze"

	describe "Primary Screen Experiment Controller testing", ->
		describe "basic plumbing checks with new experiment", ->
			beforeEach ->
				@psec = new PrimaryScreenExperimentController
					model: new PrimaryScreenExperiment()
					el: $('#fixture')
				@psec.render()
			describe "Basic loading", ->
				it "Class should exist", ->
					expect(@psec).toBeDefined()
				it "Should load the template", ->
					expect(@psec.$('.bv_experimentBase').length).toNotEqual 0
				it "Should load a base experiment controller", ->
					expect(@psec.$('.bv_experimentBase .bv_experimentName').length).toNotEqual 0
				it "Should load an analysis controller", ->
					expect(@psec.$('.bv_primaryScreenDataAnalysis .bv_analysisStatus').length).toNotEqual 0
				xit "Should load a dose response controller", ->
					expect(@psec.$('.bv_doseResponseAnalysis .bv_fixCurveMin').length).toNotEqual 0






#TODO Validation rules for different threshold modes
