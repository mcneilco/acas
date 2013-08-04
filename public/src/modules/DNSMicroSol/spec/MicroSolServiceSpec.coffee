###
This service parses data from the Micro Solubility format and saves it to the database
It also takes parameters that would normally be in a header block
It returns the usual error and warning info, but also a CSV preview of the data to load
###
#Service call data with good data:
goodDataRequest =
	fileToParse: "public/src/modules/DNSMicroSol/spec/specFiles/2013yyy_usol_xxxxx.xls"
	inputParameters: window.MicroSolTestJSON.validMicroSol
	dryRun: true
	user: 'jmcneil'
	testMode: true

#Service call data with bad data:
badDataRequest =
	fileToParse: "public/src/modules/DNSMicroSol/spec/specFiles/2013yyy_usol_xxxxx_with_error.xls"
	inputParameters:  window.MicroSolTestJSON.validMicroSol
	dryRun: true
	user: 'jmcneil'
	testMode: true

#The expected return format for save or update success is:
returnExampleSuccess =
	transactionId: -1
	results:
		path: "path/to/file"
		fileToParse: "filename.xls"
		htmlSummary: "HTML from service"
		csvDataToLoad: "Corporate Batch ID,solubility (ug/mL),Assay Comment (-)\nDNS123456789::12,11.4,good\nDNS123456790::01,6.9,ok\n"
		dryRun: true
	hasError: false
	hasWarning: true
	errorMessages: []

#The expected return format for error is:
returnExampleError =
	transactionId: null
	results:
		path: "path/to/file"
		fileToParse: "filename.xls"
		reportFile: null #if user uploads report, put temp path here
		htmlSummary: "Error: There is a problem in this file..."
		csvDataToLoad: ""
		dryRun: true
	hasError: true
	hasWarning: true
	errorMessages: [
		{errorLevel: "warning", message: "some warning"},
		{errorLevel: "error", message: "Cannot find file"},
	]

# Here is example usage
describe 'MicroSol Parser Service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'when run with valid input file', ->
		beforeEach ->
			runs ->
				$.ajax
					type: 'POST'
					url: "api/microSolParser"
					data: goodDataRequest
					success: (json) =>
						@serviceReturn = json
					error: (err) =>
						console.log 'got ajax error'
						@serviceReturn = null
					dataType: 'json'
		# combine all expects in one test to reduce test run time since the service is slow
		it 'should return no errors, dry run mode, hasWarning, and an html summary', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 10000)
			runs ->
				expect(@serviceReturn.hasError).toBeFalsy()
				expect(@serviceReturn.results.dryRun).toBeTruthy()
				expect(@serviceReturn.hasWarning).toBeDefined()
				expect(@serviceReturn.results.htmlSummary).toBeDefined()
				expect(@serviceReturn.results.csvDataToLoad).toBeDefined()

	describe 'when run with invalid input file', ->
		beforeEach ->
			runs ->
				$.ajax
					type: 'POST'
					url: "api/microSolParser"
					data: badDataRequest
					success: (json) =>
						@serviceReturn = json
					error: (err) =>
						console.log 'got ajax error'
						@serviceReturn = null
					dataType: 'json'
		it 'should not return a dry run transactionId, but return error=true, and at least one message', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 20000)
			runs ->
				expect(@serviceReturn.transactionId).toBeNull()
				expect(@serviceReturn.hasError).toBeTruthy()
				expect(@serviceReturn.errorMessages.length).toBeGreaterThan(0)
				expect(@serviceReturn.errorMessages[0].errorLevel).toEqual 'error'


