###
This service takes an experiment code,
  looks up efficacy data already saved there, and fits curves.
  It returns a summary in HTML. To see detailed result you have to open the curve curator
###
#Service call data with good data:
goodDataRequest =
	inputParameters: window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions
	user: 'jmcneil'
	experimentCode: "EXPT-0000001"
	testMode: true

#Service call data with bad data:
badDataRequest =
	inputParameters: window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions
	user: 'jmcneil'
	experimentCode: "EXPT-fail"
	testMode: true

#The expected return format for save or update success is:
returnExampleSuccess =
	transactionId: -1
	results:
		htmlSummary: "HTML from service"
		status: "complete"
	hasError: false
	hasWarning: true
	errorMessages: []

#The expected return format for error is:
returnExampleError =
	transactionId: null
	results:
		htmlSummary: "Error: There is a problem in this file..."
		status: "error"
	hasError: true
	hasWarning: true
	errorMessages: [1
		{errorLevel: "warning", message: "some warning"},
		{errorLevel: "error", message: "Cannot find file"},
	]

# Here is example usage
describe 'Dose Response Curve Fit Service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'when run with valid input data', ->
		beforeEach ->
			runs ->
				$.ajax
					type: 'POST'
					url: "api/doseResponseCurveFit"
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
				expect(@serviceReturn.results.status).toEqual "complete"
				expect(@serviceReturn.hasWarning).toBeDefined()
				expect(@serviceReturn.results.htmlSummary).toBeDefined()

	describe 'when run with invalid input file', ->
		beforeEach ->
			runs ->
				$.ajax
					type: 'POST'
					url: "api/doseResponseCurveFit"
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
				expect(@serviceReturn.results.status).toBeDefined()
				expect(@serviceReturn.hasError).toBeTruthy()
				expect(@serviceReturn.errorMessages.length).toBeGreaterThan(0)
				expect(@serviceReturn.errorMessages[0].errorLevel).toEqual 'error'


