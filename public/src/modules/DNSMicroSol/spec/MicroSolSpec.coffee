describe 'MicroSol Behavior Testing', ->

	beforeEach ->
		@.fixture = $.clone($('#fixture').get(0))

	afterEach ->
		$('#fixture').remove()
		$('body').append $(this.fixture)

	describe 'MicroSol Model', ->
		describe 'when instantiated', ->
			beforeEach ->
				@microSol = new MicroSol()
			describe "defaults tests", ->
				it  'should have defaults', ->
					expect(@microSol.get 'protocolName').toEqual ""
					expect(@microSol.get 'scientist').toEqual ""
					expect(@microSol.get 'notebook').toEqual ""
					expect(@microSol.get 'project').toEqual ""
		describe "validation tests", ->
			beforeEach ->
				@microSol = new MicroSol window.MicroSolTestJSON.validMicroSol

			it "should be valid as initialized", ->
				expect(@microSol.isValid()).toBeTruthy()

			it 'should require that protocolName not be "unassigned"', ->
				@microSol.set
					protocolName: "Select Protocol"
				expect(@microSol.isValid()).toBeFalsy()
				filtErrors = _.filter(@microSol.validationError, (err) ->
					err.attribute=='protocolName'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that scientist not be ""', ->
				@microSol.set
					scientist: ""
				expect(@microSol.isValid()).toBeFalsy()
				filtErrors = _.filter(@microSol.validationError, (err) ->
					err.attribute=='scientist'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that notebook not be ""', ->
				@microSol.set
					notebook: ""
				expect(@microSol.isValid()).toBeFalsy()
				filtErrors = _.filter(@microSol.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that project not be "unassigned"', ->
				@microSol.set
					project: "unassigned"
				expect(@microSol.isValid()).toBeFalsy()
				filtErrors = _.filter(@microSol.validationError, (err) ->
					err.attribute=='project'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe 'MicroSol Controller', ->
		describe 'when instantiated', ->
			beforeEach ->
				@fpkc = new MicroSolController
					model: new MicroSol()
					el: $('#fixture')
				@fpkc.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@fpkc).toBeDefined()
				it 'should load a template', ->
					expect(@fpkc.$('.bv_protocolName').length).toEqual 1
				it "should hide the summary table", ->
					expect(@fpkc.$('.bv_csvPreviewContainer')).not.toBeVisible()
			describe "it should show a picklist for projects", ->
				beforeEach ->
					waitsFor ->
						@fpkc.$('.bv_project option').length > 0
					,
						1000
					runs ->
				it "should show project options after loading them from server", ->
					expect(@fpkc.$('.bv_project option').length).toBeGreaterThan 0
				it "should default to unassigned", ->
					expect(@fpkc.$('.bv_project').val()).toEqual "unassigned"
			describe "it should show a picklist for protocols", ->
				beforeEach ->
					waitsFor ->
						@fpkc.$('.bv_protocolName option').length > 0
					,
						1000
					runs ->
				it "should show protocol options after loading them from server", ->
					expect(@fpkc.$('.bv_protocolName option').length).toBeGreaterThan 0
				it "should default to unassigned", ->
					expect(@fpkc.$('.bv_protocolName').val()).toEqual "unassigned"
			describe "disable and enable", ->
				it "should disable all inputs on request", ->
					@fpkc.disableAllInputs()
					expect(@fpkc.$('.bv_scientist').attr("disabled")).toEqual "disabled"
					expect(@fpkc.$('.bv_project').attr("disabled")).toEqual "disabled"
					expect(@fpkc.$('.bv_protocolName').attr("disabled")).toEqual "disabled"
				it "should enable all inputs on request", ->
					@fpkc.disableAllInputs()
					expect(@fpkc.$('.bv_scientist').attr("disabled")).toEqual "disabled"
					expect(@fpkc.$('.bv_project').attr("disabled")).toEqual "disabled"
					expect(@fpkc.$('.bv_protocolName').attr("disabled")).toEqual "disabled"
					@fpkc.enableAllInputs()
					expect(@fpkc.$('.bv_scientist').attr("disabled")).toBeUndefined()
					expect(@fpkc.$('.bv_project').attr("disabled")).toBeUndefined()
					expect(@fpkc.$('.bv_protocolName').attr("disabled")).toBeUndefined()
			describe "show preview table from dry run on request", ->
				beforeEach ->
					@fpkc.showCSVPreview window.PampaTestJSON.csvDataToLoad
				it "should show the summary table", ->
					expect(@fpkc.$('.bv_csvPreviewContainer')).toBeVisible()
				it "should show a header row with column names", ->
					expect(@fpkc.$('.csvPreviewTHead th :eq(0)').html()).toEqual "Corporate Batch ID"
				it "should show 2 data rows", ->
					expect(@fpkc.$('.csvPreviewTBody tr').length).toEqual 2
				it "should show the right value in the first row of the first cell", ->
					expect(@fpkc.$('.csvPreviewTBody tr :eq(0) td :eq(0)').html()).toEqual "DNS123456789::12"
				it "should hide preview when controls enabled", ->
					@fpkc.enableAllInputs()
					expect(@fpkc.$('.bv_csvPreviewContainer')).not.toBeVisible()

			describe 'update model when fields changed', ->
				it "should update the protocolName", ->
					waitsFor ->
						@fpkc.$('.bv_protocolName option').length > 0
					,
						1000
					runs ->
						@fpkc.$('.bv_protocolName').val "PROT-00000012"
						@fpkc.$('.bv_protocolName').change()
						expect(@fpkc.model.get('protocolName')).toEqual "ADME uSol Kinetic Solubility"
				it "should update the scientist", ->
					@fpkc.$('.bv_scientist').val " test scientist "
					@fpkc.$('.bv_scientist').change()
					expect(@fpkc.model.get('scientist')).toEqual "test scientist"
				it "should update the notebook", ->
					@fpkc.$('.bv_notebook').val " test notebook "
					@fpkc.$('.bv_notebook').change()
					expect(@fpkc.model.get('notebook')).toEqual "test notebook"
				it "should update the project", ->
					waitsFor ->
						@fpkc.$('.bv_project option').length > 0
					,
					1000
					runs ->
						@fpkc.$('.bv_project').val "project2"
						@fpkc.$('.bv_project').change()
						expect(@fpkc.model.get('project')).toEqual "project2"
				it "should trigger 'amDirty' when field changed", ->
					runs ->
						@amDirtySet = false
						@fpkc.on 'amDirty', =>
							@amDirtySet = true
						@fpkc.$('.bv_notebook').val " test notebook "
						@fpkc.$('.bv_notebook').change()
					waitsFor =>
						@amDirtySet
					,
					500
					runs ->
						expect(@amDirtySet).toBeTruthy()

		describe "validation testing", ->
			beforeEach ->
				@fpkc = new MicroSolController
					model: new MicroSol window.MicroSolTestJSON.validMicroSol
					el: $('#fixture')
				@fpkc.render()
			describe "error notification", ->
				it 'should show error if protocol is unassigned', ->
					waitsFor ->
						@fpkc.$('.bv_protocolName option').length > 0
					,
						1000
					runs ->
						@fpkc.$(".bv_protocolName").val "unassigned"
						@fpkc.$(".bv_protocolName").change()
						console.log @fpkc.$(".bv_protocolName").val()
						expect(@fpkc.$(".bv_group_protocolName").hasClass("error")).toBeTruthy()
				it 'should show error if scientist is empty', ->
					@fpkc.$(".bv_scientist").val ""
					@fpkc.$(".bv_scientist").change()
					expect(@fpkc.$(".bv_group_scientist").hasClass("error")).toBeTruthy()
				it 'should show error if notebook is empty', ->
					@fpkc.$(".bv_notebook").val ""
					@fpkc.$(".bv_notebook").change()
					expect(@fpkc.$(".bv_group_notebook").hasClass("error")).toBeTruthy()
				it 'should show error if project is unassigned', ->
					waitsFor ->
						@fpkc.$('.bv_project option').length > 0
					,
					1000
					runs ->
						@fpkc.$(".bv_project").val "unassigned"
						@fpkc.$(".bv_project").change()
						expect(@fpkc.$(".bv_group_project").hasClass("error")).toBeTruthy()
