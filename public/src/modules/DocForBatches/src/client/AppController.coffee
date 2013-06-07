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
		$.ajax
			type: 'GET'
#			url: "/api/docForBatches/"+docId
			url: "/api/experiments/"+docId
			success: (json) =>
				console.log "success from getting existing doc"
				console.log json
				@existingDocReturn(json)
			error: (err) =>
				console.log 'got ajax error in get existing doc'
				@serviceReturn = null
			dataType: 'json'

	existingDocReturn: (json) =>
#		@docForBatchesController = new DocForBatchesController
#			el: @$('.docForBatches')
#			model: new DocForBatches( json: json )
#		@docForBatchesController.render()

		@exp = new Experiment( json )
		console.log "existing return experiment"
		console.log @exp
		@dfb = new DocForBatches
			experiment: @exp
		console.log "existing return docForBatches"
		console.log @dfb
		@docForBatchesController = new DocForBatchesController
			el: @$('.docForBatches')
			model: @dfb
		@docForBatchesController.render()
