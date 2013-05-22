class window.AppRouter extends Backbone.Router

	routes:
		":docId": "existingDoc"
		"": "newDoc"

	initialize: (options) ->
		@appController = options.appController

	newDoc: =>
		console.log 'new doc'
		@appController.newDoc()

	existingDoc: (docId) =>
		console.log 'existign doc'+docId
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
		console.log docId
		$.ajax
			type: 'GET'
			url: "/api/docForBatches/"+docId
			success: (json) =>
				@existingDocReturn(json)
			error: (err) =>
				console.log 'got ajax error in get existing doc'
				@serviceReturn = null
			dataType: 'json'

	existingDocReturn: (json) =>
		@docForBatchesController = new DocForBatchesController
			el: @$('.docForBatches')
			model: new DocForBatches( json: json )
		@docForBatchesController.render()
