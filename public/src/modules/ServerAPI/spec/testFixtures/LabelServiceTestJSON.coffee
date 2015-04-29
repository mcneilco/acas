((exports) ->

	exports.nextLabelSequenceRequest =
		labelTypeAndKind:"id_codeName"
		thingTypeAndKind:"document_experiment"
		numberOfLabels: 1

	exports.nextLabelSequenceResponse =
		digits:8
		groupDigits:false
		id:2,
		ignored:false
		labelPrefix:"EXPT"
		labelSeparator:"-"
		labelTypeAndKind:"id_codeName"
		latestNumber:1
		modifiedDate:1430326747601
		thingTypeAndKind:"document_experiment"
		version:635

) (if (typeof process is "undefined" or not process.versions) then window.labelServiceTestJSON = window.labelServiceTestJSON or {} else exports)
