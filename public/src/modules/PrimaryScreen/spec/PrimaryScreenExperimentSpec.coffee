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
					expect(@psap.get('thresholdType')).toEqual "sd"

	describe "Primary Screen Experiment model testing", ->
		describe "When loaded from existing", ->
			beforeEach ->
				@pse = new PrimaryScreenExperiment window.experimentServiceTestJSON.fullExperimentFromServer
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@pse).toBeDefined()
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
				it 'should show the posControlBatch', ->
					expect(@psapc.$('.bv_posControlBatch').val()).toEqual 'CMPD-12345678-01'
				it 'should show the posControlConc', ->
					expect(@psapc.$('.bv_posControlConc').val()).toEqual '10'
				it 'should show the negControlBatch', ->
					expect(@psapc.$('.bv_negControlBatch').val()).toEqual 'CMPD-87654321-01'
				it 'should show the negControlConc', ->
					expect(@psapc.$('.bv_negControlConc').val()).toEqual '1'
				it 'should show the vehControlBatch', ->
					expect(@psapc.$('.bv_vehControlBatch').val()).toEqual 'CMPD-00000001-01'
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
					expect(@psapc.model.get('hitSDThreshold')).toEqual "24"
				it "should update the hitEfficacyThreshold ", ->
					@psapc.$('.bv_hitEfficacyThreshold').val(' 25 ')
					@psapc.$('.bv_hitEfficacyThreshold').change()
					expect(@psapc.model.get('hitEfficacyThreshold')).toEqual "25"
				it "should update the positiveControl ", ->
					@psapc.$('.bv_posControlBatch').val(' pos cont ')
					@psapc.$('.bv_posControlBatch').change()
					expect(@psapc.model.get('positiveControl').get('batchCode')).toEqual "pos cont"
				it "should update the positiveControl conc ", ->
					@psapc.$('.bv_posControlConc').val(' 61 ')
					@psapc.$('.bv_posControlConc').change()
					expect(@psapc.model.get('positiveControl').get('concentration')).toEqual "61"
				it "should update the negativeControl ", ->
					@psapc.$('.bv_negControlBatch').val(' neg cont ')
					@psapc.$('.bv_negControlBatch').change()
					expect(@psapc.model.get('negativeControl').get('batchCode')).toEqual "neg cont"
				it "should update the negativeControl conc ", ->
					@psapc.$('.bv_negControlConc').val(' 62 ')
					@psapc.$('.bv_negControlConc').change()
					expect(@psapc.model.get('negativeControl').get('concentration')).toEqual "62"
				it "should update the vehicleControl ", ->
					@psapc.$('.bv_vehControlBatch').val(' veh cont ')
					@psapc.$('.bv_vehControlBatch').change()
					expect(@psapc.model.get('vehicleControl').get('batchCode')).toEqual "veh cont"
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




	xdescribe "Primary Screen Experiment Controller testing", ->
		describe "basic plumbing checks with new experiment", ->
			beforeEach ->
				@psec = new PrimaryScreenExperimentController
					model: new Experiment()
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
					expect(@psec.$('.bv_primaryScreenDataAnalysis .bv_posControlBatch').length).toNotEqual 0
				it "Should load a dose response controller", ->
					expect(@psec.$('.bv_doseResponseAnalysis .bv_fixCurveMin').length).toNotEqual 0
			describe "saving to server", ->
				beforeEach ->
					waitsFor =>
						@psec.$('.bv_protocolCode option').length > 0 && @psec.$('.bv_projectCode option').length > 0
					, 1000
					runs =>
						@psec.$('.bv_recordedBy').val("jmcneil")
						@psec.$('.bv_recordedBy').change()
						@psec.$('.bv_shortDescription').val(" New short description   ")
						@psec.$('.bv_shortDescription').change()
						@psec.$('.bv_description').val(" New long description   ")
						@psec.$('.bv_description').change()
						@psec.$('.bv_experimentName').val(" Updated experiment name   ")
						@psec.$('.bv_experimentName').change()
						@psec.$('.bv_recordedDate').val(" 2013-3-16   ")
						@psec.$('.bv_recordedDate').change()
						@psec.$('.bv_protocolCode').val("PROT-00000001")
						@psec.$('.bv_protocolCode').change()
					waits(500)
					runs =>
						@psec.$('.bv_useProtocolParameters').click()
						# must set notebook and project after copying protocol params because those are rest
						@psec.$('.bv_projectCode').val("project1")
						@psec.$('.bv_projectCode').change()
						@psec.$('.bv_notebook').val("my notebook")
						@psec.$('.bv_notebook').change()
						@psec.$('.bv_completionDate').val(" 2013-3-16   ")
						@psec.$('.bv_completionDate').change()
					waits(200)

	describe "Primary Screen Analysis Controller testing", ->
		describe "basic plumbing checks with experiment copied from template", ->
			beforeEach ->
				@exp = new Experiment()
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



	describe "Upload and Run Primary Analysis Controller testing", ->
		beforeEach ->
			@uarpac = new UploadAndRunPrimaryAnalsysisController
				el: $('#fixture')
			@uarpac.render()

		describe "Basic loading", ->
			it "Class should exist", ->
				expect(@uarpac).toBeDefined()
			it "Should load the template", ->
				expect(@uarpac.$('.bv_parseFile').length).toNotEqual 0




#TODO add agonist field