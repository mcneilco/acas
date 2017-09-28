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

) (if (typeof process is "undefined" or not process.versions) then window.cmpdRegConfJSON = window.cmpdRegConfJSON or {} else exports)
