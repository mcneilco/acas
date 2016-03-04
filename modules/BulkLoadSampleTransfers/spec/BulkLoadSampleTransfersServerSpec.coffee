###
This service bulk laods sample transfer information provided in a CSV file.
The server takes a server-relative file path as input.
The service returns success status or an error summary
The service should save all the infomration with an associated load event id which it returns to support undo

Sample transfer file format. There is a required header row whose column heading much match exactly.
The file should not contain special characters, use u for mu

All columns are required
Column Header			Example				Note
Source Barcode			C00000001
Source Well				A1, A01 or A001		If a vial, this is always A1
Destination Barcode		C00000002
Allow Plate Creation	true				Create new plate if true and destination does not exist
Plate Size				384					Vials are plate size 1. May be left blank if plate exists = true
Destination Well		A1, A01 or A001		If a vial, this is always A1
Final Physical State	liquid				or solid
Final Concentration		10					Blank if physical state = solid
Concentration Units		mM					Blank if physical state = solid
Amount Transferred		100
Amount Units			uL					micro liter should use u, not mu
Transfer Date
###


#Service call data with good data:
goodDataRequest =
	fileToParse: "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv"
	dryRun: true
	user: 'jmcneil'

#Service call data with bad data:
badDataRequest =
	fileToParse: "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_with_error.csv"
	dryRun: true
	user: 'jmcneil'

#The expected return format for success is:
returnExampleSuccess =
	transactionId: null
	results:
		path: "path/to/file"
		fileToParse: "filename.xls"
		htmlSummary: "transfers to save: 3"
		dryRun: true
	hasError: false
	hasWarning: true
	errorMessages: [{errorLevel: "warning", message: "some warning"}]

#The expected return format for error is:
returnExampleError =
	transactionId: null
	results:
		path: "path/to/file"
		fileToParse: "filename.xls"
		htmlSummary: "Error: Barcode C00000001 already loaded..."
		dryRun: true
	hasError: true
	hasWarning: true
	errorMessages: [
		{errorLevel: "warning", message: "some warning"},
		{errorLevel: "error", message: "Barcode C00000001 already loaded"},
		{errorLevel: "error": 27, message: "Barcode C00000001, well X128 does not exist on a 384 well plate"}
	]


# Here is example usage
describe 'Bulk Load Sample Transfers testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'when run with good input file', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'POST'
				url: "api/bulkLoadSampleTransfers"
				data: goodDataRequest
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

	describe 'when run with flawed input file', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'POST'
				url: "api/bulkLoadSampleTransfers"
				data: badDataRequest
				success: (json) ->
					self.serviceReturn = json
				error: (err) ->
					console.log 'got ajax error'
					self.serviceReturn = null
				dataType: 'json'

		it 'should not return a dry run transactionId, but retuen error=true, and at least one message', ->
			waitsFor( @waitForServiceReturn, 'service did not return', 2000)
			runs ->
				expect(@serviceReturn.transactionId).toBeNull()
				expect(@serviceReturn.hasError).toBeTruthy()
				expect(@serviceReturn.errorMessages.length).toBeGreaterThan(0)
				expect(@serviceReturn.errorMessages[0].errorLevel).toEqual 'error'