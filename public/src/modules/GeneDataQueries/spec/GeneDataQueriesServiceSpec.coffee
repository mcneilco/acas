###
This service takes a list of geneids and returns related experimental data,


###
#Basic gene query Service call data with good data:
goodDataRequest =
	geneIDs: "1234, 2345, 4444"
	maxRowsToReturn: 10000
	user: 'jmcneil'

#Service call data with bad data:
badDataRequest =
	geneIDs: "1234, 2345, 4444"
	maxRowsToReturn: -1
	user: 'jmcneil'

#Advanced gene query Service call data with good data:
goodAdvancedRequest =
	queryParams:
		batchCodes: "gene1, gene2"
		experimentCodeList: [
			"EXPT-00000397"
			"EXPT-00000398"
		]
		searchFilters:
			booleanFilter: "advanced"
			advancedFilter: "Q1 AND Q2"
			filters: [
				{
					termName: "Q1"
					experimentCode: "EXPT-00000396"
					lsKind: "EC50"
					lsType: "numericValue"
					operator: "<"
					filterValue: ".05"
				}
				{
					termName: "Q2"
					experimentCode: "EXPT-00000398"
					lsKind: "KD"
					lsType: "numericValue"
					operator: ">"
					filterValue: "1"
				}
			]
	maxRowsToReturn: 10000
	user: "jmcneil"

#The expected return format basic query mode:
basicReturnExampleSuccess =
	results: window.geneDataQueriesTestJSON.geneIDQueryResults
	hasError: false
	hasWarning: true
	errorMessages: []

#advanced mode good data request
goodDataRequest =
	geneIDs: "1234, 2345, 4444"

#The expected return format advanced query mode:
advnacedReturnExampleSuccess =
	results: window.geneDataQueriesTestJSON.getGeneExperimentsReturn
	hasError: false
	hasWarning: false
	errorMessages: []

#The expected return format advanced query mode with no results:
advnacedReturnExampleSuccess =
	results: window.geneDataQueriesTestJSON.getGeneExperimentsNoResultsReturn
	hasError: false
	hasWarning: false
	errorMessages: []

#The expected return format advanced query get experiment attributes for experiment codes:
advancedReturnExampleSuccess =
	results: window.geneDataQueriesTestJSON.experimentSearchOptions
	hasError: false
	hasWarning: false
	errorMessages: []

#The expected return format advanced query mode with no results:
advnacedReturnExampleSuccess =
	results: window.geneDataQueriesTestJSON.experimentSearchOptionsNoMatches
	hasError: false
	hasWarning: false
	errorMessages: []

#The expected return format for a basic or advanced gene query with error is:
basicReturnExampleError =
	results:
		htmlSummary: "Error: There is a problem in this request..."
		data: null
	hasError: true
	hasWarning: true
	errorMessages: [
		{errorLevel: "warning", message: "some genes not found"},
		{errorLevel: "error", message: "start offset outside allowed range, please speak to an administrator"},
	]

