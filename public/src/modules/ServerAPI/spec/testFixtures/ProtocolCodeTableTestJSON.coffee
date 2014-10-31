((exports) ->
	exports.dataDictValues =
		[
			type: "protocol metadata"
			kind: "protocol status"
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
) (if (typeof process is "undefined" or not process.versions) then window.protocolCodeTableTestJSON = window.protocolCodeTableTestJSON or {} else exports)
