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
#				it 'Should have the select DNS target list be unchecked', ->
#					expect(@pspp.get('dnsList')).toBeFalsy()
				it 'Should have an default maxY curve display of 100', ->
					expect(@pspp.getCurveDisplayMax() instanceof Value).toBeTruthy()
					expect(@pspp.getCurveDisplayMax().get('numericValue')).toEqual 100.0
				it 'Should have an default minY curve display of 0', ->
					expect(@pspp.getCurveDisplayMin() instanceof Value).toBeTruthy()
					expect(@pspp.getCurveDisplayMin().get('numericValue')).toEqual 0
			describe "required states and values", ->
				it "should have an assay activity value", ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay activity') instanceof Value).toBeTruthy()
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "unassigned"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeOrigin')).toEqual "acas ddict"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeType')).toEqual "protocolMetadata"
				it "should have a molecular target value with code origin set to acas ddict", ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('molecular target') instanceof Value).toBeTruthy()
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "unassigned"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeOrigin')).toEqual "acas ddict"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeType')).toEqual "protocolMetadata"
				it "should have a target origin value", ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('target origin') instanceof Value).toBeTruthy()
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual "unassigned"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeOrigin')).toEqual "acas ddict"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeType')).toEqual "protocolMetadata"
				it "should have an assay type value", ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay type') instanceof Value).toBeTruthy()
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "unassigned"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeOrigin')).toEqual "acas ddict"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeType')).toEqual "protocolMetadata"
				it "should have an assay technology value", ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay technology') instanceof Value).toBeTruthy()
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "unassigned"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeOrigin')).toEqual "acas ddict"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeType')).toEqual "protocolMetadata"
				it "should have a cell line value", ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('cell line') instanceof Value).toBeTruthy()
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual "unassigned"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeOrigin')).toEqual "acas ddict"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeType')).toEqual "protocolMetadata"
				it "should have an assay stage value", ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay stage') instanceof Value).toBeTruthy()
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual "unassigned"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeOrigin')).toEqual "acas ddict"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeType')).toEqual "protocolMetadata"

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
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "luminescence"
				it 'Should have a molecularTarget value with the codeOrigin set to customer ddict', ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "target x"
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeOrigin')).toEqual "customer ddict"
				it 'Should have an targetOrigin value', ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual "human"
				it 'Should have an assay type value', ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "cellular assay"
				it 'Should have a molecularTarget value with code origin set to dns target list', ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "wizard triple luminescence"
				it 'Should have an targetOrigin value', ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual "cell line y"
				it 'Should have an assay stage value', ->
					expect(@pspp.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual "assay development"

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
			describe "special getters", ->
				describe "primary screen protocol parameters", ->
					it 'Should be able to get primary screen protocol parameters', ->
						expect(@psp.getPrimaryScreenProtocolParameters() instanceof PrimaryScreenProtocolParameters).toBeTruthy()
					it 'Should parse primary screen protocol parameters', ->
						expect(@psp.getPrimaryScreenProtocolParameters().getCurveDisplayMax().get('numericValue')).toEqual 200.0
						expect(@psp.getPrimaryScreenProtocolParameters().getCurveDisplayMin().get('numericValue')).toEqual 10.0
#				describe "analysis parameters", -> #TODO: Uncomment and check later
#					it 'Should be able to get analysis parameters', ->
#						expect(@pse.getAnalysisParameters() instanceof PrimaryScreenAnalysisParameters).toBeTruthy()
#					it 'Should parse analysis parameters', ->
#						expect(@pse.getAnalysisParameters().get('hitSDThreshold')).toEqual 5
#						expect(@pse.getAnalysisParameters().get('dilutionFactor')).toEqual 21
#					it 'Should parse pos control into backbone models', ->
#						expect(@pse.getAnalysisParameters().get('positiveControl').get('batchCode')).toEqual "CMPD-12345678-01"
#					it 'Should parse neg control into backbone models', ->
#						expect(@pse.getAnalysisParameters().get('negativeControl').get('batchCode')).toEqual "CMPD-87654321-01"
#					it 'Should parse veh control into backbone models', ->
#						expect(@pse.getAnalysisParameters().get('vehicleControl').get('batchCode')).toEqual "CMPD-00000001-01"
#					it 'Should parse agonist control into backbone models', ->
#						expect(@pse.getAnalysisParameters().get('agonistControl').get('batchCode')).toEqual "CMPD-87654399-01"

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
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "unassigned"
						expect(@psppc.assayActivityListController.getSelectedCode()).toEqual "unassigned"
				it "should show the molecularTarget as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_molecularTarget option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "unassigned"
						expect(@psppc.molecularTargetListController.getSelectedCode()).toEqual "unassigned"
				it "should show the targetOrigin as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual "unassigned"
						expect(@psppc.targetOriginListController.getSelectedCode()).toEqual "unassigned"
				it "should show the assay type as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_assayType option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "unassigned"
						expect(@psppc.assayTypeListController.getSelectedCode()).toEqual "unassigned"
				it "should show the assay technology as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_assayTechnology option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "unassigned"
						expect(@psppc.assayTechnologyListController.getSelectedCode()).toEqual "unassigned"
				it "should show the cell line as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_cellLine option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual "unassigned"
						expect(@psppc.cellLineListController.getSelectedCode()).toEqual "unassigned"
				it "should show the assay stage as unassigned", ->
					waitsFor ->
						@psppc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual "unassigned"
						expect(@psppc.assayStageListController.getSelectedCode()).toEqual "unassigned"
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
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "luminescence"
						expect(@psppc.assayActivityListController.getSelectedCode()).toEqual "luminescence"
				it "should have the molecularTarget set", ->
					waitsFor ->
						@psppc.$('.bv_molecularTarget option').length > 0
					, 1000
					runs ->
						waits(1000)
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "target x"
						expect(@psppc.molecularTargetListController.getSelectedCode()).toEqual "target x"
				it "should have the targetOrigin set", ->
					waitsFor ->
						@psppc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual "human"
						expect(@psppc.targetOriginListController.getSelectedCode()).toEqual "human"
				it "should have the assay type set", ->
					waitsFor ->
						@psppc.$('.bv_assayType option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "cellular assay"
						expect(@psppc.assayTypeListController.getSelectedCode()).toEqual "cellular assay"
				it "should have the assay technology set", ->
					waitsFor ->
						@psppc.$('.bv_assayTechnology option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "wizard triple luminescence"
						expect(@psppc.assayTechnologyListController.getSelectedCode()).toEqual "wizard triple luminescence"
				it "should have the cell line set", ->
					waitsFor ->
						@psppc.$('.bv_cellLine option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual "cell line y"
						expect(@psppc.cellLineListController.getSelectedCode()).toEqual "cell line y"
				it "should have the assay stage set", ->
					waitsFor ->
						@psppc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual "assay development"
						expect(@psppc.assayStageListController.getSelectedCode()).toEqual "assay development"
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
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "fluorescence"
				it "should update the molecular target", ->
					waitsFor ->
						@psppc.$('.bv_molecularTarget option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_molecularTarget .bv_parameterSelectList').val('target y')
						@psppc.$('.bv_molecularTarget').change()
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "target y"
				it "should update the target origin", ->
					waitsFor ->
						@psppc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_targetOrigin .bv_parameterSelectList').val('chimpanzee')
						@psppc.$('.bv_targetOrigin').change()
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual "chimpanzee"
				it "should update the assay type", ->
					waitsFor ->
						@psppc.$('.bv_assayType option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_assayType .bv_parameterSelectList').val('unassigned')
						@psppc.$('.bv_assayType').change()
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "unassigned"
				it "should update the assay technology", ->
					waitsFor ->
						@psppc.$('.bv_assayTechnology option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_assayTechnology .bv_parameterSelectList').val('unassigned')
						@psppc.$('.bv_assayTechnology').change()
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "unassigned"
				it "should update the cell line", ->
					waitsFor ->
						@psppc.$('.bv_cellLine option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_cellLine .bv_parameterSelectList').val('unassigned')
						@psppc.$('.bv_cellLine').change()
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual "unassigned"
				it "should update the curve display max", ->
					@psppc.$('.bv_maxY').val("130 ")
					@psppc.$('.bv_maxY').change()
					expect(@psppc.model.getCurveDisplayMax().get('numericValue')).toEqual 130
				it "should update the curve display min", ->
					@psppc.$('.bv_minY').val(" 13 ")
					@psppc.$('.bv_minY').change()
					expect(@psppc.model.getCurveDisplayMin().get('numericValue')).toEqual 13
				it "should update model when assay stage changed", ->
					waitsFor ->
						@psppc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_assayStage').val('unassigned')
						@psppc.$('.bv_assayStage').change()
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual "unassigned"
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
		beforeEach ->
			@pspmc = new PrimaryScreenProtocolModuleController
				model: new PrimaryScreenProtocol()
				el: $('#fixture')
			@pspmc.render()
		describe "when instantiated", ->
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@pspmc).toBeDefined()
				it "should have a primary screen protocol controller", ->
					expect(@pspmc.primaryScreenProtocolController).toBeDefined()
				it "should have a primary screen analysis parameters controller", ->
					expect(@pspmc.primaryScreenAnalysisParametersController).toBeDefined()






