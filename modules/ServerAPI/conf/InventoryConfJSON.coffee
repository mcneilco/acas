((exports) ->
	exports.typeKindList =
		containertypes:
			[
				typeName: "definition container"
			,
				typeName: "location"
			,
				typeName: "container"
			,
				typeName: "well"
			]

		container:
			[
				typeName: "definition container"
				kindName: "plate"
			,
				typeName: "location"
				kindName: "default"
			,
				typeName: "container"
				kindName: "plate"
			,
				typeName: "well"
				kindName: "default"
			,
				typeName: "container"
				kindName: "tube"
			]

		statetypes:
			[
				typeName: "constants"
			,
				typeName: "metadata"
			,
				typeName: "status"
			]

		statekinds:
			[
				typeName: "constants"
				kindName: "format"
			,
				typeName: "metadata"
				kindName: "information"
			,
				typeName: "status"
				kindName: "content"
			,
				typeName: "status"
				kindName: "content"
			,
				typeName: "metadata"
				kindName: "screening inventory"
			]

		valuetypes:
			[
				typeName: "numericValue"
			,
				typeName: "codeValue"
			,
				typeName: "stringValue"
			,
				typeName: "dateValue"
			]

		valuekinds:
			[
				typeName: "numericValue"
				kindName: "wells"
			,
				typeName: "numericValue"
				kindName: "rows"
			,
				typeName: "numericValue"
				kindName: "columns"
			,
				typeName: "codeValue"
				kindName: "subcontainer naming convention"
			,
				typeName: "numericValue"
				kindName: "max well volume"
			,
				typeName: "stringValue"
				kindName: "description"
			,
				typeName: "codeValue"
				kindName: "created user"
			,
				typeName: "dateValue"
				kindName: "created date"
			,
				typeName: "codeValue"
				kindName: "status"
			,
				typeName: "codeValue"
				kindName: "supplier"
			,
				typeName: "codeValue"
				kindName: "type"
			,
				typeName: "dateValue"
				kindName: "registered date"
			,
				typeName: "numericValue"
				kindName: "tare weight"
			,
				typeName: "codeValue"
				kindName: "batch code"
			,
				typeName: "codeValue"
				kindName: "solvent code"
			,
				typeName: "codeValue"
				kindName: "physical state"
			,
				typeName: "numericValue"
				kindName: "amount"
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
				kindName: "model"
			,
				typeName: "name"
				kindName: "common"
			,
				typeName: "barcode"
				kindName: "barcode"
			,
				typeName: "name"
				kindName: "well name"
			]

		ddicttypes:
			[
				typeName: "status"
			]

		ddictkinds:
			[
				typeName: "status"
				kindName: "container"
			]

		codetables:
			[
#				codeType: "type"
#				codeKind: "container tube"
#				codeOrigin: "ACAS DDICT"
#				code: "1.4 ml matrix mini-tube"
#				name: "1.4 mL Matrix Mini-Tube"
#				ignored: false
#			,
				codeType: "type tube"
				codeKind: "container"
				codeOrigin: "ACAS DDICT"
				code: "empty vial"
				name: "Empty Vial"
				ignored: false
			,
				codeType: "type"
				codeKind: "container tube"
				codeOrigin: "ACAS DDICT"
				code: "master vial"
				name: "Master Vial"
				ignored: false
			,
				codeType: "type"
				codeKind: "container tube"
				codeOrigin: "ACAS DDICT"
				code: "solution vial"
				name: "Solution Vial"
				ignored: false
			,
				codeType: "type"
				codeKind: "container tube"
				codeOrigin: "ACAS DDICT"
				code: "powder vial"
				name: "Powder Vial"
				ignored: false
			,
				codeType: "type"
				codeKind: "container plate"
				codeOrigin: "ACAS DDICT"
				code: "hitpick master plate"
				name: "Hitpick Master Plate"
				ignored: false
			,
				codeType: "type"
				codeKind: "container plate"
				codeOrigin: "ACAS DDICT"
				code: "screen system plate"
				name: "Screen System Plate"
				ignored: false
			,
#				codeType: "type"
#				codeKind: "container plate"
#				codeOrigin: "ACAS DDICT"
#				code: "combinational plate"
#				name: "Combinational Plate"
#				ignored: false
#			,
#				codeType: "type"
#				codeKind: "container plate"
#				codeOrigin: "ACAS DDICT"
#				code: "solubility calibration"
#				name: "Solubility Calibration"
#				ignored: false
#			,
				codeType: "type"
				codeKind: "container tube"
				codeOrigin: "ACAS DDICT"
				code: "solubility sample"
				name: "Solubility Sample"
				ignored: false
			,
				codeType: "type"
				codeKind: "container plate"
				codeOrigin: "ACAS DDICT"
				code: "library"
				name: "Library"
				ignored: false
			,
				codeType: "type"
				codeKind: "container plate"
				codeOrigin: "ACAS DDICT"
				code: "sidecar"
				name: "Sidecar"
				ignored: false
			,
				codeType: "type"
				codeKind: "container plate"
				codeOrigin: "ACAS DDICT"
				code: "library master"
				name: "Library Master"
				ignored: false
			,
				codeType: "type"
				codeKind: "container plate"
				codeOrigin: "ACAS DDICT"
				code: "standards"
				name: "Standards"
				ignored: false
			,
				codeType: "type"
				codeKind: "container plate"
				codeOrigin: "ACAS DDICT"
				code: "hitpick"
				name: "Hitpick"
				ignored: false
			,
				codeType: "type"
				codeKind: "container plate"
				codeOrigin: "ACAS DDICT"
				code: "mixed"
				name: "Mixed"
				ignored: false
			,
				codeType: "type"
				codeKind: "container plate"
				codeOrigin: "ACAS DDICT"
				code: "reagent"
				name: "Reagent"
				ignored: false
			,
				codeType: "type"
				codeKind: "container plate"
				codeOrigin: "ACAS DDICT"
				code: "lead profiling"
				name: "Lead Profiling"
				ignored: false
			,
#				codeType: "status"
#				codeKind: "container plate"
#				codeOrigin: "ACAS DDICT"
#				code: "hitpick plate"
#				name: "Hitpick plate"
#				ignored: false
#			,
				codeType: "status"
				codeKind: "container"
				codeOrigin: "ACAS DDICT"
				code: "in progress"
				name: "In Progress"
				ignored: false
			,
				codeType: "status"
				codeKind: "container"
				codeOrigin: "ACAS DDICT"
				code: "active"
				name: "Active"
				ignored: false
			,
#				codeType: "status"
#				codeKind: "container"
#				codeOrigin: "ACAS DDICT"
#				code: "flagged"
#				name: "Flagged"
#				ignored: false
#			,
				codeType: "status"
				codeKind: "container"
				codeOrigin: "ACAS DDICT"
				code: "expired"
				name: "Expired"
				ignored: false
			,
#				codeType: "status"
#				codeKind: "container"
#				codeOrigin: "ACAS DDICT"
#				code: "rejected"
#				name: "Rejected"
#				ignored: false
#			,
				codeType: "status"
				codeKind: "container"
				codeOrigin: "ACAS DDICT"
				code: "created"
				name: "Created"
				ignored: false
			,
#				codeType: "status"
#				codeKind: "container"
#				codeOrigin: "ACAS DDICT"
#				code: "special set"
#				name: "Special Set"
#				ignored: false
#			,
#				codeType: "status"
#				codeKind: "container"
#				codeOrigin: "ACAS DDICT"
#				code: "inactive"
#				name: "Inactive"
#				ignored: false
#			,
				codeType: "status"
				codeKind: "container"
				codeOrigin: "ACAS DDICT"
				code: "checked-out"
				name: "Checked-out"
				ignored: false
			,
				codeType: "status"
				codeKind: "container"
				codeOrigin: "ACAS DDICT"
				code: "checked-in"
				name: "Checked-in"
				ignored: false
			]

) (if (typeof process is "undefined" or not process.versions) then window.inventoryConfJSON = window.inventoryConfJSON or {} else exports)
