((exports) ->
	exports.savedCronEntry = [
		cronCode: "CRON00001234"
		schedule: "00 30 11 * * 1-5"
		scriptType: "R" # only choice for now
		scriptPath: ""


	]
) (if (typeof process is "undefined" or not process.versions) then window.cronScriptRunnerTestJSON = window.cronScriptRunnerTestJSON or {} else exports)
