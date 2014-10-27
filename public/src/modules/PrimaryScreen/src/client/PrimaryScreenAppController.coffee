class window.PrimaryScreenAppRouter extends Backbone.Router

	routes:
		":expId": "existingExperiment"
		"codeName/:code": "existingExperimentByCode"
		"": "newExperiment"

	initialize: (options) ->
		@appController = options.appController

	newExperiment: =>
		@appController.newExperiment()

	existingExperiment: (expId) =>
		@appController.existingExperiment(expId)

	existingExperimentByCode: (code) =>
		@appController.existingExperimentByCode(code)


class window.PrimaryScreenAppController extends Backbone.View

	template: _.template($('#PrimaryScreenAppControllerView').html())

	initialize: ->
		$(@el).html @template()
		#		@user = this.options.user;
		@render();

		@router = new PrimaryScreenAppRouter
			appController: @
		Backbone.history.start
			pushState: true
			root: "/primaryScreenExperiment"

	render: =>
		@

	newExperiment: =>
		@primaryScreenExperimentController = new PrimaryScreenExperimentController
			model: new PrimaryScreenExperiment()
			el: $('.bv_primaryScreenExperimentController')
		@primaryScreenExperimentController.render()

	existingExperimentByCode: (code) =>
		$.ajax
			type: 'GET'
			url: "/api/experiments/codename/"+code
			dataType: 'json'
			error: (err) ->
				alert 'Could not get experiment for code in this URL'
			success: (json) =>
				@existingExperiment json.id

	existingExperiment: (expId) =>
		exp = new PrimaryScreenExperiment id: expId
		exp.fetch success: =>
			exp.set exp.parse(exp.attributes)
#			exp.fixCompositeClasses()
			@primaryScreenExperimentController = new PrimaryScreenExperimentController
        model: exp
        el: $('.bv_primaryScreenExperimentController')
			@primaryScreenExperimentController.render()
