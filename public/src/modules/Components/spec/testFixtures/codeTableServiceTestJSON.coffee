((exports) ->
	exports.codes = [
		code: "fluorescence"
		name: "Fluorescence"
		id: 1
		displayOrder: 1
		ignored: false
	,
		code: "biochemical"
		name: "Biochemical"
		id: 2
		displayOrder: 2
		ignored: false
	,
		code: "ko"
		name: "Well Knocked Out"
		id: 3
		displayOrder: 3
		ignored: true
	]
) (if (typeof process is "undefined" or not process.versions) then window.codeTableServiceTestJSON = window.codeTableServiceTestJSON or {} else exports)



