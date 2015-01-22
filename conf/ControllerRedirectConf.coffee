((exports) ->
	exports.controllerRedirectConf =
		{
			PRCl:
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
