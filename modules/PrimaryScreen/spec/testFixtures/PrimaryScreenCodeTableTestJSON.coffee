((exports) ->
	exports.codetableValues =
		[
			type: "equipment"
			kind: "instrument reader"
			codes:
				[
					code: "flipr"
					name: "FLIPR"
					ignored: false
				]
		,
			type: "analysis parameter"
			kind: "signal direction"
			codes:
				[
					code: "increasing"
					name: "Increasing Signal (highest = 100%)"
					ignored: false
				]
		,
			type: "analysis parameter"
			kind: "aggregate by"
			codes:
				[
					code: "compound batch concentration"
					name: "Compound Batch Concentration"
					ignored: false
				]
		,
			type: "analysis parameter"
			kind: "aggregation method"
			codes:
				[
					code: "median"
					name: "Median"
					ignored: false
				,
					code: "mean"
					name: "Mean"
					ignored: false
				]
		,
			type: "analysis parameter"
			kind: "transformation"
			codes:
				[
					code: "% efficacy"
					name: "% Efficacy"
					ignored: false
				,
					code: "sd"
					name: "SD"
					ignored: false
				,
					code: "null"
					name: "Not Set"
					ignored: false
				]
		,
			type: "analysis parameter"
			kind: "normalization method"
			codes:
				[
					code: "plate order only",
					name: "Plate Order Only",
					ignored: false
				,
					code: "plate order and row",
					name: "Plate Order And Row",
					ignored: false
				,
					code: "plate order and tip",
					name: "Plate Order And Tip",
					ignored: false
				,
					code: "none"
					name: "None"
					ignored: false
				]
		,
			type: "reader data"
			kind: "read name"
			codes:
				[
					code: "luminescence"
					name: "Luminescence"
					ignored: false
				,
					code: "fluorescence"
					name: "Fluorescence"
					ignored: false
				,
					code: "Calc: (maximum-minimum)/minimum"
					name: "Calc: (maximum-minimum)/minimum"
					ignored: false
				,
					code: "none"
					name: "None"
					ignored: false
				]
		,
			type: "model fit"
			kind: "type"
			codes:
				[
					code: "4 parameter D-R"
					name: "EC50"
					ignored: false
				,
					code: "Ki Fit"
					name: "KI"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.primaryScreenCodeTableTestJSON = window.primaryScreenCodeTableTestJSON or {} else exports)
