beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Primary Screen Experiment module testing", ->
	describe "Primary Screen Experiment Controller testing", ->
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
					expect(@psec.$('.bv_primaryScreenDataAnalysis .bv_positiveControlBatch').length).toNotEqual 0
				it "Should load a dose response controller", ->
					expect(@psec.$('.bv_doseResponseAnalysis .bv_fixCurveMin').length).toNotEqual 0
			describe "saving to server", ->
				beforeEach ->
					runs ->
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

				describe "expect save to work", ->
					it "model should be valid and ready to save", ->
						expect(@psec.model.isValid()).toBeTruthy()
					it "should update experiment code", ->
						runs ->
							@psec.$('.bv_save').click()
						waits(100)
						runs ->
							expect(@psec.$('.bv_experimentCode').html()).toEqual "EXPT-00000001"

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
					expect(@psac.$('.bv_positiveControlBatch').length).toNotEqual 0
				it "Should load a data loader", ->
					expect(@psac.$('.bv_fileUploadWrapper').length).toNotEqual 0
			describe "should populate fields", ->
				it "should show the threshold", ->
					expect(@psac.$('.bv_hitThreshold').val()).toEqual '0.7'
			describe "parameter editing", ->
				it "should update the model with when the threshold is changed", ->
					@psac.$('.bv_hitThreshold').val('0.8')
					@psac.$('.bv_hitThreshold').change()
					value = @psac.model.get('lsStates').getStateValueByTypeAndKind "metadata", "experiment analysis parameters", "numericValue", "active efficacy threshold"
					expect(value.get('numericValue')).toEqual 0.8

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




#TODO Save button should be disabled if everyone not validated
#TODO Save button should change to update for existing experiment.
#TODO Need to update by field, not meta experiment