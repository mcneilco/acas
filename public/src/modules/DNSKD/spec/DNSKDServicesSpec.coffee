###
This service runs the preprocessor, promary analysis and data save for the DNS DS assay.
  The data is provided in a single data file.
###

#The required data structure is
goodExampleData =
	experimentId: 332134			# Id returned by fitProtocolService
	fileToParse: "/var/www/rScripts/specFiles/dnsKD/sampleFile.csv" # Path to a previously uploaded file
	analysisParameters: window.primaryScreenTestJSON.primaryScreenAnalysisParameters
	user: 'jmcneil'
	dryRun: true 					# a testing option to do everything but save the results


#The expected return format for success is:
returnExampleSuccess =
	transactionId: null
	results:
		fileToParse: "path/to/directory"
		htmlSummary: "plates to analyze: 3"
		experimentId: 332134
		dryRun: true
	hasError: false
	hasWarning: true
	errorMessages: [{errorLevel: "warning", message: "some warning"}]


#The expected return format for error is:
returnExampleError =
	transactionId: null
	results:
		fileToParse: "path/to/file"
		htmlSummary: "Error: Can't read data file"
		dryRun: true
	hasError: true
	hasWarning: true
	errorMessages: [
		{errorLevel: "warning", message: "some warning"},
		{errorLevel: "error", message: "Can't read file"},
		{errorLevel: "error", message: "Can't find positive control on plate"}
	]


# Here is example usage
describe 'Run DNS KD primary analysis service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'when run with valid input', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'POST'
				url: "api/dnsKDAnalysis/runDNSKDPrimaryAnalysis"
				data: goodExampleData
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'

		it 'should return error=false', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				(expect @serviceReturn.error).toBeFalsy

	describe 'when run with flawed input file', ->
		beforeEach ->
			goodExampleData.fileToParse += "_with_error"
			self = @
			$.ajax
				type: 'POST'
				url: "api/dnsKDAnalysis/runDNSKDPrimaryAnalysis"
				data: goodExampleData # modified to have bad fitProtocolId
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'

		it 'should return error=true', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				(expect @serviceReturn.error).toBeTruthy

		it 'should return error messages', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				(expect @serviceReturn.errorMessages.length).toBeGreaterThan 0

