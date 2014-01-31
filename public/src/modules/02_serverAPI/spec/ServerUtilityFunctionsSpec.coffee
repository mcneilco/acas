###
This tests the basic function and JSON validation features of the Server Utility functions
###


#Service call data with good data:
goodRunRRequest =
	fileToParse: "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv"
	dryRun: true
	user: 'jmcneil'


# Here is example usage
describe 'runRFunction testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'when run with good input file', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'POST'
				url: "api/runRFunctionTest"
				data: goodRunRRequest
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'

		it 'should return hasError=false', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.hasError).toBeFalsy()
				expect(@serviceReturn.results.dryRun).toBeTruthy()
				expect(@serviceReturn.hasWarning).toBeDefined()
				expect(@serviceReturn.results.htmlSummary).toBeDefined()

	describe 'when run with missing username', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'POST'
				url: "api/runRFunctionTest"
				data:
					fileToParse: "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv"
					dryRun: true
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'

		it 'should return error=true, and at least one message', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.hasError).toBeTruthy()

		it 'should return an error message saying username is required', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.errorMessages.length).toBeGreaterThan(0)
				expect(@serviceReturn.errorMessages[0].errorLevel).toEqual 'error'
				expect(@serviceReturn.errorMessages[0].message).toEqual 'Username is required'

