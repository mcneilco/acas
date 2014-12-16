((exports) ->
	exports.codetableValues =
		[
			type: "protocol"
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
					code: "finalized"
					name: "Finalized"
					ignored: false
				,
					code: "rejected"
					name: "Rejected"
					ignored: false
				]
		,
			type: "assay"
			kind: "stage"
			codes:
				[
					code: "assay development"
					name: "Assay Development"
					ignored: false
				]
		]
) (if (typeof process is "undefined" or not process.versions) then window.protocolCodeTableTestJSON = window.protocolCodeTableTestJSON or {} else exports)
