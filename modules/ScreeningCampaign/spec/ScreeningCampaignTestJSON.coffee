((exports) ->
	exports.transformationRules = [
		transformationRule: "percent efficacy"
		transformationParameters:
			positiveControl:
				standardNumber: "1"
				defaultValue: ""
			negativeControl:
				standardNumber: "input value"
				defaultValue: 5
	,
		transformationRule: "sd"
		transformationParameters:
			positiveControl:
				standardNumber: "3"
				defaultValue: ""
			negativeControl:
				standardNumber: "2"
				defaultValue: ""
	,
		transformationRule: "null"
		transformationParameters: {}
	]

	exports.standards = [
		standardNumber: 1
		batchCode: "CMPD-12345678-01"
		concentration: 10
		concentrationUnits: "uM"
		standardType: "PC"
	,
		standardNumber: 2
		batchCode: "CMPD-87654321-01"
		concentration: 1
		concentrationUnits: "uM"
		standardType: "NC"
	,
		standardNumber: 3
		batchCode: "CMPD-00000001-01"
		concentration: 0
		concentrationUnits: "uM"
		standardType: "VC"
	]

	exports.screeningCampaignAnalysisParameters =
		standardCompoundList: exports.standards
		signalDirectionRule: "increasing"
		aggregateBy: "compound batch concentration"
		aggregationMethod: "median"
		normalization:
			normalizationRule: "plate order only"
			positiveControl:
				standardNumber: "1"
				defaultValue: ""
			negativeControl:
				standardNumber: "input value"
				defaultValue: 23
		hitEfficacyThreshold: 42
		hitSDThreshold: 5.0
		thresholdType: "sd" #or "efficacy"
		useOriginalHits: false
		autoHitSelection: false
		transformationRuleList: exports.transformationRules

) (if (typeof process is "undefined" or not process.versions) then window.screeningCampaignTestJSON = window.screeningCampaignTestJSON or {} else exports)


