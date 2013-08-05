((exports) ->
	exports.validMicroSol =
		protocolName: "uSol Protocol 1"
		scientist: "jmcneil"
		notebook: "dnsNB1"
		project: "proj1"
	exports.csvDataToLoad = "Corporate Batch ID,solubility (ug/mL),Assay Comment (-)\nDNS123456789::12,11.4,good\nDNS123456790::01,6.9,ok\n"
) (if (typeof process is "undefined" or not process.versions) then window.MicroSolTestJSON = window.MicroSolTestJSON or {} else exports)

