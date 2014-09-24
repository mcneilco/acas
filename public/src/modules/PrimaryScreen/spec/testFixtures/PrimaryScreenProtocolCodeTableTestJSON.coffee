((exports) ->
	exports.dataDictValues =
		[
			type: "protocolMetadata"
			kind: "assay stage"
			codes:
				[
					code: "assay development"
					name: "Assay Development"
					ignored: false
				]
		,
			type: "protocolMetadata"
			kind: "assay activity"
			codes:
				[
					code: "luminescence"
					name: "Luminescence"
					ignored: false
				,
					code: "fluorescence"
					name: "Fluorescence"
					ignored: false
				]
		,
			type: "protocolMetadata"
			kind: "molecular target"
			codes:
				[
					code: "target x"
					name: "Target X"
					ignored: false
				,
					code: "target y"
					name: "Target Y"
					ignored: false
				]
		,
			type: "protocolMetadata"
			kind: "target origin"
			codes:
				[
					code: "human"
					name: "Human"
					ignored: false
				,
					code: "chimpanzee"
					name: "Chimpanzee"
					ignored: false
				]
		,
			type: "protocolMetadata"
			kind:"assay type"
			codes:
				[
					code: "cellular assay"
					name: "Cellular Assay"
					ignored: false
				]
		,
			type: "protocolMetadata"
			kind: "assay technology"
			codes:
				[
					code: "wizard triple luminescence"
					name: "Wizard Triple Luminescence"
					ignored: false
				]
		,
			type: "protocolMetadata"
			kind: "cell line"
			codes:
				[
					code: "cell line x"
					name: "Cell Line X"
					ignored: false
				,
					code: "cell line y"
					name: "Cell Line Y"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.primaryScreenProtocolCodeTableTestJSON = window.primaryScreenProtocolCodeTableTestJSON or {} else exports)
