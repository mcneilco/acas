((exports) ->
	exports.codetableValues =
		[
#			type: "properties"
#			kind: "database"
#			codes:
#				[
#					code: "corporate id"
#					name: "Corporate ID"
#					ignored: false
#				,
#					code: "lot number"
#					name: "Lot Number"
#					ignored: false
#				]
#		,
			type: "properties"
			kind: "templates"
			codes:
				[
					code: "Template 1"
					name: "Template 1"
					ignored: false
				,
					code: "Template 2"
					name: "Template 2"
					ignored: false
				]
		]

) (if (typeof process is "undefined" or not process.versions) then window.cmpdRegBulkLoaderCodeTableTestJSON = window.cmpdRegBulkLoaderCodeTableTestJSON or {} else exports)
