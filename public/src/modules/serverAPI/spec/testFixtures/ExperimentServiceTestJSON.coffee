((exports) ->
	exports.experimentLabels = [
		id: 43
		ignored: false
		imageFile: null
		lsKind: "experiment name"
		labelText: "FLIPR target A biochemical"
		lsType: "name"
		lsTypeAndKind: "name_experiment name"
		lsTransaction:
			comments: "experiment 502 transactions"
			id: 47
			recordedDate: 1362435677000
			version: 0
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		recordedBy: "userName"
		recordedDate: 1362435678000
		version: 0
	,
		id: 42
		ignored: true
		imageFile: null
		lsKind: "experiment name"
		labelText: "FLIPR target A biochemical old"
		lsType: "name"
		lsTypeAndKind: "name_experiment name"
		lsTransaction:
			comments: "experiment 502 transactions"
			id: 48
			recordedDate: 1362435677000
			version: 0
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		recordedBy: "userName"
		recordedDate: 1361435678000
		version: 0
	,
		id: 45
		ignored: false
		imageFile: null
		lsKind: "experiment full name"
		labelText: "FLIPR target A biochemical with additional name awesomness"
		lsType: "name"
		lsTypeAndKind: "name_experiment full name"
		lsTransaction:
			comments: "experiment 502 transactions"
			id: 49
			recordedDate: 1362435677000
			version: 0
		modifiedDate: null
		physicallyLabled: false
		preferred: false
		recordedBy: "userName"
		recordedDate: 1362435678001
		version: 0
	,
		id: 49
		ignored: false
		imageFile: null
		lsKind: ""
		labelText: "AAABBD13343434"
		lsType: "barcode"
		lsTypeAndKind: "barcode_"
		lsTransaction:
			comments: "experiment 502 transactions"
			id: 50
			recordedDate: 1362435679000
			version: 0
		modifiedDate: null
		physicallyLabled: false
		preferred: false
		recordedBy: "userName"
		recordedDate: 1362435679001
		version: 0
	]

	exports.experimentLabelsNoPreferred = [
		id: 43
		ignored: false
		imageFile: null
		lsKind: "experiment name"
		labelText: "FLIPR target A biochemical"
		lsType: "name"
		lsTypeAndKind: "name_experiment name"
		lsTransaction:
			comments: "experiment 502 transactions"
			id: 47
			recordedDate: 1362435677000
			version: 0
		modifiedDate: null
		physicallyLabled: false
		preferred: false
		recordedBy: "userName"
		recordedDate: 1362435678000
		version: 0
	,
		id: 42
		ignored: true
		imageFile: null
		lsKind: "experiment name"
		labelText: "FLIPR target A biochemical old"
		lsType: "name"
		lsTypeAndKind: "name_experiment name"
		lsTransaction:
			comments: "experiment 502 transactions"
			id: 48
			recordedDate: 1362435677000
			version: 0
		modifiedDate: null
		physicallyLabled: false
		preferred: false
		recordedBy: "userName"
		recordedDate: 1361435678000
		version: 0
	,
		id: 45
		ignored: false
		imageFile: null
		lsKind: "experiment full name"
		labelText: "FLIPR target A biochemical with additional name awesomness"
		lsType: "name"
		lsTypeAndKind: "name_experiment full name"
		lsTransaction:
			comments: "experiment 502 transactions"
			id: 49
			recordedDate: 1362435677000
			version: 0
		modifiedDate: null
		physicallyLabled: false
		preferred: false
		recordedBy: "userName"
		recordedDate: 1362435678001
		version: 0
	,
		id: 49
		ignored: false
		imageFile: null
		lsKind: ""
		labelText: "AAABBD13343434"
		lsType: "barcode"
		lsTypeAndKind: "barcode_"
		lsTransaction:
			comments: "experiment 502 transactions"
			id: 50
			recordedDate: 1362435679000
			version: 0
		modifiedDate: null
		physicallyLabled: false
		preferred: false
		recordedBy: "userName"
		recordedDate: 1362435679001
		version: 0
	]

	exports.experimentLabelsNoPreferredNoNames = [
		id: 45
		ignored: false
		imageFile: null
		lsKind: "experiment full name"
		labelText: "FLIPR target A biochemical with additional name awesomness"
		lsType: "barcode"
		lsTypeAndKind: "name_experiment full name"
		lsTransaction:
			comments: "experiment 502 transactions"
			id: 49
			recordedDate: 1362435677000
			version: 0
		modifiedDate: null
		physicallyLabled: false
		preferred: false
		recordedBy: "userName"
		recordedDate: 1362435678001
		version: 0
	,
		id: 49
		ignored: false
		imageFile: null
		lsKind: ""
		labelText: "AAABBD13343434"
		lsType: "barcode"
		lsTypeAndKind: "barcode_"
		lsTransaction:
			comments: "experiment 502 transactions"
			id: 50
			recordedDate: 1362435679000
			version: 0
		modifiedDate: null
		physicallyLabled: false
		preferred: false
		recordedBy: "userName"
		recordedDate: 1362435679001
		version: 0
	]

	exports.stubSavedExperiment = [
		codeName: "EXPT-00000046"
		id: 270
		ignored: false
		kind: null
		lsTransaction:
			comments: "protocol 201 transactions"
			id: 179
			recordedDate: 1361600825000
			version: 0

		modifiedBy: null
		modifiedDate: null
		recordedBy: "jmcneil"
		recordedDate: 1361600860000
		shortDescription: "experiment short description goes here"
		version: 0
	]

	exports.experimentToSave =
		ignored: false
		kind: "primary screen experiment"
		modifiedBy: null
		modifiedDate: null
		recordedBy: "jmcneil"
		recordedDate: 1361600860000
		shortDescription: "experiment short description goes here"
		lsLabels: [
			ignored: false
			imageFile: null
			lsKind: "experiment name"
			labelText: "FLIPR target A biochemical"
			lsType: "name"
			lsTypeAndKind: "name_experiment name"
			modifiedDate: null
			physicallyLabled: false
			preferred: true
			recordedBy: "jmcneil"
			recordedDate: 1362435678000
			version: 0
		]




	exports.fullExperimentFromServer =
		analysisGroups: [
			codeName: "AG-00000002"
			id: 19
			ignored: false
			lsKind: "Generic"
			lsLabels: []
			lsStates: [
				comments: null
				id: 17
				ignored: false
				lsKind: "Generic"
				lsTransaction: 2
				lsType: "data"
				lsTypeAndKind: "data_Generic"
				lsValues: [
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: "exampleUploadedFile.txt"
					id: 222222
					ignored: false
					lsKind: "Inhibition"
					lsTransaction: 2
					lsType: "fileValue"
					lsTypeAndKind: "numericValue_Inhibition"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					operatorKind: null
					operatorType: null
					operatorTypeAndKind: null
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: null
					unitType: null
					unitTypeAndKind: null
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 22
					ignored: false
					lsKind: "Inhibition"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_Inhibition"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 40
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "%"
					unitType: null
					unitTypeAndKind: "null_%"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: "CMPD-0000052-01"
					comments: null
					dateValue: null
					fileValue: null
					id: 21
					ignored: false
					lsKind: "batch code"
					lsTransaction: 2
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_batch code"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: null
					unitType: null
					unitTypeAndKind: "null_null"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 20
					ignored: false
					lsKind: "tested concentration"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_tested concentration"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 10
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "uM"
					unitType: null
					unitTypeAndKind: "null_uM"
					urlValue: null
					version: 0
				]
				modifiedBy: null
				modifiedDate: null
				recordedBy: "smeyer"
				recordedDate: 1375889490000
				version: 0
			,
				comments: null
				id: 18
				ignored: false
				lsKind: "Generic"
				lsTransaction: 2
				lsType: "data"
				lsTypeAndKind: "data_Generic"
				lsValues: [
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 25
					ignored: false
					lsKind: "Inhibition"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_Inhibition"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 100
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "%"
					unitType: null
					unitTypeAndKind: "null_%"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: "CMPD-0000052-01"
					comments: null
					dateValue: null
					fileValue: null
					id: 24
					ignored: false
					lsKind: "batch code"
					lsTransaction: 2
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_batch code"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: null
					unitType: null
					unitTypeAndKind: "null_null"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 23
					ignored: false
					lsKind: "tested concentration"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_tested concentration"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 100
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "uM"
					unitType: null
					unitTypeAndKind: "null_uM"
					urlValue: null
					version: 0
				]
				modifiedBy: null
				modifiedDate: null
				recordedBy: "smeyer"
				recordedDate: 1375889490000
				version: 0
			,
				comments: null
				id: 16
				ignored: false
				lsKind: "Generic"
				lsTransaction: 2
				lsType: "data"
				lsTypeAndKind: "data_Generic"
				lsValues: [
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 18
					ignored: false
					lsKind: "tested concentration"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_tested concentration"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 30
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "uM"
					unitType: null
					unitTypeAndKind: "null_uM"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 19
					ignored: false
					lsKind: "Inhibition"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_Inhibition"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 70
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "%"
					unitType: null
					unitTypeAndKind: "null_%"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: "CMPD-0000052-01"
					comments: null
					dateValue: null
					fileValue: null
					id: 17
					ignored: false
					lsKind: "batch code"
					lsTransaction: 2
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_batch code"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: null
					unitType: null
					unitTypeAndKind: "null_null"
					urlValue: null
					version: 0
				]
				modifiedBy: null
				modifiedDate: null
				recordedBy: "smeyer"
				recordedDate: 1375889490000
				version: 0
			]
			lsTransaction: 2
			lsType: "default"
			lsTypeAndKind: "default_Generic"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1375889490000
			treatmentGroups: []
			version: 0
		,
			codeName: "AG-00000001"
			id: 18
			ignored: false
			lsKind: "Generic"
			lsLabels: []
			lsStates: [
				comments: null
				id: 15
				ignored: false
				lsKind: "Generic"
				lsTransaction: 2
				lsType: "data"
				lsTypeAndKind: "data_Generic"
				lsValues: [
					clobValue: null
					codeValue: "CMPD-0000051-01"
					comments: null
					dateValue: null
					fileValue: null
					id: 16
					ignored: false
					lsKind: "batch code"
					lsTransaction: 2
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_batch code"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: null
					unitType: null
					unitTypeAndKind: "null_null"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 15
					ignored: false
					lsKind: "Inhibition"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_Inhibition"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 80
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "%"
					unitType: null
					unitTypeAndKind: "null_%"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 14
					ignored: false
					lsKind: "tested concentration"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_tested concentration"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 100
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "uM"
					unitType: null
					unitTypeAndKind: "null_uM"
					urlValue: null
					version: 0
				]
				modifiedBy: null
				modifiedDate: null
				recordedBy: "smeyer"
				recordedDate: 1375889490000
				version: 0
			,
				comments: null
				id: 14
				ignored: false
				lsKind: "Generic"
				lsTransaction: 2
				lsType: "data"
				lsTypeAndKind: "data_Generic"
				lsValues: [
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 12
					ignored: false
					lsKind: "tested concentration"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_tested concentration"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 10
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "uM"
					unitType: null
					unitTypeAndKind: "null_uM"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: "CMPD-0000051-01"
					comments: null
					dateValue: null
					fileValue: null
					id: 11
					ignored: false
					lsKind: "batch code"
					lsTransaction: 2
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_batch code"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: null
					unitType: null
					unitTypeAndKind: "null_null"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 13
					ignored: false
					lsKind: "Inhibition"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_Inhibition"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 10
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "%"
					unitType: null
					unitTypeAndKind: "null_%"
					urlValue: null
					version: 0
				]
				modifiedBy: null
				modifiedDate: null
				recordedBy: "smeyer"
				recordedDate: 1375889490000
				version: 0
			,
				comments: null
				id: 13
				ignored: false
				lsKind: "Generic"
				lsTransaction: 2
				lsType: "data"
				lsTypeAndKind: "data_Generic"
				lsValues: [
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 8
					ignored: false
					lsKind: "Inhibition"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_Inhibition"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 12
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "%"
					unitType: null
					unitTypeAndKind: "null_%"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 9
					ignored: false
					lsKind: "tested concentration"
					lsTransaction: 2
					lsType: "numericValue"
					lsTypeAndKind: "numericValue_tested concentration"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: 30
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: "uM"
					unitType: null
					unitTypeAndKind: "null_uM"
					urlValue: null
					version: 0
				,
					clobValue: null
					codeValue: "CMPD-0000051-01"
					comments: null
					dateValue: null
					fileValue: null
					id: 10
					ignored: false
					lsKind: "batch code"
					lsTransaction: 2
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_batch code"
					modifiedBy: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					operatorKind: null
					operatorType: "comparison"
					operatorTypeAndKind: "comparison_null"
					publicData: true
					recordedBy: "smeyer"
					recordedDate: 1375889490000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					unitKind: null
					unitType: null
					unitTypeAndKind: "null_null"
					urlValue: null
					version: 0
				]
				modifiedBy: null
				modifiedDate: null
				recordedBy: "smeyer"
				recordedDate: 1375889490000
				version: 0
			]
			lsTransaction: 2
			lsType: "default"
			lsTypeAndKind: "default_Generic"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1375889490000
			treatmentGroups: []
			version: 0
		]
		codeName: "EXPT-00000001"
		id: 17
		ignored: false
		lsKind: "default"
		lsLabels: [
			id: 34
			ignored: false
			imageFile: null
			labelText: "Test Experiment 1"
			lsKind: "experiment name"
			lsTransaction: 2
			lsType: "name"
			lsTypeAndKind: "name_experiment name"
			modifiedDate: null
			physicallyLabled: false
			preferred: true
			recordedBy: "smeyer"
			recordedDate: 1375889487000
			version: 0
		]
		lsStates: [
			comments: null
			id: 11
			ignored: false
			lsKind: "experiment metadata"
			lsTransaction: 2
			lsType: "metadata"
			lsTypeAndKind: "metadata_experiment metadata"
			lsValues: [
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 3
				ignored: false
				lsKind: "notebook page"
				lsTransaction: 2
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_notebook page"
				modifiedBy: null
				modifiedDate: null
				numberOfReplicates: null
				numericValue: null
				operatorKind: null
				operatorType: "comparison"
				operatorTypeAndKind: "comparison_null"
				publicData: true
				recordedBy: "smeyer"
				recordedDate: 1375889487000
				sigFigs: null
				stringValue: "12"
				uncertainty: null
				uncertaintyType: null
				unitKind: null
				unitType: null
				unitTypeAndKind: "null_null"
				urlValue: null
				version: 0
			,
				clobValue: "<p>Analysis not yet completed</p>"
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 4
				ignored: false
				lsKind: "analysis result html"
				lsTransaction: 2
				lsType: "clobValue"
				lsTypeAndKind: "clobValue_analysis result html"
				modifiedBy: null
				modifiedDate: null
				numberOfReplicates: null
				numericValue: null
				operatorKind: null
				operatorType: "comparison"
				operatorTypeAndKind: "comparison_null"
				publicData: true
				recordedBy: "smeyer"
				recordedDate: 1375889487000
				sigFigs: null
				stringValue: null
				uncertainty: null
				uncertaintyType: null
				unitKind: null
				unitType: null
				unitTypeAndKind: "null_null"
				urlValue: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 5
				ignored: false
				lsKind: "notebook"
				lsTransaction: 2
				lsType: "stringValue"
				lsTypeAndKind: "stringValue_notebook"
				modifiedBy: null
				modifiedDate: null
				numberOfReplicates: null
				numericValue: null
				operatorKind: null
				operatorType: "comparison"
				operatorTypeAndKind: "comparison_null"
				publicData: true
				recordedBy: "smeyer"
				recordedDate: 1375889487000
				sigFigs: null
				stringValue: "911"
				uncertainty: null
				uncertaintyType: null
				unitKind: null
				unitType: null
				unitTypeAndKind: "null_null"
				urlValue: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: 1342080000000
				fileValue: null
				id: 1
				ignored: false
				lsKind: "completion date"
				lsTransaction: 2
				lsType: "dateValue"
				lsTypeAndKind: "dateValue_completion date"
				modifiedBy: null
				modifiedDate: null
				numberOfReplicates: null
				numericValue: null
				operatorKind: null
				operatorType: "comparison"
				operatorTypeAndKind: "comparison_null"
				publicData: true
				recordedBy: "smeyer"
				recordedDate: 1375889487000
				sigFigs: null
				stringValue: null
				uncertainty: null
				uncertaintyType: null
				unitKind: null
				unitType: null
				unitTypeAndKind: "null_null"
				urlValue: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 2
				ignored: false
				lsKind: "status"
				lsTransaction: 2
				lsType: "stringValue"
				lsTypeAndKind: "stringValue_status"
				modifiedBy: null
				modifiedDate: null
				numberOfReplicates: null
				numericValue: null
				operatorKind: null
				operatorType: "comparison"
				operatorTypeAndKind: "comparison_null"
				publicData: true
				recordedBy: "smeyer"
				recordedDate: 1375889487000
				sigFigs: null
				stringValue: "Approved"
				uncertainty: null
				uncertaintyType: null
				unitKind: null
				unitType: null
				unitTypeAndKind: "null_null"
				urlValue: null
				version: 0
			]
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1375889487000
			version: 1
		,
			comments: ""
			id: 12
			ignored: false
			lsKind: "raw results locations"
			lsTransaction: 2
			lsType: "metadata"
			lsTypeAndKind: "metadata_raw results locations"
			lsValues: [
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: "experiments/EXPT-00000001/Mia-Paca.xls"
				id: 7
				ignored: false
				lsKind: "source file"
				lsTransaction: 2
				lsType: "stringValue"
				lsTypeAndKind: "stringValue_source file"
				modifiedBy: null
				modifiedDate: null
				numberOfReplicates: null
				numericValue: null
				operatorKind: null
				operatorType: "comparison"
				operatorTypeAndKind: "comparison_null"
				publicData: true
				recordedBy: "smeyer"
				recordedDate: 1375889489000
				sigFigs: null
				stringValue: null
				uncertainty: null
				uncertaintyType: null
				unitKind: null
				unitType: null
				unitTypeAndKind: "null_null"
				urlValue: null
				version: 0
			]
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1375889489000
			version: 0
		]
		lsTransaction: 2
		lsType: "default"
		lsTypeAndKind: "default_default"
		modifiedBy: null
		modifiedDate: null
		protocol:
			codeName: "PROT-00000001"
			id: 16
			ignored: false
			lsKind: "default"
			lsTransaction: 2
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1375889486000
			shortDescription: "protocol created by generic data parser"
			version: 1

		recordedBy: "smeyer"
		recordedDate: 1375889487000
		shortDescription: "experiment created by generic data parser"
		version: 1

	exports.savedExperimentWithTreatmentGroup =
		codeName: "EXPT-00000222"
		lsLabels: [
			id: 31876
			ignored: false
			imageFile: null
			lsKind: "experiment name"
			labelText: "EXPT-00000221"
			lsType: "name"
			lsTypeAndKind: "name_experiment name"
			lsTransaction:
				comments: "docForBatches upload"
				id: 423
				recordedDate: 1367455531000
				version: 0

			modifiedDate: null
			physicallyLabled: false
			preferred: true
			recordedBy: "jmcneil"
			recordedDate: 1367455532000
			version: 0
		]
		lsStates: []
		id: 64781
		ignored: false
		kind: "ACAS doc for batches"
		lsTransaction:
			comments: "docForBatches upload"
			id: 423
			recordedDate: 1367455531000
			version: 0

		modifiedBy: null
		modifiedDate: null
		protocol:
			codeName: "ACASdocForBatches"
			id: 2403
			ignored: false
			kind: null
			lsTransaction:
				comments: "docForBatches upload"
				id: 38
				recordedDate: 1362677322000
				version: 0

			modifiedBy: null
			modifiedDate: null
			recordedBy: "jmcneil"
			recordedDate: 1362677322000
			shortDescription: "ACAS Doc For Batches"
			version: 0

		recordedBy: "jmcneil"
		recordedDate: null
		shortDescription: "test description"
		version: 0
		analysisGroups: [
			lsLabels: []
			lsStates: [
				lsValues: [
					clobValue: null
					codeValue: null
					comments: "ok"
					dateValue: null
					fileValue: "exampleUploadedFile.txt"
					id: 258587
					ignored: false
					lsTransaction: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					publicData: true
					recordedDate: 1367455532000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					urlValue: null
					lsKind: "annotation"
					valueOperator: null
					lsType: "fileValue"
					lsTypeAndKind: "fileValue_annotation"
					valueUnit: null
					version: 0
				,
					clobValue: null
					codeValue: "CMPD_1112"
					comments: null
					dateValue: null
					fileValue: null
					id: 258588
					ignored: false
					lsTransaction: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					publicData: true
					recordedDate: 1367455532000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					urlValue: null
					lsKind: "batch code"
					valueOperator: null
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_batch code"
					valueUnit: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 258586
					ignored: false
					lsTransaction: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					publicData: true
					recordedDate: 1367455532000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					urlValue: null
					lsKind: "document kind"
					valueOperator: null
					lsType: "stringValue"
					lsTypeAndKind: "stringValue_document kind"
					valueUnit: null
					version: 0
				]
				comments: null
				id: 85510
				ignored: false
				lsTransaction:
					comments: "docForBatches upload"
					id: 423
					recordedDate: 1367455531000
					version: 0

				modifiedBy: null
				modifiedDate: null
				recordedBy: "jmcneil"
				recordedDate: 1367455532000
				lsKind: "Document for Batch"
				lsType: "results"
				stateTypeAndKind: "results_Document for Batch"
				version: 0
			,
				lsValues: [
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 258591
					ignored: false
					lsTransaction: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					publicData: true
					recordedDate: 1367455532000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					urlValue: null
					lsKind: "document kind"
					valueOperator: null
					lsType: "stringValue"
					lsTypeAndKind: "stringValue_document kind"
					valueUnit: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: "good"
					dateValue: null
					fileValue: "exampleUploadedFile.txt"
					id: 258589
					ignored: false
					lsTransaction: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					publicData: true
					recordedDate: 1367455532000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					urlValue: null
					lsKind: "annotation"
					valueOperator: null
					lsType: "fileValue"
					lsTypeAndKind: "fileValue_annotation"
					valueUnit: null
					version: 0
				,
					clobValue: null
					codeValue: "CMPD-0000007-01"
					comments: null
					dateValue: null
					fileValue: null
					id: 258590
					ignored: false
					lsTransaction: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					publicData: true
					recordedDate: 1367455532000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					urlValue: null
					lsKind: "batch code"
					valueOperator: null
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_batch code"
					valueUnit: null
					version: 0
				]
				comments: null
				id: 85511
				ignored: false
				lsTransaction:
					comments: "docForBatches upload"
					id: 423
					recordedDate: 1367455531000
					version: 0

				modifiedBy: null
				modifiedDate: null
				recordedBy: "jmcneil"
				recordedDate: 1367455532000
				lsKind: "Document for Batch"
				lsType: "results"
				stateTypeAndKind: "results_Document for Batch"
				version: 0
			,
				lsValues: [
					clobValue: null
					codeValue: "CMPD_1113"
					comments: null
					dateValue: null
					fileValue: null
					id: 258585
					ignored: false
					lsTransaction: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					publicData: true
					recordedDate: 1367455532000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					urlValue: null
					lsKind: "batch code"
					valueOperator: null
					lsType: "codeValue"
					lsTypeAndKind: "codeValue_batch code"
					valueUnit: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: null
					dateValue: null
					fileValue: null
					id: 258584
					ignored: false
					lsTransaction: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					publicData: true
					recordedDate: 1367455532000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					urlValue: null
					lsKind: "document kind"
					valueOperator: null
					lsType: "stringValue"
					lsTypeAndKind: "stringValue_document kind"
					valueUnit: null
					version: 0
				,
					clobValue: null
					codeValue: null
					comments: "bad"
					dateValue: null
					fileValue: "exampleUploadedFile.txt"
					id: 258583
					ignored: false
					lsTransaction: null
					modifiedDate: null
					numberOfReplicates: null
					numericValue: null
					publicData: true
					recordedDate: 1367455532000
					sigFigs: null
					stringValue: null
					uncertainty: null
					uncertaintyType: null
					urlValue: null
					lsKind: "annotation"
					valueOperator: null
					lsType: "fileValue"
					lsTypeAndKind: "fileValue_annotation"
					valueUnit: null
					version: 0
				]
				comments: null
				id: 85509
				ignored: false
				lsTransaction:
					comments: "docForBatches upload"
					id: 423
					recordedDate: 1367455531000
					version: 0

				modifiedBy: null
				modifiedDate: null
				recordedBy: "jmcneil"
				recordedDate: 1367455532000
				lsKind: "Document for Batch"
				lsType: "results"
				stateTypeAndKind: "results_Document for Batch"
				version: 0
			]
			codeName: "AG-00037424"
			id: 64782
			ignored: false
			recordedBy: "jmcneil"
			recordedDate: 1367455531000
			kind: "ACAS doc for batches"
			lsTransaction:
				comments: "docForBatches upload"
				id: 423
				recordedDate: 1367455531000
				version: 0
		]


) (if (typeof process is "undefined" or not process.versions) then window.experimentServiceTestJSON = window.experimentServiceTestJSON or {} else exports)



