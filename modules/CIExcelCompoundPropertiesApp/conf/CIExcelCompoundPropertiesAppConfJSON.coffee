((exports) ->
	exports.typeKindList =
		authortypes:
			[
				typeName: "default"
			]

		authorkinds:
			[
				typeName: "default"
				kindName: "default"
			,
				typeName: "default"
				kindName: "default"
			]

		statetypes:
			[
				typeName: "metadata"
			]

		statekinds:
			[
				typeName: "metadata"
				kindName: "module preferences"
			]

		valuetypes:
			[
				typeName: "clobValue"
			]

		valuekinds:
			[
				typeName: "clobValue"
				kindName: "CIExcelCompoundPropertiesApp"
			]


) (if (typeof process is "undefined" or not process.versions) then window.CIExcelCompoundPropertiesAppConfJSON = window.CIExcelCompoundPropertiesAppConfJSON or {} else exports)
