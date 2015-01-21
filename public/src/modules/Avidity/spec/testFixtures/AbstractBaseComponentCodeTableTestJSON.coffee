((exports) ->
	exports.dataDictValues =
		[
			type: "component"
			kind: "source"
			codes:
				[
					code: "Avidity"
					name: "Avidity"
					ignored: false
				,
					code: "vendor A"
					name: "Vendor A"
					ignored: false
				,
					code: "vendor B"
					name: "Vendor B"
					ignored: false
				,
					code: "vendor C"
					name: "Vendor C"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.abstractBaseComponentCodeTableTestJSON = window.abstractBaseComponentCodeTableTestJSON or {} else exports)
