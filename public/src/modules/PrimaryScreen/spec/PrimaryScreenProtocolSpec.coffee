beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Primary Screen Protocol module testing", ->
	describe "Primary Screen Protocol Parameters model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@pspp = new PrimaryScreenProtocolParameters()
			describe "Defaults", ->
				it 'Should have an default maxY curve display of 100', ->
					expect(@pspp.getCurveDisplayMax() instanceof Value).toBeTruthy()
					expect(@pspp.getCurveDisplayMax().get('numericValue')).toEqual 100.0
				it 'Should have an default minY curve display of 0', ->
					expect(@pspp.getCurveDisplayMin() instanceof Value).toBeTruthy()
					expect(@pspp.getCurveDisplayMin().get('numericValue')).toEqual 0
			describe "required states and values", ->
				it "should have an assay activity value", ->
					expect(@pspp.getAssayActivity() instanceof Value).toBeTruthy()
					expect(@pspp.getAssayActivity().get('codeValue')).toEqual "unassigned"
					expect(@pspp.getAssayActivity().get('codeOrigin')).toEqual "ACAS DDICT"
					expect(@pspp.getAssayActivity().get('codeType')).toEqual "assay"
					expect(@pspp.getAssayActivity().get('codeKind')).toEqual "activity"
				it "should have a molecular target value with code origin set to acas ddict", ->
					expect(@pspp.getMolecularTarget() instanceof Value).toBeTruthy()
					expect(@pspp.getMolecularTarget().get('codeValue')).toEqual "unassigned"
					expect(@pspp.getMolecularTarget().get('codeOrigin')).toEqual "ACAS DDICT"
					expect(@pspp.getMolecularTarget().get('codeType')).toEqual "assay"
					expect(@pspp.getMolecularTarget().get('codeKind')).toEqual "molecular target"
				it "should have a target origin value", ->
					expect(@pspp.getTargetOrigin() instanceof Value).toBeTruthy()
					expect(@pspp.getTargetOrigin().get('codeValue')).toEqual "unassigned"
					expect(@pspp.getTargetOrigin().get('codeOrigin')).toEqual "ACAS DDICT"
					expect(@pspp.getTargetOrigin().get('codeType')).toEqual "target"
					expect(@pspp.getTargetOrigin().get('codeKind')).toEqual "origin"
				it "should have an assay type value", ->
					expect(@pspp.getAssayType() instanceof Value).toBeTruthy()
					expect(@pspp.getAssayType().get('codeValue')).toEqual "unassigned"
					expect(@pspp.getAssayType().get('codeOrigin')).toEqual "ACAS DDICT"
					expect(@pspp.getAssayType().get('codeType')).toEqual "assay"
					expect(@pspp.getAssayType().get('codeKind')).toEqual "type"
				it "should have an assay technology value", ->
					expect(@pspp.getAssayTechnology() instanceof Value).toBeTruthy()
					expect(@pspp.getAssayTechnology().get('codeValue')).toEqual "unassigned"
					expect(@pspp.getAssayTechnology().get('codeOrigin')).toEqual "ACAS DDICT"
					expect(@pspp.getAssayTechnology().get('codeType')).toEqual "assay"
					expect(@pspp.getAssayTechnology().get('codeKind')).toEqual "technology"
				it "should have a cell line value", ->
					expect(@pspp.getCellLine() instanceof Value).toBeTruthy()
					expect(@pspp.getCellLine().get('codeValue')).toEqual "unassigned"
					expect(@pspp.getCellLine().get('codeOrigin')).toEqual "ACAS DDICT"
					expect(@pspp.getCellLine().get('codeType')).toEqual "reagent"
					expect(@pspp.getCellLine().get('codeKind')).toEqual "cell line"

		describe "When loaded from existing", ->
			beforeEach ->
				@pspp = new PrimaryScreenProtocolParameters window.primaryScreenProtocolTestJSON.primaryScreenProtocolParameters
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@pspp).toBeDefined()
			describe "after initial load", ->
				it "should have a maxY curve display ", ->
					expect(@pspp.getCurveDisplayMax().get('numericValue')).toEqual 200.0
				it "should have a minY curve display ", ->
					expect(@pspp.getCurveDisplayMin().get('numericValue')).toEqual 10.0
				it 'Should have an assay Activity value', ->
					expect(@pspp.getAssayActivity().get('codeValue')).toEqual "luminescence"
				it 'Should have a molecularTarget value with the codeOrigin set to customer ddict', ->
					expect(@pspp.getMolecularTarget().get('codeValue')).toEqual "test1"
					expect(@pspp.getMolecularTarget().get('codeOrigin')).toEqual "customer ddict"
				it 'Should have an targetOrigin value', ->
					expect(@pspp.getTargetOrigin().get('codeValue')).toEqual "human"
				it 'Should have an assay type value', ->
					expect(@pspp.getAssayType().get('codeValue')).toEqual "cellular assay"
				it 'Should have a assay technology value', ->
					expect(@pspp.getAssayTechnology().get('codeValue')).toEqual "wizard triple luminescence"
				it 'Should have an cell line value', ->
					expect(@pspp.getCellLine().get('codeValue')).toEqual "cell line y"

		describe "model validation", ->
			beforeEach ->
				@pspp = new PrimaryScreenProtocolParameters window.primaryScreenProtocolTestJSON.primaryScreenProtocolParameters
			it "should be valid when loaded from saved", ->
				expect(@pspp.isValid()).toBeTruthy()
			it "should be invalid when maxY is NaN", ->
				@pspp.getCurveDisplayMax().set numericValue: NaN
				expect(@pspp.isValid()).toBeFalsy()
				filtErrors = _.filter(@pspp.validationError, (err) ->
					err.attribute=='maxY'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when minY is NaN", ->
				@pspp.getCurveDisplayMin().set numericValue: NaN
				expect(@pspp.isValid()).toBeFalsy()
				filtErrors = _.filter(@pspp.validationError, (err) ->
					err.attribute=='minY'
				)
				expect(filtErrors.length).toBeGreaterThan 0


	describe "Primary Screen Protocol model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@psp = new PrimaryScreenProtocol()
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@psp).toBeDefined()
		describe "When loaded from existing", ->
			beforeEach ->
				@psp = new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@psp).toBeDefined()
				it "should have lsKind set to Bio Activity", ->
					expect(@psp.get('lsKind')).toEqual "Bio Activity"
			describe "special getters", ->
				describe "primary screen protocol parameters", ->
					it 'Should be able to get primary screen protocol parameters', ->
						expect(@psp.getPrimaryScreenProtocolParameters() instanceof PrimaryScreenProtocolParameters).toBeTruthy()
					it 'Should parse primary screen protocol parameters', ->
						expect(@psp.getPrimaryScreenProtocolParameters().getCurveDisplayMax().get('numericValue')).toEqual 200.0
						expect(@psp.getPrimaryScreenProtocolParameters().getCurveDisplayMin().get('numericValue')).toEqual 10.0
				describe "analysis parameters", -> #TODO: Uncomment and check later
					it 'Should be able to get analysis parameters', ->
						expect(@psp.getAnalysisParameters() instanceof PrimaryScreenAnalysisParameters).toBeTruthy()
					it 'Should parse analysis parameters', ->
						expect(@psp.getAnalysisParameters().get('hitSDThreshold')).toEqual 5
						expect(@psp.getAnalysisParameters().get('dilutionFactor')).toEqual 21
					it 'Should parse pos control into backbone models', ->
						expect(@psp.getAnalysisParameters().get('positiveControl').get('batchCode')).toEqual "CMPD-12345678-01"
					it 'Should parse neg control into backbone models', ->
						expect(@psp.getAnalysisParameters().get('negativeControl').get('batchCode')).toEqual "CMPD-87654321-01"
					it 'Should parse veh control into backbone models', ->
						expect(@psp.getAnalysisParameters().get('vehicleControl').get('batchCode')).toEqual "CMPD-00000001-01"
					it 'Should parse agonist control into backbone models', ->
						expect(@psp.getAnalysisParameters().get('agonistControl').get('batchCode')).toEqual "CMPD-87654399-01"

	describe "PrimaryScreenProtocolParametersController", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@psppc = new PrimaryScreenProtocolParametersController
					model: new PrimaryScreenProtocolParameters()
					el: $('#fixture')
				@psppc.render()
			describe "Basic existence tests", ->
				it "should exist", ->
					expect(@psppc).toBeDefined()
				it 'should load autofill template', ->
					expect(@psppc.$('.bv_assayActivity').length).toEqual 1
			describe "render existing parameters", ->
				it "should show the assayActivity as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_assayActivity option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getAssayActivity().get('codeValue')).toEqual "unassigned"
						expect(@psppc.assayActivityListController.getSelectedCode()).toEqual "unassigned"
				it "should show the molecularTarget as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_molecularTarget option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getMolecularTarget().get('codeValue')).toEqual "unassigned"
						expect(@psppc.molecularTargetListController.getSelectedCode()).toEqual "unassigned"
				it "should show the targetOrigin as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getTargetOrigin().get('codeValue')).toEqual "unassigned"
						expect(@psppc.targetOriginListController.getSelectedCode()).toEqual "unassigned"
				it "should show the assay type as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_assayType option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getAssayType().get('codeValue')).toEqual "unassigned"
						expect(@psppc.assayTypeListController.getSelectedCode()).toEqual "unassigned"
				it "should show the assay technology as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_assayTechnology option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getAssayTechnology().get('codeValue')).toEqual "unassigned"
						expect(@psppc.assayTechnologyListController.getSelectedCode()).toEqual "unassigned"
				it "should show the cell line as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_cellLine option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getCellLine().get('codeValue')).toEqual "unassigned"
						expect(@psppc.cellLineListController.getSelectedCode()).toEqual "unassigned"
				it "should have the customer molecular target ddict checkbox ", ->
					expect(@psppc.$('.bv_customerMolecularTargetDDictChkbx').attr("checked")).toBeUndefined()
				it "should show the curve display max", ->
					expect(@psppc.model.getCurveDisplayMax().get('numericValue')).toEqual 100.0
					expect(@psppc.$('.bv_maxY').val()).toEqual "100"
				it "should show the curve display min", ->
					expect(@psppc.model.getCurveDisplayMin().get('numericValue')).toEqual 0.0
					expect(@psppc.$('.bv_minY').val()).toEqual "0"

		describe "when instantiated with data", ->
			beforeEach ->
				@psppc = new PrimaryScreenProtocolParametersController
					model: new PrimaryScreenProtocolParameters window.primaryScreenProtocolTestJSON.primaryScreenProtocolParameters
					el: $('#fixture')
				@psppc.render()
			describe "Basic existence tests", ->
				it "should exist", ->
					expect(@psppc).toBeDefined()
				it 'should load autofill template', ->
					expect(@psppc.$('.bv_assayActivity').length).toEqual 1
			describe "render existing parameters", ->
				it "should have the assayActivity set", ->
					waitsFor ->
						@psppc.$('.bv_assayActivity option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getAssayActivity().get('codeValue')).toEqual "luminescence"
						expect(@psppc.assayActivityListController.getSelectedCode()).toEqual "luminescence"
				it "should have the molecularTarget set", ->
					waitsFor ->
						@psppc.$('.bv_molecularTarget option').length > 0
					, 1000
					runs ->
						waits(1000)
						expect(@psppc.model.getMolecularTarget().get('codeValue')).toEqual "test1"
						expect(@psppc.molecularTargetListController.getSelectedCode()).toEqual "test1"
				it "should have the targetOrigin set", ->
					waitsFor ->
						@psppc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getTargetOrigin().get('codeValue')).toEqual "human"
						expect(@psppc.targetOriginListController.getSelectedCode()).toEqual "human"
				it "should have the assay type set", ->
					waitsFor ->
						@psppc.$('.bv_assayType option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getAssayType().get('codeValue')).toEqual "cellular assay"
						expect(@psppc.assayTypeListController.getSelectedCode()).toEqual "cellular assay"
				it "should have the assay technology set", ->
					waitsFor ->
						@psppc.$('.bv_assayTechnology option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getAssayTechnology().get('codeValue')).toEqual "wizard triple luminescence"
						expect(@psppc.assayTechnologyListController.getSelectedCode()).toEqual "wizard triple luminescence"
				it "should have the cell line set", ->
					waitsFor ->
						@psppc.$('.bv_cellLine option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getCellLine().get('codeValue')).toEqual "cell line y"
						expect(@psppc.cellLineListController.getSelectedCode()).toEqual "cell line y"
				it "should have the customer molecular target ddict checkbox checked ", ->
					expect(@psppc.$('.bv_customerMolecularTargetDDictChkbx').attr("checked")).toEqual "checked"
				it 'should show the maxY', ->
					expect(@psppc.model.getCurveDisplayMax().get('numericValue')).toEqual 200.0
				it 'should show the minY', ->
					expect(@psppc.model.getCurveDisplayMin().get('numericValue')).toEqual 10.0

			describe "model updates", ->
				it "should update the assay activity", ->
					waitsFor ->
						@psppc.$('.bv_assayActivity option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_assayActivity .bv_parameterSelectList').val('fluorescence')
						@psppc.$('.bv_assayActivity').change()
						expect(@psppc.model.getAssayActivity().get('codeValue')).toEqual "fluorescence"
				it "should update the molecular target", ->
					waitsFor ->
						@psppc.$('.bv_molecularTarget option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_molecularTarget .bv_parameterSelectList').val('test2')
						@psppc.$('.bv_molecularTarget').change()
						expect(@psppc.model.getMolecularTarget().get('codeValue')).toEqual "test2"
				it "should update the target origin", ->
					waitsFor ->
						@psppc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_targetOrigin .bv_parameterSelectList').val('chimpanzee')
						@psppc.$('.bv_targetOrigin').change()
						expect(@psppc.model.getTargetOrigin().get('codeValue')).toEqual "chimpanzee"
				it "should update the assay type", ->
					waitsFor ->
						@psppc.$('.bv_assayType option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_assayType .bv_parameterSelectList').val('unassigned')
						@psppc.$('.bv_assayType').change()
						expect(@psppc.model.getAssayType().get('codeValue')).toEqual "unassigned"
				it "should update the assay technology", ->
					waitsFor ->
						@psppc.$('.bv_assayTechnology option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_assayTechnology .bv_parameterSelectList').val('unassigned')
						@psppc.$('.bv_assayTechnology').change()
						expect(@psppc.model.getAssayTechnology().get('codeValue')).toEqual "unassigned"
				it "should update the cell line", ->
					waitsFor ->
						@psppc.$('.bv_cellLine option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_cellLine .bv_parameterSelectList').val('unassigned')
						@psppc.$('.bv_cellLine').change()
						expect(@psppc.model.getCellLine().get('codeValue')).toEqual "unassigned"
				it "should update the curve display max", ->
					@psppc.$('.bv_maxY').val("130 ")
					@psppc.$('.bv_maxY').change()
					expect(@psppc.model.getCurveDisplayMax().get('numericValue')).toEqual 130
				it "should update the curve display min", ->
					@psppc.$('.bv_minY').val(" 13 ")
					@psppc.$('.bv_minY').change()
					expect(@psppc.model.getCurveDisplayMin().get('numericValue')).toEqual 13
			describe "behavior", ->
				it "should hide the Molecular Target's add button when the customer molecular target ddict checkbox is checked", ->
					@psppc.$('.bv_customerMolecularTargetDDictChkbx').click()
#					@psppc.$('.bv_customerMolecularTargetDDictChkbx').click()
					expect(@psppc.$('.bv_molecularTarget .bv_addOptionBtn')).toBeHidden()
				# not sure why this test fails but it works in the GUI
			describe "controller validation rules", ->
				it "should show error when maxY is NaN", ->
					@psppc.$('.bv_maxY').val("b")
					@psppc.$('.bv_maxY').change()
					expect(@psppc.$('.bv_group_maxY').hasClass('error')).toBeTruthy()
				it "should show error when minY is NaN", ->
					@psppc.$('.bv_minY').val("b")
					@psppc.$('.bv_minY').change()
					expect(@psppc.$('.bv_group_minY').hasClass('error')).toBeTruthy()

	describe "PrimaryScreenProtocolController", ->
		beforeEach ->
			@pspc = new PrimaryScreenProtocolController
				model: new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
				el: $('#fixture')
			@pspc.render()
		describe "when instantiated", ->
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@pspc).toBeDefined()
				it "should have protocol base controller", ->
					expect(@pspc.protocolBaseController).toBeDefined()
				it "should have a primary screen protocol parameters controller", ->
					expect(@pspc.primaryScreenProtocolParametersController).toBeDefined()

	describe "Abstract Primary Screen Protocol Module Controller testing", ->
		describe "Basic loading", ->
			it "Class should exist", ->
				expect(window.AbstractPrimaryScreenProtocolModuleController).toBeDefined()

	describe "Primary Screen Protocol Module Controller testing", ->
		describe "when instantiated with no data", ->
			beforeEach ->
				@pspmc = new PrimaryScreenProtocolModuleController
					model: new PrimaryScreenProtocol()
					el: $('#fixture')
				@pspmc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@pspmc).toBeDefined()
				it "should have a primary screen protocol controller", ->
					expect(@pspmc.primaryScreenProtocolController).toBeDefined()
				it "should have a primary screen analysis parameters controller", ->
					expect(@pspmc.primaryScreenAnalysisParametersController).toBeDefined()
			describe "save module button testing", ->
				describe "when instantiated with new primary screen protocol", ->
					it "should show the save button text as Save", ->
						expect(@pspmc.$('.bv_saveModule').html()).toEqual "Save"
					it "should show the save button disabled", ->
						expect(@pspmc.$('.bv_saveModule').attr('disabled')).toEqual 'disabled'
				describe "expect save to work", ->
					beforeEach ->
						runs ->
							@pspmc.$('.bv_protocolName').val(" example protocol name   ")
							@pspmc.$('.bv_protocolName').change()
							@pspmc.$('.bv_recordedBy').val("nxm7557")
							@pspmc.$('.bv_recordedBy').change()
							@pspmc.$('.bv_completionDate').val(" 2013-3-16   ")
							@pspmc.$('.bv_completionDate').val(" 2013-3-16   ")
							@pspmc.$('.bv_completionDate').change()
							@pspmc.$('.bv_notebook').val("my notebook")
							@pspmc.$('.bv_notebook').change()
							@pspmc.$('.bv_positiveControlBatch').val("test")
							@pspmc.$('.bv_positiveControlBatch').change()
							@pspmc.$('.bv_positiveControlConc').val(" 123 ")
							@pspmc.$('.bv_positiveControlConc').change()
							@pspmc.$('.bv_negativeControlBatch').val("test2")
							@pspmc.$('.bv_negativeControlBatch').change()
							@pspmc.$('.bv_negativeControlConc').val(" 1231 ")
							@pspmc.$('.bv_negativeControlConc').change()
							@pspmc.$('.bv_readName').val("luminescence")
							@pspmc.$('.bv_readName').change()
							@pspmc.$('.bv_signalDirectionRule').val("increasing")
							@pspmc.$('.bv_signalDirectionRule').change()
							@pspmc.$('.bv_aggregateBy').val("compound batch concentration")
							@pspmc.$('.bv_aggregateBy').change()
							@pspmc.$('.bv_aggregationMethod').val("mean")
							@pspmc.$('.bv_aggregationMethod').change()
							@pspmc.$('.bv_normalizationRule').val("plate order only")
							@pspmc.$('.bv_normalizationRule').change()
							@pspmc.$('.bv_transformationRule').val("sd")
							@pspmc.$('.bv_transformationRule').change()
						waitsFor ->
							@pspmc.$('.bv_transformationRule option').length > 0
						, 1000
					it "should have a save button", ->
						runs ->
							expect(@pspmc.$('.bv_saveModule').length).toEqual 1
					xit "model should be valid and ready to save", ->
						runs ->
							expect(@pspmc.model.isValid()).toBeTruthy()
					xit "should update protocol code", ->
						runs ->
							@pspmc.$('.bv_saveModule').click()
						waits(1000)
						runs ->
							console.log "save should have been clicked"
							console.log @pspmc
							expect(@pspmc.$('.bv_protocolCode').html()).toEqual "PROT-00000001"
		describe "when instantiated with data", ->
			beforeEach ->
				@pspmc = new PrimaryScreenProtocolModuleController
					model: new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
					el: $('#fixture')
				@pspmc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@pspmc).toBeDefined()
				it "should have a primary screen protocol controller", ->
					expect(@pspmc.primaryScreenProtocolController).toBeDefined()
				it "should have a primary screen analysis parameters controller", ->
					expect(@pspmc.primaryScreenAnalysisParametersController).toBeDefined()
			describe "save module button testing", ->
				describe "when instantiated with new primary screen protocol", ->
					it "should show the save button text as Update", ->
						expect(@pspmc.$('.bv_saveModule').html()).toEqual "Update"
					it "should show the save button disabled", ->
						expect(@pspmc.$('.bv_saveModule').attr('disabled')).toEqual 'disabled'
				describe "when a tab is invalid", ->
					it "should have the save button disabled if the general information tab is not filled in properly", ->
						expect(@pspmc.$('.bv_saveModule').attr('disabled')).toEqual 'disabled'
				describe "expect save to work", ->
					beforeEach ->
						runs ->
							@pspmc.$('.bv_protocolName').val(" example protocol name   ")
							@pspmc.$('.bv_protocolName').change()
							@pspmc.$('.bv_recordedBy').val("nxm7557")
							@pspmc.$('.bv_recordedBy').change()
							@pspmc.$('.bv_completionDate').val(" 2013-3-16   ")
							@pspmc.$('.bv_completionDate').change()
							@pspmc.$('.bv_notebook').val("my notebook")
							@pspmc.$('.bv_notebook').change()
							@pspmc.$('.bv_positiveControlBatch').val("test")
							@pspmc.$('.bv_positiveControlBatch').change()
							@pspmc.$('.bv_positiveControlConc').val(" 123 ")
							@pspmc.$('.bv_positiveControlConc').change()
							@pspmc.$('.bv_negativeControlBatch').val("test2")
							@pspmc.$('.bv_negativeControlBatch').change()
							@pspmc.$('.bv_negativeControlConc').val(" 1231 ")
							@pspmc.$('.bv_negativeControlConc').change()
							@pspmc.$('.bv_readName').val("luminescence")
							@pspmc.$('.bv_readName').change()
							@pspmc.$('.bv_signalDirectionRule').val("increasing")
							@pspmc.$('.bv_signalDirectionRule').change()
							@pspmc.$('.bv_aggregateBy').val("compound batch concentration")
							@pspmc.$('.bv_aggregateBy').change()
							@pspmc.$('.bv_aggregationMethod').val("mean")
							@pspmc.$('.bv_aggregationMethod').change()
							@pspmc.$('.bv_normalizationRule').val("plate order only")
							@pspmc.$('.bv_normalizationRule').change()
							@pspmc.$('.bv_transformationRule').val("sd")
							@pspmc.$('.bv_transformationRule').change()
						waitsFor ->
							@pspmc.$('.bv_transformationRule option').length > 0
						, 1000
					it "should show the save button text as Update", ->
						runs ->
							@pspmc.$('.bv_saveModule').click()
						waits(1000)
						runs ->
							expect(@pspmc.$('.bv_saveModule').html()).toEqual "Update"









