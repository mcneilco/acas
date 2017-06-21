((exports) ->
	exports.typeKindList =
		thingkinds:
			[
				typeName: "parent"
				kindName: "example thing"
			]

		statetypes:
			[
				typeName: "metadata"
			]

		statekinds:
			[
				typeName: "metadata"
				kindName: "example thing parent"
			]

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
			]

		valuekinds:
			[
				typeName: "codeValue"
				kindName: "scientist"
			,
				typeName: "dateValue"
				kindName: "completion date"
			,
				typeName: "stringValue"
				kindName: "notebook"
			,
				typeName: "stringValue"
				kindName: "notebook page"
			,
				typeName: "fileValue"
				kindName: "structural file"
			]

		labeltypes:
			[
				typeName: "name"
			]

		labelkinds:
			[
				typeName: "name"
				kindName: "experiment thing"
			]

		ddicttypes:
			[
			]

		ddictkinds:
			[
			]

		codetables:
			[
			]

		labelsequences:
			[
				digits: 6
				groupDigits: false
				labelPrefix: "ET"
				labelSeparator: "-"
				labelTypeAndKind: "corpName_Example Thing"
				thingTypeAndKind: "parent_Example Thing"
				latestNumber:1
            ,
				digits: 8
				groupDigits: false
				labelPrefix: "THING"
				labelSeparator: ""
				labelTypeAndKind: "id_codeName"
				thingTypeAndKind: "parent_Example Thing"
				latestNumber:1
			]

) (if (typeof process is "undefined" or not process.versions) then window.exampleThingConfJSON = window.exampleThingConfJSON or {} else exports)

