beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Primary Screen Protocol module testing", ->
	describe "Primary Screen Protocol model testing", ->
		describe "When loaded from new", ->
			beforeEach ->
				@psp = new PrimaryScreenProtocol()
			describe "Defaults", ->
				it 'Should have the select DNS target list be unchecked', ->
					expect(@psp.get('dnsList')).toBeFalsy()
				it 'Should have an default maxY curve display of 100', ->
					expect(@psp.getCurveDisplayMax() instanceof Value).toBeTruthy()
					expect(@psp.getCurveDisplayMax().get('numericValue')).toEqual 100.0
				it 'Should have an default minY curve display of 0', ->
					expect(@psp.getCurveDisplayMin() instanceof Value).toBeTruthy()
					expect(@psp.getCurveDisplayMin().get('numericValue')).toEqual 0
			describe "required states and values", ->
				it "should have an assay activity value", ->
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay activity') instanceof Value).toBeTruthy()
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "unassigned"
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeOrigin')).toEqual "acas ddict"
				it "should have a molecular target value with code origin set to acas ddict", ->
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('molecular target') instanceof Value).toBeTruthy()
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "unassigned"
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeOrigin')).toEqual "acas ddict"
				it "should have a target origin value", ->
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('target origin') instanceof Value).toBeTruthy()
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual "unassigned"
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeOrigin')).toEqual "acas ddict"
				it "should have an assay type value", ->
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay type') instanceof Value).toBeTruthy()
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "unassigned"
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeOrigin')).toEqual "acas ddict"
				it "should have an assay technology value", ->
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay technology') instanceof Value).toBeTruthy()
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "unassigned"
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeOrigin')).toEqual "acas ddict"
				it "should have a cell line value", ->
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('cell line') instanceof Value).toBeTruthy()
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual "unassigned"
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeOrigin')).toEqual "acas ddict"
				it "should have an assay stage value", ->
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay stage') instanceof Value).toBeTruthy()
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual "unassigned"
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeOrigin')).toEqual "acas ddict"
		describe "When loaded from existing", ->
			beforeEach ->
				@psp = new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@psp).toBeDefined()
			describe "after initial load", ->
				it "should have the Select DNS Target List be checked ", ->
