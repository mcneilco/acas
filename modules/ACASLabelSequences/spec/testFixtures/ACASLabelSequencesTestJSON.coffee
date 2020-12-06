((exports) ->
	exports.labelSequence =
		dbSequence: "labelseq_PROJ_id_codeName_project_project"
		digits: 8
		groupDigits: false
		id: 10
		ignored: false
		labelPrefix: "PROJ"
		labelSeparator: "-"
		labelSequenceRoles: [
				id: 1
				roleEntry:
					id: 2
					lsKind: "ACAS"
					lsType: "System"
					lsTypeAndKind: "System_ACAS"
					roleDescription: "ROLE_ACAS-ADMINS autocreated by ACAS"
					roleName: "ROLE_ACAS-ADMINS"
					version: 0
				version: 0

		]
		labelTypeAndKind: "id_codeName"
		startingNumber: 0
		thingTypeAndKind: "project_project"
		version: 0

	exports.labelSequenceArray = [
			dbSequence: "labelseq_PROJ_id_codeName_project_project"
			digits: 8
			groupDigits: false
			id: 10
			ignored: false
			labelPrefix: "PROJ"
			labelSeparator: "-"
			labelSequenceRoles: [
					id: 1
					roleEntry:
						id: 2
						lsKind: "ACAS"
						lsType: "System"
						lsTypeAndKind: "System_ACAS"
						roleDescription: "ROLE_ACAS-ADMINS autocreated by ACAS"
						roleName: "ROLE_ACAS-ADMINS"
						version: 0
					version: 0
			]
			labelTypeAndKind: "id_codeName"
			startingNumber: 0
			thingTypeAndKind: "project_project"
			version: 0
		,
			dbSequence: "labelseq_PROT_id_codeName_document_protocol"
			digits: 8
			groupDigits: false
			id: 11
			ignored: false
			labelPrefix: "PROT"
			labelSeparator: "-"
			labelSequenceRoles: []
			labelTypeAndKind: "id_codeName"
			startingNumber: 0
			thingTypeAndKind: "document_protocol"
			version: 0
	]

) (if (typeof process is "undefined" or not process.versions) then window.labelSequenceTestJSON = window.labelSequenceTestJSON or {} else exports)
