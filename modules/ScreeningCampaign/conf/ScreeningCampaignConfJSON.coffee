((exports) ->
	exports.typeKindList =
		experimenttypes:
			[
				typeName: "Parent"
			]

		experimentkinds:
			[
				typeName: "Parent"
				kindName: "Bio Activity"
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


