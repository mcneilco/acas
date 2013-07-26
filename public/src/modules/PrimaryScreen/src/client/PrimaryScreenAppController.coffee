class window.PrimaryScreenAppRouter extends Backbone.Router

	routes:
		":expId": "existingExperiment"
		"": "newExperiment"

	initialize: (options) ->
		@appController = options.appController

	newExperiment: =>
		#console.log 'new expt'
		@appController.newExperiment()

	existingExperiment: (expId) =>
		#console.log 'existign expt'+expId
		@appController.existingExperiment(expId)


class window.PrimaryScreenAppController extends Backbone.View

	template: _.template($('#PrimaryScreenAppControllerView').html())

	initialize: ->
		$(@el).html @template()
		#		@user = this.options.user;
		@render();

		@router = new PrimaryScreenAppRouter
			appController: @
		#console.log "starting history"
		Backbone.history.start
			pushState: true
			root: "/primaryScreenExperiment"

	render: =>
		@

	newExperiment: =>
		#console.log "got to new experiment route"
		@primaryScreenExperimentController = new PrimaryScreenExperimentController
			model: new Experiment()
			el: $('.bv_primaryScreenExperimentController')
		@primaryScreenExperimentController.render()

	existingExperiment: (expId) =>
		#console.log expId
		exp = new Experiment id: expId
		exp.fetch success: =>
			#console.log "fetched experiment"
			exp.fixCompositeClasses()
			#console.log exp
			@primaryScreenExperimentController = new PrimaryScreenExperimentController
        model: exp
        el: $('.bv_primaryScreenExperimentController')
			@primaryScreenExperimentController.render()
