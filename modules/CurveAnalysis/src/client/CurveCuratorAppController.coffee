class CurveCuratorAppRouter extends Backbone.Router
	routes:
		":exptCode": "loadCurvesForExptCode"
		":exptCode/:curveID": "loadCurvesForExptCode"

	initialize: (options) ->
		@appController = options.appController

	loadCurvesForExptCode: (exptCode, curveID) =>
		@appController.loadCurvesForExptCode(exptCode, curveID)


class CurveCuratorAppController extends Backbone.View

	template: _.template($('#CurveCuratorAppView').html())

	initialize: ->

		$(@el).html @template()
		#		@user = this.options.user;
		@ccc = new CurveCuratorController
			el: @$('.bv_curveCurator')
		@ccc.on 'getCurvesSuccessful', @hideLoadCurvesModal.bind(@)

		@render()

		@router = new CurveCuratorAppRouter
			appController: @
		Backbone.history.start
			pushState: true
			root: "/curveCurator"

	render: =>
		@ccc.render()
		@

	loadCurvesForExptCode: (exptCode, curveID) =>
		UtilityFunctions::showProgressModal @$('.bv_loadCurvesModal')
		@ccc.setupCurator(exptCode, curveID)

		@openExperimentInQueryToolController = new OpenExperimentInQueryToolController
			code: exptCode 
			experimentStatus: 'approved'
		$('.bv_openExperimentInQueryToolPlaceholder').html @openExperimentInQueryToolController.render().el

	hideLoadCurvesModal: =>
		UtilityFunctions::hideProgressModal @$('.bv_loadCurvesModal')
