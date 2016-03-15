((exports) ->
	exports.typeKindList =

		labelsequences:
			[
				digits: 8
				groupDigits: false
				labelPrefix: "AUTH"
				labelSeparator: "-"
				labelTypeAndKind: "id_codeName"
				thingTypeAndKind: "author_author"
				latestNumber:1
			]

) (if (typeof process is "undefined" or not process.versions) then window.authorConfJSON = window.authorConfJSON or {} else exports)
