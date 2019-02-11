((exports) ->
	exports.typeKindList =
		thingtypes:
			[
				typeName: "parent"
			]

		thingkinds:
			[
				typeName: "parent"
				kindName: "compound"
			]

		labeltypes:
			[
				typeName: "id"
			]

		labelkinds:
			[
				typeName: "id"
				kindName: "corpName"
			]
		ddicttypes:
			[
				typeName: "compound"
			]
		ddictkinds:
			[
				typeName: "compound"
				kindName: "scientist"
			]

) (if (typeof process is "undefined" or not process.versions) then window.cmpdRegConfJSON = window.cmpdRegConfJSON or {} else exports)
