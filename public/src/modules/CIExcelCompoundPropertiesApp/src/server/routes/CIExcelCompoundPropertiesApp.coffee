exports.setupRoutes = (app, loginRoutes) ->
	app.get '/excelApps/compoundInfo', loginRoutes.ensureAuthenticated, exports.compoundInfoIndex
	app.post '/excelApps/getPreferredIDAndProperties', loginRoutes.ensureAuthenticated, exports.getPreferredIDAndProperties


exports.compoundInfoIndex = (req, resp) ->
	global.specRunnerTestmode = if global.stubsMode then true else false
	config = require '../conf/compiled/conf.js'
	if config.all.client.require.login
		loginUserName = req.user.username
		loginUser = req.user
	else
		loginUserName = "nouser"
		loginUser =
			id: 0,
			username: "nouser",
			email: "nouser@nowhere.com",
			firstName: "no",
			lastName: "user"

	return resp.render 'CIExcelCompoundPropertiesApp',
		title: 'Compound Info'
		AppLaunchParams:
			loginUserName: loginUserName
			loginUser: loginUser
			testMode: global.specRunnerTestmode
			deployMode: global.deployMode

exports.getPreferredIDAndProperties = (req, resp) ->
	_ = require 'underscore'
	codeService = require '../routes/PreferredEntityCodeService.js'
	propertiesService = require '../routes/TestedEntityPropertiesServicesRoutes.js'
	config = require '../conf/compiled/conf.js'

	# First create an out object where we store all the information returned from services
	entities = req.body.entityIdStringLines.split('\n')
	outObject = []
	createOutObject = (entity, index) =>
		preferredIDAndPropertyObject =
				index: index
				preferredParentCode: ""
				preferredBatchCode: ""
				preferredCode: ""
				requestedName: entity
		if req.body.selectedProperties.parentNames?
	    req.body.selectedProperties.parentNames.forEach (selectedParentProperty) =>
		    preferredIDAndPropertyObject[selectedParentProperty]= ''
		if req.body.selectedProperties.batchNames?
	    req.body.selectedProperties.batchNames.forEach (selectedBatchProperty) =>
		    preferredIDAndPropertyObject[selectedBatchProperty]= ''
		outObject.push preferredIDAndPropertyObject
	createOutObject(entity, index) for entity, index in entities

	# Remove blanks for now as some services can't handle them
	blankRequest = _.where(outObject, {'requestedName':''})
	noneBlankRequest = _.reject outObject, (prefs) ->
		prefs.requestedName == ''

	# Request preferred batch ids
	requestData =
		displayName: "Corporate Batch ID"
		entityIdStringLines: _.pluck(noneBlankRequest, 'requestedName').join("\n")

	codeService.referenceCodes requestData, true, (response) =>
		lines =  response.resultCSV.split("\n")
		preferredCodes = lines.slice(1, lines.length-1)
		fillPreferred = (preferredCodeLine, index) =>
			noneBlankRequest[index].preferredBatchCode = preferredCodeLine.split(",")[1]
		fillPreferred(preferredCodeLine, index) for preferredCodeLine, index in preferredCodes

		# Request preferred parent ids
		requestData =
			displayName: "Corporate Parent ID"
			entityIdStringLines: _.pluck(noneBlankRequest, 'requestedName').join("\n")

		codeService.referenceCodes requestData, true, (response) =>
			lines =  response.resultCSV.split("\n")
			preferredCodes = lines.slice(1, lines.length-1)
			fillPreferred = (preferredCodeLine, index) =>
				if noneBlankRequest[index].preferredBatchCode == ""
					noneBlankRequest[index].preferredParentCode = preferredCodeLine.split(",")[1]
			fillPreferred(preferredCodeLine, index) for preferredCodeLine, index in preferredCodes

			#Join blanks and none blanks back together
			outObject = noneBlankRequest.concat blankRequest

			# Fill in the general preferred code with priority to batch code
			# Entities without preferred batch or parent codes get ''
			outObject = _.map outObject, (pref) ->
				if pref.preferredBatchCode != ''
					pref.preferredCode = pref.preferredBatchCode
				else
					if pref.preferredParentCode != ''
						pref.preferredCode = pref.preferredParentCode
					else
						pref.preferredCode = ''
				return pref

			# Split entities with preferred codes from those that do not
			missingPreferredCodes = _.where(outObject, {'preferredCode':''})
			preferredCodes = _.reject outObject, (prefs) ->
				prefs.preferredCode == ''

			# Request parent properties
			entityIdStringLines = _.pluck(preferredCodes, 'preferredCode').join("\n")

			exports.fillEntityProperties "Corporate Parent ID", entityIdStringLines, req.body.selectedProperties.parentNames, preferredCodes, (preferredCodes)=>
				preferredBatchCodes = _.reject preferredCodes, (prefs) ->
					prefs.preferredBatchCode == ''
				preferredParentCodes = _.reject preferredCodes, (prefs) ->
					prefs.preferredParentCode == ''

				entityIdStringLines = _.pluck preferredBatchCodes, 'preferredBatchCode'
				exports.fillEntityProperties "Corporate Batch ID", entityIdStringLines, req.body.selectedProperties.batchNames, preferredBatchCodes, (preferredBatchCodes)=>

					#Combine all lists back together
					outObject = preferredBatchCodes.concat(preferredParentCodes.concat(missingPreferredCodes))

					#Sort by index
					outObject = _.sortBy outObject, (obj) -> obj.index

					#Convert to csv
					array = if typeof outObject != 'object' then JSON.parse(outObject) else outObject
					outCSV = ''
					if req.body.includeRequestedName == "true"
						idKeys = ['requestedName', 'preferredCode']
						prettyIDKeys  = ['Requested Name', 'Preferred Code']
					else
						idKeys = ['preferredCode']
						prettyIDKeys  = ['Preferred Code']
					if req.body.selectedProperties.batchNames?
						idKeys = idKeys.concat(req.body.selectedProperties.batchNames)
						prettyIDKeys = prettyIDKeys.concat(req.body.selectedProperties.batchPrettyNames)
					if req.body.selectedProperties.parentNames?
						idKeys = idKeys.concat(req.body.selectedProperties.parentNames)
						prettyIDKeys = prettyIDKeys.concat(req.body.selectedProperties.parentPrettyNames)
					keyNames = idKeys
					prettyNames = prettyIDKeys
					if req.body.insertColumnHeaders == "true"
						outCSV += prettyNames.join('\t') + '\n'
					i = 0
					while i < array.length
						line = ''
						arr = _.pick(array[i], keyNames)
						for index of arr
							line += arr[index] + "\t"
						line = line.slice(0,line.length-1)
						outCSV += line + '\n'
						i++
					resp.json outCSV


