((exports) ->
	exports.primaryAnalysisReads = [
		readPosition: 11
		readName: "none"
		activity: true
	,
		readPosition: 12
		readName: "fluorescence"
		activity: false
	,
		readPosition:13
		readName: "luminescence"
		activity: false
	]

	exports.transformationRules = [
		transformationRule: "% efficacy"
	,
		transformationRule: "sd"
	,
		transformationRule: "null"
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
		normalizationRule: "plate order only"
		hitEfficacyThreshold: 42
		hitSDThreshold: 5.0
		thresholdType: "sd" #or "efficacy"
		transferVolume: 12
		dilutionFactor: 21
		volumeType: "dilution" #or "transfer"
		assayVolume: 24
		autoHitSelection: false
		htsFormat: false
		matchReadName: false
		primaryAnalysisReadList: exports.primaryAnalysisReads
		transformationRuleList: exports.transformationRules

) (if (typeof process is "undefined" or not process.versions) then window.primaryScreenTestJSON = window.primaryScreenTestJSON or {} else exports)


