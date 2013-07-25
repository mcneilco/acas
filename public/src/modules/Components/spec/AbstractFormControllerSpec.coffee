describe 'AbstractFormController Behavior Testing', ->
	beforeEach ->
		@.fixture = $.clone($('#fixture').get(0))
	afterEach ->
		$('#fixture').remove()
		$('body').append $(this.fixture)

	describe 'when instantiated', ->
		beforeEach ->
			class @TestAbstractFormController extends AbstractFormController
				initialize: ->
					@errorOwnerName = 'TestAbstractFormController'
					@setBindings()

			@tafc = new @TestAbstractFormController
				model: new Backbone.Model()
				el: $('#fixture')
			@tafc.render()
		describe "basic existance tests", ->
			it 'should exist', ->
				expect(AbstractFormController).toBeDefined()

		#TODO test embeded functions like show, hide, error highlighting and clearing etc

		describe "input formatting features", ->
			it "get val from input and trim it", ->
				@tafc.$el.append "<input type='text' class='bv_testInput' />"
				@tafc.$('.bv_testInput').val("  some input with spaces  ")
				expect(@tafc.getTrimmedInput('.bv_testInput')).toEqual "some input with spaces"
			it "should parse ACAS standard format yyyy-mm-dd correctly in IE8 and other browsers", ->
				expect(@tafc.convertYMDDateToMs("2013-6-6")).toEqual new Date(2013, 5, 6).getTime()

