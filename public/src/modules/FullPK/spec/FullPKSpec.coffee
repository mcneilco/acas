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

			describe 'update model when fields changed', ->
				it "should update the protocolName", ->
					@fpkc.$('.bv_protocolName').val "test protocol"
					@fpkc.$('.bv_protocolName').change()
					expect(@fpkc.model.get('protocolName')).toEqual "test protocol"
				#TODO test rest of editable fields

		describe "validation testting", ->
			beforeEach ->
				@fpkc = new FullPKController
					model: new FullPK window.FullPKTestJSON.validFullPK
					el: $('#fixture')
				@fpkc.render()
			it 'should show error if protocolName is empty', ->
				@fpkc.$(".bv_protocolName").val ""
				@fpkc.$(".bv_protocolName").change()
				expect(@fpkc.$(".bv_group_protocolName").hasClass("error")).toBeTruthy()
			#TODO validation test rest of editable fields
