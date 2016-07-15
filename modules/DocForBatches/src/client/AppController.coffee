class window.AppRouter extends Backbone.Router

	routes:
		":docId": "existingDoc"
		"": "newDoc"

	initialize: (options) ->
		@appController = options.appController

	newDoc: =>
		@appController.newDoc()

	existingDoc: (docId) =>
		@appController.existingDoc(docId)


class window.AppController extends Backbone.View

	template: _.template($('#DocForBatchesAppControllerView').html())

	initialize: ->
		$(@el).html @template()
#		@user = this.options.user;
		@render();

		@router = new AppRouter
			appController: @
		Backbone.history.start
			pushState: true
			root: "/docForBatches"

	render: =>
		@

	newDoc: =>
		@docForBatchesController = new DocForBatchesController
			el: @$('.docForBatches')
			model: new DocForBatches()
		@docForBatchesController.render()

	existingDoc: (docId) =>
		$.ajax
			type: 'GET'
#			url: "/api/docForBatches/"+docId
			url: "/api/experiments/"+docId
			success: (json) =>
				@existingDocReturn(json)
			error: (err) =>
				@serviceReturn = null
			dataType: 'json'

	existingDocReturn: (json) =>
#		@docForBatchesController = new DocForBatchesController
#			el: @$('.docForBatches')
#			model: new DocForBatches( json: json )
#		@docForBatchesController.render()

		@exp = new Experiment( json )
		@dfb = new DocForBatches
			experiment: @exp
		@docForBatchesController = new DocForBatchesController
			el: @$('.docForBatches')
			model: @dfb
		@docForBatchesController.render()
