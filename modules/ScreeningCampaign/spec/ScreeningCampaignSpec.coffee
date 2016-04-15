beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Screening Campaign module testing", ->
	describe "Screening Experiment model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@pe = new ParentExperiment()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@pe).toBeDefined()
				it "should have lsType of Parent", ->
					expect(@pe.get('lsType')).toEqual "Parent"
				it "should have lsKind of Bio Activiy", ->
					expect(@pe.get('lsKind')).toEqual "Bio Activity"
	describe "Screening Experiment Parameters model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@sep = new ScreeningExperimentParameters()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@sep).toBeDefined()
				it "should have defaults", ->
					expect(@sep.get('signalDirectionRule')).toEqual "unassigned"
					expect(@sep.get('aggregateBy')).toEqual "unassigned"
					expect(@sep.get('aggregationMethod')).toEqual "unassigned"
					expect(@sep.get('normalization') instanceof Normalization).toBeTruthy()
					expect(@sep.get('transformationRuleList') instanceof TransformationRuleList).toBeTruthy()
					expect(@sep.get('primaryHitEfficacyThreshold')).toBeNull()
					expect(@sep.get('primaryHitSDThreshold')).toBeNull()
					expect(@sep.get('primaryThresholdType')).toEqual null
					expect(@sep.get('primaryAutoHitSelection')).toBeFalsy()
					expect(@sep.get('confirmationHitEfficacyThreshold')).toBeNull()
					expect(@sep.get('confirmationHitSDThreshold')).toBeNull()
					expect(@sep.get('confirmationThresholdType')).toEqual null
					expect(@sep.get('confirmationAutoHitSelection')).toBeFalsy()
					expect(@sep.get('generateSummaryReport')).toBeTruthy()
		describe "When loaded from existing", ->
			beforeEach ->
				@sep = new ScreeningExperimentParameters window.screeningCampaignTestJSON.screeningCampaignAnalysisParameters
			describe "composite object creation", ->
				it "should convert transformationRuleList to TransformationRuleList", ->
					expect( @sep.get('transformationRuleList') instanceof TransformationRuleList).toBeTruthy()
				it "should convert normalization to Normalization", ->
					expect( @sep.get('normalization') instanceof Normalization).toBeTruthy()
			describe "model validation tests", ->
				it "should be valid as initialized", ->
					expect(@sep.isValid()).toBeTruthy()
				it "should be invalid when aggregate by is unassigned", ->
					@sep.set aggregateBy: "unassigned"
					expect(@sep.isValid()).toBeFalsy()
					filtErrors = _.filter @sep.validationError, (err) ->
						err.attribute=='aggregateBy'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when aggregatation method is unassigned", ->
					@sep.set aggregationMethod: "unassigned"
					expect(@sep.isValid()).toBeFalsy()
					filtErrors = _.filter @sep.validationError, (err) ->
						err.attribute=='aggregationMethod'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when signal direction rule is unassigned", ->
					@sep.set signalDirectionRule: "unassigned"
					expect(@sep.isValid()).toBeFalsy()
					filtErrors = _.filter @sep.validationError, (err) ->
						err.attribute=='signalDirectionRule'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when primaryAutoHitSelection is checked and primaryThresholdType is sd and primaryHitSDThreshold is not a number", ->
					@sep.set primaryAutoHitSelection: true
					@sep.set primaryThresholdType: "sd"
					@sep.set primaryHitSDThreshold: NaN
					expect(@sep.isValid()).toBeFalsy()
					filtErrors = _.filter @sep.validationError, (err) ->
						err.attribute=='primaryHitSDThreshold'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when primaryAutoHitSelection is checked and primaryThresholdType is efficacy and primaryHitEfficacyThreshold is not a number", ->
					@sep.set primaryAutoHitSelection: true
					@sep.set primaryThresholdType: "efficacy"
					@sep.set primaryHitEfficacyThreshold: NaN
					expect(@sep.isValid()).toBeFalsy()
					filtErrors = _.filter @sep.validationError, (err) ->
						err.attribute=='primaryHitEfficacyThreshold'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when confirmationAutoHitSelection is checked and confirmationThresholdType is sd and confirmationHitSDThreshold is not a number", ->
					@sep.set confirmationAutoHitSelection: true
					@sep.set confirmationThresholdType: "sd"
					@sep.set confirmationHitSDThreshold: NaN
					expect(@sep.isValid()).toBeFalsy()
					filtErrors = _.filter @sep.validationError, (err) ->
						err.attribute=='confirmationHitSDThreshold'
					expect(filtErrors.length).toBeGreaterThan 0
				it "should be invalid when confirmationAutoHitSelection is checked and confirmationThresholdType is efficacy and confirmationHitEfficacyThreshold is not a number", ->
					@sep.set confirmationAutoHitSelection: true
					@sep.set confirmationThresholdType: "efficacy"
					@sep.set confirmationHitEfficacyThreshold: NaN
					expect(@sep.isValid()).toBeFalsy()
					filtErrors = _.filter @sep.validationError, (err) ->
						err.attribute=='confirmationHitEfficacyThreshold'
					expect(filtErrors.length).toBeGreaterThan 0
	describe "AddedExperimentSummaryTableController", ->
		beforeEach ->
			@aestc = new AddedExperimentSummaryTableController
				collection: new ExperimentList()
				exptExptItxs: new Backbone.Collection
				domSuffix: "PrimaryExpt"
				el: @fixture
			@aestc.render()
		describe "Basic existence and rendering", ->
			it "should be defined", ->
				expect(@aestc).toBeDefined()
			it "should render the template", ->
				expect(@aestc.$('tbody').length).toEqual 1
		describe "Functions", ->
			it "should be able to add primary expt interactions", ->
				expect(@aestc.exptExptItxs.length).toEqual 0
				@aestc.linkPrimaryExpt(new Experiment window.experimentServiceTestJSON.fullExperimentFromServer)
				expect(@aestc.exptExptItxs.length).toEqual 1
				expect(@aestc.exptExptItxs.at(0).get('lsType')).toEqual "has member"
				expect(@aestc.exptExptItxs.at(0).get('lsKind')).toEqual "parent_primary child"
			it "should be able to add follow up expt interactions", ->
				@aestc.exptExptItxs = new Backbone.Collection
				expect(@aestc.exptExptItxs.length).toEqual 0
				@aestc.linkFollowUpExpt(new Experiment window.experimentServiceTestJSON.fullExperimentFromServer)
				expect(@aestc.exptExptItxs.length).toEqual 1
				expect(@aestc.exptExptItxs.at(0).get('lsType')).toEqual "has member"
				expect(@aestc.exptExptItxs.at(0).get('lsKind')).toEqual "parent_confirmation child"
			it "should be able to remove an itx", ->
				@aestc.exptExptItxs = new Backbone.Collection
				expect(@aestc.exptExptItxs.length).toEqual 0
				@aestc.linkFollowUpExpt(new Experiment window.experimentServiceTestJSON.fullExperimentFromServer)
				expect(@aestc.exptExptItxs.length).toEqual 1
				@aestc.$('.bv_removeExpt:eq(0)').click()
				expect(@aestc.exptExptItxs.length).toEqual 0
	describe "LinkedExperimentsController tests", ->
		beforeEach ->
			@lec = new LinkedExperimentsController
				model: new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
				el: @fixture
			@lec.render()
		describe "Basic existence and rendering tests", ->
			it "should be defined", ->
				expect(@lec).toBeDefined()
			it "should have search controller divs for primary expts and follow up expts", ->
				expect(@lec.$('.bv_primaryExperimentSearchController').length).toEqual 1
				expect(@lec.$('.bv_followUpExperimentSearchController').length).toEqual 1
	describe 'ScreeningCampaignDataAnalysisController', ->
		describe 'when instantiated', ->
			beforeEach ->
				@scdac = new ScreeningCampaignDataAnalysisController
					model: new ScreeningExperimentParameters window.screeningCampaignTestJSON.screeningCampaignAnalysisParameters
					el: $('#fixture')
				@scdac.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@scdac).toBeDefined()
				it 'should load a template', ->
					expect(@scdac.$('.bv_dataAnalysisParametersWrapper').length).toEqual 1
			describe "render existing parameters", ->
				it 'should show the signal direction rule', ->
					waitsFor ->
						@scdac.$('.bv_signalDirectionRule option').length > 0
					, 1000
					runs ->
						expect(@scdac.$('.bv_signalDirectionRule').val()).toEqual "increasing"
				it 'should show the aggregateBy', ->
					waitsFor ->
						@scdac.$('.bv_aggregateBy option').length > 0
					, 1000
					runs ->
						expect(@scdac.$('.bv_aggregateBy').val()).toEqual "compound batch concentration"
				it 'should show the aggregationMethod', ->
					waitsFor ->
						@scdac.$('.bv_aggregationMethod option').length > 0
					, 1000
					runs ->
						expect(@scdac.$('.bv_aggregationMethod').val()).toEqual "median"
				it 'should show the normalization rule', ->
					waitsFor ->
						@scdac.$('.bv_normalizationRule option').length > 0
					, 1000
					runs ->
						expect(@scdac.$('.bv_normalizationRule').val()).toEqual "plate order only"
				it 'should start with primaryAutoHitSelection unchecked', ->
					expect(@scdac.$('.bv_primaryAutoHitSelection').attr("checked")).toBeUndefined()
				it 'should show the primaryHitSDThreshold', ->
					expect(@scdac.$('.bv_primaryHitSDThreshold').val()).toEqual '5'
				it 'should show the primaryHitEfficacyThreshold', ->
					expect(@scdac.$('.bv_primaryHitEfficacyThreshold').val()).toEqual '42'
				it 'should start with primaryThresholdType radio set', ->
					expect(@scdac.$("input[name='bv_primaryThresholdType']:checked").val()).toEqual 'sd'
				it 'should hide threshold controls if the model loads unchecked primaryAutomaticHitSelection', ->
					expect(@scdac.$('.bv_primaryThresholdControls')).toBeHidden()
				it 'should start with confirmationAutoHitSelection unchecked', ->
					expect(@scdac.$('.bv_confirmationAutoHitSelection').attr("checked")).toBeUndefined()
				it 'should show the confirmationHitSDThreshold', ->
					expect(@scdac.$('.bv_confirmationHitSDThreshold').val()).toEqual '5'
				it 'should show the confirmationHitEfficacyThreshold', ->
					expect(@scdac.$('.bv_confirmationHitEfficacyThreshold').val()).toEqual '42'
					expect(@scdac.$("input[name='bv_confirmationThresholdType']:checked").val()).toEqual 'sd'
				it 'should hide threshold controls if the model loads unchecked confirmationAutomaticHitSelection', ->
					expect(@scdac.$('.bv_confirmationThresholdControls')).toBeHidden()
			describe "model updates", ->
				it "should update the signal direction rule", ->
					waitsFor ->
						@scdac.$('.bv_signalDirectionRule option').length > 0
					, 1000
					runs ->
						@scdac.$('.bv_signalDirectionRule').val('unassigned')
						@scdac.$('.bv_signalDirectionRule').change()
						expect(@scdac.model.get('signalDirectionRule')).toEqual "unassigned"
				it "should update the aggregateBy", ->
					waitsFor ->
						@scdac.$('.bv_aggregateBy option').length > 0
					, 1000
					runs ->
						@scdac.$('.bv_aggregateBy').val('unassigned')
						@scdac.$('.bv_aggregateBy').change()
						expect(@scdac.model.get('aggregateBy')).toEqual "unassigned"
				it "should update the bv_aggregationMethod", ->
					waitsFor ->
						@scdac.$('.bv_aggregationMethod option').length > 0
					, 1000
					runs ->
						@scdac.$('.bv_aggregationMethod').val('unassigned')
						@scdac.$('.bv_aggregationMethod').change()
						expect(@scdac.model.get('aggregationMethod')).toEqual "unassigned"
				it "should update the primaryHitSDThreshold ", ->
					@scdac.$('.bv_primaryHitSDThreshold').val(' 24 ')
					@scdac.$('.bv_primaryHitSDThreshold').keyup()
					expect(@scdac.model.get('primaryHitSDThreshold')).toEqual 24
				it "should update the primaryHitEfficacyThreshold ", ->
					@scdac.$('.bv_primaryHitEfficacyThreshold').val(' 25 ')
					@scdac.$('.bv_primaryHitEfficacyThreshold').keyup()
					expect(@scdac.model.get('primaryHitEfficacyThreshold')).toEqual 25
				it "should update the primaryThresholdType ", ->
					@scdac.$('.bv_primaryThresholdTypeEfficacy').click()
					expect(@scdac.model.get('primaryThresholdType')).toEqual "efficacy"
				it "should update the primaryAutoHitSelection ", ->
					@scdac.$('.bv_primaryAutoHitSelection').click()
					expect(@scdac.model.get('primaryAutoHitSelection')).toBeTruthy()
				it "should update the confirmationHitSDThreshold", ->
					@scdac.$('.bv_confirmationHitSDThreshold').val(' 24 ')
					@scdac.$('.bv_confirmationHitSDThreshold').keyup()
					expect(@scdac.model.get('confirmationHitSDThreshold')).toEqual 24
				it "should update the confirmationHitEfficacyThreshold", ->
					@scdac.$('.bv_confirmationHitEfficacyThreshold').val(' 25 ')
					@scdac.$('.bv_confirmationHitEfficacyThreshold').keyup()
					expect(@scdac.model.get('confirmationHitEfficacyThreshold')).toEqual 25
				it "should update the confirmationThresholdType", ->
					@scdac.$('.bv_confirmationThresholdTypeEfficacy').click()
					expect(@scdac.model.get('confirmationThresholdType')).toEqual "efficacy"
				it "should update the confirmationAutoHitSelection", ->
					@scdac.$('.bv_confirmationAutoHitSelection').click()
					expect(@scdac.model.get('confirmationAutoHitSelection')).toBeTruthy()
			describe "behavior and validation", ->
				it "should disable primary sd threshold field if that radio not selected", ->
					@scdac.$('.bv_primaryThresholdTypeEfficacy').click()
					expect(@scdac.$('.bv_primaryHitSDThreshold').attr("disabled")).toEqual "disabled"
					expect(@scdac.$('.bv_primaryHitEfficacyThreshold').attr("disabled")).toBeUndefined()
				it "should disable primary efficacy threshold field if that radio not selected", ->
					@scdac.$('.bv_primaryThresholdTypeEfficacy').click()
					@scdac.$('.bv_primaryThresholdTypeSD').click()
					expect(@scdac.$('.bv_primaryHitEfficacyThreshold').attr("disabled")).toEqual "disabled"
					expect(@scdac.$('.bv_primaryHitSDThreshold').attr("disabled")).toBeUndefined()
				it "should disable confirmation sd threshold field if that radio not selected", ->
					@scdac.$('.bv_confirmationThresholdTypeEfficacy').click()
					expect(@scdac.$('.bv_confirmationHitSDThreshold').attr("disabled")).toEqual "disabled"
					expect(@scdac.$('.bv_confirmationHitEfficacyThreshold').attr("disabled")).toBeUndefined()
				it "should disable confirmation efficacy threshold field if that radio not selected", ->
					@scdac.$('.bv_confirmationThresholdTypeEfficacy').click()
					@scdac.$('.bv_confirmationThresholdTypeSD').click()
					expect(@scdac.$('.bv_confirmationHitEfficacyThreshold').attr("disabled")).toEqual "disabled"
					expect(@scdac.$('.bv_confirmationHitSDThreshold').attr("disabled")).toBeUndefined()
		describe "validation testing", ->
			beforeEach ->
				@scdac = new ScreeningCampaignDataAnalysisController
					model: new ScreeningExperimentParameters window.screeningCampaignTestJSON.screeningCampaignAnalysisParameters
					el: $('#fixture')
				@scdac.render()
			describe "error notification", ->
				it "should show error if signal direction rule is unassigned", ->
					waitsFor ->
						@scdac.$('.bv_signalDirectionRule option').length > 0
					, 1000
					runs ->
						@scdac.$('.bv_signalDirectionRule').val "unassigned"
						@scdac.$('.bv_signalDirectionRule').change()
						expect(@scdac.$('.bv_group_signalDirectionRule').hasClass("error")).toBeTruthy()
				it "should show error if aggregateBy is unassigned", ->
					waitsFor ->
						@scdac.$('.bv_aggregateBy option').length > 0
					, 1000
					runs ->
						@scdac.$('.bv_aggregateBy').val "unassigned"
						@scdac.$('.bv_aggregateBy').change()
						expect(@scdac.$('.bv_group_aggregateBy').hasClass("error")).toBeTruthy()
				it "should show error if aggregationMethod is unassigned", ->
					waitsFor ->
						@scdac.$('.bv_aggregationMethod option').length > 0
					, 1000
					runs ->
						@scdac.$('.bv_aggregationMethod').val "unassigned"
						@scdac.$('.bv_aggregationMethod').change()
						expect(@scdac.$('.bv_group_aggregationMethod').hasClass("error")).toBeTruthy()
				it "should show error if primary threshold type is efficacy and efficacy threshold not a number", ->
					@scdac.$('.bv_primaryAutoHitSelection').click()
					@scdac.$('.bv_primaryThresholdTypeEfficacy').click()
					@scdac.$('.bv_primaryHitEfficacyThreshold').val ""
					@scdac.$('.bv_primaryHitEfficacyThreshold').keyup()
					expect(@scdac.$('.bv_group_primaryHitEfficacyThreshold').hasClass("error")).toBeTruthy()
				it "should show error if primary threshold type is sd and sd threshold not a number", ->
					@scdac.$('.bv_primaryAutoHitSelection').click()
					@scdac.$('.bv_primaryThresholdTypeSD').click()
					@scdac.$('.bv_primaryHitSDThreshold').val ""
					@scdac.$('.bv_primaryHitSDThreshold').keyup()
					expect(@scdac.$('.bv_group_primaryHitSDThreshold').hasClass("error")).toBeTruthy()
				it "should show error if confirmation threshold type is efficacy and efficacy threshold confirmation not a number", ->
					@scdac.$('.bv_confirmationAutoHitSelection').click()
					@scdac.$('.bv_confirmationThresholdTypeEfficacy').click()
					@scdac.$('.bv_confirmationHitEfficacyThreshold').val ""
					@scdac.$('.bv_confirmationHitEfficacyThreshold').keyup()
					expect(@scdac.$('.bv_group_confirmationHitEfficacyThreshold').hasClass("error")).toBeTruthy()
				it "should show error if confirmation threshold type is sd and sd threshold confirmation not a number", ->
					@scdac.$('.bv_confirmationAutoHitSelection').click()
					@scdac.$('.bv_confirmationThresholdTypeSD').click()
					@scdac.$('.bv_confirmationHitSDThreshold').val ""
					@scdac.$('.bv_confirmationHitSDThreshold').keyup()
					expect(@scdac.$('.bv_group_confirmationHitSDThreshold').hasClass("error")).toBeTruthy()
				it "should show error if transformation rule is unassigned", ->
					waitsFor ->
						@scdac.$('.bv_transformationRule option').length > 0
					, 1000
					runs ->
						@scdac.$('.bv_transformationRule:eq(0)').val "unassigned"
						@scdac.$('.bv_transformationRule:eq(0)').change()
						expect(@scdac.$('.bv_group_transformationRule:eq(0)').hasClass("error")).toBeTruthy()
				it "should show error if a transformation rule is selected more than once", ->
					@scdac.$('.bv_addTransformationButton').click()
					waitsFor ->
						@scdac.$('.bv_transformationInfo .bv_transformationRule option').length > 0
					, 1000
					runs ->
						@scdac.$('.bv_transformationRule:eq(0)').val "sd"
						@scdac.$('.bv_transformationRule:eq(0)').change()
						@scdac.$('.bv_transformationRule:eq(1)').val "sd"
						@scdac.$('.bv_transformationRule:eq(1)').change()
						expect(@scdac.$('.bv_group_transformationRule:eq(0)').hasClass('error')).toBeTruthy()
						expect(@scdac.$('.bv_group_transformationRule:eq(1)').hasClass('error')).toBeTruthy()
	describe "ScreeningCampaignModuleController tests", ->
		beforeEach ->
			@scmc = new ScreeningCampaignModuleController
				model: new Experiment window.experimentServiceTestJSON.fullExperimentFromServer
				el: @fixture
			@scmc.render()
		describe "Basic existence and rendering tests", ->
			it "should be defined", ->
				expect(@scmc).toBeDefined()
			it "should load the template", ->
				expect(@scmc.$('.bv_screeningCampaignGeneralInfo').length).toNotEqual 0
			it "Should load a base experiment controller", ->
				expect(@scmc.$('.bv_screeningCampaignGeneralInfo .bv_experimentName').length).toNotEqual 0
			it "Should load a linked experiments controller", ->
				expect(@scmc.$('.bv_screeningCampaignLinkedExperiments .bv_linkedExperimentsWrapper').length).toNotEqual 0
			it "Should load an analysis controller", ->
				expect(@scmc.$('.bv_screeningCampaignDataAnalysis .bv_dataAnalysisParametersWrapper').length).toNotEqual 0






