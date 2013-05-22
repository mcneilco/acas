###
This service bulk loads containers given a SDF file full of containers.
The server takes a server-relative file path as input.
The file should have been uploaded and pre-flighted with Matt's file format service
The service just returns success status or an error summary
The service should save all the infomration with an associated load event id
which it returns to support undo

Container file format. The SDF must have the attributes below
The file should not contain special characters, use u for mu

All attributes are required
Attribute name (alternalte name)	      Example				Note
BATCH_ID (SAMPLE_ID)    SAM004498536        Look in corp batch name and in batch alias columns
ALIQUOT_PLATE_BARCODE		C00000001
ALIQUOT_WELL_ID				  A1, A01 or A001		If a vial, this is always A1
ALIQUOT_SOLVENT         DMSO
ALIQUOT_CONC		        10					Blank if physical state = solid
ALIQUOT_CONC_UNIT	      mM					Blank if physical state = solid
ALIQUOT_VOLUME				  10
ALIQUOT_VOLUME_UNIT		  uL					micro liter should use u, not mu
ALIQUOT_DATE            5-Nov-12
###


#Service call data with good data:
goodDataRequest =
	fileToParse: "public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/IFF_Mock data_Confirmation_Update.sdf"
	dryRun: true
	user: 'jmcneil'

#Service call data with bad data:
badDataRequest =
	fileToParse: "public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/InputFile_with_error.sdf"
	dryRun: true
	user: 'jmcneil'

#The expected return format for success is:
returnExampleSuccess =
	transactionId: null
	results:
		path: "path/to/file"
		fileToParse: "filename.xls"
		htmlSummary: "plates to save: 3 <br/> batches to associate: 123"
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
describe 'Bulk load containers from SDF testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

	describe 'when run with good input file', ->
		beforeEach ->
			self = @
			$.ajax
				type: 'POST'
				url: "api/bulkLoadContainersFromSDF"
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
				url: "api/bulkLoadContainersFromSDF"
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
				console.log @serviceReturn
				expect(@serviceReturn.transactionId).toBeNull()
				expect(@serviceReturn.hasError).toBeTruthy()
				expect(@serviceReturn.errorMessages.length).toBeGreaterThan(0)
				expect(@serviceReturn.errorMessages[0].errorLevel).toEqual 'error'
