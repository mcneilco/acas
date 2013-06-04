((exports) ->
	exports.validFullPK =
		format: "In Vivo Full PK"
		protocolName: "Full PK Protocol 1"
		experimentName: "my full PK expt"
		scientist: "ashen"
		notebook: "dnsNB1"
		inLifeNotebook: "dnsNB2"
		assayDate: 1370125086
		project: "proj1"
		bioavailability: "55"
		aucType: "underneath"
) (if (typeof process is "undefined" or not process.versions) then window.FullPKTestJSON = window.FullPKTestJSON or {} else exports)

