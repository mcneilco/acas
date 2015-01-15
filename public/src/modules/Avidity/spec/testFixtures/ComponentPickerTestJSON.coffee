((exports) ->
	exports.componentCodeNamesList = [
		componentType: "Protein"
		componentCodeName: "PROT000001"
	,
		componentType: "Spacer"
		componentCodeName: "SP000002"
	,
		componentType: "Cationic Block"
		componentCodeName: "CB000003"
	]


) (if (typeof process is "undefined" or not process.versions) then window.componentPickerTestJSON = window.componentPickerTestJSON or {} else exports)
