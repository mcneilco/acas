describe 'Full PK Behavior Testing', ->

	beforeEach ->
		@.fixture = $.clone($('#fixture').get(0))

	afterEach ->
		$('#fixture').remove()
		$('body').append $(this.fixture)

	describe 'FullPK Model', ->
		describe 'when instantiated', ->
			beforeEach ->
				@fullPK = new FullPK()
			describe "defaults tests", ->
				it  'should have defaults', ->
					expect(@fullPK.get 'format').toEqual "In Vivo Full PK"
					expect(@fullPK.get 'protocolName').toEqual ""
					expect(@fullPK.get 'experimentName').toEqual ""
					expect(@fullPK.get 'scientist').toEqual ""
					expect(@fullPK.get 'notebook').toEqual ""
					expect(@fullPK.get 'inLifeNotebook').toEqual ""
					expect(@fullPK.get 'assayDate').toEqual null
					expect(@fullPK.get 'project').toEqual ""
					expect(@fullPK.get 'bioavailability').toEqual ""
					expect(@fullPK.get 'aucType').toEqual ""
		describe "validation tests", ->
			beforeEach ->
				@fullPK = new FullPK window.FullPKTestJSON.validFullPK

			it "should be valid as initialized", ->
				expect(@fullPK.isValid()).toBeTruthy()

			it 'should require that protocolName not be ""', ->
				@fullPK.set
					protocolName: ""
				expect(@fullPK.isValid()).toBeFalsy()
				filtErrors = _.filter(@fullPK.validationError, (err) ->
					err.attribute=='protocolName'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that experimentName not be ""', ->
				@fullPK.set
					experimentName: ""
				expect(@fullPK.isValid()).toBeFalsy()
				filtErrors = _.filter(@fullPK.validationError, (err) ->
					err.attribute=='experimentName'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that scientist not be ""', ->
				@fullPK.set
					scientist: ""
				expect(@fullPK.isValid()).toBeFalsy()
				filtErrors = _.filter(@fullPK.validationError, (err) ->
					err.attribute=='scientist'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that notebook not be ""', ->
				@fullPK.set
					notebook: ""
				expect(@fullPK.isValid()).toBeFalsy()
				filtErrors = _.filter(@fullPK.validationError, (err) ->
					err.attribute=='notebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that inLifeNotebook not be ""', ->
				@fullPK.set
					inLifeNotebook: ""
				expect(@fullPK.isValid()).toBeFalsy()
				filtErrors = _.filter(@fullPK.validationError, (err) ->
					err.attribute=='inLifeNotebook'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that project not be "unassigned"', ->
				@fullPK.set
					project: "unassigned"
				expect(@fullPK.isValid()).toBeFalsy()
				filtErrors = _.filter(@fullPK.validationError, (err) ->
					err.attribute=='project'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that bioavailability not be ""', ->
				@fullPK.set
					bioavailability: ""
				expect(@fullPK.isValid()).toBeFalsy()
				filtErrors = _.filter(@fullPK.validationError, (err) ->
					err.attribute=='bioavailability'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that aucType not be ""', ->
				@fullPK.set
					aucType: ""
				expect(@fullPK.isValid()).toBeFalsy()
				filtErrors = _.filter(@fullPK.validationError, (err) ->
					err.attribute=='aucType'
				)
				expect(filtErrors.length).toBeGreaterThan 0

			it 'should require that assayDate not be ""', ->
				@fullPK.set
					assayDate: new Date("").getTime()
				expect(@fullPK.isValid()).toBeFalsy()
				filtErrors = _.filter(@fullPK.validationError, (err) ->
					err.attribute=='assayDate'
				)
				expect(filtErrors.length).toBeGreaterThan 0

	describe 'FullPK Controller', ->
		describe 'when instantiated', ->
			beforeEach ->
				@fpkc = new FullPKController
					model: new FullPK()
					el: $('#fixture')
				@fpkc.render()
			describe "basic existance tests", ->
				it 'should exist', ->
					expect(@fpkc).toBeDefined()
				it 'should load a template', ->
					expect(@fpkc.$('.bv_protocolName').length).toEqual 1
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
			describe "disable and enable", ->
				it "should disable all inputs on request", ->
					@fpkc.disableAllInputs()
					expect(@fpkc.$('.bv_scientist').attr("disabled")).toEqual "disabled"
					expect(@fpkc.$('.bv_project').attr("disabled")).toEqual "disabled"
				it "should enable all inputs on request", ->
					@fpkc.disableAllInputs()
					expect(@fpkc.$('.bv_scientist').attr("disabled")).toEqual "disabled"
					@fpkc.enableAllInputs()
					expect(@fpkc.$('.bv_scientist').attr("disabled")).toBeUndefined()

			describe 'update model when fields changed', ->
				it "should update the protocolName", ->
					@fpkc.$('.bv_protocolName').val "test protocol"
					@fpkc.$('.bv_protocolName').change()
					expect(@fpkc.model.get('protocolName')).toEqual "test protocol"
				it "should update the experimentName", ->
					@fpkc.$('.bv_experimentName').val "test experiment"
					@fpkc.$('.bv_experimentName').change()
					expect(@fpkc.model.get('experimentName')).toEqual "test experiment"
				it "should update the scientist", ->
					@fpkc.$('.bv_scientist').val "test scientist"
					@fpkc.$('.bv_scientist').change()
					expect(@fpkc.model.get('scientist')).toEqual "test scientist"
				it "should update the notebook", ->
					@fpkc.$('.bv_notebook').val "test notebook"
					@fpkc.$('.bv_notebook').change()
					expect(@fpkc.model.get('notebook')).toEqual "test notebook"
				it "should update the inLifeNotebook", ->
					@fpkc.$('.bv_inLifeNotebook').val "test inLifeNotebook"
					@fpkc.$('.bv_inLifeNotebook').change()
					expect(@fpkc.model.get('inLifeNotebook')).toEqual "test inLifeNotebook"
				it "should update the project", ->
					waitsFor ->
						@fpkc.$('.bv_project option').length > 0
					,
					1000
					runs ->
						@fpkc.$('.bv_project').val "project2"
						@fpkc.$('.bv_project').change()
						expect(@fpkc.model.get('project')).toEqual "project2"
				it "should update the bioavailability", ->
					@fpkc.$('.bv_bioavailability').val "test bioavailability"
					@fpkc.$('.bv_bioavailability').change()
					expect(@fpkc.model.get('bioavailability')).toEqual "test bioavailability"
				it "should update the aucType", ->
					@fpkc.$('.bv_aucType').val "test aucType"
					@fpkc.$('.bv_aucType').change()
					expect(@fpkc.model.get('aucType')).toEqual "test aucType"
				it "should update the assayDate", ->
					@fpkc.$('.bv_assayDate').val "2013-6-6"
					@fpkc.$('.bv_assayDate').change()
					expect(@fpkc.model.get('assayDate')).toEqual new Date("2013-6-6").getTime()

		describe "validation testing", ->
			beforeEach ->
				@fpkc = new FullPKController
					model: new FullPK window.FullPKTestJSON.validFullPK
					el: $('#fixture')
				@fpkc.render()
			describe "error notification", ->
				it 'should show error if protocolName is empty', ->
					@fpkc.$(".bv_protocolName").val ""
					@fpkc.$(".bv_protocolName").change()
					expect(@fpkc.$(".bv_group_protocolName").hasClass("error")).toBeTruthy()
				it 'should show error if experimentName is empty', ->
					@fpkc.$(".bv_experimentName").val ""
					@fpkc.$(".bv_experimentName").change()
					expect(@fpkc.$(".bv_group_experimentName").hasClass("error")).toBeTruthy()
				it 'should show error if scientist is empty', ->
					@fpkc.$(".bv_scientist").val ""
					@fpkc.$(".bv_scientist").change()
					expect(@fpkc.$(".bv_group_scientist").hasClass("error")).toBeTruthy()
				it 'should show error if notebook is empty', ->
					@fpkc.$(".bv_notebook").val ""
					@fpkc.$(".bv_notebook").change()
					expect(@fpkc.$(".bv_group_notebook").hasClass("error")).toBeTruthy()
				it 'should show error if inLifeNotebook is empty', ->
					@fpkc.$(".bv_inLifeNotebook").val ""
					@fpkc.$(".bv_inLifeNotebook").change()
					expect(@fpkc.$(".bv_group_inLifeNotebook").hasClass("error")).toBeTruthy()
				it 'should show error if project is unassigned', ->
					waitsFor ->
						@fpkc.$('.bv_project option').length > 0
					,
					1000
					runs ->
						@fpkc.$(".bv_project").val "unassigned"
						@fpkc.$(".bv_project").change()
						expect(@fpkc.$(".bv_group_project").hasClass("error")).toBeTruthy()
				it 'should show error if bioavailability is empty', ->
					@fpkc.$(".bv_bioavailability").val ""
					@fpkc.$(".bv_bioavailability").change()
					expect(@fpkc.$(".bv_group_bioavailability").hasClass("error")).toBeTruthy()
				it 'should show error if aucType is empty', ->
					@fpkc.$(".bv_aucType").val ""
					@fpkc.$(".bv_aucType").change()
					expect(@fpkc.$(".bv_group_aucType").hasClass("error")).toBeTruthy()
				it 'should show error if assayDate is empty', ->
					@fpkc.$(".bv_assayDate").val ""
					@fpkc.$(".bv_assayDate").change()
					expect(@fpkc.$(".bv_group_assayDate").hasClass("error")).toBeTruthy()
