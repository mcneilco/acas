((exports) ->
	exports.experimenttypes =
		[
			typeName: "Biology"
		,
			typeName: "default"
		]

	exports.experimentkind =
		[
			typeName: "Biology"
			kindName: "Bio Activity"
		,
			typeName: "default"
			kindName: "default"
		]

	exports.statetypes =
		[
			typeName: "metadata"
		]

	exports.statekinds =
		[
			typeName: "metadata"
			kindName: "experiment metadata"
		,
			typeName: "metadata"
			kindName: "raw results locations"
		,
			typeName: "metadata"
			kindName: "report locations"
		]

	exports.valuetypes =
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
		]

	exports.valuekinds =
		[
			typeName: "codeValue"
			kindName: "project"
		,
			typeName: "codeValue"
			kindName: "scientist"
		,
			typeName: "dateValue"
			kindName: "completion date"
		,
			typeName: "stringValue"
			kindName: "notebook"
		,
			typeName: "clobValue"
			kindName: "experiment details"
		,
			typeName: "clobValue"
			kindName: "comments"
		,
			typeName: "codeValue"
			kindName: "experiment status"
		,
			typeName: "codeValue"
			kindName: "analysis status"
		,
			typeName: "codeValue"
			kindName: "model fit status"
		,
			typeName: "codeValue"
			kindName: "dry run status"
		,
			typeName: "clobValue"
			kindName: "analysis result html"
		,
			typeName: "clobValue"
			kindName: "model fit result html"
		,
			typeName: "clobValue"
			kindName: "dry run result html"
		,
			typeName: "fileValue"
			kindName: "reference file"
		,
			typeName: "clobValue"
			kindName: "data analysis parameters"
		,
			typeName: "clobValue"
			kindName: "model fit parameters"
		,
			typeName: "stringValue"
			kindName: "hts format"
		,
			typeName: "fileValue"
			kindName: "experiment file"
		,
			typeName: "inlineFileValue"
			kindName: "image file"
		,
			typeName: "fileValue"
			kindName: "report file"
		]

	exports.labeltypes =
		[
			typeName: "name"
		]

	exports.labelkinds =
		[
			typeName: "name"
			kindName: "experiment name"
		]

	exports.ddicttypes =
		[
			typeName: "project"
		,
			typeName: "experiment"
		,
			typeName: "analysis"
		,
			typeName: "model fit"
		,
			typeName: "dry run "
		,
			typeName: "equipment"
		,
			typeName: "reader data"
		,
			typeName: "analysis parameter"
		,
			typeName: "experiment metadata"
		]

	exports.ddictkinds =
		[
			typeName: "project"
			kindName: "biology"
		,
			typeName: "experiment"
			kindName: "status"
		,
			typeName: "analysis"
			kindName: "status"
		,
			typeName: "model fit"
			kindName: "status"
		,
			typeName: "dry run"
			kindName: "status"
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
			typeName: "experiment metadata"
			kindName: "file type"
		,
			typeName: "model fit"
			kindName: "type"
		]

	exports.ddictvalues =
		[
			codeType: "project"
			codeKind: "biology"
			codeOrigin: "ACAS DDICT"
			code: "project 1"
			name: "Project 1"
			ignored: false
		,
			codeType: "experiment"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "created"
			name: "Created"
			ignored: false
		,
			codeType: "experiment"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "in process"
			name: "In Process"
			ignored: false
		,
			codeType: "experiment"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "complete"
			name: "Complete"
			ignored: false
		,
			codeType: "experiment"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "approved"
			name: "Approved"
			ignored: false
		,
			codeType: "experiment"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "rejected"
			name: "Rejected"
			ignored: false
		,
			codeType: "analysis"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "not started"
			name: "Not Started"
			ignored: false
		,
			codeType: "analysis"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "running"
			name: "Running"
			ignored: false
		,
			codeType: "analysis"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "complete"
			name: "Complete"
			ignored: false
		,
			codeType: "analysis"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "failed"
			name: "Failed"
			ignored: false
		,
			codeType: "model fit"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "not started"
			name: "Not Started"
			ignored: false
		,
			codeType: "model fit"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "running"
			name: "Running"
			ignored: false
		,
			codeType: "model fit"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "complete"
			name: "Complete"
			ignored: false
		,
			codeType: "dry run"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "not started"
			name: "Not Started"
			ignored: false
		,
			codeType: "dry run"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "running"
			name: "Running"
			ignored: false
		,
			codeType: "dry run"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "complete"
			name: "Complete"
			ignored: false
		,
			codeType: "dry run"
			codeKind: "status"
			codeOrigin: "ACAS DDICT"
			code: "failed"
			name: "Failed"
			ignored: false
		,
			codeType: "equipment"
			codeKind: "instrument reader"
			codeOrigin: "ACAS DDICT"
			code: "flipr"
			name: "FLIPR"
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
			codeKind: "transformation"
			codeOrigin: "ACAS DDICT"
			code: "sd"
			name: "SD"
			ignored: false
		,
			codeType: "experiment metadata"
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
		]

	exports.labelsequences =
		[
			digits: 8
			groupDigits: false
			labelPrefix: "EXPT"
			labelSeparator: "-"
			labelTypeAndKind: "id_codeName"
			thingTypeAndKind: "document_experiment"
		]
) (if (typeof process is "undefined" or not process.versions) then window.experimentConfJSON = window.experimentConfJSON or {} else exports)
