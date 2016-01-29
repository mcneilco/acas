((exports) ->
	exports.primaryAnalysisReads = [
		readNumber: 1
		readPosition: 11
		readName: "none"
		activity: true
	,
		readNumber: 2
		readPosition: 12
		readName: "fluorescence"
		activity: false
	,
		readNumber: 3
		readPosition:13
		readName: "luminescence"
		activity: false
	]

	exports.primaryAnalysisTimeWindows = [
		position: 1
		statistic: "max"
		windowStart: -5
		windowEnd: 5
		unit: "s"
	,
		position: 2
		statistic: "min"
		windowStart: 0
		windowEnd: 15
		unit: "s"
	,
		position: 3
		statistic: "max"
		windowStart: 20
		windowEnd: 50
		unit: "s"
	]

	exports.transformationRules = [
		transformationRule: "% efficacy"
		transformationParameters:
			positiveControl:
				standardNumber: 1
				defaultValue: ""
			negativeControl:
				standardNumber: ""
				defaultValue: 5
	,
		transformationRule: "sd"
		transformationParameters:
			positiveControl:
				standardNumber: 1
				defaultValue: ""
			negativeControl:
				standardNumber: ""
				defaultValue: 5
	,
		transformationRule: "null"
		transformationParameters: {}
	]

	exports.primaryScreenAnalysisParameters =
		controls: [
			standardNumber: 1
			batchCode: "CMPD-12345678-01"
			concentration: 10
			concentrationUnits: "uM"
			controlType: "PC"
		,
			batchCode: "CMPD-87654321-01"
			concentration: 1
			concentrationUnits: "uM"
			controlType: "NC"
		,
			batchCode: "CMPD-00000001-01"
			concentration: null
			concentrationUnits: null
			controlType: "VC"
		]
		agonist:
			batchCode: "CMPD-87654399-01"
		instrumentReader: "flipr"
		signalDirectionRule: "increasing"
		aggregateBy: "compound batch concentration"
		aggregationMethod: "median"
		normalization:
			normalizationRule: "plate order only"
			positiveControl:
				standardNumber: 1
				defaultValue: ""
			negativeControl:
				standardNumber: ""
				defaultValue: 5
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
		fluorescentStart: -5
		fluorescentEnd: 10
		fluorescentStep: 50
		latePeakTime: 80
		primaryAnalysisReadList: exports.primaryAnalysisReads
		transformationRuleList: exports.transformationRules

) (if (typeof process is "undefined" or not process.versions) then window.primaryScreenTestJSON = window.primaryScreenTestJSON or {} else exports)


