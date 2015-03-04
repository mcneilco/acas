((exports) ->
	exports.typeKindList =
		protocoltypes:
			[
				typeName: "default"
			]

		protocolkinds:
			[
				typeName: "default"
				kindName: "default"
			,
				typeName: "default"
				kindName: "flipr screening assay"
			]

		experimenttypes:
			[
				typeName: "default"
			]

		experimentkinds:
			[
				typeName: "default"
				kindName: "default"
			]

		interactiontypes:
			[
				typeName: "added to"
				typeVerb: "first added to second"
			,
				typeName: "removed from"
				typeVerb: "first removed from second"
			,
				typeName: "operated on"
				typeVerb: "first operated on second"
			,
				typeName: "created by"
				typeVerb: "first created by second"
			,
				typeName: "destroyed by"
				typeVerb: "first destroyed by second"
			,
				typeName: "refers to"
				typeVerb: "first refers to second"
			,
				typeName: "has member"
				typeVerb: "first has second as a member"
			,
				typeName: "moved to"
				typeVerb: "first was moved to second"
			,
				typeName: "transferred to"
				typeVerb: "contents of first were transferred to second"
			]

		interactionKinds:
			[
				kindName: "test subject"
				typeName: "first refers to second"
			,
				kindName: "plate well"
				typeName: "first has second as a member"
			]

		containertypes:
			[
				typeName: "material"
			,
				typeName: "plate"
			,
				typeName: "well"
			]

		containerkinds:
			[
				kindName: "animal"
				typeName: "material"
			,
				kindName: "384 well compound plate"
				typeName: "plate"
			,
				kindName: "plate well"
				typeName: "well"
			]
		statetypes:
			[
				typeName: "metadata"
			,
				typeName: "data"
			,
				typeName: "constants"
			,
				typeName: "status"
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
				kindName: "animal information"
			,
				typeName: "metadata"
				kindName: "protocol metadata"
			,
				typeName: "metadata"
				kindName: "plate information"
			,
				typeName: "metadata"
				kindName: "subject metadata"
			,
				typeName: "data"
				kindName: "dose response"
			,
				typeName: "data"
				kindName: "results"
			,
				typeName: "data"
				kindName:	"test compound treatment"
			,
				typeName: "data"
				kindName: "treatment"
			,
				typeName: "data"
				kindName: "raw data"
			,
				typeName: "data"
				kindName: "calculated data"
			,
				typeName: "data"
				kindName: "transfer data"
			,
				typeName: "data"
				kindName: "auto flag"
			,
				typeName: "data"
				kindName: "user flag"
			,
				typeName: "constants"
				kindName: "plate format"
			,
				typeName: "status"
				kindName: "test compound content"
			,
				typeName: "status"
				kindName: "solvent content"
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
				typeName: "urlValue"
			,
				typeName: "blobValue"
			,
				typeName: "inlineFileValue"
			,
				typeName: "numericValue"
			]

		valuekinds:
			[
				kindName: "batch code"
				typeName: "codeValue"
			,
				kindName: "tested concentration"
				typeName: "numericValue"
			,
				kindName: "source file"
				typeName: "fileValue"
			,
				kindName: "notebook"
				typeName: "stringValue"
			,
				kindName: "notebook page"
				typeName: "stringValue"
			,
				kindName: "completion date"
				typeName: "dateValue"
			,
				kindName: "scientist"
				typeName: "stringValue"
			,
				kindName: "status"
				typeName: "stringValue"
			,
				kindName: "analysis status"
				typeName: "stringValue"
			,
				kindName: "analysis result html"
				typeName: "clobValue"
			,
				kindName: "project"
				typeName: "codeValue"
			,
				kindName: "time"
				typeName: "numericValue"
			,
				kindName: "Rendering Hint"
				typeName: "stringValue"
			,
				kindName: "curve id"
				typeName: "stringValue"
			,
				kindName: "Dose"
				typeName: "numericValue"
			,
				kindName: "Response"
				typeName: "numericValue"
			,
				kindName: "flag"
				typeName: "stringValue"
			,
				kindName: "annotation file"
				typeName: "fileValue"
			,
				kindName: "rows"
				typeName: "numericValue"
			,
				kindName: "columns"
				typeName: "numericValue"
			,
				kindName: "wells"
				typeName: "numericValue"
			,
				kindName: "concentration"
				typeName: "numericValue"
			,
				kindName: "volume"
				typeName: "numericValue"
			,
				kindName: "date prepared"
				typeName: "dateValue"
			,
				kindName: "report file"
				typeName: "fileValue"
			,
				kindName: "target"
				typeName: "stringValue"
			,
				kindName: "assay format"
				typeName: "stringValue"
			,
				kindName: "experiment status"
				typeName: "stringValue"
			,
				kindName: "control type"
				typeName: "stringValue"
			,
				kindName: "reader instrument"
				typeName: "stringValue"
			,
				kindName: "data source"
				typeName: "stringValue"
			,
				kindName: "data transformation rule"
				typeName: "stringValue"
			,
				kindName: "normalization rule"
				typeName: "stringValue"
			,
				kindName: "active efficacy threshold"
				typeName: "numericValue"
			,
				kindName: "active SD threshold"
				typeName: "numericValue"
			,
				kindName: "curve min"
				typeName: "numericValue"
			,
				kindName: "curve max"
				typeName: "numericValue"
			,
				kindName: "replicate aggregation"
				typeName: "stringValue"
			,
				kindName: "barcode"
				typeName: "codeValue"
			,
				kindName: "seq file"
				typeName: "fileValue"
			,
				kindName: "min file"
				typeName: "fileValue"
			,
				kindName: "max file"
				typeName: "fileValue"
			,
				kindName: "raw r results location"
				typeName: "fileValue"
			,
				kindName: "data results location"
				typeName: "fileValue"
			,
				kindName: "summary location"
				typeName: "fileValue"
			,
				kindName: "well type"
				typeName: "stringValue"
			,
				kindName: "well name"
				typeName: "stringValue"
			,
				kindName: "maximum"
				typeName: "numericValue"
			,
				kindName: "minimum"
				typeName: "numericValue"
			,
				kindName: "fluorescent"
				typeName: "stringValue"
			,
				kindName: "transformed efficacy"
				typeName: "numericValue"
			,
				kindName: "normalized efficacy"
				typeName: "numericValue"
			,
				kindName: "over efficacy threshold"
				typeName: "stringValue"
			,
				kindName: "fluorescencePoints"
				typeName: "clobValue"
			,
				kindName: "timePoints"
				typeName: "clobValue"
			,
				kindName: "data analysis parameters"
				typeName: "clobValue"
			,
				kindName: "description"
				typeName: "clobValue"
			,
				kindName: "comparison graph"
				typeName:"inlineFileValue"
			,
				kindName: "previous experiment code"
				typeName: "codeValue"
			,
				kindName: "late peak"
				typeName: "stringValue"
			,
				kindName: "max time"
				typeName: "numericValue"
			,
				kindName: "has agonist"
				typeName: "stringValue"
			,
				kindName: "dryrun source file"
				typeName: "fileValue"
			,
				kindName: "hts format"
				typeName:"stringValue"

			]

		labeltypes:
			[
				typeName: "name"
			,
				typeName: "barcode"
			]

		labelkinds:
			[
				typeName: "name"
				kindName: "experiment name"
			,
				typeName: "name"
				kindName: "protocol name"
			,
				typeName: "name"
				kindName: "container name"
			,
				typeName: "name"
				kindName: "well name"
			,
				typeName: "barcode"
				kindName: "plate barcode"
			]

		operatortypes:
			[
				typeName: "comparison"
			,
				typeName: "mathematical"
			,
				typeName: "boolean"
			]
	
		operatorkinds:
			[
				typeName: "comparison"
				kindName: ">"
			,
				typeName: "comparison"
				kindName: "<"
			,
				typeName: "comparison"
				kindName: "<="
			,
				typeName: "comparison"
				kindName: ">="
			,
				typeName: "comparison"
				kindName: "="
			]

		unittypes:
			[
				typeName: "PK"
			,
				typeName: "time"
			,
				typeName: "frequency"
			,
				typeName: "concentration"
			,
				typeName: "mass"
			,
				typeName: "specific volume"
			,
				typeName: "percentage"
			,
				typeName: "volume"
			,
				typeName: "length"
			,
				typeName: "density"
			,
				typeName: "pressure"
			,
				typeName: "energy"
			,
				typeName: "power"
			]
		
		unitkinds:
			[
				typeName: "frequency"
				kindName: "1/hr"
			,
				typeName: "time"
				kindName: "hr"
			,
				typeName: "concentration"
				kindName: "ng/mL"
			,
				typeName: "PK"
				kindName: "kg*ng/mL/mg"
			,
				typeName: "PK"
				kindName: "hr*ng/mL"
			,
				typeName: "percentage"
				kindName: "%"
			,
				typeName: "PK"
				kindName: "hr*hr*ng/mL"
			,
				typeName: "specific volume"
				kindName: "L/kg"
			,
				typeName: "PK"
				kindName: "mL/min/kg"
			,
				typeName: "concentration"
				kindName: "mg/kg"
			,
				typeName: "mass"
				kindName: "g"
			,
				typeName: "time"
				kindName: "min"
			,
				typeName: "percentage"
				kindName: "% Freezing"
			]

		labelsequences:
			[
				"digits":8
				"groupDigits":false
				"labelPrefix":"PROT"
				"labelSeparator":"-"
				"labelTypeAndKind":"id_codeName"
				"latestNumber":1
				"thingTypeAndKind":"document_protocol"
			,
				"digits":8
				"groupDigits":false
				"labelPrefix":"EXPT"
				"labelSeparator":"-"
				"labelTypeAndKind":"id_codeName"
				"latestNumber":1
				"thingTypeAndKind":"document_experiment"
			,
				"digits":8
				"groupDigits":false
				"labelPrefix":"AG"
				"labelSeparator":"-"
				"labelTypeAndKind":"id_codeName"
				"latestNumber":1
				"thingTypeAndKind":"document_analysis group"
			,
				"digits":8
				"groupDigits":false
				"labelPrefix":"TG"
				"labelSeparator":"-"
				"labelTypeAndKind":"id_codeName"
				"latestNumber":1
				"thingTypeAndKind":"document_treatment group"
			,
				"digits":8
				"groupDigits":false
				"labelPrefix":"SUBJ"
				"labelSeparator":"-"
				"labelTypeAndKind":"id_codeName"
				"latestNumber":1
				"thingTypeAndKind":"document_subject"
			,
				"digits":8
				"groupDigits":false
				"labelPrefix":"CONT"
				"labelSeparator":"-"
				"labelTypeAndKind":"id_codeName"
				"latestNumber":1
				"thingTypeAndKind":"material_container"
			,
				"digits":8
				"groupDigits":false
				"labelPrefix":"CITX"
				"labelSeparator":"-"
				"labelTypeAndKind":"id_codeName"
				"latestNumber":1
				"thingTypeAndKind":"interaction_containerContainer"
			,
				"digits":8
				"groupDigits":false
				"labelPrefix":"SITX"
				"labelSeparator":"-"
				"labelTypeAndKind":"id_codeName"
				"latestNumber":1
				"thingTypeAndKind":"interaction_subjectContainer"
			]

) (if (typeof process is "undefined" or not process.versions) then window.genericDataParserConfJSON = window.genericDataParserConfJSON or {} else exports)
