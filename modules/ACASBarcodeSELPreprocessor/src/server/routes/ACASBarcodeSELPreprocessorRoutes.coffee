exports.setupAPIRoutes = (app, loginRoutes) ->
	app.post '/aCASBarcodeSELPreprocessor/parseSEL', exports.parseSEL

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/aCASBarcodeSELPreprocessor/parseSEL', loginRoutes.ensureAuthenticated, exports.parseSEL


exports.parseSEL = (req, resp)  ->
	req.connection.setTimeout 6000000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	fs = require 'fs'
	path = require('path')
	inventoryServices = require "./InventoryServiceRoutes.js"
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	config = require '../conf/compiled/conf.js'
	ACAS_HOME = '.'

	selData = req.body

	replyData =
		transactionId: null
		results:
			path: req.body.path
			fileToParse: selData.fileToParse
			reportFile: selData.reportFile
			htmlSummary: ""
			dryRunMode: true
		hasError: false
		hasWarning: false
		errorMessages: []

	addError = (msg) ->
		replyData.hasError = true
		replyData.errorMessages.push
			errorLevel: "error", message: msg

	infilePath = path.join ACAS_HOME, config.all.server.datafiles.relative_path, selData.fileToParse
	fs.readFile infilePath, 'utf8', (err, selFile) ->
		if err?
			addError "Error reading file "+err
			resp.json replyData
			return

		inLines = selFile.split '\r'
		outLines = []
		barcodesToSub = []
		linesToSub = []
		rawLines = []
		foundBarcodeHeader = false
		foundRawResultsHeader = false
		for line in inLines
			console.log line
			cells = line.split ','
			if foundBarcodeHeader && !foundRawResultsHeader
				if cells[0].trim() != ""
					barcodesToSub.push cells[0].trim()
					linesToSub.push = cells
				else
					outLines.push cells.join ','
			else if foundRawResultsHeader
				rawLines.push = line
			else if !foundBarcodeHeader
				outLines.push line
			else
				if cells[0].trim() == "Barcode"
					foundBarcodeHeader = true
					cells[0] == "Corporate Batch ID"
					outLines.push cells.join ','
				else if cells[0].trim() == "Raw Results"
					foundRawResultsHeader = true
					rawLines.push line

		if !foundBarcodeHeader
			addError "Expected to find left-hand cell containing the word \"Barcode\""
			resp.json replyData
			return

		console.log barcodesToSub
		inventoryServices.getWellContentByContainerLabelsInternal barcodesToSub, 'container', 'tube', 'barcode', 'barcode', (wells, wellStatusCode) ->
			if wellStatusCode != 200
				addError "There was a problem looking up the barcodes"
				resp.json replyData
				return

			batches = {}
			for well in wells
				wellInfo = wells[0]?.wellContent[0]
				if wellInfo?.batchCode? and wellInfo.batchCode != ""
					batches[wellInfo.barcode] = wellInfo.batchCode
				else
					addError "Could not find lot/bath name for barcode #{wellInfo.barcode}"
			if replyData.hasError
				resp.json replyData
				return

			console.log batches
			for line in linesToSub
				line[0] = batches[line[0]]
				outLines.push line.join ','

			outLines.push rawLines
			console.log "number of lines: "+outLines.length

			outFile = outLines.join '\r\n'
			outFileName = selData.fileToParse.slice(0, -4) + "_converted.csv"
			outFilePath = path.join ACAS_HOME, config.all.server.datafiles.relative_path, outFileName
			fs.writeFile outFilePath, outFile, 'utf8', (err) ->
				if err?
					addError "Error writing intermediate file "+err
					resp.json replyData
					return

				selData.fileToParse = outFileName
				console.log selData
				serverUtilityFunctions.runRFunctionOutsideRequest selData.user, selData, "src/r/GenericDataParser/generic_data_parser.R", "parseGenericData", (rReturn) ->
					resp.end rReturn
