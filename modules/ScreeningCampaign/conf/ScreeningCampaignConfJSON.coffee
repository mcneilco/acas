((exports) ->
	exports.typeKindList =
		protocoltypes:
			[
				typeName: "Parent"
			]

		protocolkinds:
			[
				typeName: "Parent"
				kindName: "Bio Activity"
			,
				typeName: "Parent"
				kindName: "Bio Activity Screen"
			]

		experimenttypes:
			[
				typeName: "Parent"
			]

		experimentkinds:
			[
				typeName: "Parent"
				kindName: "Bio Activity"
			,
				typeName: "Parent"
				kindName: "Bio Activity Screen"
			]

		interactiontypes:
			[
				typeName: "has member"
				typeVerb: "parent has member primary child"
			]

		interactionkinds:
			[
				typeName: "has member"
				kindName: "parent_primary child"
			]
) (if (typeof process is "undefined" or not process.versions) then window.screeningCampaignExperimentConfJSON = window.screeningCampaignExperimentConfJSON or {} else exports)


