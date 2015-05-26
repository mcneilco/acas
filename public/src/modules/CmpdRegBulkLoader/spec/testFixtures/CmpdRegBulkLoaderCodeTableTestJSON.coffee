((exports) ->
	exports.codetableValues =
		[
			type: "properties"
			kind: "database"
			codes:
				[
					code: "corporate id"
					name: "Corporate ID"
					ignored: false
				,
					code: "lot number"
					name: "Lot Number"
					ignored: false
				]
		]

) (if (typeof process is "undefined" or not process.versions) then window.cmpdRegBulkLoaderCodeTableTestJSON = window.cmpdRegBulkLoaderCodeTableTestJSON or {} else exports)
