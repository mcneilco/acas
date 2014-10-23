((exports) ->
	exports.controllerRedirectConf =
		{
			PROT:
				entityName: "protocols"
				stub: true #route will return a stub. this is only used for stubsMode testing
				default:
					deepLink: "protocol_base"
				"flipr screening assay":
					deepLink: "primary_screen_protocol"
			EXPT:
				entityName: "experiments"
				stub: false #route will return full expt
				default:
					deepLink: "experiment_base"
				"flipr screening assay":
					deepLink: "flipr_screening_assay"
		}

) (if (typeof process is "undefined" or not process.versions) then window.controllerRedirectConf = window.controllerRedirectConf or {} else exports)
