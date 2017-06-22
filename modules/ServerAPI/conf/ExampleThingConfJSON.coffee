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
			,
				typeName: "metadata"
				kindName: "example thing data"
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
			,
				typeName: "numericValue"
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
			,
				typeName: "stringValue"
				kindName: "media component"
			,
				typeName: "numericValue"
				kindName: "Volume"
			,
				typeName: "codeValue"
				kindName: "performed by"
			,
				typeName: "dateValue"
				kindName: "performed date"
			]
		unittypes:
			[
				typeName: "volume"
			]

		unitkinds:
			[
				typeName: "volume"
				kindName: "mL"
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
				typeName: "metadata"
			]

		ddictkinds:
			[
				typeName: "metadata"
				kindName: "category"
			,
				typeName: "metadata"
				kindName: "color"
			]

		codetables:
			[
				codeType: "metadata"
				codeKind: "category"
				codeOrigin: "ACAS DDICT"
				code: "alpha"
				name: "Alpha"
				ignored: false
			,
				codeType: "metadata"
				codeKind: "category"
				codeOrigin: "ACAS DDICT"
				code: "beta"
				name: "Beta"
				ignored: false
			,
				codeType: "metadata"
				codeKind: "color"
				codeOrigin: "ACAS DDICT"
				code: "blue"
				name: "Blue"
				ignored: false
			,
				codeType: "metadata"
				codeKind: "color"
				codeOrigin: "ACAS DDICT"
				code: "purple"
				name: "Purple"
				ignored: false
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

