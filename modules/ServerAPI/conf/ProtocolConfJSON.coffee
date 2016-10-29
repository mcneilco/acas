((exports) ->
	exports.typeKindList =
		protocoltypes:
			[
				typeName: "Biology"
			,
				typeName: "default"
			]

		protocolkinds:
			[
				typeName: "Biology"
				kindName: "Bio Activity"
			,
				typeName: "default"
				kindName: "default"
			]

		statetypes:
			[
				typeName: "metadata"
			]

		statekinds:
			[
				typeName: "metadata"
				kindName: "protocol metadata"
			,
				typeName: "metadata"
				kindName: "screening assay"
			,
				typeName: "metadata"
				kindName: "experiment metadata"
			]

		valuetypes:
			[
				typeName: "dateValue"
			,
				typeName: "codeValue"
			,
				typeName: "stringValue"
			,
				typeName: "clobValue"
			,
				typeName: "fileValue"
			,
				typeName: "numericValue"
			]

		valuekinds:
			[
				typeName: "dateValue"
				kindName: "creation date"
			,
				typeName: "codeValue"
				kindName: "protocol status"
			,
				typeName: "codeValue"
				kindName: "review status"
			,
				typeName: "clobValue"
				kindName: "materials"
			,
				typeName: "clobValue"
				kindName: "equipment"
			,
				typeName: "clobValue"
				kindName: "methods"
			,
				typeName: "clobValue"
				kindName: "comments"
			,
				typeName: "stringValue"
				kindName: "notebook"
			,
				typeName: "clobValue"
				kindName: "protocol details"
			,
				typeName: "clobValue"
				kindName: "assay principle"
			,
				typeName: "fileValue"
				kindName: "file"
			,
				typeName: "codeValue"
				kindName: "scientist"
			,
				typeName: "stringValue"
				kindName: "etl origin"
			,
				typeName: "stringValue"
				kindName: "assay tree rule"
			,
				typeName: "codeValue"
				kindName: "assay stage"
			,
				typeName: "codeValue"
				kindName: "assay activity"
			,
				typeName: "codeValue"
				kindName: "molecular target"
			,
				typeName: "stringValue"
				kindName: "clone name"
			,
				typeName: "codeValue"
				kindName: "assay type"
			,
				typeName: "codeValue"
				kindName: "assay technology"
			,
				typeName: "codeValue"
				kindName: "cell line"
			,
				typeName: "codeValue"
				kindName: "target origin"
			,
				typeName: "numericValue"
				kindName: "curve display min"
			,
				typeName: "numericValue"
				kindName: "curve display max"
			,
				typeName: "clobValue"
				kindName: "data analysis parameters"
			,
				typeName: "clobValue"
				kindName: "model fit parameters"
			,
				typeName: "codeValue"
				kindName: "model fit type"
			,
				typeName: "stringValue"
				kindName: "model fit transformation"
			,
				typeName: "codeValue"
				kindName: "model fit transformation units"
			]

		labeltypes:
			[
				typeName: "name"
			]

		labelkinds:
			[
				typeName: "name"
				kindName: "protocol name"
			]

		ddicttypes:
			[
				typeName: "protocol"
			,
				typeName: "assay"
			,
				typeName: "reagent"
			,
				typeName: "target"
			,
				typeName: "equipment"
			,
				typeName: "reader data"
			,
				typeName: "analysis parameter"
			,
				typeName: "protocol metadata"

			]

		ddictkinds:
			[
				typeName: "protocol"
				kindName: "status"
			,
				typeName: "protocol"
				kindName: "review status"
			,
				typeName: "assay"
				kindName: "scientist"
			,
				typeName: "assay"
				kindName: "stage"
			,
				typeName: "assay"
				kindName: "activity"
			,
				typeName: "assay"
				kindName: "molecular target"
			,
				typeName: "assay"
				kindName: "type"
			,
				typeName: "assay"
				kindName: "technology"
			,
				typeName: "reagent"
				kindName: "cell line"
			,
				typeName: "target"
				kindName: "origin"
			,
				typeName: "equipment"
				kindName: "instrument reader"
			,
				typeName: "reader data"
				kindName: "read name"
			,
				typeName: "analysis parameter"
				kindName: "signal direction"
			,
				typeName: "analysis parameter"
				kindName: "aggregate by"
			,
				typeName: "analysis parameter"
				kindName: "aggregation method"
			,
				typeName: "analysis parameter"
				kindName: "normalization method"
			,
				typeName: "analysis parameter"
				kindName: "transformation"
			,
				typeName: "protocol metadata"
				kindName: "file type"
			,
				typeName: "model fit"
				kindName: "type"
			,
				typeName: "model fit"
				kindName: "transformation units"
			]

		codetables:
			[
				codeType: "protocol"
				codeKind: "status"
				codeOrigin: "ACAS DDICT"
				code: "created"
				name: "Created"
				ignored: false
			,
				codeType: "protocol"
				codeKind: "status"
				codeOrigin: "ACAS DDICT"
				code: "in process"
				name: "In Process"
				ignored: false
			,
				codeType: "protocol"
				codeKind: "status"
				codeOrigin: "ACAS DDICT"
				code: "complete"
				name: "Complete"
				ignored: false
			,
				codeType: "protocol"
				codeKind: "status"
				codeOrigin: "ACAS DDICT"
				code: "approved"
				name: "Approved"
				ignored: false
			,
				codeType: "protocol"
				codeKind: "status"
				codeOrigin: "ACAS DDICT"
				code: "rejected"
				name: "Rejected"
				ignored: false
			,
				codeType: "protocol"
				codeKind: "status"
				codeOrigin: "ACAS DDICT"
				code: "deleted"
				name: "Deleted"
				ignored: false
			,
				codeType: "protocol"
				codeKind: "review status"
				codeOrigin: "ACAS DDICT"
				code: "in progress"
				name: "In Progress"
				ignored: false
			,
				codeType: "protocol"
				codeKind: "review status"
				codeOrigin: "ACAS DDICT"
				code: "ready for review"
				name: "Ready for Review"
				ignored: false
			,
				codeType: "protocol"
				codeKind: "review status"
				codeOrigin: "ACAS DDICT"
				code: "reviewed"
				name: "Reviewed"
				ignored: false
			,
				codeType: "assay"
				codeKind: "stage"
				codeOrigin: "ACAS DDICT"
				code: "assay development"
				name: "Assay Development"
				ignored: false
			,
				codeType: "assay"
				codeKind: "stage"
				codeOrigin: "ACAS DDICT"
				code: "production"
				name: "Production"
				ignored: false
			,
				codeType: "assay"
				codeKind: "activity"
				codeOrigin: "ACAS DDICT"
				code: "atp levels"
				name: "ATP levels"
				ignored: false
			,
				codeType: "assay"
				codeKind: "molecular target"
				codeOrigin: "ACAS DDICT"
				code: "kop"
				name: "KOP"
				ignored: false
			,
				codeType: "assay"
				codeKind: "type"
				codeOrigin: "ACAS DDICT"
				code: "biochemical"
				name: "Biochemical"
				ignored: false
			,
				codeType: "assay"
				codeKind: "technology"
				codeOrigin: "ACAS DDICT"
				code: "promega mao-glo"
				name: "Promega MAO-Glo"
				ignored: false
			,
				codeType: "reagent"
				codeKind: "cell line"
				codeOrigin: "ACAS DDICT"
				code: "hek293"
				name: "HEK293"
				ignored: false
			,
				codeType: "target"
				codeKind: "origin"
				codeOrigin: "ACAS DDICT"
				code: "bovine"
				name: "Bovine"
				ignored: false
			,
				codeType: "equipment"
				codeKind: "instrument reader"
				codeOrigin: "ACAS DDICT"
				code: "flipr"
				name: "FLIPR"
				ignored: false
			,
				codeType: "equipment"
				codeKind: "instrument reader"
				codeOrigin: "ACAS DDICT"
				code: "generic plate"
				name: "Generic Plate"
				ignored: false
			,
				codeType: "reader data"
				codeKind: "read name"
				codeOrigin: "ACAS DDICT"
				code: "luminescence"
				name: "Luminescence"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "signal direction"
				codeOrigin: "ACAS DDICT"
				code: "increasing"
				name: "Increasing Signal (highest = 100%)"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "aggregate by"
				codeOrigin: "ACAS DDICT"
				code: "assay plate"
				name: "Assay Plate"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "aggregation method"
				codeOrigin: "ACAS DDICT"
				code: "mean"
				name: "Mean"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "normalization method"
				codeOrigin: "ACAS DDICT"
				code: "plate order only"
				name: "Plate Order Only"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "normalization method"
				codeOrigin: "ACAS DDICT"
				code: "none"
				name: "None"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "transformation"
				codeOrigin: "ACAS DDICT"
				code: "sd"
				name: "SD"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "transformation"
				codeOrigin: "ACAS DDICT"
				code: "percent efficacy"
				name: "% efficacy"
				ignored: false
			,
				codeType: "protocol metadata"
				codeKind: "file type"
				codeOrigin: "ACAS DDICT"
				code: "reference file"
				name: "Reference File"
				ignored: false
			,
				codeType: "model fit"
				codeKind: "type"
				codeOrigin: "ACAS DDICT"
				code: "4 parameter D-R"
				name: "EC50"
				ignored: false
			,
				codeType: "model fit"
				codeKind: "transformation units"
				codeOrigin: "ACAS DDICT"
				code: "none"
				name: "None"
				ignored: false
			,
				codeType: "model fit"
				codeKind: "transformation units"
				codeOrigin: "ACAS DDICT"
				code: "%"
				name: "%"
				ignored: false
			]

		labelsequences:
			[
				digits: 8
				groupDigits: false
				labelPrefix: "PROT"
				labelSeparator: "-"
				labelTypeAndKind: "id_codeName"
				thingTypeAndKind: "document_protocol"
				latestNumber:0
			]

) (if (typeof process is "undefined" or not process.versions) then window.protocolConfJSON = window.protocolConfJSON or {} else exports)
