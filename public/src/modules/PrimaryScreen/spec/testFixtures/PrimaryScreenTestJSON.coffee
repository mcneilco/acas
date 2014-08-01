((exports) ->
	exports.primaryAnalysisReads = [
		readOrder: 11
		readName: "luminescence"
		matchReadName: true
	,
		readOrder: 12
		readName: "fluorescence"
		matchReadName: true
	,
		readOrder:13
		readName: "other read name"
		matchReadName: false
	]

	exports.primaryScreenAnalysisParameters =
		positiveControl:
			batchCode: "CMPD-12345678-01"
			concentration: 10
			concentrationUnits: "uM"
		negativeControl:
			batchCode: "CMPD-87654321-01"
			concentration: 1
			concentrationUnits: "uM"
		agonistControl:
			batchCode: "CMPD-87654399-01"
			concentration: 250753.77
			concentrationUnits: "uM"
		vehicleControl:
			batchCode: "CMPD-00000001-01"
			concentration: null
			concentrationUnits: null
		instrumentReader: "flipr"
		signalDirectionRule: "increasing signal (highest = 100%)"
		aggregateBy1: "compound batch concentration"
		aggregateBy2: "median"
		transformationRule: "(maximum-minimum)/minimum"
		normalizationRule: "plate order"
		hitEfficacyThreshold: 42
		hitSDThreshold: 5.0
		thresholdType: "sd" #or "efficacy"
		transferVolume: 12
		dilutionFactor: 21
		volumeType: "dilution" #or "transfer"
		assayVolume: 24
		autoHitSelection: false
		primaryAnalysisReadList: exports.primaryAnalysisReads

) (if (typeof process is "undefined" or not process.versions) then window.primaryScreenTestJSON = window.primaryScreenTestJSON or {} else exports)