# Here is example usage
describe 'Gene Data Queries Service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe "basic gene data query", ->
		describe 'when run with valid input data', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/geneDataQuery"
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
					expect(@serviceReturn.results.data.aaData.length).toEqual 4
					expect(@serviceReturn.hasWarning).toBeDefined()
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
		describe 'when run with no results expected', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/geneDataQuery"
						data:
							geneIDs: "fiona"
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
					expect(@serviceReturn.results.data.iTotalRecords).toEqual 0
					expect(@serviceReturn.hasWarning).toBeDefined()
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
		describe 'when run with invalid input', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/geneDataQuery"
						data: badDataRequest
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'
			it 'should return error=true, and at least one message', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 20000)
				runs ->
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
					expect(@serviceReturn.hasError).toBeTruthy()
					expect(@serviceReturn.errorMessages.length).toBeGreaterThan(0)
					expect(@serviceReturn.errorMessages[1].errorLevel).toEqual 'error'
		describe 'when run with valid input data and format is CSV', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/geneDataQuery?format=csv"
						data:
							geneIDs: "fiona"
						success: (res) =>
							console.log res
							@serviceReturn = res
			it 'should return no errors, dry run mode, hasWarning, and an html summary', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 300)
				runs ->
					#returns a link to a temp file
					expect(@serviceReturn.fileURL).toContain "http://"

	describe "advanced experiments for genes query", ->
		describe 'when run with valid input data', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/getGeneExperiments"
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
					expect(@serviceReturn.results.experimentData[0].parent).toEqual "Root Node"
					expect(@serviceReturn.hasWarning).toBeDefined()
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
		describe 'when run with no results expected', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/getGeneExperiments"
						data:
							geneIDs: "fiona"
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
					expect(@serviceReturn.results.experimentData.length).toEqual 0
					expect(@serviceReturn.hasWarning).toBeDefined()
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
		describe 'when run with invalid input file', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/getGeneExperiments"
						data: badDataRequest
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'
			it 'should return error=true, and at least one message', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 20000)
				runs ->
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
					expect(@serviceReturn.hasError).toBeTruthy()
					expect(@serviceReturn.errorMessages.length).toBeGreaterThan(0)
					expect(@serviceReturn.errorMessages[1].errorLevel).toEqual 'error'

	describe "advanced experiment attributes for experiments", ->
		describe 'when run with valid input data', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/getExperimentSearchAttributes"
						data:
							experimentCodes: ["EXPT-00000398", "EXPT-00000396", "EXPT-00000398"]
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
					expect(@serviceReturn.results.experiments[0].experimentCode).toEqual "EXPT-00000396"
					expect(@serviceReturn.hasWarning).toBeDefined()
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
		describe 'when run with no results expected', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/getExperimentSearchAttributes"
						data:
							experimentCodes: ["fiona"]
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
					expect(@serviceReturn.results.experiments.length).toEqual 0
					expect(@serviceReturn.hasWarning).toBeDefined()
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
		describe 'when run with invalid input data', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/getExperimentSearchAttributes"
						data:
							experimentCodes: ["error"]
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'
			it 'should return error=true, and at least one message', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 20000)
				runs ->
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
					expect(@serviceReturn.hasError).toBeTruthy()
					expect(@serviceReturn.errorMessages.length).toBeGreaterThan(0)
					expect(@serviceReturn.errorMessages[1].errorLevel).toEqual 'error'

	describe "advanced data search", ->
		describe 'when run with valid input data', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/geneDataQueryAdvanced"
						data: goodAdvancedRequest
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
					expect(@serviceReturn.results.data.aaData.length).toEqual 4
					expect(@serviceReturn.hasWarning).toBeDefined()
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
		describe 'when run with no results expected', ->
			beforeEach ->
				runs ->
					goodAdvancedRequest.queryParams.batchCodes = "fiona"
					$.ajax
						type: 'POST'
						url: "api/geneDataQueryAdvanced"
						data: goodAdvancedRequest
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
					expect(@serviceReturn.results.data.iTotalRecords).toEqual 0
					expect(@serviceReturn.hasWarning).toBeDefined()
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
		describe 'when run with invalid input file', ->
			beforeEach ->
				runs ->
					goodAdvancedRequest.maxRowsToReturn = -1
					$.ajax
						type: 'POST'
						url: "api/geneDataQueryAdvanced"
						data: goodAdvancedRequest
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'
			it 'should return error=true, and at least one message', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 20000)
				runs ->
					expect(@serviceReturn.results.htmlSummary).toBeDefined()
					expect(@serviceReturn.hasError).toBeTruthy()
					expect(@serviceReturn.errorMessages.length).toBeGreaterThan(0)
					expect(@serviceReturn.errorMessages[1].errorLevel).toEqual 'error'
		describe 'when run with valid input data and format is CSV', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/geneDataQueryAdvanced?format=csv"
						data: goodAdvancedRequest
						success: (res) =>
							console.log res
							@serviceReturn = res
			# combine all expects in one test to reduce test run time since the service is slow
			it 'should return no errors, dry run mode, hasWarning, and an html summary', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 500)
				runs ->
					#returns a link to a temp file
					expect(@serviceReturn.fileURL).toContain "http://"


