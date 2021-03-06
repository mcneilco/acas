((exports) ->
	exports.codetableValues =
		[
			type: "experiment"
			kind: "status"
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
					code: "approved"
					name: "Approved"
					ignored: false
				,
					code: "rejected"
					name: "Rejected"
					ignored: false
				]
		,
			type: "experiment metadata"
			kind: "file type"
			codes:
				[
					code: "reference file"
					name: "Reference File"
					ignored: false
				,
					code: "experiment file"
					name: "Experiment File"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.experimentCodeTableTestJSON = window.experimentCodeTableTestJSON or {} else exports)
