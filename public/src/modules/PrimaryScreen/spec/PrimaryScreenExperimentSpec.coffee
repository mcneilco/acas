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
					expect(@par.get('readNumber')).toEqual 1
					expect(@par.get('readPosition')).toEqual ""
					expect(@par.get('readName')).toEqual "unassigned"
					expect(@par.get('activity')).toBeFalsy()
		describe "model validation tests", ->
			beforeEach ->
				@par = new PrimaryAnalysisRead window.primaryScreenTestJSON.primaryAnalysisReads[0]
			it "should be valid as initialized", ->
				expect(@par.isValid()).toBeTruthy()
			it "should be invalid when read position is text and read name is not calculated", ->
				@par.set readPosition: "text"
				expect(@par.isValid()).toBeFalsy()
				filtErrors = _.filter @par.validationError, (err) ->
					err.attribute=='readPosition'
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be valid when read position is '' and read name is a calculated read", ->
				@par.set
					readPosition: ''
					readName: 'Calc: (maximum-minimum)/minimum'
				expect(@par.isValid()).toBeTruthy()
				filtErrors = _.filter @par.validationError, (err) ->
					err.attribute=='readPosition'
				expect(filtErrors.length).toEqual 0
			it "should be invalid when read name is unassigned", ->
				@par.set readName: "unassigned"
				expect(@par.isValid()).toBeFalsy()
				filtErrors = _.filter @par.validationError, (err) ->
					err.attribute=='readName'
				expect(filtErrors.length).toBeGreaterThan 0


	describe "Primary Analysis Time Window model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@par = new PrimaryAnalysisTimeWindow()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@par).toBeDefined()
				it "should have defaults", ->
					expect(@par.get('position')).toEqual 1
					expect(@par.get('statistic')).toEqual "max"
					expect(@par.get('windowStart')).toBeFalsy()
					expect(@par.get('windowEnd')).toBeFalsy()
					expect(@par.get('unit')).toEqual "s"
		describe "model validation tests", ->
			beforeEach ->
				@par = new PrimaryAnalysisTimeWindow window.primaryScreenTestJSON.primaryAnalysisTimeWindows[0]
			it "should be valid as initialized", ->
				expect(@par.isValid()).toBeTruthy()
			it "should be invalid when window start is NaN", ->
				@par.set windowStart: NaN
				expect(@par.isValid()).toBeFalsy()
				filteredErrors = _.filter @par.validationError, (err) ->
					err.attribute=='timeWindowStart'
				expect(filteredErrors.length).toBeGreaterThan 0
			it "should be invalid when window end is text", ->
				@par.set windowStart: 0
				@par.set windowEnd: "the end of the world as we know it..."
				expect(@par.isValid()).toBeFalsy()
				filteredErrors = _.filter @par.validationError, (err) ->
					err.attribute=='timeWindowEnd'
				expect(filteredErrors.length).toBeGreaterThan 0

	describe "Standard Compound model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@sc = new StandardCompound()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@sc).toBeDefined()
				it "should have defaults", ->
					expect(@sc.get('batchCode')).toEqual ""
					expect(@sc.get('concentration')).toEqual ""
					expect(@sc.get('concentrationUnits')).toEqual "uM"
					expect(@sc.get('standardType')).toEqual ""
		describe "model validation tests", ->
			beforeEach ->
				@sc = new StandardCompound window.primaryScreenTestJSON.standards[0]
			it "should be valid as initialized", ->
				expect(@sc.isValid()).toBeTruthy()
			it "should be invalid when positive control batch is empty", ->
				@sc.set
					batchCode: ""
				expect(@sc.isValid()).toBeFalsy()
				filtErrors = _.filter @sc.validationError, (err) ->
					err.attribute=='batchCode'
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when concentration is NaN", ->
				@sc.set
					concentration: NaN
				expect(@sc.isValid()).toBeFalsy()
				filtErrors = _.filter @sc.validationError, (err) ->
					err.attribute=='concentration'
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be valid when batchCode is entered and concentration is ''", ->
				@sc.set
					batchCode:"CMPD-87654399-01"
					concentration: ''
				expect(@sc.isValid()).toBeTruthy()

	describe "Additive model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@par = new Additive()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@par).toBeDefined()
				it "should have defaults", ->
					expect(@par.get('batchCode')).toEqual ""
					expect(@par.get('concentration')).toEqual ""
					expect(@par.get('concentrationUnits')).toEqual "uM"
					expect(@par.get('additiveType')).toEqual ""
		describe "model validation tests", ->
			beforeEach ->
				@par = new Additive window.primaryScreenTestJSON.additives[0]
			it "should be valid as initialized", ->
				expect(@par.isValid()).toBeTruthy()

	describe "Transformation Rule Model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@tr = new TransformationRule()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@tr).toBeDefined()
				it "should have defaults", ->
					expect(@tr.get('transformationRule')).toEqual "unassigned"
		describe "model validation tests", ->
			beforeEach ->
				@tr = new TransformationRule window.primaryScreenTestJSON.transformationRules[0]
			it "should be valid as initialized", ->
				expect(@tr.isValid()).toBeTruthy()
			it "should be invalid when transformation rule is unassigned", ->
				@tr.set transformationRule: "unassigned"
				expect(@tr.isValid()).toBeFalsy()
				filtErrors = _.filter @tr.validationError, (err) ->
					err.attribute=='transformationRule'
				expect(filtErrors.length).toBeGreaterThan 0

	describe "Primary Analysis Read List testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@parl = new PrimaryAnalysisReadList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@parl).toBeDefined()
		describe "When loaded from existing", ->
			beforeEach ->
				@parl = new PrimaryAnalysisReadList window.primaryScreenTestJSON.primaryAnalysisReads
			it "should have three reads", ->
				expect(@parl.length).toEqual 3
			it "should have the correct read info for the first read", ->
				readone = @parl.at(0)
				expect(readone.get('readNumber')).toEqual 1
				expect(readone.get('readPosition')).toEqual 11
				expect(readone.get('readName')).toEqual "none"
				expect(readone.get('activity')).toBeTruthy()
			it "should have the correct read info for the second read", ->
				readtwo = @parl.at(1)
				expect(readtwo.get('readNumber')).toEqual 2
				expect(readtwo.get('readPosition')).toEqual 12
				expect(readtwo.get('readName')).toEqual "fluorescence"
				expect(readtwo.get('activity')).toBeFalsy()
			it "should have the correct read info for the third read", ->
				readthree = @parl.at(2)
				expect(readthree.get('readNumber')).toEqual 3
				expect(readthree.get('readPosition')).toEqual 13
				expect(readthree.get('readName')).toEqual "luminescence"
				expect(readthree.get('activity')).toBeFalsy()

	describe "Primary Analysis Time Window List testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@parl = new PrimaryAnalysisTimeWindowList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@parl).toBeDefined()
		describe "When loaded from existing", ->
			beforeEach ->
				@parl = new PrimaryAnalysisTimeWindowList window.primaryScreenTestJSON.primaryAnalysisTimeWindows
			it "should have three reads", ->
				expect(@parl.length).toEqual 3
			it "should have the correct read info for the first read", ->
				@par = @parl.at(0)
				expect(@par.get('position')).toEqual 1
				expect(@par.get('statistic')).toEqual "max"
				expect(@par.get('windowStart')).toEqual -5
				expect(@par.get('windowEnd')).toEqual 5
				expect(@par.get('unit')).toEqual "s"
			it "should have the correct read info for the second read", ->
				@par = @parl.at(1)
				expect(@par.get('position')).toEqual 2
				expect(@par.get('statistic')).toEqual "min"
				expect(@par.get('windowStart')).toEqual 0
				expect(@par.get('windowEnd')).toEqual 15
				expect(@par.get('unit')).toEqual "s"
			it "should have the correct read info for the third read", ->
				@par = @parl.at(2)
				expect(@par.get('position')).toEqual 3
				expect(@par.get('statistic')).toEqual "max"
				expect(@par.get('windowStart')).toEqual 20
				expect(@par.get('windowEnd')).toEqual 50
				expect(@par.get('unit')).toEqual "s"



	describe "Transformation Rule List testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@trl = new TransformationRuleList()
			describe "Existence", ->
				it "should be defined", ->
					expect(@trl).toBeDefined()
		describe "When loaded form existing", ->
			beforeEach ->
				@trl = new TransformationRuleList window.primaryScreenTestJSON.transformationRules
			it "should have three reads", ->
				expect(@trl.length).toEqual 3
			it "should have the correct rule info for the first rule", ->
				ruleone = @trl.at(0)
				expect(ruleone.get('transformationRule')).toEqual "% efficacy"
			it "should have the correct read info for the second rule", ->
				ruletwo = @trl.at(1)
				expect(ruletwo.get('transformationRule')).toEqual "sd"
			it "should have the correct read info for the third read", ->
				rulethree = @trl.at(2)
				expect(rulethree.get('transformationRule')).toEqual "null"
		describe "collection validation", ->
			beforeEach ->
				@trl= new TransformationRuleList window.primaryScreenTestJSON.transformationRules
			it "should be invalid if a transformation rule is selected more than once", ->
				@trl.at(0).set transformationRule: "sd"
				@trl.at(1).set transformationRule: "sd"
				expect((@trl.validateCollection()).length).toBeGreaterThan 0

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
					expect(@psap.get('aggregateBy')).toEqual "unassigned"
					expect(@psap.get('aggregationMethod')).toEqual "unassigned"
					expect(@psap.get('normalization').get('normalizationRule')).toEqual "unassigned"
					expect(@psap.get('hitEfficacyThreshold')).toBeNull()
					expect(@psap.get('hitSDThreshold')).toBeNull()
					expect(@psap.get('standardCompoundList') instanceof StandardCompoundList).toBeTruthy()
					expect(@psap.get('additiveList') instanceof AdditiveList).toBeTruthy()
					expect(@psap.get('thresholdType')).toEqual null
					expect(@psap.get('autoHitSelection')).toBeFalsy()
					expect(@psap.get('htsFormat')).toBeTruthy()
					expect(@psap.get('matchReadName')).toBeFalsy()
					expect(@psap.get('fluorescentStart')).toBeNull()
					expect(@psap.get('fluorescentEnd')).toBeNull()
					expect(@psap.get('fluorescentStep')).toBeNull()
					expect(@psap.get('latePeakTime')).toBeNull()
					expect(@psap.get('primaryAnalysisReadList') instanceof PrimaryAnalysisReadList).toBeTruthy()
					expect(@psap.get('transformationRuleList') instanceof TransformationRuleList).toBeTruthy()
		describe "When loaded from existing", ->
			beforeEach ->
				@psap = new PrimaryScreenAnalysisParameters window.primaryScreenTestJSON.primaryScreenAnalysisParameters
			describe "composite object creation", ->
				it "should convert readlist to PrimaryAnalysisReadList", ->
					expect( @psap.get('primaryAnalysisReadList') instanceof PrimaryAnalysisReadList).toBeTruthy()
				it "should convert transformationRuleList to TransformationRuleList", ->
					expect( @psap.get('transformationRuleList') instanceof TransformationRuleList).toBeTruthy()
				it "should convert transformationRuleList to TransformationRuleList", ->
					expect( @psap.get('transformationRuleList') instanceof TransformationRuleList).toBeTruthy()
				it "should convert standardCompoundList to StandardCompoundList", ->
					expect( @psap.get('standardCompoundList') instanceof StandardCompoundList).toBeTruthy()
				it "should convert additiveList to AdditiveList", ->
					expect( @psap.get('additiveList') instanceof AdditiveList).toBeTruthy()
				it "should convert normalization to Normalization", ->
					expect( @psap.get('normalization') instanceof Normalization).toBeTruthy()
			describe "model validation tests", ->
				it "should be valid as initialized", ->
					expect(@psap.isValid()).toBeTruthy()
				it "should be invalid when assayVolume is NaN (but can be empty)", ->
					@psap.set assayVolume: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='assayVolume'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when assayVolume is not set but transfer volume is set", ->
					@psap.set assayVolume: ""
					@psap.set dilutionFactor: ""
					@psap.set transferVolume: 40
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='assayVolume'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be valid when assayVolume, transfer volume, and dilution factors are empty", ->
					@psap.set assayVolume: ""
					@psap.set transferVolume: ""
					@psap.set dilutionFactor: ""
					expect(@psap.isValid()).toBeTruthy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='assayVolume'
					expect(filtErrors.length).toEqual 0
				it "should be invalid when instrument reader is unassigned", ->
					@psap.set instrumentReader: "unassigned"
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='instrumentReader'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when aggregate by is unassigned", ->
					@psap.set aggregateBy: "unassigned"
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='aggregateBy'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when aggregatation method is unassigned", ->
					@psap.set aggregationMethod: "unassigned"
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='aggregationMethod'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when signal direction rule is unassigned", ->
					@psap.set signalDirectionRule: "unassigned"
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='signalDirectionRule'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when normalization rule is unassigned", ->
					@psap.get('normalization').set normalizationRule: "unassigned"
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='normalizationRule'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when fluorescentStart is NaN (but can be empty)", ->
					@psap.set fluorescentStart: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='fluorescentStart'
				it "should be invalid when fluorescentEnd is NaN (but can be empty)", ->
					@psap.set fluorescentEnd: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='fluorescentEnd'
				it "should be invalid when fluorescentStep is NaN (but can be empty)", ->
					@psap.set fluorescentStep: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='fluorescentStep'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when latePeakTime is NaN (but can be empty)", ->
					@psap.set latePeakTime: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='latePeakTime'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when volumeType is dilution and dilutionFactor is not a number (but can be empty)", ->
					@psap.set volumeType: "dilution"
					@psap.set dilutionFactor: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='dilutionFactor'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be valid when volumeType is dilution and dilutionFactor is empty", ->
					@psap.set volumeType: "dilution"
					@psap.set dilutionFactor: ""
					expect(@psap.isValid()).toBeTruthy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='dilutionFactor'
					expect(filtErrors.length).toEqual 0
				it "should be invalid when volumeType is transfer and transferVolume is not a number (but can be empty)", ->
					@psap.set volumeType: "transfer"
					@psap.set transferVolume: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='transferVolume'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be valid when volumeType is transfer and transferVolume is empty", ->
					@psap.set volumeType: "transfer"
					@psap.set transferVolume: ""
					expect(@psap.isValid()).toBeTruthy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='transferVolume'
					expect(filtErrors.length).toEqual 0
				it "should be invalid when autoHitSelection is checked and thresholdType is sd and hitSDThreshold is not a number", ->
					@psap.set autoHitSelection: true
					@psap.set thresholdType: "sd"
					@psap.set hitSDThreshold: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='hitSDThreshold'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when autoHitSelection is checked and thresholdType is efficacy and hitEfficacyThreshold is not a number", ->
					@psap.set autoHitSelection: true
					@psap.set thresholdType: "efficacy"
					@psap.set hitEfficacyThreshold: NaN
					expect(@psap.isValid()).toBeFalsy()
					filtErrors = _.filter @psap.validationError, (err) ->
						err.attribute=='hitEfficacyThreshold'
					expect(filtErrors.length).toBeGreaterThan 0

			describe "autocalculating volumes", ->
				it "should autocalculate the dilution factor from the transfer volume and assay volume", ->
					@psap.set volumeType: "transfer"
					@psap.set transferVolume: 12
					@psap.set assayVolume: 36
					expect(@psap.autocalculateVolumes()).toEqual 36/12
				it "should autocalculate the transfer volume from the dilution factor and assay volume", ->
					@psap.set volumeType: "dilution"
					@psap.set dilutionFactor: 4
					@psap.set assayVolume: 36
					expect(@psap.autocalculateVolumes()).toEqual 36/4
				it "should not autocalculate the dilution factor if transfer volume is NaN", ->
					@psap.set volumeType: "transfer"
					@psap.set transferVolume: NaN
					@psap.set assayVolume: 36
					expect(@psap.autocalculateVolumes()).toEqual ""
				it "should not autocalculate the dilution factor if assay volume is NaN", ->
					@psap.set volumeType: "transfer"
					@psap.set transferVolume: 14
					@psap.set assayVolume: NaN
					expect(@psap.autocalculateVolumes()).toEqual ""
				it "should not autocalculate the transfer volume if the dilution factor is NaN", ->
					@psap.set volumeType: "dilution"
					@psap.set dilutionFactor: NaN
					@psap.set assayVolume: 36
					expect(@psap.autocalculateVolumes()).toEqual ""
				it "should not autocalculate the dilution factor if the transfer volume is 0", ->
					@psap.set volumeType: "transfer"
					@psap.set transferVolume: 0
					@psap.set assayVolume: 123
					expect(@psap.autocalculateVolumes()).toEqual ""
				it "should not autocalculate the transfer volume if the dilution factor is 0", ->
					@psap.set volumeType: "dilution"
					@psap.set dilutionFactor: 0
					@psap.set assayVolume: 123
					expect(@psap.autocalculateVolumes()).toEqual ""

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
				describe "model fit parameters", ->
					it 'Should be able to get model parameters', ->
						# this is not hydrated into a specific model type at this level, it is passed to the specific curve fit class for that
						expect(@pse.getModelFitParameters().inverseAgonistMode ).toBeTruthy()
				describe "special states", ->
					it "should be able to get the dry run status", ->
						expect(@pse.getDryRunStatus().get('codeValue')).toEqual "not started"
					it "should be able to get the dry run result html", ->
						expect(@pse.getDryRunResultHTML().get('clobValue')).toEqual "<p>Dry Run not started</p>"
					it "should be able to get the analysis status", ->
						expect(@pse.getAnalysisStatus().get('codeValue')).toEqual "not started"
					it "should be able to get the analysis result html", ->
						expect(@pse.getAnalysisResultHTML().get('clobValue')).toEqual "<p>Analysis not yet completed</p>"
					it "should be able to get the model fit status", ->
						expect(@pse.getModelFitStatus().get('codeValue')).toEqual "not started"
					it "should be able to get the model result html", ->
						expect(@pse.getModelFitResultHTML().get('clobValue')).toEqual "<p>Model fit not yet completed</p>"
		describe "When loaded from new", ->
			beforeEach ->
				@pse2 = new PrimaryScreenExperiment()
			describe "special states", ->
				it "should be able to get the dry run status", ->
					expect(@pse2.getDryRunStatus().get('codeValue')).toEqual "not started"
				it "should be able to get the dry run result html", ->
					expect(@pse2.getDryRunResultHTML().get('clobValue')).toEqual ""
				it "should be able to get the analysis status", ->
					expect(@pse2.getAnalysisStatus().get('codeValue')).toEqual "not started"
					expect(@pse2.getAnalysisStatus().get('codeType')).toEqual "analysis"
					expect(@pse2.getAnalysisStatus().get('codeKind')).toEqual "status"
					expect(@pse2.getAnalysisStatus().get('codeOrigin')).toEqual "ACAS DDICT"
				it "should be able to get the analysis result html", ->
					expect(@pse2.getAnalysisResultHTML().get('clobValue')).toEqual ""
				it "should be able to get the model fit status", ->
					expect(@pse2.getModelFitStatus().get('codeValue')).toEqual "not started"
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
				it "should show read number", ->
					expect(@parc.$('.bv_readNumber').html()).toEqual "R1"
				it "should show read position", ->
					expect(@parc.$('.bv_readPosition').val()).toEqual "11"
				it "should show read name", ->
					waitsFor ->
						@parc.$('.bv_readName option').length > 0
					, 1000
					runs ->
						expect(@parc.$('.bv_readName').val()).toEqual "none"
				it "should have activity checked", ->
					expect(@parc.$('.bv_activity').attr("checked")).toEqual "checked"
			describe "model updates", ->
				it "should update the readPosition ", ->
					@parc.$('.bv_readPosition').val( '42' )
					@parc.$('.bv_readPosition').keyup()
					expect(@parc.model.get('readPosition')).toEqual '42'
				it "should update the read name", ->
					waitsFor ->
						@parc.$('.bv_readName option').length > 0
					, 1000
					runs ->
						@parc.$('.bv_readName').val('unassigned')
						@parc.$('.bv_readName').change()
						expect(@parc.model.get('readName')).toEqual "unassigned"
		describe "validation testing", ->
			beforeEach ->
				@parc = new PrimaryAnalysisReadController
					model: new PrimaryAnalysisRead window.primaryScreenTestJSON.primaryAnalysisReads
					el: $('#fixture')
				@parc.render()
			it "should hide the hide the read position if a calculated read is chosen", ->
				waitsFor ->
					@parc.$('.bv_readName option').length > 0
				, 1000
				runs ->
					@parc.$('.bv_readName').val('Calc: (maximum-minimum)/minimum')
					@parc.$('.bv_readName').change()
					expect(@parc.model.get('readName')).toEqual "Calc: (maximum-minimum)/minimum"
					expect(@parc.$('.bv_readPosition')).toBeHidden()
					expect(@parc.$('.bv_readPositionHolder')).toBeVisible()

	describe "PrimaryAnalysisTimeWindowController", ->
		describe "when instantiated", ->
			beforeEach ->
				@parc = new PrimaryAnalysisTimeWindowController
					model: new PrimaryAnalysisTimeWindow window.primaryScreenTestJSON.primaryAnalysisTimeWindows[0]
					el: $('#fixture')
				@parc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@parc).toBeDefined()
				it "should load a template", ->
					expect(@parc.$('.bv_timeWindowStart').length).toEqual 1
			describe "render existing parameters", ->
				it "should show window start", ->
					expect(@parc.$('.bv_timeWindowStart').val()).toEqual "-5"
				it "should show window end", ->
					expect(@parc.$('.bv_timeWindowEnd').val()).toEqual "5"
				it "should show statistic", ->
					waitsFor ->
						@parc.$('.bv_timeStatistic option').length > 0
					, 1000
					runs ->
						expect(@parc.$('.bv_timeStatistic').val()).toEqual "max"
			describe "model updates", ->
				it "should update the window end", ->
					@parc.$('.bv_timeWindowEnd').val( '42' )
					@parc.$('.bv_timeWindowEnd').keyup()
					expect(@parc.model.get('windowEnd')).toEqual 42
				it "should update the statistic", ->
					waitsFor ->
						@parc.$('.bv_timeStatistic option').length > 0
					, 1000
					runs ->
						@parc.$('.bv_timeStatistic').val('unassigned')
						@parc.$('.bv_timeStatistic').change()
						expect(@parc.model.get('statistic')).toEqual "unassigned"

	describe "StandardCompoundController", ->
		describe "when instantiated", ->
			beforeEach ->
				@scc = new StandardCompoundController
					model: new StandardCompound window.primaryScreenTestJSON.standards[0]
					el: $('#fixture')
				@scc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@scc).toBeDefined()
				it "should load a template", ->
					expect(@scc.$('.bv_batchCode').length).toEqual 1
			describe "render existing parameters", ->
				it "should show batch code", ->
					expect(@scc.$('.bv_batchCode').val()).toEqual "CMPD-12345678-01"
				it "should show window end", ->
					expect(@scc.$('.bv_concentration').val()).toEqual "10"
				it "should show standardType", ->
					waitsFor ->
						@scc.$('.bv_standardType option').length > 0
					, 1000
					runs ->
						expect(@scc.$('.bv_standardType').val()).toEqual "PC"
			describe "model updates", ->
				it "should update the batch code", ->
					@scc.$('.bv_batchCode').val( 'CMPD-99345678-01' )
					@scc.$('.bv_batchCode').keyup()
					waitsFor ->
						@scc.model.get('batchCode') == 'CMPD-99345678-01'
					, 1000
					runs ->
						expect(@scc.model.get('batchCode')).toEqual 'CMPD-99345678-01'
				it "should update the standard type", ->
					waitsFor ->
						@scc.$('.bv_standardType option').length > 0
					, 1000
					runs ->
						@scc.$('.bv_standardType').val('unassigned')
						@scc.$('.bv_standardType').change()
						expect(@scc.model.get('standardType')).toEqual "unassigned"
			describe "validation", ->
				it "should show error if batchCode is not set", ->
					@scc.$('.bv_batchCode').val ""
					@scc.$('.bv_batchCode').keyup()
					waits(1000)
					runs ->
						expect(@scc.$('.bv_group_batchCode').hasClass("error")).toBeTruthy()
						expect(@scc.$('.bv_group_batchCode').attr('data-toggle')).toEqual "tooltip"
				it "should show error if batchCode is not a preferred batch", ->
					@scc.$('.bv_batchCode').val "none"
					@scc.$('.bv_batchCode').keyup()
					waits(1000)
					runs ->
						expect(@scc.$('.bv_group_batchCode').hasClass("error")).toBeTruthy()
						expect(@scc.$('.bv_group_batchCode').attr('data-toggle')).toEqual "tooltip"

	describe "TransformationRuleController", ->
		describe "when instantiated", ->
			beforeEach ->
				@trc = new TransformationRuleController
					model: new TransformationRule window.primaryScreenTestJSON.transformationRules[0]
					el: $('#fixture')
				@trc.render()
			describe "basic existance tests", ->
				it "should exist", ->
					expect(@trc).toBeDefined()
				it "should load a template", ->
					expect(@trc.$('.bv_transformationRule').length).toEqual 1
			describe "render existing parameters", ->
				it "should show transformation rule", ->
					waitsFor ->
						@trc.$('.bv_transformationRule option').length > 0
					, 1000
					runs ->
						expect(@trc.$('.bv_transformationRule').val()).toEqual "% efficacy"
			describe "model updates", ->
				it "should update the transformation rule", ->
					waitsFor ->
						@trc.$('.bv_transformationRule option').length > 0
					, 1000
					runs ->
						@trc.$('.bv_transformationRule').val('sd')
						@trc.$('.bv_transformationRule').change()
						expect(@trc.model.get('transformationRule')).toEqual "sd"

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
				it "should show one read with the activity selected", ->
					expect(@parlc.$('.bv_readInfo .bv_readName').length).toEqual 1
					expect(@parlc.collection.length).toEqual 1
