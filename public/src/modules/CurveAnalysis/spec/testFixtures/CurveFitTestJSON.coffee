((exports) ->
	exports.doseResponseBulkFitOptions =
		fixedParameters:
			curveMin:
				parameter: "min"
				value: 0.0
			curveMax:
				parameter: "max"
				value: 100.0
			hillSlope:
				parameter: "slope"
				value: null
			ec50:
				parameter: "ec50"
				value: null
		groupBy: "across all plates"
		inactiveThreshold:
			type: "threshold"
			value: 20
			activeDoses: 1
		failSettings:
			maxUncertaintyRule:
				parameter: "max"
				type: "stdErr"
				value: 3
				operator: ">"
				displayName: "Max uncertainty exceeded"
			ec50PValue:
				parameter: "ec50"
				type: "pValue"
				value: 0.05
				operator: "<"
				displayName: "EC50 p-value too low"
		overriddenValues:
			maxThreshold:
				parameter: "max"
				type: "threshold"
				value: 100
				operator: ">"
				displayName: "Max threshold exceeded"
			ec50Threshold:
				parameter: "ec50"
				type: "logAboveReference"
				reference: "dose.max"
				value: 0.5
				operator: ">"
				displayName: "EC50 threshold exceeded"



) (if (typeof process is "undefined" or not process.versions) then window.primaryScreenTestJSON = window.primaryScreenTestJSON or {} else exports)
