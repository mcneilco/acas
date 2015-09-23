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

	# Request preferred batch ids
	requestData =
		type: "compound"
		kind: "batch name"
		entityIdStringLines: req.body.entityIdStringLines

	codeService.preferredCodes requestData, (response) =>
		# Parse the response to JSON instead of csv
		preferredBatchCodeJSON = preferredCodeResponseToJSON response.resultCSV, true, 'preferredBatchCode'

		# Separate entities that have preferred batch codes from those that do not
		missingPreferredBatchCodes = _.where preferredBatchCodeJSON, {'preferredBatchCode':''}
		preferredBatchCodes = _.reject preferredBatchCodeJSON, (prefs) ->
				prefs.preferredBatchCode == ''

		# Request preferred parent ids
		requestEntitiesArray = _.pluck(missingPreferredBatchCodes,'requestedName')
		entityIdStringLines = requestEntitiesArray.join('\n')
		requestData =
			type: "compound"
			kind: "parent name"
			entityIdStringLines: entityIdStringLines
		codeService.preferredCodes requestData, (response) =>
			# Parse the response to JSON instead of csv
			preferredParentCodeJSON = preferredCodeResponseToJSON(response.resultCSV, false, 'preferredParentCode')

			# Add the preferred code to the original 'missingPreferredBatchCodes' object
			addPreferredCode = (preferredCode, index) ->
				preferredCode.preferredParentCode = preferredParentCodeJSON[index].preferredParentCode
				return preferredCode
			preferredParentCodes = (addPreferredCode(preferredCode, index) for preferredCode, index in missingPreferredBatchCodes)

			# Combine the preferred batch code and preferred parent code lists
			preferredCodes = preferredBatchCodes.concat(preferredParentCodes)

			# Fill in the general preferred code with priority to batch code
			# Entities without preferred batch or parent codes get ''
			preferredCodes = _.map preferredCodes, (pref) ->
				if pref.preferredBatchCode != ''
					pref.preferredCode = pref.preferredBatchCode
				else
					if pref.preferredParentCode != ''
						pref.preferredCode = pref.preferredParentCode
					else
						pref.preferredCode = ''
				return pref

			# Split entities with preferred codes from those that do not
			missingPreferredCodes = _.where(preferredBatchCodeJSON, {'preferredCode':''})
			preferredCodes = _.reject(preferredCodes, (prefs) ->
				prefs.preferredCode == ''
			)

			# Request parent properties
			entityIdStringLines = _.pluck(preferredCodes, 'preferredCode').join("\n")
			propertiesService.getTestedEntityProperties req.body.selectedProperties.parent, entityIdStringLines, (response) =>

				# Parse the csv response and add properties back to the preferredCodes object
				addRow =  (row, header, rowIndex) ->
					out = {}
					columns = row.split(",")
					columns = columns.slice(1, row.length-1)
					addColumnValue = (columnValue, header, columnIndex) ->
						propName = header[columnIndex]
						preferredCodes[rowIndex][propName] = columnValue
					addColumnValue(columnValue, header, index) for columnValue, index in columns

				rows = response.resultCSV.split("\n")
				header = rows[0].split(",")
				header = header.slice(1, header.length)
				rows = rows.slice(1, rows.length-1)
				addRow(row, header, index) for row, index in rows
				console.log preferredCodes

				# Request batch properties
				propertiesService.getTestedEntityProperties req.body.selectedProperties.batch, entityIdStringLines, (response) =>














preferredCodeResponseToJSON = (csv, shouldIndex, codeKind) ->
	toArray =  (preferredCode, index) ->
		out = {}
		prefs = preferredCode.split(",")
		out.requestedName = prefs[0]
		out[codeKind] = prefs[1]
		if shouldIndex
			out.index = index
		return out
	lines = csv.split("\n")
	preferredCodes = lines.slice(1, lines.length-1)
	splitLines = (toArray(preferredCode, index) for preferredCode, index in preferredCodes)
	return splitLines
