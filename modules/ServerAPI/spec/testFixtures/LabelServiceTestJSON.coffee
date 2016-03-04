((exports) ->

	exports.nextLabelSequenceRequest =
		labelTypeAndKind:"id_codeName"
		thingTypeAndKind:"document_experiment"
		numberOfLabels: 1

	exports.nextLabelSequenceResponse = [
		autoLabel: "EXPT-00000001"
	]

) (if (typeof process is "undefined" or not process.versions) then window.labelServiceTestJSON = window.labelServiceTestJSON or {} else exports)
