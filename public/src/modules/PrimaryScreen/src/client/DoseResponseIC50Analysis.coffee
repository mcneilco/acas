class window.DoseResponsePlotCurveLL4IC50 extends Backbone.Model

	log10: (val) ->
		Math.log(val) / Math.LN10

	render: (brd, curve, plotWindow) =>
		log10 = @log10
		fct = (x) ->
			curve.max + (curve.min - curve.max) / (1 + Math.exp(curve.slope * Math.log(Math.pow(10,x) / curve.ic50)))
		brd.create('functiongraph', [fct, plotWindow[0], plotWindow[2]], {strokeWidth:2});
		if curve.curveAttributes.IC50?
			intersect = fct(log10(curve.curveAttributes.IC50))
			if curve.curveAttributes.Operator?
				color = '#ff0000'
			else
				color = '#808080'
			#				Horizontal Line
			brd.create('line',[[plotWindow[0],intersect],[log10(curve.curveAttributes.IC50),intersect]], {fixed: true, straightFirst:false, straightLast:false, strokeWidth:2, dash: 3, strokeColor: color});
			#				Vertical Line
			brd.create('line',[[log10(curve.curveAttributes.IC50),intersect],[log10(curve.curveAttributes.IC50),0]], {fixed: true, straightFirst:false, straightLast:false, strokeWidth:2, dash: 3, strokeColor: color});

class window.DoseResponseIC50AnalysisParameters extends DoseResponseAnalysisParameters
	defaults: _.extend {}, DoseResponseAnalysisParameters.prototype.defaults,{inactiveThresholdMode: false, inactiveThreshold: null, inverseAgonistMode: true}
