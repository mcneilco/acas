((exports) ->
	exports.controllerRedirectConf =
		{
			CB:
				entityName: "cationicBlockParents"
				stub: false #route will return a stub. this is only used for stubsMode testing
				"cationic block":
					deepLink: "cationic_block"
			LSM:
				entityName: "linkerSmallMoleculeParents"
				stub: false #route will return a stub. this is only used for stubsMode testing
				"linker small molecule":
					deepLink: "linker_small_molecule"
			PROT:
				entityName: "proteinParents"
				stub: false #route will return a stub. this is only used for stubsMode testing
				"protein":
					deepLink: "protein"
			SP:
				entityName: "spacerParents"
				stub: false #route will return a stub. this is only used for stubsMode testing
				"spacer":
					deepLink: "spacer"
#			EXPT:
#				entityName: "experiments"
##				stub: false #route will return full expt
#				cationic block:
#					deepLink: "experiment_base"
#				"flipr screening assay":
#					deepLink: "flipr_screening_assay"
		}

) (if (typeof process is "undefined" or not process.versions) then window.controllerRedirectConf = window.controllerRedirectConf or {} else exports)
