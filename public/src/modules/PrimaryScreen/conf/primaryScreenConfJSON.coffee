((exports) ->
	exports.typeKindList =

		valuetypes:
			[
				typeName: "dateValue"
			,
				typeName: "codeValue"
			,
				typeName: "stringValue"
			,
				typeName: "clobValue"
			,
				typeName: "fileValue"
			,
				typeName: "urlValue"
			,
				typeName: "blobValue"
			,
				typeName: "inlineFileValue"
			,
				typeName: "numericValue"
			]

		valuekinds:
			[
				kindName: "efficacy"
				typeName: "numericValue"
			]

) (if (typeof process is "undefined" or not process.versions) then window.genericDataParserConfJSON = window.genericDataParserConfJSON or {} else exports)
