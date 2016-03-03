((exports) ->
	exports.firstLsThingItx1 =
		firstLsThing:
			codeName: "A000001"
			id: 1 #only required attribute
			ignored: false
			lsKind: "protein"
			lsType: "parent"
			lsTypeAndKind: "parent_protein"
			recordedBy: "egao"
			recordedDate: 1375141504000
		ignored: false
		lsKind: "assembly_component"
		lsType: "incorporates"
		lsTypeAndKind: "incorporates_assembly_component"
		lsStates:[
			lsKind: "composition"
			lsType: "metadata"
			lsValues: [
				lsKind: "order"
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_order"
				numericValue: 1
			]
		]
		recordedBy: "egao"
		recordedDate: 1375141504000

	exports.firstLsThingItx2 =
		firstLsThing:
			codeName: "B000001"
			id: 2
			lsKind: "protein"
			lsType: "parent"
			lsTypeAndKind: "parent_protein"
			recordedBy: "egao"
			recordedDate: 1375141504000
		ignored: false
		lsKind: "assembly_component"
		lsType: "incorporates"
		lsTypeAndKind: "incorporates_assembly_component"
		lsStates:[
			lsKind: "composition"
			lsType: "metadata"
			lsValues: [
				lsKind: "order"
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_order"
				numericValue: 1
			]
		]
		recordedBy: "egao"
		recordedDate: 1375141504000

	exports.firstLsThingItx3 =
		firstLsThing:
			codeName: "C000001"
			id: 3
			lsKind: "protein"
			lsType: "parent"
			lsTypeAndKind: "parent_protein"
			recordedBy: "egao"
			recordedDate: 1375141504000
		ignored: false
		lsKind: "assembly_component"
		lsType: "incorporates"
		lsTypeAndKind: "incorporates_assembly_component"
		lsStates:[
			lsKind: "composition"
			lsType: "metadata"
			lsValues: [
				lsKind: "order"
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_order"
				numericValue: 1
			]
		]
		recordedBy: "egao"
		recordedDate: 1375141504000

	exports.secondLsThingItx1 =
		secondLsThing:
			codeName: "W000001"
			id: 11 #only required attribute
			ignored: false
			lsKind: "protein"
			lsType: "parent"
			lsTypeAndKind: "parent_protein"
			recordedBy: "egao"
			recordedDate: 1375141504000
		ignored: false
		lsKind: "assembly_component"
		lsType: "incorporates"
		lsTypeAndKind: "incorporates_assembly_component"
		lsStates:[
			lsKind: "composition"
			lsType: "metadata"
			lsValues: [
				lsKind: "order"
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_order"
				numericValue: 1
			]
		]
		recordedBy: "egao"
		recordedDate: 1375141504000

	exports.secondLsThingItx2 =
		secondLsThing:
			codeName: "W000002"
			id: 12 #only required attribute
			ignored: false
			lsKind: "protein"
			lsType: "parent"
			lsTypeAndKind: "parent_protein"
			recordedBy: "egao"
			recordedDate: 1375141504000
		ignored: false
		lsKind: "assembly_component"
		lsType: "incorporates"
		lsTypeAndKind: "incorporates_assembly_component"
		lsStates:[
			lsKind: "composition"
			lsType: "metadata"
			lsValues: [
				lsKind: "order"
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_order"
				numericValue: 1
			]
		]
		recordedBy: "egao"
		recordedDate: 1375141504000

	exports.secondLsThingItx3 =
		secondLsThing:
			codeName: "W000003"
			id: 13 #only required attribute
			ignored: false
			lsKind: "protein"
			lsType: "parent"
			lsTypeAndKind: "parent_protein"
			recordedBy: "egao"
			recordedDate: 1375141504000
		ignored: false
		lsKind: "assembly_component"
		lsType: "incorporates"
		lsTypeAndKind: "incorporates_assembly_component"
		lsStates:[
			lsKind: "composition"
			lsType: "metadata"
			lsValues: [
				lsKind: "order"
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_order"
				numericValue: 1
			]
		]
		recordedBy: "egao"
		recordedDate: 1375141504000

	exports.firstLsThingItxList = [
		exports.firstLsThingItx1
	,
		exports.firstLsThingItx2
	,
		exports.firstLsThingItx3
	]

	exports.secondLsThingItxList = [
		exports.secondLsThingItx1
	,
		exports.secondLsThingItx2
	,
		exports.secondLsThingItx3
	]

) (if (typeof process is "undefined" or not process.versions) then window.thingInteractionTestJSON = window.thingInteractionTestJSON or {} else exports)
