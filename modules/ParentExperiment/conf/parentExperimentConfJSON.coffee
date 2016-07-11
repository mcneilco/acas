((exports) ->
	exports.typeKindList =
		experimenttypes:
			[
				typeName: "Parent"
			]

		experimentkinds:
			[
				typeName: "Parent"
				kindName: "Parent Bio Activity"
			]

		interactionkinds:
			[
				kindName: "collection member"
				typeName: "has member"
			]

		ddicttypes:
			[
				typeName: "parent experiment metadata"
			]

		ddictkinds:
			[
				typeName: "parent experiment metadata"
				kindName: "file type"
			]

		codetables:
			[
				codeType: "parent experiment metadata"
				codeKind: "file type"
				codeOrigin: "ACAS DDICT"
				code: "source file"
				name: "Source File"
				ignored: false
			]

) (if (typeof process is "undefined" or not process.versions) then window.parentExperimentConfJSON = window.parentExperimentConfJSON or {} else exports)
