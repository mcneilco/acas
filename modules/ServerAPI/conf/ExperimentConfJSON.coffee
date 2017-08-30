((exports) ->
	exports.typeKindList =
		experimenttypes:
			[
				typeName: "Biology"
			,
				typeName: "default"
			]

		experimentkinds:
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
				kindName: "experiment metadata"
			,
				typeName: "metadata"
				kindName: "raw results locations"
			,
				typeName: "metadata"
				kindName: "report locations"
			,
				typeName: "metadata"
				kindName: "custom experiment metadata"
			,
				typeName: "metadata"
				kindName: "custom experiment metadata gui"
			,
				typeName: "metadata"
				kindName: "data column order"
			,
				typeName: "metadata"
				kindName: "data column object"
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
			]

		valuekinds:
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
				typeName: "stringValue"
				kindName: "notebook page"
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
				typeName: "fileValue"
				kindName: "source file"
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
			,
				typeName: "fileValue"
				kindName: "annotation file"
			,
				typeName: "codeValue"
				kindName: "model fit type"
			,
				typeName: "clobValue"
				kindName: "GUI descriptor"
			,
				typeName: "numericValue"
				kindName: "column order"
			,
				typeName: "stringValue"
				kindName: "column name"
			,
				typeName: "stringValue"
				kindName: "column units"
			,
				typeName: "stringValue"
				kindName: "column type"
			,
				typeName: "stringValue"
				kindName: "hide column"	
			,
				typeName: "numericValue"
				kindName: "column concentration"	
			,
				typeName: "stringValue"
				kindName: "column conc units"	
			,
				typeName: "numericValue"
				kindName: "column time"	
			,
				typeName: "stringValue"
				kindName: "column time units"	
			,
				typeName: "stringValue"
				kindName: "condition column"	
			,
				typeName: "codeValue"
				kindName: "agonist batch code"
			]

		labeltypes:
			[
				typeName: "name"
			]

		labelkinds:
			[
				typeName: "name"
				kindName: "experiment name"
			]

		ddicttypes:
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
			,
				typeName: "custom experiment metadata"
			]

		ddictkinds:
			[
				typeName: "project"
				kindName: "biology"
			,
				typeName: "experiment"
				kindName: "status"
			,
				typeName: "experiment"
				kindName: "review status"
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
				kindName: "standard type"
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
				typeName: "analysis parameter"
				kindName: "statistic"
			,
				typeName: "experiment metadata"
				kindName: "file type"
			,
				typeName: "model fit"
				kindName: "type"
			]

		codetables:
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
				codeType: "experiment"
				codeKind: "status"
				codeOrigin: "ACAS DDICT"
				code: "deleted"
				name: "Deleted"
				ignored: false
			,
				codeType: "experiment"
				codeKind: "review status"
				codeOrigin: "ACAS DDICT"
				code: "in progress"
				name: "In Progress"
				ignored: false
			,
				codeType: "experiment"
				codeKind: "review status"
				codeOrigin: "ACAS DDICT"
				code: "ready for review"
				name: "Ready for Review"
				ignored: false
			,
				codeType: "experiment"
				codeKind: "review status"
				codeOrigin: "ACAS DDICT"
				code: "read and understood"
				name: "Read and Understood"
				ignored: false
			,
				codeType: "experiment"
				codeKind: "review status"
				codeOrigin: "ACAS DDICT"
				code: "needs attention"
				name: "Needs Attention"
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
				codeType: "equipment"
				codeKind: "instrument reader"
				codeOrigin: "ACAS DDICT"
				code: "acumen"
				name: "Acumen"
				ignored: false
			,
				codeType: "equipment"
				codeKind: "instrument reader"
				codeOrigin: "ACAS DDICT"
				code: "arrayscan"
				name: "ArrayScan"
				ignored: false
			,
				codeType: "equipment"
				codeKind: "instrument reader"
				codeOrigin: "ACAS DDICT"
				code: "biacore"
				name: "Biacore"
				ignored: false
			,
				codeType: "equipment"
				codeKind: "instrument reader"
				codeOrigin: "ACAS DDICT"
				code: "envision"
				name: "EnVision"
				ignored: false
			,
				codeType: "equipment"
				codeKind: "instrument reader"
				codeOrigin: "ACAS DDICT"
				code: "lumilux"
				name: "LumiLux"
				ignored: false
			,
				codeType: "equipment"
				codeKind: "instrument reader"
				codeOrigin: "ACAS DDICT"
				code: "microbeta"
				name: "Microbeta"
				ignored: false
			,
				codeType: "equipment"
				codeKind: "instrument reader"
				codeOrigin: "ACAS DDICT"
				code: "quantstudio"
				name: "QuantStudio"
				ignored: false
			,
				codeType: "equipment"
				codeKind: "instrument reader"
				codeOrigin: "ACAS DDICT"
				code: "viewlux"
				name: "ViewLux"
				ignored: false
			,
				codeType: "reader data"
				codeKind: "read name"
				codeOrigin: "ACAS DDICT"
				code: "luminescence"
				name: "Luminescence"
				ignored: false
			,
				codeType: "reader data"
				codeKind: "read name"
				codeOrigin: "ACAS DDICT"
				code: "maximum"
				name: "Maximum"
				ignored: false
			,
				codeType: "reader data"
				codeKind: "read name"
				codeOrigin: "ACAS DDICT"
				code: "minimum"
				name: "Minimum"
				ignored: false
			,
				codeType: "reader data"
				codeKind: "read name"
				codeOrigin: "ACAS DDICT"
				code: "Calc: (R2-R1)/R1"
				name: "Calc: (R2-R1)/R1"
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
				codeKind: "aggregate by"
				codeOrigin: "ACAS DDICT"
				code: "cmpd batch conc"
				name: "Compound Batch Concentration"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "aggregate by"
				codeOrigin: "ACAS DDICT"
				code: "entire assay"
				name: "Across Entire Assay"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "aggregate by"
				codeOrigin: "ACAS DDICT"
				code: "cmpd plate"
				name: "Compound Plate"
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
				codeKind: "aggregate by"
				codeOrigin: "ACAS DDICT"
				code: "none"
				name: "No Aggregation"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "standard type"
				codeOrigin: "ACAS DDICT"
				code: "PC"
				name: "Positive Control"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "standard type"
				codeOrigin: "ACAS DDICT"
				code: "NC"
				name: "Negative Control"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "standard type"
				codeOrigin: "ACAS DDICT"
				code: "VC"
				name: "Vehicle Control"
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
				codeKind: "aggregation method"
				codeOrigin: "ACAS DDICT"
				code: "median"
				name: "Median"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "aggregation method"
				codeOrigin: "ACAS DDICT"
				code: "none"
				name: "No Aggregation"
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
				code: "plate order & section by 8"
				name: "Plate Order and Tip"
				ignored: true
			,
				codeType: "analysis parameter"
				codeKind: "normalization method"
				codeOrigin: "ACAS DDICT"
				code: "plate order and row"
				name: "Plate Order and Row"
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
				codeType: "analysis parameter"
				codeKind: "transformation"
				codeOrigin: "ACAS DDICT"
				code: "none"
				name: "None"
				ignored: false
			,
				codeType: "experiment metadata"
				codeKind: "file type"
				codeOrigin: "ACAS DDICT"
				code: "reference file"
				name: "Reference File"
				ignored: false
			,
				codeType: "experiment metadata"
				codeKind: "file type"
				codeOrigin: "ACAS DDICT"
				code: "source file"
				name: "Source File"
				ignored: false
			,
				codeType: "experiment metadata"
				codeKind: "file type"
				codeOrigin: "ACAS DDICT"
				code: "annotation file"
				name: "Report File"
				ignored: false
			,
				codeType: "model fit"
				codeKind: "type"
				codeOrigin: "ACAS DDICT"
				code: "4 parameter D-R"
				name: "EC50"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "statistic"
				codeOrigin: "ACAS DDICT"
				code: "max"
				name: "Max"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "statistic"
				codeOrigin: "ACAS DDICT"
				code: "min"
				name: "Min"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "statistic"
				codeOrigin: "ACAS DDICT"
				code: "mean"
				name: "Mean"
				ignored: false
			,
				codeType: "analysis parameter"
				codeKind: "statistic"
				codeOrigin: "ACAS DDICT"
				code: "median"
				name: "Median"
				ignored: false
			]

		labelsequences:
			[
				digits: 8
				groupDigits: false
				labelPrefix: "EXPT"
				labelSeparator: "-"
				labelTypeAndKind: "id_codeName"
				thingTypeAndKind: "document_experiment"
				latestNumber:0
			]

) (if (typeof process is "undefined" or not process.versions) then window.experimentConfJSON = window.experimentConfJSON or {} else exports)
