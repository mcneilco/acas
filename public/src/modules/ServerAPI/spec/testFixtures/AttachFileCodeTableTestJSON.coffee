((exports) ->
	exports.dataDictValues =
		[
			type: "analytical method"
			kind: "file type"
			codes:
				[
					code: "hplc"
					name: "HPLC"
					ignored: false
				,
					code: "nmr"
					name: "NMR"
					ignored: false
				,
					code: "gpc"
					name: "GPC"
					ignored: false
				,
					code: "ms"
					name: "MS"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.attachFileCodeTableTestJSON = window.attachFileCodeTableTestJSON or {} else exports)
