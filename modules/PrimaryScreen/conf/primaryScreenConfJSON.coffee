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
			,
				kindName: "flag file"
				typeName: "fileValue"
			,
				kindName: "dryrun flag file"
				typeName: "fileValue"
			,
				kindName: "plate order"
				typeName: "clobValue"
			,
				kindName: "compound barcodes"
				typeName: "stringValue"
			]

) (if (typeof process is "undefined" or not process.versions) then window.genericDataParserConfJSON = window.genericDataParserConfJSON or {} else exports)
