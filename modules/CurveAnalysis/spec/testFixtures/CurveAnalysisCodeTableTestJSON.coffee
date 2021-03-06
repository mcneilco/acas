((exports) ->
	exports.codetableValues =
		[
			type: "algorithm well flags"
			kind: "flag observation"
			codes:
				[
					code: "outlier"
					name: "Outlier"
					ignored: false
				,
					code: "high"
					name: "Value too high"
					ignored: true
				,
					code: "low"
					name: "Value too low"
					ignored: true
				,
					code: "crashout"
					name: "Compound crashed out"
					ignored: false
				]
		,
			type: "user well flags"
			kind: "flag observation"
			codes:
				[
					code: "outlier"
					name: "Outlier"
					ignored: false
				,
					code: "high"
					name: "Value too high"
					ignored: true
				,
					code: "low"
					name: "Value to low"
					ignored: true
				,
					code: "crashout"
					name: "Compound crashed out"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.dataDictServiceTestJSON = window.dataDictServiceTestJSON or {} else exports)

