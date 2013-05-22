class window.DoseResponseAnalysisController extends AbstractFormController
	template: _.template($("#DoseResponseAnalysisView").html())

	render: =>
		$(@el).empty()
		$(@el).html @template()
