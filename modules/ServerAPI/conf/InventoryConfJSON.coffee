((exports) ->
	exports.typeKindList =
		containertypes:
			[
				typeName: "virtual"
			,
				typeName: "physical"
			]

		container:
			[
				typeName: "virtual"
				kindName: "plate"
      ,
				typeName: "physical"
				kindName: "plate"
			,
				typeName: "physical"
				kindName: "well"
			,
				typeName: "physical"
				kindName: "system"
			]

		statetypes:
			[
				typeName: "metadata"
      ,
				typeName: "constants"
      ,
				typeName: "status"
			]

		statekinds:
			[
				typeName: "constants"
				kindName: "format"
			,
				typeName: "metadata"
				kindName: "container"
			,
				typeName: "status"
				kindName: "location"
			,
				typeName: "status"
				kindName: "content"
			,
				typeName: "constants"
				kindName: "container"
			]

		valuetypes:
			[
				typeName: "dateValue"
			,
				typeName: "codeValue"
			,
				typeName: "stringValue"
			,
				typeName: "numericValue"
			]

		valuekinds:
			[
        typeName: "numericValue"
        kindName: "wells"
      ,
        typeName: "numericValue"
        kindName: "rows"
      ,
        typeName: "numericValue"
        kindName: "columns"
      ,
        typeName: "codeValue"
        kindName: "subcontainer naming convention"
      ,
        typeName: "numericValue"
        kindName: "max well volume"
      ,
        typeName: "dateValue"
        kindName: "registration date"
      ,
        typeName: "codeValue"
        kindName: "supplier code"
      ,
        typeName: "codeValue"
        kindName: "status code"
      ,
        typeName: "codeValue"
        kindName: "availability"
      ,
        typeName: "numericValue"
        kindName: "gross mass"
      ,
        typeName: "numericValue"
        kindName: "tare weight"
      ,
        typeName: "stringValue"
        kindName: "created user"
      ,
        typeName: "dateValue"
        kindName: "created date"
      ,
        typeName: "codeValue"
        kindName: "CUSTOM_LOCATION"
      ,
        typeName: "codeValue"
        kindName: "batch code"
      ,
        typeName: "stringValue"
        kindName: "description"
      ,
        typeName: "codeValue"
        kindName: "plate template"
      ,
        typeName: "codeValue"
        kindName: "k plate id"
      ,
        typeName: "numericValue"
        kindName: "current mass"
      ,
        typeName: "numericValue"
        kindName: "net mass"
      ,
        typeName: "numericValue"
        kindName: "initial mass"
      ,
        typeName: "codeValue"
        kindName: "solvent code"
      ,
        typeName: "codeValue"
        kindName: "plate type"
       ]

		labeltypes:
			[
				typeName: "name"
			]

		labelkinds:
			[
				typeName: "name"
				kindName: "model"
			,
				typeName: "name"
				kindName: "common"
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
				digits: 8
				groupDigits: false
				labelPrefix: "PLATE"
				labelSeparator: "-"
				labelTypeAndKind: "id_codeName"
				thingTypeAndKind: "document_plate"
				latestNumber:0
			]


) (if (typeof process is "undefined" or not process.versions) then window.protocolConfJSON = window.protocolConfJSON or {} else exports)