#					expect(@psp.get('dnsTargetList')).toEqual true
					expect(@psp.get('dnsList')).toBeTruthy()
				it "should have a maxY curve display ", ->
					expect(@psp.getCurveDisplayMax().get('numericValue')).toEqual 200
				it "should have a minY curve display ", ->
					expect(@psp.getCurveDisplayMin().get('numericValue')).toEqual 10.0
				it 'Should have an assay Activity value', ->
					console.log @psp.getPrimaryScreenProtocolParameterCodeValue('assay activity')
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "luminescence"
				it 'Should have a molecularTarget value', ->
					console.log @psp.getPrimaryScreenProtocolParameterCodeValue('molecular target')
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "target x"
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeOrigin')).toEqual "dns target list"
				it 'Should have an targetOrigin value', ->
					console.log @psp.getPrimaryScreenProtocolParameterCodeValue('target origin')
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual "human"
				it 'Should have an assay type value', ->
					console.log @psp.getPrimaryScreenProtocolParameterCodeValue('assay type')
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "cellular assay"
				it 'Should have a molecularTarget value with code origin set to dns target list', ->
					console.log @psp.getPrimaryScreenProtocolParameterCodeValue('assay technology')
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "wizard triple luminescence"
				it 'Should have an targetOrigin value', ->
					console.log @psp.getPrimaryScreenProtocolParameterCodeValue('cell line')
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual "cell line y"
				it 'Should have an assay stage value', ->
					console.log @psp.getPrimaryScreenProtocolParameterCodeValue('assay stage')
					expect(@psp.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual "assay development"
		describe "model validation", ->
			beforeEach ->
				@psp = new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
			it "should be valid when loaded from saved", ->
				expect(@psp.isValid()).toBeTruthy()
			it "should be invalid when maxY is NaN", ->
				@psp.getCurveDisplayMax().set numericValue: NaN
				expect(@psp.isValid()).toBeFalsy()
				filtErrors = _.filter(@psp.validationError, (err) ->
					err.attribute=='maxY'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when minY is NaN", ->
				@psp.getCurveDisplayMin().set numericValue: NaN
				expect(@psp.isValid()).toBeFalsy()
				filtErrors = _.filter(@psp.validationError, (err) ->
					err.attribute=='minY'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe "AbstractPrimaryScreenProtocolParameterController testing", ->
		describe "Basic loading", ->
			it "class should exist", ->
				expect(window.AbstractPrimaryScreenProtocolParameterController).toBeDefined()

	describe "AssayActivityController testing", ->
		describe "when created from a new protocol", ->
			beforeEach ->
				@aac = new AssayActivityController
					model: new PrimaryScreenProtocol()
				@aac.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@aac).toBeDefined()
				it "should have the parameter variable set to assay activity", ->
					expect(@aac.parameter).toEqual "assayActivity"
				it "should show the assayActivity as unassigned", ->
					waitsFor ->
						@aac.$('.bv_assayActivity option').length > 0
					, 1000
					runs ->
						expect(@aac.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "unassigned"
						expect(@aac.$('.bv_assayActivity').val()).toEqual "unassigned"
		describe "when created from a saved primary screen protocol", ->
			beforeEach ->
				@aac = new AssayActivityController
					model: new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
					el: $('#fixture')
				@aac.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@aac).toBeDefined()
				it "should have the parameter variable set to assay activity", ->
					expect(@aac.parameter).toEqual "assayActivity"
				it "should show the assayActivity", ->
					waitsFor ->
						@aac.$('.bv_assayActivity option').length > 0
					, 1000
					runs ->
						expect(@aac.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "luminescence"
						expect(@aac.$('.bv_assayActivity').val()).toEqual "luminescence"
			describe "model updates", ->
				it "should update the assay activity", ->
					waitsFor ->
						@aac.$('.bv_assayActivity option').length > 0
					, 1000
					runs ->
						@aac.$('.bv_assayActivity').val('fluorescence')
						@aac.$('.bv_assayActivity').change()
						expect(@aac.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "fluorescence"
				describe "pop modal testing", ->
					it "should display a modal when add button is clicked", ->
						@aac.$('.bv_addAssayActivityBtn').click()
						expect(@aac.$('.bv_newAssayActivityLabel').length).toEqual 1
					# TODO: validation testing for added option
					it "should show confirmation message if new option is added", ->
						@aac.$('.bv_newAssayActivityLabel').val("new option")
						@aac.$('.bv_newAssayActivityLabel').change()
						@aac.$('.bv_addNewAssayActivityOption').click()
						expect(@aac.$('.bv_optionAddedMessage')).toBeVisible()
						expect(@aac.$('.bv_errorMessage')).toBeHidden()
					it "should show error message if user tries to add existing option", ->
						@aac2 = new AssayActivityController # new controller needed to pass test
							model: new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
							el: $('#fixture')
						@aac2.render()
						@aac2.$('.bv_addAssayActivityBtn').click()
						@aac2.$('.bv_newAssayActivityLabel').val("luminescence")
						@aac2.$('.bv_newAssayActivityLabel').change()
						@aac2.$('.bv_addNewAssayActivityOption').click()
						expect(@aac2.$('.bv_optionAddedMessage')).toBeHidden()
						expect(@aac2.$('.bv_errorMessage')).toBeVisible()


	describe "MolecularTargetController testing", ->
		describe "when created from a new protocol", ->
			beforeEach ->
				@mtc = new MolecularTargetController
					model: new PrimaryScreenProtocol()
				@mtc.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@mtc).toBeDefined()
				it "should have the parameter variable set to molecular target ", ->
					expect(@mtc.parameter).toEqual "molecularTarget"
				it "should show the molecularTarget as unassigned", ->
					waitsFor ->
						@mtc.$('.bv_molecularTarget option').length > 0
					, 1000
					runs ->
						expect(@mtc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "unassigned"
						expect(@mtc.$('.bv_molecularTarget').val()).toEqual "unassigned"
		describe "when created from a saved primary screen protocol", ->
			beforeEach ->
				@mtc = new MolecularTargetController
					model: new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
					el: $('#fixture')
				@mtc.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@mtc).toBeDefined()
				it "should have the parameter variable set to molecular target ", ->
					expect(@mtc.parameter).toEqual "molecularTarget"
				it "should show the molecularTarget", ->
					waitsFor ->
						@mtc.$('.bv_molecularTarget option').length > 0
					, 1000
					runs ->
						expect(@mtc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "target x"
						expect(@mtc.$('.bv_molecularTarget').val()).toEqual "target x"
			describe "model updates", ->
				it "should update the molecular target", ->
					waitsFor ->
						@mtc.$('.bv_molecularTarget option').length > 0
					, 1000
					runs ->
						@mtc.$('.bv_molecularTarget').val('target y')
						@mtc.$('.bv_molecularTarget').change()
						expect(@mtc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "target y"

	describe "TargetOriginController testing", ->
		describe "when created from a new protocol", ->
			beforeEach ->
				@toc = new TargetOriginController
					model: new PrimaryScreenProtocol()
				@toc.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@toc).toBeDefined()
				it "should have the parameter variable set to target origin", ->
					expect(@toc.parameter).toEqual "targetOrigin"
				it "should show the targetOrigin as unassigned", ->
					waitsFor ->
						@toc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						expect(@toc.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual "unassigned"
						expect(@toc.$('.bv_targetOrigin').val()).toEqual "unassigned"
		describe "when created from a saved primary screen protocol", ->
			beforeEach ->
				@toc = new TargetOriginController
					model: new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
					el: $('#fixture')
				@toc.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@toc).toBeDefined()
				it "should have the parameter variable set to target origin", ->
					expect(@toc.parameter).toEqual "targetOrigin"
				it "should show the targetOrigin", ->
					waitsFor ->
						@toc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						expect(@toc.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual "human"
						expect(@toc.$('.bv_targetOrigin').val()).toEqual "human"
			describe "model updates", ->
				it "should update the target origin", ->
					waitsFor ->
						@toc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						@toc.$('.bv_targetOrigin').val('chimpanzee')
						@toc.$('.bv_targetOrigin').change()
						expect(@toc.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual "chimpanzee"

	describe "AssayTypeController testing", ->
		describe "when created from a new protocol", ->
			beforeEach ->
				@atc = new AssayTypeController
					model: new PrimaryScreenProtocol()
				@atc.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@atc).toBeDefined()
				it "should have the parameter variable set to assay type", ->
					expect(@atc.parameter).toEqual "assayType"
				it "should show the assay type as unassigned", ->
					waitsFor ->
						@atc.$('.bv_assayType option').length > 0
					, 1000
					runs ->
						expect(@atc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "unassigned"
						expect(@atc.$('.bv_assayType').val()).toEqual "unassigned"
		describe "when created from a saved primary screen protocol", ->
			beforeEach ->
				@atc = new AssayTypeController
					model: new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
					el: $('#fixture')
				@atc.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@atc).toBeDefined()
				it "should have the parameter variable set to assay type", ->
					expect(@atc.parameter).toEqual "assayType"
				it "should show the assayType", ->
					waitsFor ->
						@atc.$('.bv_assayType option').length > 0
					, 1000
					runs ->
						expect(@atc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "cellular assay"
						expect(@atc.$('.bv_assayType').val()).toEqual "cellular assay"
			describe "model updates", ->
				it "should update the assay type", ->
					waitsFor ->
						@atc.$('.bv_assayType option').length > 0
					, 1000
					runs ->
						@atc.$('.bv_assayType').val('unassigned')
						@atc.$('.bv_assayType').change()
						expect(@atc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "unassigned"

	describe "AssayTechnologyController testing", ->
		describe "when created from a new protocol", ->
			beforeEach ->
				@atc2 = new AssayTechnologyController
					model: new PrimaryScreenProtocol()
				@atc2.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@atc2).toBeDefined()
				it "should have the parameter variable set to assay technology", ->
					expect(@atc2.parameter).toEqual "assayTechnology"
				it "should show the assay technology as unassigned", ->
					waitsFor ->
						@atc2.$('.bv_assayTechnology option').length > 0
					, 1000
					runs ->
						expect(@atc2.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "unassigned"
						expect(@atc2.$('.bv_assayTechnology').val()).toEqual "unassigned"
		describe "when created from a saved primary screen protocol", ->
			beforeEach ->
				@atc2 = new AssayTechnologyController
					model: new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
					el: $('#fixture')
				@atc2.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@atc2).toBeDefined()
				it "should have the parameter variable set to assay technology", ->
					expect(@atc2.parameter).toEqual "assayTechnology"
				it "should show the assayTechnology", ->
					waitsFor ->
						@atc2.$('.bv_assayTechnology option').length > 0
					, 1000
					runs ->
						expect(@atc2.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "wizard triple luminescence"
						expect(@atc2.$('.bv_assayTechnology').val()).toEqual "wizard triple luminescence"
			describe "model updates", ->
				it "should update the assay technology", ->
					waitsFor ->
						@atc2.$('.bv_assayTechnology option').length > 0
					, 1000
					runs ->
						@atc2.$('.bv_assayTechnology').val('unassigned')
						@atc2.$('.bv_assayTechnology').change()
						expect(@atc2.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "unassigned"


	describe "CellLineController testing", ->
		describe "when created from a new protocol", ->
			beforeEach ->
				@clc = new CellLineController
					model: new PrimaryScreenProtocol()
				@clc.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@clc).toBeDefined()
				it "should have the parameter variable set to cell line", ->
					expect(@clc.parameter).toEqual "cellLine"
				it "should show the cell line as unassigned", ->
					waitsFor ->
						@clc.$('.bv_cellLine option').length > 0
					, 1000
					runs ->
						expect(@clc.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual "unassigned"
						expect(@clc.$('.bv_cellLine').val()).toEqual "unassigned"
		describe "when created from a saved primary screen protocol", ->
			beforeEach ->
				@clc = new CellLineController
					model: new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
					el: $('#fixture')
				@clc.render()
			describe "when instantiated", ->
				it "should exist", ->
					expect(@clc).toBeDefined()
				it "should have the parameter variable set to cell line", ->
					expect(@clc.parameter).toEqual "cellLine"
				it "should show the cellLine", ->
					waitsFor ->
						@clc.$('.bv_cellLine option').length > 0
					, 1000
					runs ->
						expect(@clc.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual "cell line y"
						expect(@clc.$('.bv_cellLine').val()).toEqual "cell line y"
			describe "model updates", ->
				it "should update the cell line", ->
					waitsFor ->
						@clc.$('.bv_cellLine option').length > 0
					, 1000
					runs ->
						@clc.$('.bv_cellLine').val('unassigned')
						@clc.$('.bv_cellLine').change()
						expect(@clc.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual "unassigned"


	describe "Primary Screen Protocol Parameters Controller", ->
		describe "when created from a new primary screen protocol", ->
			beforeEach ->
				@psppc = new PrimaryScreenProtocolParametersController
					model: new PrimaryScreenProtocol()
					el: $('#fixture')
				@psppc.render()
			describe "basic existence tests", ->
				it "should exist", ->
					expect(@psppc).toBeDefined()
				it "should load a template", ->
					expect(@psppc.$('.bv_dnsTargetListChkbx').length).toEqual 1
			describe "render parameters", ->
				it "should have the select dns target list be unchecked", ->
					console.log "dns list test"
					console.log @psppc.$('.bv_dnsTargetListChkbx').attr("checked")
					expect(@psppc.$('.bv_dnsTargetListChkbx').attr("checked")).toBeUndefined()
				it "should show the curve display max", ->
					expect(@psppc.model.getCurveDisplayMax().get('numericValue')).toEqual 100.0
					expect(@psppc.$('.bv_maxY').val()).toEqual "100"
				it "should show the curve display min", ->
					expect(@psppc.model.getCurveDisplayMin().get('numericValue')).toEqual 0.0
					expect(@psppc.$('.bv_minY').val()).toEqual "0"
				it 'should show the assayStage', ->
					waitsFor ->
						@psppc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual "unassigned"
						expect(@psppc.$('.bv_assayStage').val()).toEqual "unassigned"

			describe "model updates", ->
				it "should update the select DNS target list", ->
					@psppc.$('.bv_dnsTargetListChkbx').click()
					@psppc.$('.bv_dnsTargetListChkbx').click()
					expect(@psppc.model.get('dnsList')).toBeTruthy()
					expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeOrigin')).toEqual "dns target list"
					# don't know why you need to click twice for spec to pass. The implementation works.
				it "should update the curve display max", ->
					@psppc.$('.bv_maxY').val("130")
					@psppc.$('.bv_maxY').change()
					expect(@psppc.model.getCurveDisplayMax().get('numericValue')).toEqual "130"
				it "should update the curve display min", ->
					@psppc.$('.bv_minY').val("13")
					@psppc.$('.bv_minY').change()
					expect(@psppc.model.getCurveDisplayMin().get('numericValue')).toEqual "13"
				it "should update model when assay stage changed", ->
					waitsFor ->
						@psppc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						@psppc.$('.bv_assayStage').val('unassigned')
						@psppc.$('.bv_assayStage').change()
						expect(@psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual "unassigned"

			describe "behavior", ->
				it "should hide the Molecular Target's add button when the Select dns target list checkbox is checked", ->
					@psppc.$('.bv_dnsTargetListChkbx').click()
					expect(@psppc.model.get('dnsList')).toBeTruthy()
					expect(@psppc.$('.bv_addMolecularTargetBtn')).toBeHidden()

			describe "controller validation rules", ->
				it "should show error when maxY is NaN", ->
					@psppc.$('.bv_maxY').val("b")
					@psppc.$('.bv_maxY').change()
					expect(@psppc.$('.bv_group_maxY').hasClass('error')).toBeTruthy()
				it "should show error when minY is NaN", ->
					@psppc.$('.bv_minY').val("b")
					@psppc.$('.bv_minY').change()
					expect(@psppc.$('.bv_group_minY').hasClass('error')).toBeTruthy()




		describe "when created from a saved primary screen protocol", ->
			beforeEach ->
				@psppc = new PrimaryScreenProtocolParametersController
					model: new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
					el: $('#fixture')
				@psppc.render()
			describe "when instantiated", ->
				describe "basic existence tests", ->
					it "should exist", ->
						expect(@psppc).toBeDefined()
					it "should load a template", ->
						expect(@psppc.$('.bv_dnsTargetListChkbx').length).toEqual 1
				describe "render existing parameters", ->
					it "should have the select dns target list be checked", ->
						expect(@psppc.$('.bv_dnsTargetListChkbx').attr("checked")).toEqual "checked"
					it 'should show the maxY', ->
						expect(@psppc.$('.bv_maxY').val()).toEqual "200"
					it 'should show the minY', ->
						expect(@psppc.$('.bv_minY').val()).toEqual "10"
					it 'should show the assayStage', ->
						waitsFor ->
							@psppc.$('.bv_assayStage option').length > 0
						, 1000
						runs ->
							expect(@psppc.$('.bv_assayStage').val()).toEqual "assay development"




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
				it "should load a template", ->
					expect(@pspc.$('.bv_protocolBase').length).toEqual 1
					expect(@pspc.$('.bv_assayActivity').length).toEqual 1
			describe "render existing parameters", ->
				it 'should show the assayActivity', ->
					waitsFor ->
						@pspc.$('.bv_assayActivity option').length > 0
					, 1000
					runs ->
						expect(@pspc.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual "luminescence"
						expect(@pspc.$('.bv_assayActivity').val()).toEqual "luminescence"
				it 'should show the molecularTarget', ->
					waitsFor ->
						@pspc.$('.bv_molecularTarget option').length > 0
					, 1000
					runs ->
						expect(@pspc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual "target x"
						expect(@pspc.$('.bv_molecularTarget').val()).toEqual "target x"
				it 'should show the targetOrigin', ->
					waitsFor ->
						@pspc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						expect(@pspc.$('.bv_targetOrigin').val()).toEqual "human"
				it 'should show the assayType', ->
					waitsFor ->
						@pspc.$('.bv_assayType option').length > 0
					, 1000
					runs ->
						expect(@pspc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual "cellular assay"
						expect(@pspc.$('.bv_assayType').val()).toEqual "cellular assay"
				it 'should show the assayTechnology', ->
					waitsFor ->
						@pspc.$('.bv_assayTechnology option').length > 0
					, 1000
					runs ->
						expect(@pspc.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual "wizard triple luminescence"
						expect(@pspc.$('.bv_assayTechnology').val()).toEqual "wizard triple luminescence"
				it 'should show the cellLine', ->
					waitsFor ->
						@pspc.$('.bv_cellLine option').length > 0
					, 1000
					runs ->
						expect(@pspc.$('.bv_cellLine').val()).toEqual "cell line y"
				it 'should show the assayStage', ->
					waitsFor ->
						@pspc.$('.bv_assayStage option').length > 0
					, 1000
					runs ->
						expect(@pspc.$('.bv_assayStage').val()).toEqual "assay development"
				it "should update the curve display max", ->
					@pspc.$('.bv_maxY').val("130")
					@pspc.$('.bv_maxY').change()
					expect(@pspc.model.getCurveDisplayMax().get('numericValue')).toEqual "130"
				it "should update the curve display min", ->
					@pspc.$('.bv_minY').val("13")
					@pspc.$('.bv_minY').change()
					expect(@pspc.model.getCurveDisplayMin().get('numericValue')).toEqual "13"






