((exports) ->
	#This is an example of a saved cron job spev that has not executed yet
	exports.savedCronEntry =
#The requestor must provide these attributes
		schedule: "0-59/10 * * * * *"
			#cron format string
			#This example runs evey 10 seconds
			#mocha tests depend on this timing example
		scriptType: "R"
			#only choice for now, later python, knime, etc
		scriptFile: "public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R"
			#the acas_home relative path and filename to the script file to be run
		functionName: "runRFunctionTest"
			#function name to call within the script file
			#Required for R scripts
		scriptJSONData: '{"fileToParse": "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv", "dryRun": "true", "user": "jmcneil" }'
			#JSON string passed to the script as arguments.
			#This will be converted to language-native data structure when script is run.
			# e.g. R runner will convert this to nested list objects
		active: true
			#true if should run, false otherwise, essentially pause
		ignored: false
			#true is logical delete state. Job will be dequeued
		user: 'jmcneil'
			#required login user of person whose actions caused this cron to be created
#Attributes below this are filled in by the service and not required from the requestor
		cronCode: "CRON123456789"
			#identifier we will also use as a key to lookup the handle to the cron job in memory
			#generated sequentially by the persistence
		lastStartTime: null
			#last time script was started in ms of the unix epoch in the local time zone
			#null if not run
		lastDuration: null
			#execution time in ms otherwise
			#null if not run
		lastResultJSON: null
			#JSON format string of last run results
			#null if not run
		numberOfExcutions: null
			#number of times script has been executed for this job
			#null if not run

) (if (typeof process is "undefined" or not process.versions) then window.cronScriptRunnerTestJSON = window.cronScriptRunnerTestJSON or {} else exports)


