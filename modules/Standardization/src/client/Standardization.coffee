class window.StandardizationCurrentSettingsController extends Backbone.View
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

class window.DownloadDryResultsController extends Backbone.View
	template: _.template($("#DownloadDryRunResultsView").html())


	events: ->
		"click .bv_download": "handleDownloadClicked"
		
	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		if @options.mostRecentHistory.standardizationStatus == null && @options.mostRecentHistory.dryRunStatus == "complete" && @options.mostRecentHistory.dryRunStandardizationChangesCount > 0 && @options.mostRecentHistory.dryRunStandardizationChangesCount? > 0
			@$('.bv_download').prop('disabled', false);
		else
			@$('.bv_download').prop("disabled",true);
			

	getFileNameFromHeader: (header) ->
		return header.split(';')[1].split('=')[1]

	handleDownloadClicked: (event) =>
		@$('.bv_running').show()
		@$('.bv_download').addClass("disabled")
		url = "/cmpdReg/standardizationDryRunFiles"
		fileName = "download.sdf"
		fetch(url)
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



class window.StandardizationHistoryRowSummaryController extends Backbone.View
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

class window.StandardizationHistorySummaryTableController extends Backbone.View

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

class window.StandardizationDryRunReportStatsController extends Backbone.View
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
				[stats.structuresStandardizedCount, stats.changedStructureCount, stats.displayChangeCount, stats.newDuplicateCount, stats.asDrawnDisplayChangeCount, stats.existingDuplicateCount]
			]
			"aoColumns": [
				{ "sTitle": "# Structures Standardized" },
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

class window.StandardizationDryRunReportRowSummaryController extends Backbone.View
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

		$(@el).html(@template(toDisplay))

		@

	roundToTwo: (num) ->
		+(Math.round(num + 'e+2') + 'e-2')

class window.StandardizationDryRunReportSummaryTableController extends Backbone.View

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

			filters = ['Corporate ID', 'Structure Change', 'Display Change', 'New Duplicates', 'Existing Duplicates', 'Delta Mol. Weight', 'New Mol. Weight', 'Old Mol. Weight', 'As Drawn Display Change']
			@.$('thead tr.bv_colFilters th').each (i) ->
				if @innerHTML in filters
					@innerHTML = fnCreateSelect(oTable.fnGetColumnData(i))
					$('select', this).change ->
						oTable.fnFilter $(this).val(), i
						return
					return
				else
					@innerHTML = ""

			@oTable = oTable
			@updateColumnVisibility()
		@

class window.StandardizationController extends Backbone.View
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
		@$('.bv_getStandardizationDryRunReportError').hide()
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
				@$('.bv_standardizationDryRunReportStats').hide()
				@$('.bv_standardizationDryRunReport').hide()
				@$('.bv_downloadStandardizationDryRunFiles').hide()
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
					@setupLastDryRunReportSummaryTable(mostRecentHistoryEntry)
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
		if mostRecentHistory.dryRunStandardizationChangesCount < 1
			@$('.bv_executeStandardization').attr 'disabled', 'disabled'

	setupLastDryRunReportSummaryTable: (mostRecentHistory)->
		maxDisplayCount = window.conf.cmpdreg.serverSettings.maxStandardizationDisplay
		@downloadDryRunResultsController = new DownloadDryResultsController
			mostRecentHistory: mostRecentHistory
		@$(".bv_downloadStandardizationDryRunFiles").html @downloadDryRunResultsController.render().el
		@$('.bv_exceededMaxDisplayLimit').hide()
		# Only show dry run table if dry run execution
		dryRunStatus = mostRecentHistory.dryRunStatus
		standardizationStatus = mostRecentHistory.standardizationStatus
		dryRunStandardizationChangesCount = mostRecentHistory.dryRunStandardizationChangesCount
		if dryRunStatus == "complete" and standardizationStatus != "complete"
			if dryRunStandardizationChangesCount < maxDisplayCount
				@$('.bv_loadingStandardizationDryRunReportText').text("Please wait, loading #{dryRunStandardizationChangesCount} standardization changes")
				@$('.bv_loadingStandardizationDryRunReport').show()
				$.ajax
					type: 'GET'
					url: "/cmpdReg/standardizationDryRun?reportOnly=true"
					success: (dryRunReport) =>
						@$('.bv_loadingStandardizationDryRunReport').hide()
						if @standardizationDryRunReportSummaryTableController?
							@standardizationDryRunReportSummaryTableController.undelegateEvents()
						if dryRunReport.length > 0
							@setupLastDryRunReportStatsSummaryTable()
							@$(".bv_standardizationDryRunReport").show()
							@$(".bv_standardizationDryRunReportStats").show()
							@standardizationDryRunReportSummaryTableController = new StandardizationDryRunReportSummaryTableController
								collection: new Backbone.Collection dryRunReport
							@$(".bv_standardizationDryRunReport").html @standardizationDryRunReportSummaryTableController.render().el
						else
							@$(".bv_standardizationDryRunReport").hide()
							@$(".bv_standardizationDryRunReportStats").hide()
					error: (err) =>
						@$('.bv_loadingStandardizationDryRunReport').hide()
						@$('.bv_getStandardizationDryRunReportError').show()
						@$('.bv_standardizerControlsWrapper').hide()
			else
				@$('.bv_exceededMaxDisplayLimit').show()
		
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
		
class window.StandardizationReasonPanelController extends Backbone.View
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
