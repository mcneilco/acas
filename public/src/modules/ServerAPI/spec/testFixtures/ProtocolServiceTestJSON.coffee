((exports) ->
	exports.fullSavedProtocol =
		codeName: "PROT-00000001"
		id: 1
		ignored: false
		lsKind: "default"
		lsLabels: [
			id: 1
			ignored: false
			imageFile: null
			labelText: "FLIPR target A biochemical"
			lsKind: "protocol name"
			lsTransaction: 1
			lsType: "name"
			lsTypeAndKind: "name_protocol name"
			modifiedDate: null
			physicallyLabled: false
			preferred: true
			recordedBy: "userName"
			recordedDate: 1375141504000
			version: 0
		]
		lsStates: [
			comments: null
			id: 2
			ignored: false
			lsKind: "experiment controls"
			lsTransaction: 1
			lsType: "metadata"
			lsTypeAndKind: "metadata_experiment controls"
			lsValues: [
				clobValue: '{  "positiveControl": {    "batchCode": "CMPD-12345678-01",    "concentration": 10,    "concentrationUnits": "uM"  },  "negativeControl": {    "batchCode": "CMPD-87654321-01",    "concentration": 1,    "concentrationUnits": "uM"  },  "agonistControl": {    "batchCode": "CMPD-87654399-01",    "concentration": 250753.77,    "concentrationUnits": "uM"  },  "vehicleControl": {    "batchCode": "CMPD-00000001-01",    "concentration": null,    "concentrationUnits": null  },  "assayVolume": 24, "transferVolume": 12, "dilutionFactor": 21, "volumeType": "dilution", "instrumentReader": "flipr", "signalDirectionRule": "increasing signal (highest = 100%)", "aggregateBy1": "compound batch concentration", "aggregateBy2": "median", "transformationRule": "(maximum-minimum)/minimum",  "normalizationRule": "plate order",  "hitEfficacyThreshold": 42,  "hitSDThreshold": 5.0,  "thresholdType": "sd", "autoHitSelection": true, "readName": "fluorescence"}'
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 333
				ignored: false
				lsKind: "data analysis parameters"
				lsTransaction: 2
				lsType: "clobValue"
				lsTypeAndKind: "clobValue_data analysis parameters"
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
				id: 80471
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: null
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: "negative control"
				uncertainty: null
				urlValue: null
				lsKind: "control type"
				valueOperator: null
				lsType: "stringValue"
				lsTypeAndKind: "stringValue_control type"
				valueUnit: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 80470
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: 1.0
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: null
				uncertainty: null
				urlValue: null
				lsKind: "tested concentration"
				valueOperator: null
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_tested concentration"
				valueUnit: "uM"
				version: 0
			,
				clobValue: null
				codeValue: "CRA-000396:1"
				comments: null
				dateValue: null
				fileValue: null
				id: 80469
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: null
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: null
				uncertainty: null
				urlValue: null
				lsKind: "batch code"
				valueOperator: null
				lsType: "codeValue"
				lsTypeAndKind: "codeValue_batch code"
				valueUnit: null
				version: 0
			]
			modifiedBy: null
			modifiedDate: null
			recordedBy: "userName"
			recordedDate: 1375141474000
			version: 0
		,
			comments: null
			id: 3
			ignored: false
			lsKind: "experiment metadata"
			lsTransaction: 1
			lsType: "metadata"
			lsTypeAndKind: "metadata_experiment metadata"
			lsValues: [
				clobValue: "long description goes here"
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 804699999
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0
				modifiedDate: null
				numericValue: null
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: null
				uncertainty: null
				urlValue: null
				lsKind: "description"
				valueOperator: null
				lsType: "clobValue"
				lsTypeAndKind: "clobValue_description"
				valueUnit: null
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
				stringValue: "912"
				uncertainty: null
				uncertaintyType: null
				unitKind: null
				unitType: null
				unitTypeAndKind: "null_null"
				urlValue: null
				version: 0
			,
				clobValue: null
				codeValue: "project1"
				comments: null
				dateValue: null
				fileValue: null
				id: 904699999
				ignored: false
				lsTransaction:
					comments: ""
					id: 87
					recordedDate: 1363388477000
					version: 0
				modifiedDate: null
				numericValue: null
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: null
				uncertainty: null
				urlValue: null
				lsKind: "project"
				valueOperator: null
				lsType: "codeValue"
				lsTypeAndKind: "codeValue_project"
				valueUnit: null
				version: 0
			]
			modifiedBy: null
			modifiedDate: null
			recordedBy: "userName"
			recordedDate: 1375141460000
			version: 0
		,
			comments: null
			id: 4
			ignored: false
			lsKind: "experiment analysis parameters"
			lsTransaction: 1
			lsType: "metadata"
			lsTypeAndKind: "metadata_experiment analysis parameters"
			lsValues: [
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 80483
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: 100.0
				publicData: true
				recordedDate: 1363388477000
				sigFigs: 2
				stringValue: null
				uncertainty: null
				urlValue: null
				lsKind: "curve max"
				valueOperator: null
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_curve max"
				valueUnit: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 80480
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: null
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: "(maximum-minimum)/minimum"
				uncertainty: null
				urlValue: null
				lsKind: "data transformation rule"
				valueOperator: null
				lsType: "stringValue"
				lsTypeAndKind: "stringValue_data transformation rule"
				valueUnit: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 80479
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: -5.0
				publicData: true
				recordedDate: 1363388477000
				sigFigs: 1
				stringValue: null
				uncertainty: null
				urlValue: null
				lsKind: "active SD threshold"
				valueOperator: null
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_active SD threshold"
				valueUnit: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 80484
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: null
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: "FLIPR Min Max"
				uncertainty: null
				urlValue: null
				lsKind: "data source"
				valueOperator: null
				lsType: "stringValue"
				lsTypeAndKind: "stringValue_data source"
				valueUnit: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 80481
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: 0.0
				publicData: true
				recordedDate: 1363388477000
				sigFigs: 2
				stringValue: null
				uncertainty: null
				urlValue: null
				lsKind: "curve min"
				valueOperator: null
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_curve min"
				valueUnit: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 80478
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: null
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: "none"
				uncertainty: null
				urlValue: null
				lsKind: "normalization rule"
				valueOperator: null
				lsType: "stringValue"
				lsTypeAndKind: "stringValue_normalization rule"
				valueUnit: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 80482
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: null
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: "no"
				uncertainty: null
				urlValue: null
				lsKind: "replicate aggregation"
				valueOperator: null
				lsType: "stringValue"
				lsTypeAndKind: "stringValue_replicate aggregation"
				valueUnit: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 80477
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: null
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: "Molecular Dynamics FLIPR"
				uncertainty: null
				urlValue: null
				lsKind: "reader instrument"
				valueOperator: null
				lsType: "stringValue"
				lsTypeAndKind: "stringValue_reader instrument"
				valueUnit: null
				version: 0
			,
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 80476
				ignored: false
				lsTransaction:
					comments: "primary analysis protocol transactions"
					id: 87
					recordedDate: 1363388477000
					version: 0

				modifiedDate: null
				numericValue: 0.7
				publicData: true
				recordedDate: 1363388477000
				sigFigs: 1
				stringValue: null
				uncertainty: null
				urlValue: null
				lsKind: "active efficacy threshold"
				valueOperator: null
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_active efficacy threshold"
				valueUnit: null
				version: 0
			]
			modifiedBy: null
			modifiedDate: null
			recordedBy: "userName"
			recordedDate: 1375141485000
			version: 0
		,
			comments: null
			id: 1
			ignored: false
			lsKind: "experiment controls"
			lsTransaction: 1
			lsType: "metadata"
			lsTypeAndKind: "metadata_experiment controls"
			lsValues: []
			modifiedBy: null
			modifiedDate: null
			recordedBy: "userName"
			recordedDate: 1375141470000
			version: 0
		,
			comments: null
			id: 5
			ignored: false
			lsKind: "experiment controls"
			lsTransaction: 1
			lsType: "metadata"
			lsTypeAndKind: "metadata_experiment controls"
			lsValues: []
			modifiedBy: null
			modifiedDate: null
			recordedBy: "userName"
			recordedDate: 1375141466000
			version: 0
		]
		lsTransaction: 1
		lsType: "default"
		lsTypeAndKind: "default_default"
		modifiedBy: null
		modifiedDate: null
		recordedBy: "username"
		recordedDate: 1375141508000
		shortDescription: "primary analysis"
		version: 1


	exports.stubSavedProtocol = [
		codeName: "PROT-00000001"
		id: 14325
		ignored: false
		lsKind: null #changed from kind to lsKind
		lsTransaction:
			comments: "protocol 201 transactions"
			id: 179
			recordedDate: 1361600825000
			version: 0

		modifiedBy: null
		modifiedDate: null
		recordedBy: "jmcneil"
		recordedDate: 1361600860000
		shortDescription: "protocol short description goes here"
		version: 0
	]
	exports.protocolToSave = [
		codeName: "PROT-00000066"
		ignored: false
		lsKind: null #changed from kind to lsKind
		lsLabels: [
			ignored: false
			imageFile: null
			labelKind: "protocol name"
			labelText: "FLIPR target A biochemical"
			labelType: "name"
			labelTypeAndKind: "name_protocol name"
			modifiedDate: null
			physicallyLabled: false
			preferred: true
			recordedBy: "userName"
			recordedDate: 1363388477000
			version: 0
		]
		lslStates: []
		modifiedBy: null
		modifiedDate: null
		recordedBy: "jmcneil"
		recordedDate: 1361600860000
		shortDescription: "protocol to save description goes here"
		version: 0
	]

	exports.lsLabels = [
		id: 67
		ignored: false
		imageFile: null
		labelText: "Rat IVPO PK"
		lsKind: "protocol name"
		lsTransaction: 74
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000007"
			id: 2585
			ignored: false
			lsKind: "PK"
			lsTransaction: 74
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303115000
			shortDescription: "protocol created by hand"
			version: 1

		recordedBy: "smeyer"
		recordedDate: 1372303115000
		version: 0
	,
		id: 68
		ignored: false
		imageFile: null
		labelText: "Mouse IVPO PK"
		lsKind: "protocol name"
		lsTransaction: 75
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000008"
			id: 2586
			ignored: false
			lsKind: "PK"
			lsTransaction: 75
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303145000
			shortDescription: "protocol created by hand"
			version: 1

		recordedBy: "smeyer"
		recordedDate: 1372303145000
		version: 0
	,
		id: 69
		ignored: false
		imageFile: null
		labelText: "Dog IVPO PK"
		lsKind: "protocol name"
		lsTransaction: 76
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000009"
			id: 2587
			ignored: false
			lsKind: "PK"
			lsTransaction: 76
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303156000
			shortDescription: "protocol created by hand"
			version: 1

		recordedBy: "smeyer"
		recordedDate: 1372303156000
		version: 0
	,
		id: 70
		ignored: false
		imageFile: null
		labelText: "Rat PO CNS penetration"
		lsKind: "protocol name"
		lsTransaction: 77
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000010"
			id: 2588
			ignored: false
			lsKind: "default"
			lsTransaction: 77
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303164000
			shortDescription: "protocol created by hand"
			version: 1

		recordedBy: "smeyer"
		recordedDate: 1372303164000
		version: 0
	,
		id: 71
		ignored: false
		imageFile: null
		labelText: "Mouse PO CNS penetration"
		lsKind: "protocol name"
		lsTransaction: 78
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000011"
			id: 2589
			ignored: false
			lsKind: "default"
			lsTransaction: 78
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303173000
			shortDescription: "protocol created by hand"
			version: 1
		recordedBy: "smeyer"
		recordedDate: 1372303115000
		version: 0
	,
		id: 72
		ignored: false
		imageFile: null
		labelText: "ADME uSol Kinetic Solubility"
		lsKind: "protocol name"
		lsTransaction: 78
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000012"
			id: 2590
			ignored: false
			lsKind: "default"
			lsTransaction: 78
			lsType: "uSol"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303173000
			shortDescription: "protocol created by hand"
			version: 1
		recordedBy: "smeyer"
		recordedDate: 1372303115000
		version: 0
	,
		id: 73
		ignored: false
		imageFile: null
		labelText: "BBB-PAMPA"
		lsKind: "protocol name"
		lsTransaction: 78
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000013"
			id: 2590
			ignored: false
			lsKind: "PAMPA"
			lsTransaction: 78
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303173000
			shortDescription: "protocol created by hand"
			version: 1
		recordedBy: "smeyer"
		recordedDate: 1372303115000
		version: 0
	,
		id: 74
		ignored: false
		imageFile: null
		labelText: "ADME_Human Liver Microsome Stability"
		lsKind: "protocol name"
		lsTransaction: 78
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000014"
			id: 2590
			ignored: false
			lsKind: "Microsome Stability"
			lsTransaction: 78
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303173000
			shortDescription: "protocol created by hand"
			version: 1
		recordedBy: "smeyer"
		recordedDate: 1372303115000
		version: 0
	,
		id: 75
		ignored: false
		imageFile: null
		labelText: "Ignore this protocol"
		lsKind: "protocol name"
		lsTransaction: 78
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000015"
			id: 2590
			ignored: true
			lsKind: "FLIPR"
			lsTransaction: 78
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303173000
			shortDescription: "protocol created by hand"
			version: 1
		recordedBy: "smeyer"
		recordedDate: 1372303115000
		version: 0
	,
		id: 72
		ignored: false
		imageFile: null
		labelText: "FLIPR target A biochemical"
		lsKind: "protocol name"
		lsTransaction: 79
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000001"
			id: 2590
			ignored: false
			lsKind: "FLIPR"
			lsTransaction: 79
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303173000
			shortDescription: "protocol created by hand"
			version: 1

		recordedBy: "smeyer"
		recordedDate: 1372303173000
		version: 0
	,
		id: 73
		ignored: false
		imageFile: null
		labelText: "KD Experiment"
		lsKind: "protocol name"
		lsTransaction: 79
		lsType: "name"
		lsTypeAndKind: "name_protocol name"
		modifiedDate: null
		physicallyLabled: false
		preferred: true
		protocol:
			codeName: "PROT-00000111"
			id: 2591
			ignored: false
			lsKind: "KD"
			lsTransaction: 79
			lsType: "default"
			lsTypeAndKind: "default_default"
			modifiedBy: null
			modifiedDate: null
			recordedBy: "smeyer"
			recordedDate: 1372303173000
			shortDescription: "protocol created by hand"
			version: 1

		recordedBy: "smeyer"
		recordedDate: 1372303173000
		version: 0
	]

	exports.protocolKinds = [
		id: 1
		lsKind: "default" #changed from kindName to lsKind
		lsType:
			id: 1
			typeName: "default"
			version: 0

		lsTypeAndKind: "default_default"
		version: 0
	,
		id: 2
		lsKind: "FLIPR" #changed from kindName to lsKind
		lsType:
			id: 1
			typeName: "default"
			version: 0

		lsTypeAndKind: "FLIPR_default"
		version: 0
	,
		id: 3
		lsKind: "KD" #changed from kindName to lsKind
		lsType:
			id: 1
			typeName: "default"
			version: 0

		lsTypeAndKind: "KD_default"
		version: 0
	,
		id: 4
		lsKind: "Microsome Stability" #changed from kindName to lsKind
		lsType:
			id: 1
			typeName: "default"
			version: 0

		lsTypeAndKind: "Microsome Stability_default"
		version: 0
	,
		id: 5
		lsKind: "uSol" #changed from kindName to lsKind
		lsType:
			id: 1
			typeName: "default"
			version: 0

		lsTypeAndKind: "uSol_default"
		version: 0
	]
) (if (typeof process is "undefined" or not process.versions) then window.protocolServiceTestJSON = window.protocolServiceTestJSON or {} else exports)



