((exports) ->

	exports.siRNA =
		codeName: "ExampleThing-00000001"
		id: 1
		ignored: false
		lsKind: "siRNA" #should be same as the className
		lsLabels: [
			id: 1
			ignored: false
			imageFile: null
			labelText: "Example siRNA 1"
			lsKind: "name"
			lsTransaction: 1
			lsType: "name"
			lsTypeAndKind: "name_name"
			modifiedDate: null
			physicallyLabled: false
			preferred: true
			recordedBy: "egao"
			recordedDate: 1375141504000
			version: 0
		,
			id: 2
			ignored: false
			imageFile: null
			labelText: "Corp name 1"
			lsKind: "corpName"
			lsTransaction: 1
			lsType: "name"
			lsTypeAndKind: "name_corpName"
			modifiedDate: null
			physicallyLabled: false
			preferred: false
			recordedBy: "egao"
			recordedDate: 1375141504000
			version: 0
		,
			id: 3
			ignored: false
			imageFile: null
			labelText: "Barcode 1"
			lsKind: "barcode"
			lsTransaction: 1
			lsType: "barcode"
			lsTypeAndKind: "barcode_barcode"
			modifiedDate: null
			physicallyLabled: false
			preferred: false
			recordedBy: "egao"
			recordedDate: 1375141504000
			version: 0
		]
		lsStates: [
			comments: null
			id: 11
			ignored: false
			lsKind: "unique attributes"
			lsTransaction: 1
			lsType: "descriptors"
			lsTypeAndKind: "descriptors_unique attributes"
			lsValues: [
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 21
				ignored: false
				lsTransaction:
					comments: "siRNA transactions"
					id: 123
					recordedDate: 1363388477000
					version: 0
				modifiedDate: null
				numericValue: null
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: "test sequence"
				uncertainty: null
				urlValue: null
				lsKind: "sequence"
				valueOperator: null
				lsType: "stringValue"
				lsTypeAndKind: "stringValue_sequence"
				valueUnit: null
				version: 0
			]
		,
			comments: null
			id: 12
			ignored: false
			lsKind: "other attributes"
			lsTransaction: 1
			lsType: "descriptors"
			lsTypeAndKind: "descriptors_other attributes"
			lsValues: [
				clobValue: null
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 22
				ignored: false
				lsTransaction:
					comments: "siRNA transactions"
					id: 124
					recordedDate: 1363388477000
					version: 0
				modifiedDate: null
				numericValue: 12.3
				publicData: true
				recordedDate: 1363388477000
				sigFigs: null
				stringValue: null
				uncertainty: null
				urlValue: null
				lsKind: "mass"
				unitKind: "mg"
				unitType: "mass"
				valueOperator: null
				lsType: "numericValue"
				lsTypeAndKind: "numericValue_mass"
				valueUnit: null
				version: 0
			]
		,
			comments: null
			id: 13
			ignored: false
			lsKind: "experiment meta"
			lsTransaction: 1
			lsType: "meta"
			lsTypeAndKind: "meta_experiment meta"
			lsValues: [
				clobValue: "parameters clobValue example"
				codeValue: null
				comments: null
				dateValue: null
				fileValue: null
				id: 23
				ignored: false
				lsTransaction:
					comments: "siRNA transactions"
					id: 125
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
				lsKind: "analysis parameters"
				valueOperator: null
				lsType: "clobValue"
				lsTypeAndKind: "clobValue_analysis parameters"
				valueUnit: null
				version: 0
			]
		]
		lsType: "thing"
		recordedBy: "egao"
		recordedDate: 1375889487000
		shortDescription: "thing created by egao"


) (if (typeof process is "undefined" or not process.versions) then window.thingTestJSON = window.thingTestJSON or {} else exports)
