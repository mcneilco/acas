class window.CurveCuratorAppRouter extends Backbone.Router
	routes:
		":exptCode": "loadCurvesForExptCode"
		":exptCode/:curveID": "loadCurvesForExptCode"

	initialize: (options) ->
		@appController = options.appController

	loadCurvesForExptCode: (exptCode, curveID) =>
		@appController.loadCurvesForExptCode(exptCode, curveID)


class window.CurveCuratorAppController extends Backbone.View

	template: _.template($('#CurveCuratorAppView').html())

	initialize: ->

		$(@el).html @template()
		#		@user = this.options.user;
		@ccc = new CurveCuratorController
			el: @$('.bv_curveCurator')
		@ccc.on 'getCurvesSuccessful', @hideLoadCurvesModal

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
		resultViewerURL = "/openExptInQueryTool?experiment="+exptCode
		@$('.bv_resultViewerBtn').attr('href',resultViewerURL)
		@$('.bv_resultViewerBtn').html('Open in '+window.conf.service.result.viewer.displayName)
		@$('.bv_resultViewerBtn').show()


	hideLoadCurvesModal: =>
		UtilityFunctions::hideProgressModal @$('.bv_loadCurvesModal')
