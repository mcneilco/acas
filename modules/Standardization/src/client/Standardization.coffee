class StandardizationCurrentSettingsController extends Backbone.View
	template: _.template($("#StandardizationCurrentSettingsView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_getCurrentSettingsError').hide()
		@$('.bv_currentSettingsTable').hide()
		@getCurrentSettings()

	getCurrentSettings: ->
		$.ajax
			type: 'GET'
			url: "/cmpdReg/getStandardizationSettings"
			success: (currentSettings) =>
				@$('.bv_currentSettingsTable').show()
				@setupCurrentSettingsTable currentSettings
			error: (err) =>
				@$('.bv_getCurrentSettingsError').show()

	setupCurrentSettingsTable: (settings) ->
		@$('.bv_currentSettingsTable').dataTable
			"aaData": [
				[ "Needs standardization", settings.needsStandardization],
				[ "Time modified", UtilityFunctions::convertMSToYMDTimeDate(settings.modifiedDate, "12hr")]
			]
			"aoColumns": [
				{ "sTitle": "Name" },
				{ "sTitle": "Value" }
			]
			bFilter: false
			bInfo: false
			bPaginate: false
			bSort: false

class DownloadDryResultsController extends Backbone.View
	template: _.template($("#DownloadDryRunResultsView").html())


	events: ->
		"click .bv_download": "handleDownloadClicked"
		
	initialize: ->
		$(@el).empty()
		$(@el).html @template()
			

	getFileNameFromHeader: (header) ->
		return header.split(';')[1].split('=')[1]

	handleDownloadClicked: (event) =>
		@$('.bv_running').show()
		@$('.bv_download').addClass("disabled")
		url = "/cmpdReg/standardizationDryRunSearchExport"
		modelData = @options.searchModel.toJSON()
		delete modelData.maxResults
		fileName = "download.sdf"
		fetch(url, {
			method: 'POST'
			headers:
				'Content-Type': 'application/json'
			body: JSON.stringify(modelData)
		})
		.then((resp) =>
			fileName = @getFileNameFromHeader(resp.headers.get('Content-Disposition'));
			resp.blob()
		)
		.then((blob) =>
			url = window.URL.createObjectURL(blob);
			a = document.createElement('a');
			a.style.display = 'none';
			a.href = url;
			a.download = fileName;
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			@$('.bv_running').hide()
			@$('.bv_download').removeClass("disabled")
		)
		.catch(() => 
			@$('.bv_running').hide()
			@$('.bv_download').removeClass("disabled")
			alert('Failed to fetch Dry Run results.sdf')
		);



class StandardizationHistoryRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'

	initialize: ->
		@template = _.template($('#StandardizationHistoryRowSummaryView').html())

	render: =>
		recordedDate = @model.get('recordedDate')
		if recordedDate?
			recordedDate = UtilityFunctions::convertMSToYMDDate recordedDate
		else
			recordedDate = ""

		dryRunStart = @model.get('dryRunStart')
		if dryRunStart?
			dryRunStart = UtilityFunctions::convertMSToYMDTimeDate(dryRunStart, "12hr")
		else
			dryRunStart = ""

		dryRunComplete = @model.get('dryRunComplete')
		if dryRunComplete?
			dryRunComplete = UtilityFunctions::convertMSToYMDTimeDate(dryRunComplete, "12hr")
		else
			dryRunComplete = ""

		standardizationStart = @model.get('standardizationStart')
		if standardizationStart?
			standardizationStart = UtilityFunctions::convertMSToYMDTimeDate(standardizationStart, "12hr")
		else
			standardizationStart = ""

		standardizationComplete = @model.get('standardizationComplete')
		if standardizationComplete?
			standardizationComplete = UtilityFunctions::convertMSToYMDTimeDate(standardizationComplete, "12hr")
		else
			standardizationComplete = ""

		toDisplay =
			id: @model.get('id')
			recordedDate: recordedDate
			structuresStandardizedCount: @model.get('structuresStandardizedCount')
			standardizationErrorCount: @model.get('standardizationErrorCount')
			registrationErrorCount: @model.get('registrationErrorCount')
			structuresUpdatedCount: @model.get('structuresUpdatedCount')
			changedStructureCount: @model.get('changedStructureCount')
			displayChangeCount: @model.get('displayChangeCount')
			newDuplicateCount: @model.get('newDuplicateCount')
			asDrawnDisplayChangeCount: @model.get('asDrawnDisplayChangeCount')
			existingDuplicateCount: @model.get('existingDuplicateCount')
			settingsHash: @model.get('settingsHash')
			dryRunStatus: @model.get('dryRunStatus')
			dryRunStart: dryRunStart
			dryRunComplete: dryRunComplete
			standardizationStatus: @model.get('standardizationStatus')
			standardizationStart: standardizationStart
			standardizationComplete: standardizationComplete
			standardizationReason: @model.get('standardizationReason')


		$(@el).html(@template(toDisplay))
		@

class StandardizationHistorySummaryTableController extends Backbone.View

	render: =>
		@template = _.template($("#StandardizationHistorySummaryTableView").html())
		$(@el).html @template

		@$("body").tooltip selector: '.bv_structuresStandardizedCountPopover'
		console.dir @collection
		if @collection.models.length > 0
			@collection.each (run) =>
				shrsc = new StandardizationHistoryRowSummaryController
					model: run
				@$("tbody").append shrsc.render().el

			oTable = @$(".bv_standardizationHistorySummaryTable").dataTable
				iDisplayLength: 3
				aaSorting: [[ 0, "desc" ]]
				oLanguage:
					sSearch: "Filter history: " #rename summary table's search bar

		@

	events: ->
		"click .bv_standardizationHistoryInfo": "handleStandardizationHistoryModalOpen"
		"click .bv_standardizationHistoryModalCloseBtn": "handleStandardizationHistoryModalClose"

	handleStandardizationHistoryModalOpen: ->
		@$('.bv_standardizationHistoryModal').modal
			backdrop: 'static'
		@$('.bv_standardizationHistoryModal').modal 'show'

	handleStandardizationHistoryModalClose: ->
		@$('.bv_standardizationHistoryModal').modal 'hide'

class StandardizationDryRunReportStatsController extends Backbone.View
	template: _.template($("#StandardizationDryRunReportStatsView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_standardizationDryRunReportStatsTable').hide()
		@$('.bv_getDryRunReportStatsError').hide()

		@$("body").tooltip selector: '.bv_structuresStandardizedCountPopover'

		@getDryRunReportStats()

	getDryRunReportStats: ->
		$.ajax
			type: 'GET'
			url: "/cmpdReg/standardizationDryRunStats"
			success: (dryRunStats) =>
				@$('.bv_standardizationDryRunReportStatsTable').show()
				@setupDryRunStatsTable dryRunStats
			error: (err) =>
				@$('.bv_getDryRunReportStatsError').show()

	setupDryRunStatsTable: (stats) ->
		@$('.bv_standardizationDryRunReportStatsTable').dataTable
			"aaData": [
				[stats.structuresStandardizedCount, stats.standardizationErrorCount, stats.registrationErrorCount, stats.changedStructureCount, stats.displayChangeCount, stats.newDuplicateCount, stats.asDrawnDisplayChangeCount, stats.existingDuplicateCount]
			]
			"aoColumns": [
				{ "sTitle": "# Structures Standardized" },
				{ "sTitle": "# Standardization Errors" },
				{ "sTitle": "# Registration Errors" },
				{ "sTitle": "# Structures Changed" },
				{ "sTitle": "# Display Change" },
				{ "sTitle": "# New Duplicates" },
				{ "sTitle": "# As Drawn Display Change" },
				{ "sTitle": "# Existing Duplicates" }
			]
			bFilter: false
			bInfo: false
			bPaginate: false
			bSort: false

	events: ->
		"click .bv_dryRunResultsInfo": "handleDryRunResultsModalOpen"
		"click .bv_dryRunResultsModalCloseBtn": "handleDryRunResultsModalClose"

	handleDryRunResultsModalOpen: ->
		@$('.bv_dryRunResultsModal').modal
			backdrop: 'static'
		@$('.bv_dryRunResultsModal').modal 'show'

	handleDryRunResultsModalClose: ->
		@$('.bv_dryRunResultsModal').modal 'hide'

class StandardizationDryRunReportRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'

	initialize: ->
		@template = _.template($('#StandardizationDryRunReportRowSummaryView').html())

	render: =>
		toDisplay =
			corpName: @model.get('corpName')
			changedStructure: @model.get('changedStructure')
			displayChange: @model.get('displayChange')
			newDuplicates: @model.get('newDuplicates')
			existingDuplicates: @model.get('existingDuplicates')
			deltaMolWeight: @roundToTwo(@model.get('newMolWeight')- @model.get('oldMolWeight'))
			newMolWeight: @model.get('newMolWeight')
			oldMolWeight: @model.get('oldMolWeight')
			asDrawnDisplayChange: @model.get('asDrawnDisplayChange')
			standardizationStatus: @model.get('standardizationStatus')
			standardizationComment: @model.get('standardizationComment')
			registrationStatus: @model.get('registrationStatus')
			registrationComment: @model.get('registrationComment')

		$(@el).html(@template(toDisplay))

		@

	roundToTwo: (num) ->
		+(Math.round(num + 'e+2') + 'e-2')

class StandardizationDryRunReportSearch extends Backbone.Model
	defaults:
		maxResults: null
		changedStructure: true
		displayChange: false
		hasNewDuplicates: true
		hasExistingDuplicates: true
		standardizationStatus: null
		registrationStatus: null
		deltaMolWeight: 
			operator: ">"
			value: null
		newMolWeight: 
			operator: ">"
			value: null
		oldMolWeight: 
			operator: ">"
			value: null
		asDrawnDisplayChange: null
		includeCorpNames: null
		corpNames: []

class StandardizationDryRunReportSearchController extends Backbone.View
	template: _.template($("#StandardizationDryRunReportSearchView").html())

	events: ->
		"input input": "updateModel"
		"change select": "updateModel"
		"input textarea": "updateModel"

	initialize: () ->
		@downloadDryRunResultsController = new DownloadDryResultsController
			mostRecentHistory: @mostRecentHistory
			searchModel: @model
		

	render: ->
		$(@el).empty()
		$(@el).html @template()
		@updateModel()
		@$(".bv_downloadStandardizationDryRunFiles").html @downloadDryRunResultsController.render().el

		@

	getBooleanRadioOption: (name) ->
		radioValue = @$("input[name='#{name}']:checked").val()
		# Switch to translate string value to boolean options
		if(radioValue == "blank")
			return null
		else
			return radioValue == "true"

	getRadioChoiceOptions: (name) ->
		radioValues = @$("input[name='#{name}']:checked").map ->
			$(this).val()
		.get()
		# Switch to translate string value to boolean options
		if(radioValues.includes("blank"))
			return null
		else
			return radioValues

	getNumberValue: (claz) ->
		value = @$(claz).find("input").get()[0].valueAsNumber
		# Check if NaN return null
		if(isNaN(value))
			return null
		else
			return value
		

	updateModel: ->
		# We are using radio buttons for standardization and registration status but this can be sent in as an array to filter on multiple values
		@.model.set "standardizationStatuses", @getRadioChoiceOptions('standardizationStatuses')
		@.model.set "registrationStatuses", @getRadioChoiceOptions('registrationStatuses')

		# True/False no filter radios
		@.model.set "changedStructure", @getBooleanRadioOption('changedStructure')
		@.model.set "asDrawnDisplayChange",  @getBooleanRadioOption('asDrawnDisplayChange')
		@.model.set "displayChange",  @getBooleanRadioOption('displayChange')
		@.model.set "hasNewDuplicates",  @getBooleanRadioOption('hasNewDuplicates')
		@.model.set "hasExistingDuplicates",  @getBooleanRadioOption('hasExistingDuplicates')
		@.model.set "includeCorpNames",  @getBooleanRadioOption('includeCorpNames')

		# Number inputs with operators
		@.model.get("deltaMolWeight").value = @getNumberValue('.deltaMolWeight')
		@.model.get("deltaMolWeight").operator = @$(".deltaMolWeight").find("select").first().val()
		@.model.get("oldMolWeight").value = @getNumberValue('.oldMolWeight')
		@.model.get("oldMolWeight").operator = @$(".oldMolWeight").find("select").first().val()
		@.model.get("newMolWeight").value = @getNumberValue('.newMolWeight')
		@.model.get("newMolWeight").operator = @$(".newMolWeight").find("select").first().val()

		# Integer inputs
		@.model.set("maxResults", @getNumberValue('.maxResults'))

		# Text filter input for corp names
		if @.model.get("includeCorpNames")?
			@$(".corpNames").removeAttr 'disabled'
		else
			@$(".corpNames").attr 'disabled', 'disabled'

		corpNameList = []
		corpNamesText = @$(".corpNames").val().split(/\n|;|,|\s/)
		## Remove blanks from list
		corpNamesText.forEach (corpName) ->
			corpName = corpName.trim()
			if(corpName.length > 0)
				corpNameList.push(corpName)
		@.model.set("corpNames", corpNameList)

		# Let the controller know that the model has changed
		@trigger "modelUpdated"

		@updateSearchCount()

	getDryRunSearch: (countOnly) ->
		requestData = @model.toJSON()
		url = "/cmpdReg/standardizationDryRunSearch"
		if countOnly? && countOnly
			url = url + "?countOnly=true"
				
		return fetch(url, {
			method: 'POST'
			headers:
				'Content-Type': 'application/json'
			body: JSON.stringify(requestData)
		})
		.then((resp) =>
			resp.json()
		)

	updateSearchCount: () ->
		@getDryRunSearch(true)
		.then((json) =>
			@searchCount = json.count
			@$('.bv_searchResultCount').text("out of #{@searchCount} query results")
			return @searchCount
		)
	
class StandardizationDryRunReportSummaryController extends Backbone.View
	template: _.template($("#StandardizationDryRunReportSummaryView").html())

	events: ->
		"click .bv_search": "handleSearchClicked"

	initialize: ->
		@model = new StandardizationDryRunReportSearch()
		@mostRecentHistory = @options.mostRecentHistory
		@maxDisplayCount = window.conf.cmpdreg.serverSettings.maxStandardizationDisplay
		searchModel = new StandardizationDryRunReportSearch()
		@standardizationDryRunReportSearchController = new StandardizationDryRunReportSearchController
			model: searchModel
		# @listenTo(@standardizationDryRunReportSearchController, 'countUpdated', @searchCountUpdated)
		
	render: ->
		$(@el).empty()
		$(@el).html @template()
		@$(".bv_dryRunSearchController").html @standardizationDryRunReportSearchController.render().el
		@$('.bv_exceededMaxDisplayLimit').hide()
		@$('.bv_getStandardizationDryRunReportError').hide()
		@
	@

	handleSearchClicked: ->
		@standardizationDryRunReportSearchController.updateSearchCount()
		.then((count) =>
			@$('.bv_searchRunning').show()
			@$('.bv_search').addClass("disabled")
			maxResults = @standardizationDryRunReportSearchController.model.get("maxResults")
			@$('.bv_loadingStandardizationDryRunReportText').text("Please wait, fetching #{Math.min(count, if maxResults == null then Infinity else maxResults)} results")
			@$('.bv_loadingStandardizationDryRunReport').show()
			requestData = @standardizationDryRunReportSearchController.model.toJSON()
			@standardizationDryRunReportSearchController.getDryRunSearch(false)
			.then((json) =>
				@$('.bv_searchRunning').hide()
				@$('.bv_search').removeClass("disabled")
				@$('.bv_loadingStandardizationDryRunReport').hide()
				if @standardizationDryRunReportSummaryTableController?
					@standardizationDryRunReportSummaryTableController.undelegateEvents()
				@$(".bv_standardizationDryRunReportTable").show()
				@standardizationDryRunReportSummaryTableController = new StandardizationDryRunReportSummaryTableController
					collection: new Backbone.Collection json
				@$(".bv_standardizationDryRunReportTable").html @standardizationDryRunReportSummaryTableController.render().el
			)
			.catch((error) => 
				@$('.bv_searchRunning').hide()
				@$('.bv_search').removeClass("disabled")
				@$('.bv_loadingStandardizationDryRunReport').hide()
				@$('.bv_getStandardizationDryRunReportError').show()
				@$('.bv_standardizerControlsWrapper').hide()
			)
		)
		.catch((error) =>
			@$('.bv_searchRunning').hide()
			@$('.bv_search').removeClass("disabled")
			@$('.bv_loadingStandardizationDryRunReport').hide()
			@$('.bv_getStandardizationDryRunReportError').show()
			@$('.bv_standardizerControlsWrapper').hide()
			console.error(error)
		)
		
		

class StandardizationDryRunReportSummaryTableController extends Backbone.View

	events: ->
		"click .selectBox": "handleDropDownClicked"
		"change .bv_dryRunReportColumnCheckBoxes ": "handleHideShowCheckboxChanged"

	initialize: ->
		@expanded = false


	updateColumnVisibility: =>
		checkboxes = @$(".bv_dryRunReportColumnCheckBoxes").find("input");
		checkboxes.each (i, checkbox) =>
			@setColumnVisibility(checkbox.id, checkbox.checked)

	handleDropDownClicked: ->
		checkboxes = @$(".bv_dryRunReportColumnCheckBoxes")
		if !@expanded
			checkboxes.css("display","inline-block");
			@expanded = true
		else
			checkboxes.css("display","none");

			@expanded = false
		return

	handleHideShowCheckboxChanged: (el) ->
		iCol = el.target.id
		checked = $(el.target).is(':checked')
		visible = false
		if checked? && checked
			visible = true
		@setColumnVisibility(iCol, visible)
	
	setColumnVisibility: (iCol, visible) ->
		@oTable.fnSetColumnVis iCol, visible

	render: =>
		@template = _.template($("#StandardizationDryRunReportSummaryTableView").html())
		$(@el).html @template
		if @collection.models.length > 0
			@collection.each (result) =>
				sdrrrsc = new StandardizationDryRunReportRowSummaryController
					model: result
				@$("tbody").append sdrrrsc.render().el

		$.fn.dataTableExt.oApi.fnGetColumnData = (oSettings, iColumn, bUnique, bFiltered, bIgnoreEmpty) ->
			# check that we have a column id
			if typeof iColumn == 'undefined'
				return new Array
			# by default we only want unique data
			if typeof bUnique == 'undefined'
				bUnique = true
			# by default we do want to only look at filtered data
			if typeof bFiltered == 'undefined'
				bFiltered = true
			# by default we do not want to include empty values
			if typeof bIgnoreEmpty == 'undefined'
				bIgnoreEmpty = true
			# list of rows which we're going to loop through
			aiRows = undefined
			# use only filtered rows
			if bFiltered == true
				aiRows = oSettings.aiDisplay
			else
				aiRows = oSettings.aiDisplayMaster
			# all row numbers
			# set up data array   
			asResultData = new Array
			i = 0
			c = aiRows.length
			while i < c
				iRow = aiRows[i]
				aData = @fnGetData(iRow)
				sValue = aData[iColumn]
				# ignore empty values?
				if bIgnoreEmpty == true and sValue.length == 0
					i++
					continue
				else if bUnique == true and jQuery.inArray(sValue, asResultData) > -1
					i++
					continue
				else
					asResultData.push sValue
				i++
			asResultData.sort()

		fnCreateSelect = (aData) ->
			r = '<select><option value=""></option>'
			i = undefined
			iLen = aData.length
			i = 0
			while i < iLen
				r += '<option value="' + aData[i] + '">' + aData[i] + '</option>'
				i++
			r + '</select>'

		oTable = @$(".bv_standardizationDryRunReportSummaryTable").dataTable
				bAutoWidth: false
				bLengthChange: true
				aLengthMenu: [ [10, 15, 25, 50, 100, -1], [10, 15, 25, 50, 100, "All"] ],
				iDisplayLength: 20
				sPaginationType: "full_numbers"
				fnRowCallback: (row, data, index) =>
					$('.bv_parentStructure', row).html "<img src='/cmpdreg/structureimage/parent/"+data[0]+"?hSize=300&wSize=300'>"
					data[1] = "<img src='/cmpdreg/structureimage/parent/"+data[0]+"?hSize=300&wSize=300'>"
					$('.bv_standardizedStructure', row).html "<img src='/cmpdreg/structureimage/standardization/"+data[0]+"?hSize=300&wSize=300'>"
					data[2] = "<img src='/cmpdreg/structureimage/standardization/"+data[0]+"?hSize=300&wSize=300'>"
					$('.bv_asDrawnStructure', row).html "<img src='/cmpdreg/structureimage/originallydrawnas/"+data[0]+"?hSize=300&wSize=300'>"
					data[3] = "<img src='/cmpdreg/structureimage/originallydrawnas/"+data[0]+"?hSize=300&wSize=300'>"
				oLanguage:
					sSearch: "Filter results: " #rename summary table's search bar

		filters = ['Corporate ID', 'Standardization Status', 'Standardization Comment', 'Registration Status', 'Registration Comment', 'Structure Change', 'Display Change', 'New Duplicates', 'Existing Duplicates', 'Delta Mol. Weight', 'New Mol. Weight', 'Old Mol. Weight', 'As Drawn Display Change']
		@.$('thead tr.bv_colFilters th').each (i) ->
			if @innerHTML in filters
				@innerHTML = fnCreateSelect(oTable.fnGetColumnData(i))
				$('select', this).change ->
					if $(this).val() != ""
						# Filter based on value
						oTable.fnFilter "^"+$(this).val()+"$", i, true
					else
						# If Filter is not set then remove the filter
						oTable.fnFilter('', i)
					return
				return
			else
				@innerHTML = ""

		@oTable = oTable
		@updateColumnVisibility()
		@

class StandardizationController extends Backbone.View
	moduleLaunchName: "standardization"
	template: _.template($("#StandardizationView").html())

	events: ->
		"click .bv_refresh": "handleRefreshClicked"
		"click .bv_executeDryRun": "handleExecuteDryRunClicked"
		"click .bv_executeStandardization": "handleExecuteStandardizationClicked"
		"click .bv_standardizationCompleteModalCloseBtn": "handleStandardizationCompleteModalCloseClicked"

	initialize: ->
		@openStandardizationControllerSocket()
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_standardizerControlsWrapper').hide()
		@$('.bv_getStandardizationHistoryError').hide()
		@$('.bv_executeDryRunError').hide()
		@$('.bv_executeStandardizationError').hide()
		@standardizationReasonPanel = new StandardizationReasonPanelController
			el: @$('.bv_standardizationReasonPanelView')
		@standardizationReasonPanel.on 'readyForExecution', (reason) =>
			@socket.emit 'executeDryRunOrStandardization', {runType:'standardization', username: window.AppLaunchParams.loginUserName, reason: reason}
		@standardizationReasonPanel.on 'executionCancelled', () =>
			@enableExecuteButtons()

		@standardizationReasonPanel.render()
		# @$('.bv_standardizationReasonPanel').hide()
		@getStandardizationHistory()
		@setupCurrentSettingsController()

	openStandardizationControllerSocket: ->
		unless @socket?
			@socket = io '/standardizationController:connected'
			@socket.on 'dryRunOrStandardizationInProgress', (runType) =>
				if runType is 'dryRun'
					@$('.bv_executingStandardizationDryRunModal').modal
						backdrop: 'static'
					@$('.bv_executingStandardizationDryRunModal').modal 'show'
				else if runType is 'standardization'
					@$('.bv_executingStandardizationModal').modal
						backdrop: 'static'
					@$('.bv_executingStandardizationModal').modal 'show'

			@socket.on 'dryRunOrStandardizationComplete', (runType, report) =>
				if runType is 'dryRun'
					@$('.bv_executingStandardizationDryRunModal').modal 'hide'
					@initialize()
				else if runType is 'standardization'
					@$('.bv_executingStandardizationModal').modal 'hide'
					@$('.bv_standardizationCompleteRecordedDate').html UtilityFunctions::convertMSToYMDDate report.recordedDate
					@$('.bv_standardizationCompleteStructuresStandardizedCount').html report.structuresStandardizedCount
					@$('.bv_standardizationCompleteStandardizationErrorCount').html report.standardizationErrorCount
					@$('.bv_standardizationCompleteRegistrationErrorCount').html report.registrationErrorCount
					@$('.bv_standardizationCompleteChangedStructureCount').html report.changedStructureCount
					@$('.bv_standardizationCompleteDisplayChangeCount').html report.displayChangeCount
					@$('.bv_standardizationCompleteNewDuplicateCount').html report.newDuplicateCount
					@$('.bv_standardizationCompleteAsDrawnDisplayChangeCount').html report.asDrawnDisplayChangeCount
					@$('.bv_standardizationCompleteExistingDuplicateCount').html report.existingDuplicateCount
					@$('.bv_standardizationCompleteModal').modal
						backdrop: 'static'
					@$('.bv_standardizationCompleteModal').modal 'show'

			@socket.on 'dryRunOrStandardizationError', (runType, report) =>
				if runType is 'dryRun'
					@$('.bv_executingStandardizationDryRunModal').modal 'hide'
					@$('.bv_executeDryRunError').show()
				else if runType is 'standardization'
					@$('.bv_executingStandardizationModal').modal 'hide'
					@$('.bv_executeStandardizationError').show()
				# @$('.bv_standardizationDryRunReportStats').hide()
				# @$('.bv_standardizationDryRunReport').hide()
				# @$('.bv_downloadStandardizationDryRunFiles').hide()
				@$('.bv_standardizerControlsWrapper').hide()

	setupCurrentSettingsController: ->
		if @currentSettingsController?
			@currentSettingsController.undelegateEvents()
		@currentSettingsController = new StandardizationCurrentSettingsController
			el: @$('.bv_currentSettings')

	getStandardizationHistory: ->
		$.ajax
			type: 'GET'
			url: "/cmpdReg/getStandardizationHistory"
			success: (history) =>
				@$('.bv_standardizerControlsWrapper').show()
				mostRecentHistoryEntry = _.max history, (row) =>
					row.id
				runningDryRunOrStandardization = @isDryRunOrStandardizationInProgress mostRecentHistoryEntry

				unless runningDryRunOrStandardization
					@setupStandardizationHistorySummaryTable history
					@setupExecuteButtons mostRecentHistoryEntry
					@setupLastDryRunReportSummary(mostRecentHistoryEntry)
			error: (err) =>
				@$('.bv_getStandardizationHistoryError').show()

	isDryRunOrStandardizationInProgress: (mostRecentHistoryEntry) ->
		dryRunStatus = mostRecentHistoryEntry.dryRunStatus
		standardizationStatus = mostRecentHistoryEntry.standardizationStatus
		if dryRunStatus is 'running'
			@$('.bv_executingStandardizationDryRunModal').modal
				backdrop: 'static'
			@$('.bv_executingStandardizationDryRunModal').modal 'show'
			return true
		else if standardizationStatus is 'running'
			@$('.bv_executingStandardizationModal').modal
				backdrop: 'static'
			@$('.bv_executingStandardizationModal').modal 'show'
			return true
		else
			return false

	setupStandardizationHistorySummaryTable: (history) ->
		if @standardizationHistorySummaryTableController?
			@standardizationHistorySummaryTableController.undelegateEvents()
		@standardizationHistorySummaryTableController = new StandardizationHistorySummaryTableController
			collection: new Backbone.Collection history
		@$(".bv_standardizationHistory").html @standardizationHistorySummaryTableController.render().el

	setupExecuteButtons: (mostRecentHistory) ->
		dryRunStatus = mostRecentHistory.dryRunStatus
		standardizationStatus = mostRecentHistory.standardizationStatus
		#Execution Dry-run Disabled when most recent history dryRunStatus is running or standardizationStatus running
		if dryRunStatus is "running" or standardizationStatus is "running"
			@$('.bv_executeDryRun').attr 'disabled', 'disabled'
		#Execute Standardization Disabled when most recent history dryRunStatus != "complete" or standardizationStatus == "running" or standardization == "complete"
		if dryRunStatus != 'complete' or standardizationStatus is 'running' or standardizationStatus is 'complete'
			@$('.bv_executeStandardization').attr 'disabled', 'disabled'


	setupLastDryRunReportSummary: (mostRecentHistory)->		
		standardizationStatus = mostRecentHistory.standardizationStatus
		dryRunStatus = mostRecentHistory.dryRunStatus
		if dryRunStatus == "complete" and standardizationStatus != "complete"
			@setupLastDryRunReportStatsSummaryTable()
			@$(".bv_standardizationDryRunReportStats").show()
			@standardizationDryRunReportSummaryController = new StandardizationDryRunReportSummaryController
				mostRecentHistory: mostRecentHistory
			@$(".bv_standardizationDryRunReport").html @standardizationDryRunReportSummaryController.render().el
			@$(".bv_standardizationDryRunReport").show()
		else
			@$(".bv_standardizationDryRunReportStats").hide()

		
	setupLastDryRunReportStatsSummaryTable: ->
		if @standardizationDryRunReportStatsController?
			@standardizationDryRunReportStatsController.undelegateEvents()
		@standardizationDryRunReportStatsController = new StandardizationDryRunReportStatsController
			el: @$(".bv_standardizationDryRunReportStats")

	handleRefreshClicked: ->
		@initialize()

	handleExecuteDryRunClicked: ->
		@disableExecuteButtons()
		@socket.emit 'executeDryRunOrStandardization', {runType:'dryRun'}

	handleExecuteStandardizationClicked: =>
		@disableExecuteButtons()
		@standardizationReasonPanel.show()

	handleStandardizationCompleteModalCloseClicked: ->
		#refreshes standardization history summary table and last dry run report summary table
		@$('.bv_standardizationCompleteModal').modal 'hide'
		@initialize()

	enableExecuteButtons: ->
		@$('.bv_executeDryRun').removeAttr 'disabled'
		@$('.bv_executeStandardization').removeAttr 'disabled'

	disableExecuteButtons: ->
		@$('.bv_executeDryRun').attr 'disabled', 'disabled'
		@$('.bv_executeStandardization').attr 'disabled', 'disabled'
		
class StandardizationReasonPanelController extends Backbone.View
	template: _.template($("#StandardizationReasonPanelView").html())

	render: =>
		@$el.empty()
		@$el.html @template()
		@$('.bv_standardizationReasonPanel').on "show", =>
			@$('.bv_reasonForStandardization').focus()
		@

	events: ->
		"input .bv_reasonForStandardization": "handleReasonChanged"
		"click .bv_standardizationReasonPanelExecuteBtn": "handleExecuteClicked"
		"click .bv_standardizationReasonPanelCancelBtn": "handleCancelClicked"

	show: =>
		@$('.bv_standardizationReasonPanel').modal
			backdrop: "static"
		@$('.bv_standardizationReasonPanel').modal "show"

	handleReasonChanged: =>
		val = @$('.bv_reasonForStandardization')[0].value
		if val? && val != ""
			@$('.bv_standardizationReasonPanelExecuteBtn').removeAttr 'disabled'
		else
			@$('.bv_standardizationReasonPanelExecuteBtn').attr 'disabled', 'disabled'

	handleExecuteClicked: =>
		@$('.bv_standardizationReasonPanel').modal "hide"
		@trigger 'readyForExecution', @$('.bv_reasonForStandardization')[0].value

	handleCancelClicked: =>
		console.log 'hiasdf'
		@$('.bv_standardizationReasonPanel').modal "hide"
		@trigger 'executionCancelled'

