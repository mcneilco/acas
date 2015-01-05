((exports) ->
	exports.dataDictValues =
		[
			type: "protein"
			kind: "type"
			codes:
				[
					code: "mab"
					name: "mAb"
					ignored: false
				,
					code: "fab"
					name: "fAb"
					ignored: false
				,
					code: "centyrin"
					name: "Centyrin"
					ignored: false
				,
					code: "other"
					name: "Other"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.proteinCodeTableTestJSON = window.proteinCodeTableTestJSON or {} else exports)
