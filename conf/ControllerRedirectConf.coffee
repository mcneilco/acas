((exports) ->
	exports.controllerRedirectConf =
	#NOTE, oreder matters!
	#If you have prefixes in a system where one is contained in another, the shorter must be listed last
	#e.g. if you have both PT and EXPT, you must list PT after EXPT for code lookup to work correctly
		{
			PROT:
				entityName: "protocols"
				stub: true #route will return a stub. this is only used for stubsMode testing
				default:
					deepLink: "protocol_base"
				"Bio Activity":
					deepLink: "primary_screen_protocol"
				relatedFilesRelativePath: "protocols"
			EXPT:
				entityName: "experiments"
				stub: false #route will return full expt
				default:
					deepLink: "experiment_base"
				"Bio Activity":
					deepLink: "primary_screen_experiment"
				relatedFilesRelativePath: "experiments"
			PT:
				entityName: "parent thing"
				stub: false #route will return full parent thing
				default:
					deepLink: "parent_thing"
				"Bio Activity":
					deepLink: "thing_parent"
				relatedFilesRelativePath: "entities/parentThings"
		}

) (if (typeof process is "undefined" or not process.versions) then window.controllerRedirectConf = window.controllerRedirectConf or {} else exports)
