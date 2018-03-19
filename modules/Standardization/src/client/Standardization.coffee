class window.StandardizationCurrentSettingsController extends Backbone.View
	template: _.template($("#StandardizationCurrentSettingsView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@getCurrentSettings()

	getCurrentSettings: ->
		$.ajax
			type: 'GET'
			url: "/cmpdReg/getStandardizationSettings"
			success: (currentSettings) =>
				console.log "got current settings"
				console.log currentSettings
				@setupCurrentSettingsTable currentSettings
			error: (err) =>
				console.log "error getting current settings"
				#TODO: error handling

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

		$(@el).html(@template(toDisplay))
		@

class window.StandardizationHistorySummaryTableController extends Backbone.View

	render: =>
		@template = _.template($("#StandardizationHistorySummaryTableView").html())
		$(@el).html @template
		structuresStandardizedCountInfo = "<li># Structures Standardized: Total number of structures run through the standardizer.</li>"
		structuresUpdatedCountInfo = "<li># Structures Updated: Count of parent structures that were changed as a result of standardization.</li>"
		changedStructureCountInfo = "<li># Structures Changed: Count of structures that are no longer the same as their parent structure taking into account tautomers.</li>"
		displayChangeCountInfo = "<li># Display Change: Count of structures that are no longer exact string matches for their parent structure.</li>"
		newDuplicateCountInfo = "<li># New Duplicates: Count of structures that are now the same as one or more parent structures taking into account tautomers, stereo comments and stereo categories.</li>"
		asDrawnDisplayChangeCountInfo = "<li># As Drawn Display Change: Count of structures that are no longer exact string matches for their originally drawn as structure.</li>"
		existingDuplicateCountIinfo = "<li># Existing Duplicates: Count of structures that were already the same as one or more parent structures taking into account tautomers, stereo comments and stereo categories.</li>"
		settingsHashInfo = "<li>Settings Hash: Hash of the effective standardization settings</li>"

		@$('.bv_standardizationHistoryPopover').popover
			title: "Standardization History Table Attributes"
			content: "<ul>#{structuresStandardizedCountInfo}#{structuresUpdatedCountInfo}#{changedStructureCountInfo}#{displayChangeCountInfo}#{newDuplicateCountInfo}#{asDrawnDisplayChangeCountInfo}#{existingDuplicateCountIinfo}#{settingsHashInfo}</ul>"
		@$("body").tooltip selector: '.bv_structuresStandardizedCountPopover'
		console.dir @collection
		if @collection.models.length is 0
			#TODO: display message indicating no results were found
		else
			@collection.each (run) =>
				shrsc = new StandardizationHistoryRowSummaryController
					model: run
				@$("tbody").append shrsc.render().el

			@$(".bv_standardizationHistorySummaryTable").dataTable
				aaSorting: [[ 0, "desc" ]]
				oLanguage:
					sSearch: "Filter history: " #rename summary table's search bar

		@

class window.StandardizationDryRunReportStatsController extends Backbone.View
	template: _.template($("#StandardizationDryRunReportStatsView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		structuresStandardizedCountInfo = "<li># Structures Standardized: Total number of structures run through the standardizer.</li>"
		structuresUpdatedCountInfo = "<li># Structures Updated: Count of parent structures that were changed as a result of standardization.</li>"
		changedStructureCountInfo = "<li># Structures Changed: Standardized structure is no longer the same as it's parent structure taking into account tautomers.</li>"
		displayChangeCountInfo = "<li># Display Change: Standardized structure is no longer an exact string matches for it's parent structure.</li>"
		newDuplicateCountInfo = "<li># New Duplicates: List of parent corp names that are now the same structure as the standardized structure taking into account tautomers, stereo comments and stereo categories.</li>"
		asDrawnDisplayChangeCountInfo = "<li># As Drawn Display Change: Count of structures that are no longer exact string matches for their originally drawn as structure.</li>"
		existingDuplicateCountIinfo = "<li># Existing Duplicates: List of parent corp names that were already the same structure as the standardized structure taking into account tautomers, stereo comments and stereo categories.</li>"

		@$('.bv_dryRunResultsPopover').popover
			title: "Dry Run Results Table Attributes"
			content: "<ul>#{structuresStandardizedCountInfo}#{structuresUpdatedCountInfo}#{changedStructureCountInfo}#{displayChangeCountInfo}#{newDuplicateCountInfo}#{asDrawnDisplayChangeCountInfo}#{existingDuplicateCountIinfo}</ul>"
		@$("body").tooltip selector: '.bv_structuresStandardizedCountPopover'

		@getDryRunReportStats()

	getDryRunReportStats: ->
		$.ajax
			type: 'GET'
			url: "/cmpdReg/standardizationDryRunStats"
			success: (dryRunStats) =>
				console.log "got dry run stats"
				console.log dryRunStats
				@setupDryRunStatsTable dryRunStats
			error: (err) =>
				console.log "error getting dry run stats"
				#TODO: error handling

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
			deltaMolWeight: @model.get('newMolWeight')- @model.get('oldMolWeight')
			newMolWeight: @model.get('newMolWeight')
			oldMolWeight: @model.get('oldMolWeight')
			asDrawnDisplayChange: @model.get('asDrawnDisplayChange')

		$(@el).html(@template(toDisplay))

		@

class window.StandardizationDryRunReportSummaryTableController extends Backbone.View

	render: =>
		@template = _.template($("#StandardizationDryRunReportSummaryTableView").html())
		$(@el).html @template
		console.dir @collection
		if @collection.models.length is 0
			#TODO: display message indicating no results were found
		else
			@collection.each (result) =>
				sdrrrsc = new StandardizationDryRunReportRowSummaryController
					model: result
				@$("tbody").append sdrrrsc.render().el

			@$(".bv_standardizationDryRunReportSummaryTable").dataTable
					bAutoWidth: false
					fnRowCallback: (row, data, index) =>
						$('.bv_parentStructure', row).html "<img src='/cmpdreg/structureimage/parent/"+data[0]+"?hSize=200&wSize=200'>"
						data[1] = "<img src='/cmpdreg/structureimage/parent/"+data[0]+"?hSize=200&wSize=200'>"
						$('.bv_standardizedStructure', row).html "<img src='/cmpdreg/structureimage/standardization/"+data[0]+"?hSize=200&wSize=200'>"
						data[2] = "<img src='/cmpdreg/structureimage/standardization/"+data[0]+"?hSize=200&wSize=200'>"
						$('.bv_asDrawnStructure', row).html "<img src='/cmpdreg/structureimage/originallydrawnas/"+data[0]+"?hSize=200&wSize=200'>"
						data[3] = "<img src='/cmpdreg/structureimage/originallydrawnas/"+data[0]+"?hSize=200&wSize=200'>"
					oLanguage:
						sSearch: "Filter results: " #rename summary table's search bar
					"aoColumnDefs": [
						{ "sWidth": "10%", "aTargets": [0] },
						{ "sWidth": "10%", "aTargets": [1] },
						{ "sWidth": "10%", "aTargets": [2] },
						{ "sWidth": "10%", "aTargets": [3] }
					]

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
		#TODO maybe call current settings controller after getting history
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
				console.log 'dryRunOrStandardizationComplete'
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
				console.log "got history"
				console.log history
				mostRecentHistoryEntry = _.max history, (row) =>
					row.id
				runningDryRunOrStandardization = @isDryRunOrStandardizationInProgress mostRecentHistoryEntry

				unless runningDryRunOrStandardization
					@setupStandardizationHistorySummaryTable history
					@setupExecuteButtons mostRecentHistoryEntry
					@setupLastDryRunReportSummaryTable()
			error: (err) =>
				console.log "error getting history"
				#TODO: error handling

	isDryRunOrStandardizationInProgress: (mostRecentHistoryEntry) ->
		dryRunStatus = mostRecentHistoryEntry.dryRunStatus
		standardizationStatus = mostRecentHistoryEntry.standardizationStatus
		if dryRunStatus is 'running' #TODO change back to running
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
		console.log "dryRunStatus: " + dryRunStatus
		console.log "standardizationStatus: " + standardizationStatus
		#Execution Dry-run Disabled when most recent history dryRunStatus is running or standardizationStatus running
		if dryRunStatus is "running" or standardizationStatus is "running"
			@$('.bv_executeDryRun').attr 'disabled', 'disabled'
		#Execute Standardization Disabled when most recent history dryRunStatus != "complete" or standardizationStatus == "running" or standardization == "complete"
		if dryRunStatus != 'complete' or standardizationStatus is 'running' or standardizationStatus is 'complete'
			@$('.bv_executeStandardization').attr 'disabled', 'disabled'

	setupLastDryRunReportSummaryTable: ->
		$.ajax
			type: 'GET'
			url: "/cmpdReg/standardizationDryRun?reportOnly=true"
			success: (dryRunReport) =>
				console.log "got dry run report"
				console.log dryRunReport
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
				console.log "error getting dry run report"
				#TODO: error handling

	setupLastDryRunReportStatsSummaryTable: ->
		if @standardizationDryRunReportStatsController?
			@standardizationDryRunReportStatsController.undelegateEvents()
		@standardizationDryRunReportStatsController = new StandardizationDryRunReportStatsController
			el: @$(".bv_standardizationDryRunReportStats")

	handleRefreshClicked: ->
		@initialize()

	handleExecuteDryRunClicked: ->
		@disableExecuteButtons()
		@socket.emit 'executeDryRunOrStandardization', 'dryRun'
		#TODO: error handling
		
	handleExecuteStandardizationClicked: ->
		@disableExecuteButtons()
		@socket.emit 'executeDryRunOrStandardization', 'standardization'
		#TODO: error handling

	handleStandardizationCompleteModalCloseClicked: ->
		#refreshes standardization history summary table and last dry run report summary table
		@$('.bv_standardizationCompleteModal').modal 'hide'
		@getStandardizationHistory()
		@$('.bv_executeDryRun').removeAttr 'disabled'
		@$('.bv_executeStandardization').attr 'disabled', 'disabled'

	enableExecuteButtons: ->
		@$('.bv_executeDryRun').removeAttr 'disabled'
		@$('.bv_executeStandardization').removeAttr 'disabled'

	disableExecuteButtons: ->
		@$('.bv_executeDryRun').attr 'disabled', 'disabled'
		@$('.bv_executeStandardization').attr 'disabled', 'disabled'
