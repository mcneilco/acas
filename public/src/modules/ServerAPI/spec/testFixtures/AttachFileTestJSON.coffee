((exports) ->
	exports.attachFileInfo = [
		fileType: "hplc"
		fileValue: "hplc.xlsx"
	,
		fileType: "nmr"
		fileVaue: "nmr.xls"
	]
) (if (typeof process is "undefined" or not process.versions) then window.attachFileTestJSON = window.attachFileTestJSON or {} else exports)