preferredCodeResponseToJSON = (csv, shouldIndex, codeKind, additionalFieldsToAdd) ->
	_ = require 'underscore'
	toArray =  (preferredCode, index, additionalFieldsToAdd) ->
		out = {}
		prefs = preferredCode.split(",")
		out.requestedName = prefs[0]
		out[codeKind] = prefs[1]
		if shouldIndex
			out.index = index
		out = _.extend out, additionalFieldsToAdd
		return out
	lines = csv.split("\n")
	preferredCodes = lines.slice(1, lines.length-1)
	splitLines = (toArray(preferredCode, index, additionalFieldsToAdd) for preferredCode, index in preferredCodes)
	return splitLines

exports.fillEntityProperties = (displayName, entityIdStringLines, descriptorNames, outObject, callback) ->
	propertiesService = require '../routes/TestedEntityPropertiesServicesRoutes.js'
	if descriptorNames? && entityIdStringLines.length > 0 && entityIdStringLines != ""
		propertiesService.entityProperties displayName, entityIdStringLines, descriptorNames, "tsv", (response) =>
			# Parse the tsv response and add properties back to the preferredCodes object
			addRow =  (row, header, rowIndex) ->
				out = {}
				columns = row.split("\t")
				columns = columns.slice(1, row.length-1)
				addColumnValue = (columnValue, header, columnIndex) ->
					propName = header[columnIndex]
					outObject[rowIndex][propName] = columnValue
				addColumnValue(columnValue, header, index) for columnValue, index in columns
			rows = response.split("\n")
			header = rows[0].split("\t")
			header = header.slice(1, header.length)
			rows = rows.slice(1, rows.length-1)
			addRow(row, header, index) for row, index in rows
			callback outObject
	else
		callback outObject
