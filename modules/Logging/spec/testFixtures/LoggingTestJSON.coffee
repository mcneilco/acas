((exports) ->
	exports.savedReagent =
		cas: 123456
		barcode: "RR123345"
		vendor: "vendor1"
		hazardCategory: "flammable"

	exports.hazardCategories = [
		code: "flammable"
		name: "Flammable"
		ignored: false
	,
		code: "acid"
		name: "Acid"
		ignored: false
	,
		code: "badSmell"
		name: "Smells Bad"
		ignored: true
	,
		code: "base"
		name: "Base"
		ignored: false
	]

) (if (typeof process is "undefined" or not process.versions) then window.reagentRegTestJSON = window.reagentRegTestJSON or {} else exports)
