((exports) ->
	exports.dataDictValues =
		[
			"assayStageCodes":
				[
					code: "assay development"
					name: "Assay Development"
					ignored: false
				]
		,
			"assayActivityCodes":
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
			"molecularTargetCodes":
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
			"targetOriginCodes":
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
			"assayTypeCodes":
				[
					code: "cellular assay"
					name: "Cellular Assay"
					ignored: false
				]
		,
			"assayTechnologyCodes":
				[
					code: "wizard triple luminescence"
					name: "Wizard Triple Luminescence"
					ignored: false
				]
		,
			"cellLineCodes":
				[
					code: "cell line x"
					name: "Cell Line X"
					ignored: false
				,
					code: "cell line y"
					name: "Cell Line Y"
					ignored: false
				]
		,
			"protocolStatus":
				[
					code: "created"
					name: "Created"
					ignored: false
				,
					code: "started"
					name: "Started"
					ignored: false
				,
					code: "complete"
					name: "Complete"
					ignored: false
				,
					code: "finalized"
					name: "Finalized"
					ignored: false
				,
					code: "rejected"
					name: "Rejected"
					ignored: false
				]

		]
) (if (typeof process is "undefined" or not process.versions) then window.protocolCodeTableTestJSON = window.protocolCodeTableTestJSON or {} else exports)
