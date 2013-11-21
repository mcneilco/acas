((exports) ->
	exports.validMetStab =
		protocolName: "MetStab Protocol 1"
		scientist: "jmcneil"
		notebook: "dnsNB1"
		project: "proj1"
		assayDate: 1370125086
	exports.csvDataToLoad = "Corporate Batch ID,solubility (ug/mL),Assay Comment (-)\nDNS123456789::12,11.4,good\nDNS123456790::01,6.9,ok\n"

) (if (typeof process is "undefined" or not process.versions) then window.MetStabTestJSON = window.MetStabTestJSON or {} else exports)

