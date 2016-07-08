((exports) ->

	exports.runRFunctionRequest =
		rScript:"src/r/spec/ServerAPI/serviceTests/runRApacheFunction.R"
		rFunction:"testFunction"
		request: "{\"smartMode\":true,\"inactiveThresholdMode\":true,\"inactiveThreshold\":20,\"inverseAgonistMode\":false,\"max\":{\"limitType\":\"none\"},\"min\":{\"limitType\":\"none\"},\"slope\":{\"limitType\":\"none\"}}"

	exports.runRFunctionResponse =
		hasError: false
		results:
			dryRun: true
			htmlSummary: true
		hasWarning: true

) (if (typeof process is "undefined" or not process.versions) then window.runRFunctionServiceTestJSON = window.runRFunctionServiceTestJSON or {} else exports)
