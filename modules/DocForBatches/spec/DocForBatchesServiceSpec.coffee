###
This service saves and fetches DocForBatches items
###


#The required data structure is
goodExampleData =
	docForBatches: window.testJSON.docForBatches
	user: 'jmcneil'

#The required data structure is
goodExperimentExampleData =
	docForBatches: window.testJSON.docForBatches
	experiment: window.testJSON.nexExpForBatch
	user: 'jmcneil'

#The expected return format for save or update success is:
returnExampleSuccess =
	transactionId: 1234
	results: transactionId: 1234
	hasError: false
	hasWarning: true
	errorMessages: []

#The expected return format for error is:
returnExampleError =
	transactionId: null
	results: null
	hasError: true
	hasWarning: true
	errorMessages: [
		{errorLevel: "warning", message: "some warning"},
		{errorLevel: "error", message: "Cannot find file"},
	]


# Here is example usage
describe 'DocForBatches Service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'get existing entity from experiment', ->
		describe 'when run with valid input', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'GET'
						url: "api/experiments/1"
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'

			it 'should return a valide model', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 3000)
				runs ->
					expect(@serviceReturn.id).toEqual 17


			it 'should return a fileName', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 3000)
				runs ->
					console.log @serviceReturn
					expect(@serviceReturn.analysisGroups[0].lsStates[0].lsValues[0].fileValue).toEqual "exampleUploadedFile.txt"


	describe 'post new entity to docForBatches', ->
		describe 'when run with valid input', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						#todo:shall we change this?
						url: "api/docForBatches"
						data: goodExperimentExampleData
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'

			it 'should return error=false', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 3000)
				runs ->
					expect(@serviceReturn.error).toBeFalsy()
					expect(@serviceReturn.errorMessages.length).toEqual 0

			it 'should return a transactionId', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 3000)
				runs ->
					expect(@serviceReturn.transactionId).toBeDefined()
			it 'should return a experiment id', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 3000)
				runs ->
					expect(@serviceReturn.results.id).toBeDefined()

		describe 'when run with bad data', ->
			beforeEach ->
				goodExampleData.docForBatches.batchNameList[0].preferredName = ""
				$.ajax
					type: 'POST'
					url: "api/docForBatches"
					data: goodExampleData
					success: (json) =>
						@serviceReturn = json
					error: (err) =>
						console.log 'got ajax error'
						@serviceReturn = null
					dataType: 'json'

			it 'should return error=true', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 3000)
				runs ->
					expect(@serviceReturn.error).toBeTruthy()

			it 'should not return a load event ID', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 3000)
				runs ->
					expect(@serviceReturn.transactionId).toBeNull()

			it 'should return error messages', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 3000)
				runs ->
					expect(@serviceReturn.errorMessages.length).toEqual 1
					expect(@serviceReturn.errorMessages[0].errorLevel).toEqual "error"
