beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Primary Screen Experiment module testing", ->

	describe "Primary Analysis Read model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@par = new PrimaryAnalysisRead()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@par).toBeDefined()
				it "should have defaults", ->
					expect(@par.get('readOrder')).toBeNull()
					expect(@par.get('readName')).toEqual "unassigned"
					expect(@par.get('matchReadName')).toBeTruthy()
		describe "model validation tests", ->
			beforeEach ->
				@par = new PrimaryAnalysisRead window.primaryScreenTestJSON.primaryAnalysisReads[0]
			it "should be valid as initialized", ->
				expect(@par.isValid()).toBeTruthy()
			it "should be invalid when read order is NaN", ->
				@par.set readOrder: NaN
				expect(@par.isValid()).toBeFalsy()
				filtErrors = _.filter(@par.validationError, (err) ->
					err.attribute=='readOrder'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when read name is unassigned", ->
				@par.set readName: "unassigned"
				expect(@par.isValid()).toBeFalsy()
				filtErrors = _.filter(@par.validationError, (err) ->
					err.attribute=='readName'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe "Primary Analysis Read List testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@parl = new PrimaryAnalysisReadList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@parl).toBeDefined()

	describe "Analysis Parameter model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@psap = new PrimaryScreenAnalysisParameters()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@psap).toBeDefined()
				it "should have defaults", ->
					expect(@psap.get('assayVolume')).toBeNull()
					expect(@psap.get('transferVolume')).toBeNull()
					expect(@psap.get('dilutionFactor')).toBeNull()
					expect(@psap.get('volumeType')).toEqual "dilution"
					expect(@psap.get('instrumentReader')).toEqual "unassigned"
					expect(@psap.get('signalDirectionRule')).toEqual "unassigned"
					expect(@psap.get('aggregateBy1')).toEqual "unassigned"
					expect(@psap.get('aggregateBy2')).toEqual "unassigned"
					expect(@psap.get('transformationRule')).toEqual "unassigned"
					expect(@psap.get('normalizationRule')).toEqual "unassigned"
					expect(@psap.get('hitEfficacyThreshold')).toBeNull()
					expect(@psap.get('hitSDThreshold')).toBeNull()
					expect(@psap.get('positiveControl') instanceof Backbone.Model).toBeTruthy()
					expect(@psap.get('negativeControl') instanceof Backbone.Model).toBeTruthy()
					expect(@psap.get('vehicleControl') instanceof Backbone.Model).toBeTruthy()
					expect(@psap.get('agonistControl') instanceof Backbone.Model).toBeTruthy()
					expect(@psap.get('thresholdType')).toEqual "sd"
					expect(@psap.get('autoHitSelection')).toBeTruthy()
					expect(@psap.get('primaryAnalysisReadList') instanceof PrimaryAnalysisReadList).toBeTruthy()

		describe "When loaded form existing", ->
			beforeEach ->
				@psap = new PrimaryScreenAnalysisParameters window.primaryScreenTestJSON.primaryScreenAnalysisParameters
			describe "composite object creation", ->
				it "should convert readlist to PrimaryAnalysisReadList", ->
					expect( @psap.get('primaryAnalysisReadList') instanceof PrimaryAnalysisReadList).toBeTruthy()
			describe "model validation tests", ->
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
				it "should be invalid when assayVolume is NaN", ->
					@psap.set assayVolume: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter(@psap.validationError, (err) ->
						err.attribute=='assayVolume'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when instrument reader is unassigned", ->
					@psap.set instrumentReader: "unassigned"
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter(@psap.validationError, (err) ->
						err.attribute=='instrumentReader'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when aggregate by1 is unassigned", ->
					@psap.set aggregateBy1: "unassigned"
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter(@psap.validationError, (err) ->
						err.attribute=='aggregateBy1'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when aggregate by2 is unassigned", ->
					@psap.set aggregateBy2: "unassigned"
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter(@psap.validationError, (err) ->
						err.attribute=='aggregateBy2'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when signal direction rule is unassigned", ->
					@psap.set signalDirectionRule: "unassigned"
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter(@psap.validationError, (err) ->
						err.attribute=='signalDirectionRule'
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
				it "should be invalid when volumeType is dilution and dilutionFactor is not a number", ->
					@psap.set volumeType: "dilution"
					@psap.set dilutionFactor: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter(@psap.validationError, (err) ->
						err.attribute=='dilutionFactor'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when volumeType is transfer and transferVolume is not a number", ->
					@psap.set volumeType: "transfer"
					@psap.set transferVolume: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter(@psap.validationError, (err) ->
						err.attribute=='transferVolume'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when autoHitSelection is checked and thresholdType is sd and hitSDThreshold is not a number", ->
					@psap.set autoHitSelection: true
					@psap.set thresholdType: "sd"
					@psap.set hitSDThreshold: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter(@psap.validationError, (err) ->
						err.attribute=='hitSDThreshold'
					)
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when autoHitSelection is checked and thresholdType is efficacy and hitEfficacyThreshold is not a number", ->
					@psap.set autoHitSelection: true
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
						expect(@pse.getAnalysisParameters().get('dilutionFactor')).toEqual 21
					it 'Should parse pos control into backbone models', ->
						expect(@pse.getAnalysisParameters().get('positiveControl').get('batchCode')).toEqual "CMPD-12345678-01"
					it 'Should parse neg control into backbone models', ->
						expect(@pse.getAnalysisParameters().get('negativeControl').get('batchCode')).toEqual "CMPD-87654321-01"
					it 'Should parse veh control into backbone models', ->
						expect(@pse.getAnalysisParameters().get('vehicleControl').get('batchCode')).toEqual "CMPD-00000001-01"
					it 'Should parse agonist control into backbone models', ->
						expect(@pse.getAnalysisParameters().get('agonistControl').get('batchCode')).toEqual "CMPD-87654399-01"
				describe "model fit parameters", ->
					it 'Should be able to get model parameters', ->
						# this is not hydrated into a specific model type at this level, it is passed to the specific curve fit class for that
						expect(@pse.getModelFitParameters().inverseAgonistMode ).toBeTruthy()
				describe "special states", ->
					it "should be able to get the analysis status", ->
						expect(@pse.getAnalysisStatus().get('stringValue')).toEqual "not started"
					it "should be able to get the analysis result html", ->
						expect(@pse.getAnalysisResultHTML().get('clobValue')).toEqual "<p>Analysis not yet completed</p>"
					it "should be able to get the model fit status", ->
						expect(@pse.getModelFitStatus().get('stringValue')).toEqual "not started"
					it "should be able to get the model result html", ->
						expect(@pse.getModelFitResultHTML().get('clobValue')).toEqual "<p>Model fit not yet completed</p>"
		describe "When loaded from new", ->
			beforeEach ->
				@pse2 = new PrimaryScreenExperiment()
			describe "special states", ->
				it "should be able to get the analysis status", ->
					expect(@pse2.getAnalysisStatus().get('stringValue')).toEqual "not started"
				it "should be able to get the analysis result html", ->
					expect(@pse2.getAnalysisResultHTML().get('clobValue')).toEqual ""
				it "should be able to get the model fit status", ->
					expect(@pse2.getModelFitStatus().get('stringValue')).toEqual "not started"
				it "should be able to get the model result html", ->
					expect(@pse2.getModelFitResultHTML().get('clobValue')).toEqual ""

	describe "PrimaryAnalysisReadController", ->
		describe "when instantiated", ->
			beforeEach ->
				@parc = new PrimaryAnalysisReadController
					model: new PrimaryAnalysisRead window.primaryScreenTestJSON.primaryAnalysisReads[0]
					el: $('#fixture')
				@parc.render()
			describe "basic existance tests", ->
				it "should exist", ->
					expect(@parc).toBeDefined()
				it "should load a template", ->
					expect(@parc.$('.bv_readName').length).toEqual 1
			describe "render existing parameters", ->
				it "should show read order", ->
					expect(@parc.$('.bv_readOrder').val()).toEqual "11"
				it "should show read name", ->
					waitsFor ->
						@parc.$('.bv_readName option').length > 0
					, 1000
					runs ->
						expect(@parc.$('.bv_readName').val()).toEqual "luminescence"
				it "should have Match Read Name checked", ->
					expect(@parc.$('.bv_matchReadName').attr("checked")).toEqual "checked"
			describe "model updates", ->
				it "should update the readOrder ", ->
					@parc.$('.bv_readOrder').val( '42' )
					@parc.$('.bv_readOrder').change()
					expect(@parc.model.get('readOrder')).toEqual '42'
				it "should update the read name", ->
					waitsFor ->
						@parc.$('.bv_readName option').length > 0
					, 1000
					runs ->
						@parc.$('.bv_readName').val('unassigned')
						@parc.$('.bv_readName').change()
						expect(@parc.model.get('readName')).toEqual "unassigned"
				it "should update the matchReadName ", ->
					@parc.$('.bv_matchReadName').click()
					expect(@parc.model.get('matchReadName')).toBeFalsy()
		describe "validation testing", ->
			beforeEach ->
				@parc = new PrimaryAnalysisReadController
					model: new PrimaryAnalysisRead window.primaryScreenTestJSON.primaryAnalysisReads[0]
					el: $('#fixture')
				@parc.render()
			describe "error notification", ->
				it "should show error if readOrder is NaN", ->
					@parc.$('.bv_readOrder').val ""
					@parc.$('.bv_readOrder').change()
					expect(@parc.$('.bv_group_readOrder').hasClass("error")).toBeTruthy()
				it "should show error if read name is unassigned", ->
					waitsFor ->
						@parc.$('.bv_readName option').length > 0
					, 1000
					runs ->
						@parc.$('.bv_readName').val "unassigned"
						@parc.$('.bv_readName').change()
						expect(@parc.$('.bv_group_readName').hasClass("error")).toBeTruthy()



	describe "Primary Analysis Read List Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@parlc= new PrimaryAnalysisReadListController
					el: $('#fixture')
					collection: new PrimaryAnalysisReadList()
				@parlc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@parlc).toBeDefined()
				it "should load a template", ->
					expect(@parlc.$('.bv_addReadButton').length).toEqual 1
			describe "rendering", ->
				it "should show one read", ->
					expect(@parlc.$('.bv_readInfo .bv_readName').length).toEqual 1
					expect(@parlc.collection.length).toEqual 1
			describe "adding and removing", ->
				it "should have two reads when add read is clicked", ->
					@parlc.$('.bv_addReadButton').click()
					expect(@parlc.$('.bv_readInfo .bv_readName').length).toEqual 2
					expect(@parlc.collection.length).toEqual 2
				it "should have no reads when there is one read and remove is clicked", ->
					expect(@parlc.collection.length).toEqual 1
					@parlc.$('.bv_delete').click()
					expect(@parlc.$('.bv_readInfo .bv_readName').length).toEqual 0
					expect(@parlc.collection.length).toEqual 0
				it "should have one read when there are two reads and remove is clicked", ->
					@parlc.$('.bv_addReadButton').click()
					expect(@parlc.$('.bv_readInfo .bv_readName').length).toEqual 2
					@parlc.$('.bv_delete:eq(0)').click()
					expect(@parlc.$('.bv_readInfo .bv_readName').length).toEqual 1
					expect(@parlc.collection.length).toEqual 1
		describe "when instantiated with data", ->
			beforeEach ->
				@parlc= new PrimaryAnalysisReadListController
					el: $('#fixture')
					collection: new PrimaryAnalysisReadList window.primaryScreenTestJSON.primaryAnalysisReads
				@parlc.render()
			it "should have three reads", ->
				expect(@parlc.collection.length).toEqual 3
			it "should have the correct read info for the first read", ->
				readone = @parlc.collection.at(0)
				expect(readone.get('readOrder')).toEqual 11
				expect(readone.get('readName')).toEqual "luminescence"
				expect(readone.get('matchReadName')).toBeTruthy()
			it "should have the correct read info for the second read", ->
				readtwo = @parlc.collection.at(1)
				expect(readtwo.get('readOrder')).toEqual 12
				expect(readtwo.get('readName')).toEqual "fluorescence"
				expect(readtwo.get('matchReadName')).toBeTruthy()
			it "should have the correct read info for the third read", ->
				readthree = @parlc.collection.at(2)
				expect(readthree.get('readOrder')).toEqual 13
				expect(readthree.get('readName')).toEqual "other read name"
				expect(readthree.get('matchReadName')).toBeFalsy()

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
				it 'should show the instrumentReader', ->
					waitsFor ->
						@psapc.$('.bv_instrumentReader option').length > 0
					, 1000
					runs ->
						expect(@psapc.$('.bv_instrumentReader').val()).toEqual "flipr"
				it 'should show the signal direction rule', ->
					waitsFor ->
						@psapc.$('.bv_signalDirectionRule option').length > 0
					, 1000
					runs ->
						expect(@psapc.$('.bv_signalDirectionRule').val()).toEqual "increasing signal (highest = 100%)"
				it 'should show the aggregateBy1', ->
					waitsFor ->
						@psapc.$('.bv_aggregateBy1 option').length > 0
					, 1000
					runs ->
						expect(@psapc.$('.bv_aggregateBy1').val()).toEqual "compound batch concentration"
				it 'should show the aggregateBy2', ->
					waitsFor ->
						@psapc.$('.bv_aggregateBy2 option').length > 0
					, 1000
					runs ->
						expect(@psapc.$('.bv_aggregateBy2').val()).toEqual "median"
				it 'should show the transformation rule', ->
					waitsFor ->
						@psapc.$('.bv_transformationRule option').length > 0
					, 1000
					runs ->
						expect(@psapc.$('.bv_transformationRule').val()).toEqual "(maximum-minimum)/minimum"
				it 'should show the normalization rule', ->
					waitsFor ->
						@psapc.$('.bv_normalizationRule option').length > 0
					, 1000
					runs ->
						expect(@psapc.$('.bv_normalizationRule').val()).toEqual "plate order"
				it 'should show the assayVolume', ->
					expect(@psapc.$('.bv_assayVolume').val()).toEqual '24'
				it 'should show the transferVolume', ->
					expect(@psapc.$('.bv_transferVolume').val()).toEqual '12'
				it 'should show the dilutionFactor', ->
					expect(@psapc.$('.bv_dilutionFactor').val()).toEqual '21'
				it 'should start with volumeType radio set', ->
					expect(@psapc.$("input[name='bv_volumeType']:checked").val()).toEqual 'dilution'
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
					expect(@psapc.$('.bv_agonistControlConc').val()).toEqual '250753.77'
				it 'should start with autoHitSelection unchecked', ->
					expect(@psapc.$('.bv_autoHitSelection').attr("checked")).toBeUndefined()
				it 'should show the hitSDThreshold', ->
					expect(@psapc.$('.bv_hitSDThreshold').val()).toEqual '5'
				it 'should show the hitEfficacyThreshold', ->
					expect(@psapc.$('.bv_hitEfficacyThreshold').val()).toEqual '42'
				it 'should start with thresholdType radio set', ->
					expect(@psapc.$("input[name='bv_thresholdType']:checked").val()).toEqual 'sd'
				it 'should hide threshold controls if the model loads unchecked automaticHitSelection', ->
					expect(@psapc.$('.bv_thresholdControls')).toBeHidden()
				it 'should show a primary analysis read list', ->
					expect(@psapc.$('.bv_readInfo .bv_readName').length).toEqual 3
			describe "model updates", ->
				it "should update the instrument reader", ->
					waitsFor ->
						@psapc.$('.bv_instrumentReader option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_instrumentReader').val('unassigned')
						@psapc.$('.bv_instrumentReader').change()
						expect(@psapc.model.get('instrumentReader')).toEqual "unassigned"
				it "should update the signal direction rule", ->
					waitsFor ->
						@psapc.$('.bv_signalDirectionRule option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_signalDirectionRule').val('unassigned')
						@psapc.$('.bv_signalDirectionRule').change()
						expect(@psapc.model.get('signalDirectionRule')).toEqual "unassigned"
				it "should update the aggregateBy1", ->
					waitsFor ->
						@psapc.$('.bv_aggregateBy1 option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_aggregateBy1').val('unassigned')
						@psapc.$('.bv_aggregateBy1').change()
						expect(@psapc.model.get('aggregateBy1')).toEqual "unassigned"
				it "should update the bv_aggregateBy2", ->
					waitsFor ->
						@psapc.$('.bv_aggregateBy2 option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_aggregateBy2').val('unassigned')
						@psapc.$('.bv_aggregateBy2').change()
						expect(@psapc.model.get('aggregateBy2')).toEqual "unassigned"
				it "should update the transformation rule", ->
					waitsFor ->
						@psapc.$('.bv_transformationRule option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_transformationRule').val('unassigned')
						@psapc.$('.bv_transformationRule').change()
						expect(@psapc.model.get('transformationRule')).toEqual "unassigned"
				it "should update the normalizationRule rule", ->
					waitsFor ->
						@psapc.$('.bv_normalizationRule option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_normalizationRule').val('unassigned')
						@psapc.$('.bv_normalizationRule').change()
						expect(@psapc.model.get('normalizationRule')).toEqual "unassigned"
				it "should update the assayVolume ", ->
					@psapc.$('.bv_assayVolume').val(' 24 ')
					@psapc.$('.bv_assayVolume').change()
					expect(@psapc.model.get('assayVolume')).toEqual 24
				it "should update the transferVolume ", ->
					@psapc.$('.bv_transferVolume').val(' 12 ')
					@psapc.$('.bv_transferVolume').change()
					expect(@psapc.model.get('transferVolume')).toEqual 12
				it "should update the dilution factor ", ->
					@psapc.$('.bv_dilutionFactor').val(' 21 ')
					@psapc.$('.bv_dilutionFactor').change()
					expect(@psapc.model.get('dilutionFactor')).toEqual 21
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
					@psapc.$('.bv_positiveControlConc').val(' 250753.77 ')
					@psapc.$('.bv_positiveControlConc').change()
					expect(@psapc.model.get('positiveControl').get('concentration')).toEqual 250753.77
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
					expect(@psapc.model.get('agonistControl').get('concentration')).toEqual 250753.77
				it "should update the thresholdType ", ->
					@psapc.$('.bv_thresholdTypeEfficacy').click()
					expect(@psapc.model.get('thresholdType')).toEqual "efficacy"
				it "should update the volumeType ", ->
					@psapc.$('.bv_volumeTypeTransfer').click()
					expect(@psapc.model.get('volumeType')).toEqual "transfer"
				it "should update the autoHitSelection ", ->
					@psapc.$('.bv_autoHitSelection').click()
					expect(@psapc.model.get('autoHitSelection')).toBeTruthy()

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
				it "should disable dilutionFactor field if that radio not selected", ->
					@psapc.$('.bv_volumeTypeTransfer').click()
					expect(@psapc.$('.bv_dilutionFactor').attr("disabled")).toEqual "disabled"
					expect(@psapc.$('.bv_transferVolume').attr("disabled")).toBeUndefined()
				it "should disable transferVolume if that radio not selected", ->
					@psapc.$('.bv_volumeTypeTransfer').click()
					@psapc.$('.bv_volumeTypeDilution').click()
					expect(@psapc.$('.bv_transferVolume').attr("disabled")).toEqual "disabled"
					expect(@psapc.$('.bv_dilutionFactor').attr("disabled")).toBeUndefined()
		describe "validation testing", ->
			beforeEach ->
				@psapc = new PrimaryScreenAnalysisParametersController
					model: new PrimaryScreenAnalysisParameters window.primaryScreenTestJSON.primaryScreenAnalysisParameters
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
				it "should show error if instrumentReader is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_instrumentReader option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_instrumentReader').val "unassigned"
						@psapc.$('.bv_instrumentReader').change()
						expect(@psapc.$('.bv_group_instrumentReader').hasClass("error")).toBeTruthy()
				it "should show error if signal direction rule is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_signalDirectionRule option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_signalDirectionRule').val "unassigned"
						@psapc.$('.bv_signalDirectionRule').change()
						expect(@psapc.$('.bv_group_signalDirectionRule').hasClass("error")).toBeTruthy()
				it "should show error if aggregateBy1 is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_aggregateBy1 option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_aggregateBy1').val "unassigned"
						@psapc.$('.bv_aggregateBy1').change()
						expect(@psapc.$('.bv_group_aggregateBy1').hasClass("error")).toBeTruthy()
				it "should show error if aggregateBy2 is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_aggregateBy2 option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_aggregateBy2').val "unassigned"
						@psapc.$('.bv_aggregateBy2').change()
						expect(@psapc.$('.bv_group_aggregateBy2').hasClass("error")).toBeTruthy()
				it "should show error if transformationRule is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_transformationRule option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_transformationRule').val "unassigned"
						@psapc.$('.bv_transformationRule').change()
						expect(@psapc.$('.bv_group_transformationRule').hasClass("error")).toBeTruthy()
				it "should show error if normalizationRule is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_normalizationRule option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_normalizationRule').val "unassigned"
						@psapc.$('.bv_normalizationRule').change()
						expect(@psapc.$('.bv_group_normalizationRule').hasClass("error")).toBeTruthy()
				it "should show error if threshold type is efficacy and efficacy threshold not a number", ->
					@psapc.$('.bv_thresholdTypeEfficacy').click()
					@psapc.$('.bv_hitEfficacyThreshold').val ""
					@psapc.$('.bv_hitEfficacyThreshold').change()
					expect(@psapc.$('.bv_group_hitEfficacyThreshold').hasClass("error")).toBeTruthy()
				it "should show error if threshold type is sd and sd threshold not a number", ->
					@psapc.$('.bv_thresholdTypeSD').click()
					@psapc.$('.bv_hitSDThreshold').val ""
					@psapc.$('.bv_hitSDThreshold').change()
					expect(@psapc.$('.bv_group_hitSDThreshold').hasClass("error")).toBeTruthy()
				it "should show error if volume type is transferVolume and transferVolume not a number", ->
					@psapc.$('.bv_volumeTypeTransfer').click()
					@psapc.$('.bv_transferVolume').val ""
					@psapc.$('.bv_transferVolume').change()
					expect(@psapc.$('.bv_group_transferVolume').hasClass("error")).toBeTruthy()
				it "should show error if volume type is dilutionFactor and dilutionFactor not a number", ->
					@psapc.$('.bv_volumeTypeDilution').click()
					@psapc.$('.bv_dilutionFactor').val ""
					@psapc.$('.bv_dilutionFactor').change()
					expect(@psapc.$('.bv_group_dilutionFactor').hasClass("error")).toBeTruthy()
				it "should show error if assayVolume is NaN", ->
					@psapc.$('.bv_assayVolume').val ""
					@psapc.$('.bv_assayVolume').change()
					expect(@psapc.$('.bv_group_assayVolume').hasClass("error")).toBeTruthy()
				it "should show error if assayVolume is NaN", ->
					@psapc.$('.bv_assayVolume').val ""
					@psapc.$('.bv_assayVolume').change()
					expect(@psapc.$('.bv_group_assayVolume').hasClass("error")).toBeTruthy()




	describe "Abstract Upload and Run Primary Analysis Controller testing", ->
		describe "Basic loading", ->
			it "Class should exist", ->
				expect(window.AbstractUploadAndRunPrimaryAnalsysisController).toBeDefined()

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
					uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
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
					expect(@psac.$('.bv_resultsContainer')).toBeHidden()
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
					uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
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
					uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
				@psac.render()
			it "should show upload button as re-analyze since status is not 'not started'", ->
				expect(@psac.$('.bv_save').html()).toEqual "Re-Analyze"


	describe "Abstract Primary Screen Experiment Controller testing", ->
		describe "Basic loading", ->
			it "Class should exist", ->
				expect(window.AbstractPrimaryScreenExperimentController).toBeDefined()

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
				it "Should load a dose response controller", ->
					expect(@psec.$('.bv_doseResponseAnalysis .bv_fitModelButton').length).toNotEqual 0




#TODO Validation rules for different threshold modes





