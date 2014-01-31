class window.CurveCuratorAppRouter extends Backbone.Router
	routes:
		":exptCode": "loadCurvesForExptCode"

	initialize: (options) ->
		@appController = options.appController

	loadCurvesForExptCode: (exptCode) =>
		@appController.loadCurvesForExptCode(exptCode)


class window.CurveCuratorAppController extends Backbone.View

	template: _.template($('#CurveCuratorAppView').html())

	initialize: ->
		$(@el).html @template()
		#		@user = this.options.user;
		@ccc = new CurveCuratorController
			el: @$('.bv_curveCurator')

		@render();

		@router = new CurveCuratorAppRouter
			appController: @
		Backbone.history.start
			pushState: true
			root: "/curveCurator"

	render: =>
		@ccc.render()
		@

	loadCurvesForExptCode: (exptCode) =>
		@ccc.getCurvesFromExperimentCode(exptCode)

