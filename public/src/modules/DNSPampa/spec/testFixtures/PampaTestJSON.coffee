((exports) ->
	exports.validPampa =
		protocolName: "uSol Protocol 1"
		scientist: "jmcneil"
		notebook: "dnsNB1"
		project: "proj1"
) (if (typeof process is "undefined" or not process.versions) then window.PampaTestJSON = window.PampaTestJSON or {} else exports)

