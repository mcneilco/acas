((exports) ->
	exports.dataDictValues =
		[
			type: "subcomponents"
			kind: "internalization agent"
			codes:
				[
					code: "Cationic Block"
					name: "Cationic Block"
					ignored: false
				,
					code: "Linker Small Molecule"
					name: "Linker Small Molecule"
					ignored: false
				,
					code: "Protein"
					name: "Protein"
					ignored: false
				,
					code: "Spacer"
					name: "Spacer"
					ignored: false
				]
		,
			type: "subcomponents"
			kind: "linker"
			codes:
				[
					code: "Spacer"
					name: "Spacer"
					ignored: false
				,
					code: "Linker Small Molecule"
					name: "Linker Small Molecule"
					ignored: false
				]
		,
			type: "subcomponents"
			kind: "polymer"
			codes:
				[
					code: "Cationic Block"
					name: "Cationic Block"
					ignored: false
				,
					code: "Spacer"
					name: "Spacer"
					ignored: false
				]
		,
			type: "codeNames"
			kind: "protein"
			codes:
				[
					code: "PROT000001"
					name: "PROT000001"
					ignored: false
				,
					code: "PROT000002"
					name: "PROT000002"
					ignored: false
				]
		,
			type: "codeNames"
			kind: "spacer"
			codes:
				[
					code: "SP000001"
					name: "SP000001"
					ignored: false
				,
					code: "SP000002"
					name: "SP000002"
					ignored: false
				]
		,
			type: "codeNames"
			kind: "cationic block"
			codes:
				[
					code: "CB000001"
					name: "CB000001"
					ignored: false
				,
					code: "CB000002"
					name: "CB000002"
					ignored: false
				,
					code: "CB000003"
					name: "CB000003"
					ignored: false
				]
		,
			type: "codeNames"
			kind: "linker small molecule"
			codes:
				[
					code: "LSM000001"
					name: "LSM000001"
					ignored: false
				,
					code: "LSM000002"
					name: "LSM000002"
					ignored: false
				,
					code: "LSM000003"
					name: "LSM000003"
					ignored: false
				]

		]
) (if (typeof process is "undefined" or not process.versions) then window.componentPickerCodeTableTestJSON = window.componentPickerCodeTableTestJSON or {} else exports)
