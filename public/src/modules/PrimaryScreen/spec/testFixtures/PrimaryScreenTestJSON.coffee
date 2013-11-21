((exports) ->
	exports.primaryScreenAnalysisParameters =
		dataAnalysis:
			positiveControl:
				batchCode: "CMPD-12345678-01"
				concentratation: 10
				conentrationUnits: "uM"
			negativeControl:
				batchCode: "CMPD-87654321-01"
				concentratation: 1
				conentrationUnits: "uM"
			vehicleControl:
				batchCode: "CMPD-00000001-01"
				concentratation: null
				conentrationUnits: null
			transformation: "(Max-Min)/Min"
			normalization: "Plate Order"
			hitEfficacyThreshold: null
			hitSDThreshold: 5.0
		modelFit:
			fitParameters:
				curveMin:
					lock: true
					value: 0.0
				curveMax:
					lock: true
					value: 100.0
				hilSlope:
					lock: false
					value: null
				ec50:
					lock: false
					value: null
				groupBy: "across all plates"

) (if (typeof process is "undefined" or not process.versions) then window.protocolServiceTestJSON = window.protocolServiceTestJSON or {} else exports)
