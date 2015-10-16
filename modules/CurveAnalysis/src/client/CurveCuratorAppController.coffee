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
		$.ajax
				type: 'GET'
				url: "/api/experiments/resultViewerURL/"+exptCode
				success: (json) =>
					@resultViewerURL = json
					resultViewerURL = @resultViewerURL.resultViewerURL
					@$('.bv_resultViewerBtn').attr('href',resultViewerURL)
					@$('.bv_resultViewerBtn').show()
				error: (err) =>
					@serviceReturn = null
				dataType: 'json'

	hideLoadCurvesModal: =>
		UtilityFunctions::hideProgressModal @$('.bv_loadCurvesModal')