#					expect(@parlc.$('.bv_readPosition:eq(0)').toBeTruthy())
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
				waitsFor ->
					@parlc.$('.bv_readName option').length > 0
				, 1000
				runs ->
					expect(@parlc.$('.bv_readNumber:eq(0)').html()).toEqual "R1"
					expect(@parlc.$('.bv_readPosition:eq(0)').val()).toEqual "11"
					expect(@parlc.$('.bv_readName:eq(0)').val()).toEqual "none"
					expect(@parlc.$('.bv_activity:eq(0)').attr("checked")).toEqual "checked"
			it "should have the correct read info for the second read", ->
				waitsFor ->
					@parlc.$('.bv_readName option').length > 0
				, 1000
				runs ->
					expect(@parlc.$('.bv_readNumber:eq(1)').html()).toEqual "R2"
					expect(@parlc.$('.bv_readPosition:eq(1)').val()).toEqual "12"
					expect(@parlc.$('.bv_readName:eq(1)').val()).toEqual "fluorescence"
					expect(@parlc.$('.bv_activity:eq(1)').attr("checked")).toBeUndefined()
			it "should have the correct read info for the third read", ->
				waitsFor ->
					@parlc.$('.bv_readName option').length > 0
				, 1000
				runs ->
					expect(@parlc.$('.bv_readNumber:eq(2)').html()).toEqual "R3"
					expect(@parlc.$('.bv_readPosition:eq(2)').val()).toEqual "13"
					expect(@parlc.$('.bv_readName:eq(2)').val()).toEqual "luminescence"
					expect(@parlc.$('.bv_activity:eq(2)').attr("checked")).toBeUndefined()

	describe "Primary Analysis Time Window List Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@parlc= new PrimaryAnalysisTimeWindowListController
					el: $('#fixture')
					collection: new PrimaryAnalysisTimeWindowList()
				@parlc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@parlc).toBeDefined()
				it "should load a template", ->
					expect(@parlc.$('.bv_addTimeWindowButton').length).toEqual 1
			describe "rendering", ->
				it "should show no time windows", ->
					expect(@parlc.$('.bv_timeWindowInfo .bv_timeWindowStart').length).toEqual 0
					expect(@parlc.collection.length).toEqual 0
			describe "adding and removing", ->
				it "should have one read when add read is clicked", ->
					@parlc.$('.bv_addTimeWindowButton').click()
					expect(@parlc.$('.bv_timeWindowInfo .bv_timeWindowStart').length).toEqual 1
					expect(@parlc.collection.length).toEqual 1
				it "should have two reads when add read is clicked again", ->
					@parlc.$('.bv_addTimeWindowButton').click()
					@parlc.$('.bv_addTimeWindowButton').click()
					expect(@parlc.$('.bv_timeWindowInfo .bv_timeWindowStart').length).toEqual 2
					expect(@parlc.collection.length).toEqual 2
				it "should have no reads when there is one read and remove is clicked", ->
					@parlc.$('.bv_addTimeWindowButton').click()
					expect(@parlc.collection.length).toEqual 1
					@parlc.$('.bv_delete').click()
					expect(@parlc.$('.bv_timeWindowInfo .bv_timeWindowStart').length).toEqual 0
					expect(@parlc.collection.length).toEqual 0
				it "should have one read when there are two reads and remove is clicked", ->
					@parlc.$('.bv_addTimeWindowButton').click()
					@parlc.$('.bv_addTimeWindowButton').click()
					expect(@parlc.$('.bv_timeWindowInfo .bv_timeWindowStart').length).toEqual 2
					@parlc.$('.bv_delete:eq(0)').click()
					expect(@parlc.$('.bv_timeWindowInfo .bv_timeWindowStart').length).toEqual 1
					expect(@parlc.collection.length).toEqual 1
		describe "when instantiated with data", ->
			beforeEach ->
				@parlc= new PrimaryAnalysisTimeWindowListController
					el: $('#fixture')
					collection: new PrimaryAnalysisTimeWindowList window.primaryScreenTestJSON.primaryAnalysisTimeWindows
				@parlc.render()
			it "should have three time windows", ->
				expect(@parlc.collection.length).toEqual 3
			it "should have the correct read info for the first time window", ->
				waitsFor ->
					@parlc.$('.bv_timeStatistic option').length > 0
				, 1000
				runs ->
					expect(@parlc.$('.bv_timePosition:eq(0)').html()).toEqual "T1"
					expect(@parlc.$('.bv_timeStatistic:eq(0)').val()).toEqual "max"
					expect(@parlc.$('.bv_timeWindowStart:eq(0)').val()).toEqual "-5"
					expect(@parlc.$('.bv_timeWindowEnd:eq(0)').val()).toEqual "5"
			it "should have the correct read info for the second time window", ->
				waitsFor ->
					@parlc.$('.bv_timeStatistic option').length > 0
				, 1000
				runs ->
					expect(@parlc.$('.bv_timePosition:eq(1)').html()).toEqual "T2"
					expect(@parlc.$('.bv_timeStatistic:eq(1)').val()).toEqual "min"
					expect(@parlc.$('.bv_timeWindowStart:eq(1)').val()).toEqual "0"
					expect(@parlc.$('.bv_timeWindowEnd:eq(1)').val()).toEqual "15"
			it "should have the correct read info for the third time window", ->
				waitsFor ->
					@parlc.$('.bv_timeStatistic option').length > 0
				, 1000
				runs ->
					expect(@parlc.$('.bv_timePosition:eq(2)').html()).toEqual "T3"
					expect(@parlc.$('.bv_timeStatistic:eq(2)').val()).toEqual "max"
					expect(@parlc.$('.bv_timeWindowStart:eq(2)').val()).toEqual "20"
					expect(@parlc.$('.bv_timeWindowEnd:eq(2)').val()).toEqual "50"

	describe "Primary Analysis Standard Compound List Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@paslc= new StandardCompoundListController
					el: $('#fixture')
					collection: new StandardCompoundList()
				@paslc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@paslc).toBeDefined()
				it "should load a template", ->
					expect(@paslc.$('.bv_addStandardCompoundButton').length).toEqual 1
			describe "rendering", ->
				it "should show a standard slot", ->
					expect(@paslc.$('.bv_standardCompoundInfo .bv_batchCode').length).toEqual 1
					expect(@paslc.collection.length).toEqual 1
			describe "adding and removing", ->
				it "should have two standards when add standard is clicked", ->
					@paslc.$('.bv_addStandardCompoundButton').click()
					expect(@paslc.$('.bv_standardCompoundInfo .bv_batchCode').length).toEqual 2
					expect(@paslc.collection.length).toEqual 2
				it "should have three reads when add read is clicked again", ->
					@paslc.$('.bv_addStandardCompoundButton').click()
					@paslc.$('.bv_addStandardCompoundButton').click()
					expect(@paslc.$('.bv_standardCompoundInfo .bv_batchCode').length).toEqual 3
					expect(@paslc.collection.length).toEqual 3
				it "should have no reads when there is one read and remove is clicked", ->
					expect(@paslc.collection.length).toEqual 1
					@paslc.$('.bv_delete').click()
					expect(@paslc.$('.bv_standardCompoundInfo .bv_batchCode').length).toEqual 0
					expect(@paslc.collection.length).toEqual 0
				it "should have one read when there are two reads and remove is clicked", ->
					@paslc.$('.bv_addStandardCompoundButton').click()
					expect(@paslc.$('.bv_standardCompoundInfo .bv_batchCode').length).toEqual 2
					@paslc.$('.bv_delete:eq(0)').click()
					expect(@paslc.$('.bv_standardCompoundInfo .bv_batchCode').length).toEqual 1
					expect(@paslc.collection.length).toEqual 1
		describe "when instantiated with data", ->
			beforeEach ->
				@paslc= new StandardCompoundListController
					el: $('#fixture')
					collection: new StandardCompoundList window.primaryScreenTestJSON.standards
				@paslc.render()
			it "should have three standards", ->
				expect(@paslc.collection.length).toEqual 3
			it "should have the correct standard info for the first standard", ->
				waitsFor ->
					@paslc.$('.bv_standardType option').length > 0
				, 1000
				runs ->
					expect(@paslc.$('.bv_standardNumber:eq(0)').html()).toEqual "S1"
					expect(@paslc.$('.bv_batchCode:eq(0)').val()).toEqual "CMPD-12345678-01"
					expect(@paslc.$('.bv_concentration:eq(0)').val()).toEqual "10"
					expect(@paslc.$('.bv_standardType:eq(0)').val()).toEqual "PC"
			it "should have the correct standard info for the second standard", ->
				waitsFor ->
					@paslc.$('.bv_standardType option').length > 0
				, 1000
				runs ->
					expect(@paslc.$('.bv_standardNumber:eq(1)').html()).toEqual "S2"
					expect(@paslc.$('.bv_batchCode:eq(1)').val()).toEqual "CMPD-87654321-01"
					expect(@paslc.$('.bv_concentration:eq(1)').val()).toEqual "1"
					expect(@paslc.$('.bv_standardType:eq(1)').val()).toEqual "NC"
			it "should have the correct standard info for the third standard", ->
				waitsFor ->
					@paslc.$('.bv_standardType option').length > 0
				, 1000
				runs ->
					expect(@paslc.$('.bv_standardNumber:eq(2)').html()).toEqual "S3"
					expect(@paslc.$('.bv_batchCode:eq(2)').val()).toEqual "CMPD-00000001-01"
					expect(@paslc.$('.bv_concentration:eq(2)').val()).toEqual "0"
					expect(@paslc.$('.bv_standardType:eq(2)').val()).toEqual "VC"

	describe "Additive List Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@alc= new AdditiveListController
					el: $('#fixture')
					collection: new AdditiveList()
				@alc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@alc).toBeDefined()
				it "should load a template", ->
					expect(@alc.$('.bv_addAdditiveButton').length).toEqual 1
			describe "rendering", ->
				it "should show an additive slot", ->
					expect(@alc.$('.bv_additiveInfo .bv_batchCode').length).toEqual 1
					expect(@alc.collection.length).toEqual 1
			describe "adding and removing", ->
				it "should have two additives when add additive is clicked", ->
					@alc.$('.bv_addAdditiveButton').click()
					expect(@alc.$('.bv_additiveInfo .bv_batchCode').length).toEqual 2
					expect(@alc.collection.length).toEqual 2
				it "should have three additives when add additive is clicked again", ->
					@alc.$('.bv_addAdditiveButton').click()
					@alc.$('.bv_addAdditiveButton').click()
					expect(@alc.$('.bv_additiveInfo .bv_batchCode').length).toEqual 3
					expect(@alc.collection.length).toEqual 3
				it "should have no additives when there is one additive and remove is clicked", ->
					expect(@alc.collection.length).toEqual 1
					@alc.$('.bv_delete').click()
					expect(@alc.$('.bv_additiveInfo .bv_batchCode').length).toEqual 0
					expect(@alc.collection.length).toEqual 0
				it "should have one additive when there are two additives and remove is clicked", ->
					@alc.$('.bv_addAdditiveButton').click()
					expect(@alc.$('.bv_additiveInfo .bv_batchCode').length).toEqual 2
					@alc.$('.bv_delete:eq(0)').click()
					expect(@alc.$('.bv_additiveInfo .bv_batchCode').length).toEqual 1
					expect(@alc.collection.length).toEqual 1
		describe "when instantiated with data", ->
			beforeEach ->
				@alc= new AdditiveListController
					el: $('#fixture')
					collection: new AdditiveList window.primaryScreenTestJSON.additives
				@alc.render()
			it "should have two additives", ->
				expect(@alc.collection.length).toEqual 2
			it "should have the correct additive info for the first additive", ->
				waitsFor ->
					@alc.$('.bv_additiveType option').length > 0
				, 1000
				runs ->
					expect(@alc.$('.bv_additiveNumber:eq(0)').html()).toEqual "A1"
					expect(@alc.$('.bv_batchCode:eq(0)').val()).toEqual "CMPD-87654399-01"
					expect(@alc.$('.bv_concentration:eq(0)').val()).toEqual "10"
					expect(@alc.$('.bv_additiveType:eq(0)').val()).toEqual "agonist"
			it "should have the correct read info for the second time window", ->
				waitsFor ->
					@alc.$('.bv_additiveType option').length > 0
				, 1000
				runs ->
					expect(@alc.$('.bv_additiveNumber:eq(1)').html()).toEqual "A2"
					expect(@alc.$('.bv_batchCode:eq(1)').val()).toEqual "CMPD-92345698-01"
					expect(@alc.$('.bv_concentration:eq(1)').val()).toEqual "15"
					expect(@alc.$('.bv_additiveType:eq(1)').val()).toEqual "antagonist"

	describe "Transformation Rule List Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@trlc= new TransformationRuleListController
					el: $('#fixture')
					collection: new TransformationRuleList()
				@trlc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@trlc).toBeDefined()
				it "should load a template", ->
					expect(@trlc.$('.bv_addTransformationButton').length).toEqual 1
			describe "rendering", ->
				it "should show one rule", ->
					expect(@trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual 1
					expect(@trlc.collection.length).toEqual 1
			describe "adding and removing", ->
				it "should have two rules when add transformation button is clicked", ->
					@trlc.$('.bv_addTransformationButton').click()
					expect(@trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual 2
					expect(@trlc.collection.length).toEqual 2
				it "should have one rule when there are two rules and remove is clicked", ->
					@trlc.$('.bv_addTransformationButton').click()
					expect(@trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual 2
					@trlc.$('.bv_deleteRule:eq(0)').click()
					expect(@trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual 1
					expect(@trlc.collection.length).toEqual 1
				it "should always have one read", ->
					expect(@trlc.collection.length).toEqual 1
					@trlc.$('.bv_deleteRule').click()
					expect(@trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual 1
					expect(@trlc.collection.length).toEqual 1

		describe "when instantiated with data", ->
			beforeEach ->
				@trlc= new TransformationRuleListController
					el: $('#fixture')
					collection: new TransformationRuleList window.primaryScreenTestJSON.transformationRules
				@trlc.render()
			it "should have three rules", ->
				expect(@trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual 3
				expect(@trlc.collection.length).toEqual 3
			it "should have the correct rule info for the first rule", ->
				waitsFor ->
					@trlc.$('.bv_transformationRule option').length > 0
				, 1000
				runs ->
					expect(@trlc.$('.bv_transformationInfo .bv_transformationRule:eq(0)').val()).toEqual "% efficacy"
			it "should have the correct rule info for the second rule", ->
				waitsFor ->
					@trlc.$('.bv_transformationRule option').length > 0
				, 1000
				runs ->
					expect(@trlc.$('.bv_transformationInfo .bv_transformationRule:eq(1)').val()).toEqual "sd"
			it "should have the correct rule info for the third rule", ->
				# note: this test sometimes breaks for no reason. If run the specific test, it will pass.
				waitsFor ->
					@trlc.$('.bv_transformationRule option').length > 0
				, 1000
				runs ->
					expect(@trlc.$('.bv_transformationInfo .bv_transformationRule:eq(2)').val()).toEqual "null"


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
						expect(@psapc.$('.bv_signalDirectionRule').val()).toEqual "increasing"
				it 'should show the aggregateBy', ->
					waitsFor ->
						@psapc.$('.bv_aggregateBy option').length > 0
					, 1000
					runs ->
						expect(@psapc.$('.bv_aggregateBy').val()).toEqual "compound batch concentration"
				it 'should show the aggregationMethod', ->
					waitsFor ->
						@psapc.$('.bv_aggregationMethod option').length > 0
					, 1000
					runs ->
						expect(@psapc.$('.bv_aggregationMethod').val()).toEqual "median"
				it 'should show the normalization rule', ->
					waitsFor ->
						@psapc.$('.bv_normalizationRule option').length > 0
					, 1000
					runs ->
						expect(@psapc.$('.bv_normalizationRule').val()).toEqual "plate order only"
				it 'should show the assayVolume', ->
					expect(@psapc.$('.bv_assayVolume').val()).toEqual '24'
				it 'should show the transferVolume', ->
					expect(@psapc.$('.bv_transferVolume').val()).toEqual '12'
				it 'should show the dilutionFactor', ->
					expect(@psapc.$('.bv_dilutionFactor').val()).toEqual '21'
				it 'should start with volumeType radio set', ->
					expect(@psapc.$("input[name='bv_volumeType']:checked").val()).toEqual 'dilution'
				it 'should show a standard compound list', ->
					expect(@psapc.$('.bv_standardCompoundInfo .bv_batchCode').length).toEqual 3
				it 'should show an additive list', ->
					expect(@psapc.$('.bv_additiveInfo .bv_batchCode').length).toEqual 2
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
				it 'should start with htsFormat unchecked', ->
					expect(@psapc.$('.bv_htsFormat').attr("checked")).toBeUndefined()
				it 'should start with matchReadName unchecked', ->
					expect(@psapc.$('.bv_matchReadName').attr("checked")).toBeUndefined()
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
				it "should update the aggregateBy", ->
					waitsFor ->
						@psapc.$('.bv_aggregateBy option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_aggregateBy').val('unassigned')
						@psapc.$('.bv_aggregateBy').change()
						expect(@psapc.model.get('aggregateBy')).toEqual "unassigned"
				it "should update the bv_aggregationMethod", ->
					waitsFor ->
						@psapc.$('.bv_aggregationMethod option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_aggregationMethod').val('unassigned')
						@psapc.$('.bv_aggregationMethod').change()
						expect(@psapc.model.get('aggregationMethod')).toEqual "unassigned"
				it "should update the normalizationRule rule", ->
					waitsFor ->
						@psapc.$('.bv_normalizationRule option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_normalizationRule').val('unassigned')
						@psapc.$('.bv_normalizationRule').change()
						expect(@psapc.model.get('normalization').get('normalizationRule')).toEqual "unassigned"
				it "should update the assayVolume and recalculate the transfer volume if the dilution factor is set ", ->
					@psapc.$('.bv_volumeTypeDilution').click()
					@psapc.$('.bv_dilutionFactor').val(' 3 ')
					@psapc.$('.bv_dilutionFactor').keyup()
					expect(@psapc.model.get('dilutionFactor')).toEqual 3
					@psapc.$('.bv_assayVolume').val(' 27 ')
					@psapc.$('.bv_assayVolume').keyup()
					expect(@psapc.model.get('assayVolume')).toEqual 27
					expect(@psapc.model.get('transferVolume')).toEqual 9
				it "should update the transferVolume and autocalculate the dilution factor based on assay and transfer volumes", ->
					@psapc.$('.bv_volumeTypeTransfer').click()
					@psapc.$('.bv_transferVolume').val(' 12 ')
					@psapc.$('.bv_transferVolume').keyup()
					expect(@psapc.model.get('transferVolume')).toEqual 12
					@psapc.$('.bv_assayVolume').val(' 24 ')
					@psapc.$('.bv_assayVolume').keyup()
					expect(@psapc.model.get('dilutionFactor')).toEqual 2
				it "should update the dilution factor and autocalculate the transfer volume based on assay volume and dilution factor ", ->
					@psapc.$('.bv_dilutionFactor').val(' 4 ')
					@psapc.$('.bv_dilutionFactor').keyup()
					expect(@psapc.model.get('dilutionFactor')).toEqual 4
					@psapc.$('.bv_assayVolume').val(' 24 ')
					@psapc.$('.bv_assayVolume').keyup()
					expect(@psapc.model.get('transferVolume')).toEqual 6
				it "should update the hitSDThreshold ", ->
					@psapc.$('.bv_hitSDThreshold').val(' 24 ')
					@psapc.$('.bv_hitSDThreshold').keyup()
					expect(@psapc.model.get('hitSDThreshold')).toEqual 24
				it "should update the hitEfficacyThreshold ", ->
					@psapc.$('.bv_hitEfficacyThreshold').val(' 25 ')
					@psapc.$('.bv_hitEfficacyThreshold').keyup()
					expect(@psapc.model.get('hitEfficacyThreshold')).toEqual 25
				it "should update the thresholdType ", ->
					@psapc.$('.bv_thresholdTypeEfficacy').click()
					expect(@psapc.model.get('thresholdType')).toEqual "efficacy"
				it "should update the volumeType ", ->
					@psapc.$('.bv_volumeTypeTransfer').click()
					expect(@psapc.model.get('volumeType')).toEqual "transfer"
				it "should update the autoHitSelection ", ->
					@psapc.$('.bv_autoHitSelection').click()
					expect(@psapc.model.get('autoHitSelection')).toBeTruthy()
				it "should update the htsFormat checkbox ", ->
					@psapc.$('.bv_htsFormat').click()
					expect(@psapc.model.get('htsFormat')).toBeTruthy()
				it "should update the matchReadName checkbox ", ->
					@psapc.$('.bv_matchReadName').click()
					@psapc.$('.bv_matchReadName').click()
					expect(@psapc.model.get('matchReadName')).toBeTruthy()
					#don't know why matchReadName needs to be clicked twice for spec to pass but the implementation is correct
			describe "behavior and validation", ->
				it "should disable read position field if match read name is selected", ->
					@psapc.$('.bv_matchReadName').click()
					@psapc.$('.bv_matchReadName').click()
					expect(@psapc.$('.bv_readPosition').attr("disabled")).toEqual "disabled"
				it "should enable read position field if match read name is not selected", ->
					expect(@psapc.$('.bv_readPosition').attr("disabled")).toBeUndefined()
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
				it "should show error if aggregateBy is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_aggregateBy option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_aggregateBy').val "unassigned"
						@psapc.$('.bv_aggregateBy').change()
						expect(@psapc.$('.bv_group_aggregateBy').hasClass("error")).toBeTruthy()
				it "should show error if aggregationMethod is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_aggregationMethod option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_aggregationMethod').val "unassigned"
						@psapc.$('.bv_aggregationMethod').change()
						expect(@psapc.$('.bv_group_aggregationMethod').hasClass("error")).toBeTruthy()
				it "should show error if normalizationRule is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_normalizationRule option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_normalizationRule').val "unassigned"
						@psapc.$('.bv_normalizationRule').change()
						expect(@psapc.$('.bv_group_normalizationRule').hasClass("error")).toBeTruthy()
				it "should show error if threshold type is efficacy and efficacy threshold not a number", ->
					@psapc.$('.bv_autoHitSelection').click()
					@psapc.$('.bv_thresholdTypeEfficacy').click()
					@psapc.$('.bv_hitEfficacyThreshold').val ""
					@psapc.$('.bv_hitEfficacyThreshold').keyup()
					expect(@psapc.$('.bv_group_hitEfficacyThreshold').hasClass("error")).toBeTruthy()
				it "should show error if threshold type is sd and sd threshold not a number", ->
					@psapc.$('.bv_autoHitSelection').click()
					@psapc.$('.bv_thresholdTypeSD').click()
					@psapc.$('.bv_hitSDThreshold').val ""
					@psapc.$('.bv_hitSDThreshold').keyup()
					expect(@psapc.$('.bv_group_hitSDThreshold').hasClass("error")).toBeTruthy()
				it "should show error if volume type is transferVolume and transferVolume not a number (but can be empty)", ->
					@psapc.$('.bv_volumeTypeTransfer').click()
					@psapc.$('.bv_transferVolume').val "hello"
					@psapc.$('.bv_transferVolume').keyup()
					expect(@psapc.$('.bv_group_transferVolume').hasClass("error")).toBeTruthy()
				it "should not show error if volume type is transferVolume and transferVolume is empty", ->
					@psapc.$('.bv_volumeTypeTransfer').click()
					@psapc.$('.bv_transferVolume').val ""
					@psapc.$('.bv_transferVolume').keyup()
					expect(@psapc.$('.bv_group_transferVolume').hasClass("error")).toBeFalsy()
				it "should show error if volume type is dilutionFactor and dilutionFactor not a number (but can be empty)", ->
					@psapc.$('.bv_volumeTypeDilution').click()
					@psapc.$('.bv_dilutionFactor').val "hello again"
					@psapc.$('.bv_dilutionFactor').keyup()
					expect(@psapc.$('.bv_group_dilutionFactor').hasClass("error")).toBeTruthy()
				it "should not show error if volume type is dilutionFactor and dilutionFactor is empty", ->
					@psapc.$('.bv_volumeTypeDilution').click()
					@psapc.$('.bv_dilutionFactor').val ""
					@psapc.$('.bv_dilutionFactor').keyup()
					expect(@psapc.$('.bv_group_dilutionFactor').hasClass("error")).toBeFalsy()
				it "should show error if assayVolume is NaN", ->
					@psapc.$('.bv_assayVolume').val "b"
					@psapc.$('.bv_assayVolume').keyup()
					expect(@psapc.$('.bv_group_assayVolume').hasClass("error")).toBeTruthy()
				it "should show error if fluorescentStart is NaN", ->
					@psapc.$('.bv_fluorescentStart').val "b"
					@psapc.$('.bv_fluorescentStart').keyup()
					expect(@psapc.$('.bv_group_fluorescentStart').hasClass("error")).toBeTruthy()
				it "should show error if fluorescentEnd is NaN", ->
					@psapc.$('.bv_fluorescentEnd').val "b"
					@psapc.$('.bv_fluorescentEnd').keyup()
					expect(@psapc.$('.bv_group_fluorescentEnd').hasClass("error")).toBeTruthy()
				it "should show error if fluorescentStep is NaN", ->
					@psapc.$('.bv_fluorescentStep').val "b"
					@psapc.$('.bv_fluorescentStep').keyup()
					expect(@psapc.$('.bv_group_fluorescentStep').hasClass("error")).toBeTruthy()
				it "should show error if latePeakTime is NaN", ->
					@psapc.$('.bv_latePeakTime').val "b"
					@psapc.$('.bv_latePeakTime').keyup()
					expect(@psapc.$('.bv_group_latePeakTime').hasClass("error")).toBeTruthy()
				it "should not show error if assayVolume, dilutionFactor, and transferVolume are empty", ->
					@psapc.$('.bv_assayVolume').val ""
					@psapc.$('.bv_assayVolume').keyup()
					@psapc.$('.bv_dilutionFactor').val ""
					@psapc.$('.bv_dilutionFactor').keyup()
					@psapc.$('.bv_transferVolume').val ""
					@psapc.$('.bv_transferVolume').keyup()
					expect(@psapc.$('.bv_group_assayVolume').hasClass("error")).toBeFalsy()
				it "should not show error on read position if match read name is checked", ->
					@psapc.$('.bv_matchReadName').click()
					expect(@psapc.$('bv_group_readPosition').hasClass("error")).toBeFalsy()
				it "should show error if readPosition is NaN", ->
					@psapc.$('.bv_readPosition:eq(0)').val ""
					@psapc.$('.bv_readPosition:eq(0)').keyup()
					expect(@psapc.$('.bv_group_readPosition:eq(0)').hasClass("error")).toBeTruthy()
				it "should show error if read name is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_readName option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_readName:eq(0)').val "unassigned"
						@psapc.$('.bv_readName:eq(0)').change()
						expect(@psapc.$('.bv_group_readName').hasClass("error")).toBeTruthy()
				it "should show error if transformation rule is unassigned", ->
					waitsFor ->
						@psapc.$('.bv_transformationRule option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_transformationRule:eq(0)').val "unassigned"
						@psapc.$('.bv_transformationRule:eq(0)').change()
						expect(@psapc.$('.bv_group_transformationRule:eq(0)').hasClass("error")).toBeTruthy()
				it "should show error if a transformation rule is selected more than once", ->
					@psapc.$('.bv_addTransformationButton').click()
					waitsFor ->
						@psapc.$('.bv_transformationInfo .bv_transformationRule option').length > 0
					, 1000
					runs ->
						@psapc.$('.bv_transformationRule:eq(0)').val "sd"
						@psapc.$('.bv_transformationRule:eq(0)').change()
						@psapc.$('.bv_transformationRule:eq(1)').val "sd"
						@psapc.$('.bv_transformationRule:eq(1)').change()
						expect(@psapc.$('.bv_group_transformationRule:eq(0)').hasClass('error')).toBeTruthy()
						expect(@psapc.$('.bv_group_transformationRule:eq(1)').hasClass('error')).toBeTruthy()


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
				@exp.copyProtocolAttributes new Protocol JSON.parse(JSON.stringify(window.protocolServiceTestJSON.fullSavedProtocol))
				@psac = new PrimaryScreenAnalysisController
					model: @exp
					el: $('#fixture')
					uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
				@psac.render()
			describe "Basic loading", ->
				it "Class should exist", ->
					expect(@psac).toBeDefined
				it "Should load the template", ->
					expect(@psac.$('.bv_fileUploadWrapper').length).toNotEqual 0
			describe "display logic", ->
#				it "should show analysis status not started becuase this is a new experiment", ->
#					expect(@psac.$('.bv_analysisStatus').html()).toEqual "not started"
#				it "should not show analysis results becuase this is a new experiment", ->
#					expect(@psac.$('.bv_analysisResultsHTML').html()).toEqual ""
#					expect(@psac.$('.bv_resultsContainer')).toBeHidden()
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
			it "Should disable analsyis parameter editing if status is approved", ->
				@psac.model.getStatus().set codeValue: "approved"
				@psac.handleStatusChanged()
				expect(@psac.$('.bv_normalizationRule').attr('disabled')).toEqual 'disabled'
			it "Should enable analsyis parameter editing if status is started", ->
				@psac.model.getStatus().set codeValue: "approved"
				@psac.model.getStatus().set codeValue: "started"
				expect(@psac.$('.bv_normalizationRule').attr('disabled')).toBeUndefined()
			it "should show upload button as upload data since status is 'not started'", ->
				expect(@psac.$('.bv_save').html()).toEqual "Upload Data"
		describe "handling re-analysis", ->
			beforeEach ->
				@exp = new PrimaryScreenExperiment window.experimentServiceTestJSON.fullExperimentFromServer
				@exp.getAnalysisStatus().set codeValue: "analsysis complete"
				@psac = new PrimaryScreenAnalysisController
					model: @exp
					el: $('#fixture')
					uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
				@psac.render()
			it "should show upload button as re-analyze since status is not 'not started'", ->
				expect(@psac.$('.bv_loadAnother').html()).toEqual "Re-Analyze"
		describe "rendering analysis based on dry run status and analysis status", ->
			beforeEach ->
				@exp = new PrimaryScreenExperiment window.experimentServiceTestJSON.fullExperimentFromServer
				@exp.getDryRunStatus().set codeValue: "not started"
				@exp.getAnalysisStatus().set codeValue: "not started"
				@psac = new PrimaryScreenAnalysisController
					model: @exp
					el: $('#fixture')
					uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
				@psac.render()
			it "should show the upload data page", ->
				expect(@psac.$('.bv_nextControlContainer')).toBeVisible()


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
					expect(@psec.$('.bv_primaryScreenDataAnalysis .bv_fileUploadWrapper').length).toNotEqual 0
				#TODO this spec is not running because prod redactedCustomer does not include a fit module yet
				xit "Should load a dose response controller", ->
					expect(@psec.$('.bv_doseResponseAnalysis .bv_fitModelButton').length).toNotEqual 0




#TODO Validation rules for different threshold modes





