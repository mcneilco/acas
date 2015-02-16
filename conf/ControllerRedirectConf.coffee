((exports) ->
	exports.controllerRedirectConf =
		{
			CB:
				entityName: "things/parent/cationic block"
				stub: false #route will return a stub. this is only used for stubsMode testing
				"cationic block":
					deepLink: "cationic_block"
			LSM:
				entityName: "things/parent/linker small molecule"
				stub: false #route will return a stub. this is only used for stubsMode testing
				"linker small molecule":
					deepLink: "linker_small_molecule"
			PRTN:
				entityName: "things/parent/protein"
				stub: false #route will return a stub. this is only used for stubsMode testing
				"protein":
					deepLink: "protein"
			SP:
				entityName: "things/parent/spacer"
				stub: false #route will return a stub. this is only used for stubsMode testing
				"spacer":
					deepLink: "spacer"
			PROT:
				entityName: "protocols"
				stub: true #route will return a stub. this is only used for stubsMode testing
				default:
					deepLink: "protocol_base"
				"Bio Activity":
					deepLink: "primary_screen_protocol"
			EXPT:
				entityName: "experiments"
				stub: false #route will return full expt
				default:
					deepLink: "experiment_base"
				"Bio Activity":
					deepLink: "primary_screen_experiment"
		}

) (if (typeof process is "undefined" or not process.versions) then window.controllerRedirectConf = window.controllerRedirectConf or {} else exports)
