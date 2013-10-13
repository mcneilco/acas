class window.DoseResponseAnalysisController extends AbstractFormController
	template: _.template($("#DoseResponseAnalysisView").html())
	events:
		"change .bv_curveMin": "handleCurveMinChanged"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		console.log @getCurveMin()
		@$('.bv_curveMin').val(@getCurveMin())
		@$('.bv_curveMax').val(@getCurveMax())
		@

	getCurveMin: ->
		value = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment analysis parameters", "numericValue", "curve min"
		value.get('numericValue')

	getCurveMax: ->
		value = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment analysis parameters", "numericValue", "curve max"
		value.get('numericValue')

	handleCurveMinChanged: =>
		value = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment analysis parameters", "numericValue", "curve min"
		value.set numericValue: parseFloat($.trim(@$('.bv_curveMin').val()))

	handleCurveMaxChanged: =>
		value = @model.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment analysis parameters", "numericValue", "curve max"
		value.set numericValue: parseFloat($.trim(@$('.bv_curveMax').val()))
