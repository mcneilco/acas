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
#				it 'Should have the select DNS target list be unchecked', ->
#					expect(@psp.get('dnsTargetList')).toEqual false
				it 'Should have an default maxY curve display of 100', ->
					expect(@psp.get('maxY')).toEqual 100
				it 'Should have an default minY curve display of 0', ->
					expect(@psp.get('minY')).toEqual 0
			describe "required states and values", ->
				it "should have an assay activity value", ->
					expect(@psp.getPrimaryScreenProtocolParameter('assay activity') instanceof Value).toBeTruthy()
					expect(@psp.getPrimaryScreenProtocolParameter('assay activity').get('codeValue')).toEqual "unassigned"
				it "should have a target origin value", ->
					expect(@psp.getPrimaryScreenProtocolParameter('target origin') instanceof Value).toBeTruthy()
					expect(@psp.getPrimaryScreenProtocolParameter('target origin').get('codeValue')).toEqual "unassigned"
		describe "When loaded from existing", ->
			beforeEach ->
				@psp = new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
			describe "Existence and Defaults", ->
				it "should be defined", ->
					expect(@psp).toBeDefined()
			describe "after initial load", ->
#				it "should have the Select DNS Target List be checked ", ->
#					expect(@psp.get('dnsTargetList')).toEqual true
				it 'Should have an assayActivity value', ->
					console.log @psp.getPrimaryScreenProtocolParameter('assay activity')
					expect(@psp.getPrimaryScreenProtocolParameter('assay activity').get('codeValue')).toEqual "luminescence"
				it 'Should have an targetOrigin value', ->
					console.log @psp.getPrimaryScreenProtocolParameter('target origin')
					expect(@psp.getPrimaryScreenProtocolParameter('target origin').get('codeValue')).toEqual "human"
		describe "model validation", ->
			beforeEach ->
				@psp = new PrimaryScreenProtocol window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol
			it "should be valid when loaded from saved", ->
				expect(@psp.isValid()).toBeTruthy()
			it "should be invalid when maxY is NaN", ->
				@psp.set maxY: NaN
				expect(@psp.isValid()).toBeFalsy()
				filtErrors = _.filter(@psp.validationError, (err) ->
					err.attribute=='maxY'
				)
				expect(filtErrors.length).toBeGreaterThan 0
			it "should be invalid when minY is NaN", ->
				@psp.set minY: NaN
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
					expect(@aac.model.getPrimaryScreenProtocolParameter('assay activity').get('codeValue')).toEqual "luminescence"
					expect(@aac.$('.bv_assayActivity').val()).toEqual "luminescence"
		describe "model updates", ->
			it "should update the assay activity", ->
				waitsFor ->
					@aac.$('.bv_assayActivity option').length > 0
				, 1000
				runs ->
					@aac.$('.bv_assayActivity').val('fluorescence')
					@aac.$('.bv_assayActivity').change()
					expect(@aac.model.getPrimaryScreenProtocolParameter('assay activity').get('codeValue')).toEqual "fluorescence"
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





	describe "Primary Screen Protocol Parameters Controller", ->
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
					expect(@psppc.$('.bv_targetOrigin').length).toEqual 1
				it "should load template", ->
					expect(@psppc.$('.bv_targetOrigin').length).toEqual 1
			describe "render existing parameters", ->
				it 'should show the assayActivity', ->
					expect(@psppc.model.getPrimaryScreenProtocolParameter('assay activity').get('codeValue')).toEqual "luminescence"
					waitsFor ->
						@psppc.$('.bv_assayActivity option').length > 0
					, 1000
					runs ->
						expect(@psppc.model.getPrimaryScreenProtocolParameter('assay activity').get('codeValue')).toEqual "luminescence"
						expect(@psppc.$('.bv_assayActivity').val()).toEqual "luminescence"
				it 'should show the targetOrigin', ->
					waitsFor ->
						@psppc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						expect(@psppc.$('.bv_targetOrigin').val()).toEqual "human"
		describe "model updates", ->
			it "should update the assay activity", ->
				waitsFor ->
					@psppc.$('.bv_assayActivity option').length > 0
				, 1000
				runs ->
					@psppc.$('.bv_assayActivity').val('fluorescence')
					@psppc.$('.bv_assayActivity').change()
					expect(@psppc.model.getPrimaryScreenProtocolParameter('assay activity').get('codeValue')).toEqual "fluorescence"
			it "should update the target origin", ->
				waitsFor ->
					@psppc.$('.bv_targetOrigin option').length > 0
				, 1000
				runs ->
					@psppc.$('.bv_targetOrigin').val('chimpanzee')
					@psppc.$('.bv_targetOrigin').change()
					expect(@psppc.model.getPrimaryScreenProtocolParameter('target origin').get('codeValue')).toEqual "chimpanzee"
			describe "pop modal testing", ->
				it "should display a modal when add button is clicked", ->
					@psppc.$('.bv_addNewAssayActivity').click()
					expect(@psppc.$('.bv_newAssayActivityLabel').length).toEqual 1
				# TODO: validation testing for added option

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
						expect(@pspc.model.getPrimaryScreenProtocolParameter('assay activity').get('codeValue')).toEqual "luminescence"
						expect(@pspc.$('.bv_assayActivity').val()).toEqual "luminescence"
				it 'should show the targetOrigin', ->
					waitsFor ->
						@pspc.$('.bv_targetOrigin option').length > 0
					, 1000
					runs ->
						expect(@pspc.$('.bv_targetOrigin').val()).toEqual "human"

				console.log





