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

#		#TODO test embeded functions like show, hide, error highlighting and clearing etc
