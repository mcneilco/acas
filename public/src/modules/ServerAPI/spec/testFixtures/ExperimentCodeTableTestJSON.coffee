((exports) ->
	exports.dataDictValues =
		[
			type: "experiment metadata"
			kind: "experiment status"
			codes:
				[
					code: "created"
					name: "Created"
					ignored: false
				,
					code: "started"
					name: "Started"
					ignored: false
				,
					code: "complete"
					name: "Complete"
					ignored: false
				,
					code: "finalized"
					name: "Finalized"
					ignored: false
				,
					code: "rejected"
					name: "Rejected"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.experimentCodeTableTestJSON = window.experimentCodeTableTestJSON or {} else exports)
