((exports) ->
	exports.typeKindList =
		protocoltypes:
			[
				typeName: "Parent"
			]

		protocolkinds:
			[
				typeName: "Parent"
				kindName: "Parent Bio Activity"
			]

		interactionkinds:
			[
				kindName: "collection member"
				typeName: "has member"
			]

) (if (typeof process is "undefined" or not process.versions) then window.parentProtocolConfJSON = window.parentProtocolConfJSON or {} else exports)
