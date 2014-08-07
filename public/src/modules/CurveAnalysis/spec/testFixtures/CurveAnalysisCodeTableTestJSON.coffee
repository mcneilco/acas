((exports) ->
	exports.dataDictValues =
		[
			"algorithm well flags":
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

