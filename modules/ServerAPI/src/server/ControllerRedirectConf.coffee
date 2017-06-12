((exports) ->
	exports.controllerRedirectConf =
	#NOTE, order matters!
	#If you have prefixes in a system where one is contained in another, the shorter must be listed last
	#e.g. if you have both PT and EXPT, you must list PT after EXPT for code lookup to work correctly
		{
			PROT:
				entityName: "protocols"
				default:
					deepLink: "protocol_base"
				study:
					deepLink: "study_tracker_protocol"
				"Bio Activity":
					deepLink: "primary_screen_protocol"
				"Parent Bio Activity":
					deepLink: "parent_protocol"
				study:
					deepLink: "study_tracker_protocol"
				relatedFilesRelativePath: "protocols"
			EXPT:
				entityName: "experiments"
				default:
					deepLink: "experiment_base"
				study:
					deepLink: "study_tracker_experiment"
				"Bio Activity":
					deepLink: "primary_screen_experiment"
				"Bio Activity Screen":
					deepLink: "screening_campaign"
				"Parent Bio Activity":
					deepLink: "parent_experiment"
				relatedFilesRelativePath: "experiments"
			PROJ:
				entityName: "things/project/project"
				"project":
					deepLink: "project"
				relatedFilesRelativePath: "entities/projects"
			PT:
				entityName: "parent thing"
				default:
					deepLink: "parent_thing"
				"Bio Activity":
					deepLink: "thing_parent"
				relatedFilesRelativePath: "entities/parentThings"
			CB:
				entityName: "things/parent/cationic block"
				"cationic block":
					deepLink: "cationic_block"
				relatedFilesRelativePath: "entities/cationicBlockParents"
		}

) (if (typeof process is "undefined" or not process.versions) then window.controllerRedirectConf = window.controllerRedirectConf or {} else exports)
