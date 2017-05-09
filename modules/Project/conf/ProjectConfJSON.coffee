((exports) ->
	exports.typeKindList =
		thingtypes:
			[
				typeName: "project"
			]

		thingkinds:
			[
				typeName: "project"
				kindName: "project"
			]

		statetypes:
			[
				typeName: "metadata"
			]

		statekinds:
			[
				typeName: "metadata"
				kindName: "project metadata"
			]

		valuetypes:
			[
				typeName: "dateValue"
			,
				typeName: "codeValue"
			,
				typeName: "stringValue"
			,
				typeName: "fileValue"
			,
				typeName: "numericValue"
			,
				typeName: "clobValue"
			]

		valuekinds:
			[
				typeName: "dateValue"
				kindName: "start date"
			,
				typeName: "codeValue"
				kindName: "project status"
			,
				typeName: "stringValue"
				kindName: "short description"
			,
				typeName: "clobValue"
				kindName: "project details"
			,
				typeName: "fileValue"
				kindName: "reference file"
			,
				typeName: "fileValue"
				kindName: "presentation file"
			,
				typeName: "codeValue"
				kindName: "project leader"
			,			
				typeName: "numericValue"
				kindName: "live design id"
			,
				typeName: "codeValue"
				kindName: "is restricted"
			]

		labeltypes:
			[
				typeName: "name"
			]

		labelkinds:
			[
				typeName: "name"
				kindName: "project name"
			]

		roletypes:
			[
				typeName: "Project"
			,
				typeName: "LDAP"
			,
				typeName: "System"
			]

		rolekinds:
			[
				typeName: "System"
				kindName: "ACAS"
			,
				typeName: "System"
				kindName: "CmpdReg"
			,
				typeName: "LDAP"
				kindName: "Auto"
			]

		lsroles:
			[
				lsType: "System"
				lsKind: "ACAS"
				roleName: "ROLE_ACAS-USERS"
			,
				lsType: "System"
				lsKind: "ACAS"
				roleName: "ROLE_ACAS-ADMINS"
			,
				lsType: "System"
				lsKind: "CmpdReg"
				roleName: "ROLE_CMPDREG-USERS"
			,
				lsType: "System"
				lsKind: "CmpdReg"
				roleName: "ROLE_CMPDREG-ADMINS"
			,
				lsType: "System"
				lsKind: "ACAS"
				roleName: "ROLE_ACAS-CROSS-PROJECT-LOADER"
			]

		labelsequences:
			[
				digits: 8
				groupDigits: false
				labelPrefix: "PROJ"
				labelSeparator: "-"
				labelTypeAndKind: "id_codeName"
				thingTypeAndKind: "project_project"
				latestNumber:0
			]

		ddicttypes:
			[
				typeName: "project"
			,
				typeName: "project metadata"
			]

		ddictkinds:
			[
				typeName: "project"
				kindName: "status"
			,
				typeName: "project metadata"
				kindName: "file type"
			]

		codetables:
			[
				codeType: "project"
				codeKind: "status"
				codeOrigin: "ACAS DDICT"
				code: "active"
				name: "Active"
				ignored: false
			,
				codeType: "project"
				codeKind: "status"
				codeOrigin: "ACAS DDICT"
				code: "inactive"
				name: "Inactive"
				ignored: false
			,
				codeType: "project metadata"
				codeKind: "file type"
				codeOrigin: "ACAS DDICT"
				code: "reference file"
				name: "Reference File"
				ignored: false
			,
				codeType: "project metadata"
				codeKind: "file type"
				codeOrigin: "ACAS DDICT"
				code: "presentation file"
				name: "Presentation File"
				ignored: false
			]

) (if (typeof process is "undefined" or not process.versions) then window.projectConfJSON = window.projectConfJSON or {} else exports)
