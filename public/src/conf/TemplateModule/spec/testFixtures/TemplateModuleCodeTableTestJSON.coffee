# This is a stub for getting code table values.
# This file's name must end with 'CodeTableTestJSON'
((exports) ->
	exports.codetableValues =
		[
			type: "reagentReg"
			kind: "hazardCategories"
			codes:
				[
					code: "category 1"
					name: "Category 1"
					ignored: false
				,
					code: "category 2"
					name: "Category 2"
					ignored: false
				,
					code: "category 3"
					name: "Category 3"
					ignored: false
				]
		,
			type: "reagentReg"
			kind: "reagents"
			codes:
				[
					code: "reagent 1"
					name: "Reagent 1"
					ignored: false
				,
					code: "reagent 2"
					name: "Reagent 2"
					ignored: false
				,
					code: "reagent 3"
					name: "Reagent 3"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.templateModuleCodeTableTestJSON = window.templateModuleCodeTableTestJSON or {} else exports)
