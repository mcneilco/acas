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

			#TODO decide btw tooltips (flickers for columns that are hidden on initial load (iow have horizontal scroll) and popovers (will sort column too when press on it and not in right location when have horizontal scroll)
			#https://github.com/twbs/bootstrap/issues/15590
			#TODO maybe just have one info icon that's a popover and a list of descriptions
			@$('.bv_structuresStandardizedCountPopover').popover
				content: "# Structures Standardized: "
			@$("body").tooltip selector: '.bv_structuresStandardizedCountPopover'
			@$('.bv_changedStructureCountPopover').popover
				content: "# Structures Changed: "
			@$("body").tooltip selector: '.bv_changedStructureCountPopover'
			@$('.bv_displayChangeCountPopover').popover
				content: "# Display Change: "
			@$("body").tooltip selector: '.bv_displayChangeCountPopover'
			@$('.bv_newDuplicateCountPopover').popover
				content: "# New Duplicates: "
			@$("body").tooltip selector: '.bv_newDuplicateCountPopover'
			@$('.bv_asDrawnDisplayChangeCountPopover').popover
				content: "# As Drawn Display Change: "
			@$("body").tooltip selector: '.bv_asDrawnDisplayChangeCountPopover'
			@$('.bv_existingDuplicateCountPopover').popover
				content: "# Existing Duplicates: "
			@$("body").tooltip selector: '.bv_existingDuplicateCountPopover'
			@$('.bv_settingsHashPopover').popover
				content: "Settings Hash: "
			@$("body").tooltip selector: '.bv_settingsHashPopover'
			@$('.bv_dryRunStatusPopover').popover
				content: "Dry-Run Status: "
			@$("body").tooltip selector: '.bv_dryRunStatusPopover'
			@$('.bv_dryRunStartPopover').popover
				content: "Dry-Run Start: "
			@$("body").tooltip selector: '.bv_dryRunStartPopover'
			@$('.bv_dryRunCompletePopover').popover
				content: "Dry-Run Complete: "
			@$("body").tooltip selector: '.bv_dryRunCompletePopover'
			@$('.bv_standardizationStatusPopover').popover
				content: "Standardization Status: "
			@$("body").tooltip selector: '.bv_standardizationStatusPopover'
			@$('.bv_standardizationStartPopover').popover
				content: "Standardization Start: "
			@$("body").tooltip selector: '.bv_standardizationStartPopover'
			@$('.bv_standardizationCompletePopover').popover
				content: "Standardization Complete: "
			@$("body").tooltip selector: '.bv_standardizationCompletePopover'

#			@$('.bv_structuresStandardizedCountTooltip').tooltip
#				title: "# Structures Standardized: "
#			@$('.bv_changedStructureCountTooltip').tooltip
#				title: "# Structures Changed: "
#			@$('.bv_displayChangeCountTooltip').tooltip
#				title: "# Display Change: "
#			@$('.bv_newDuplicateCountTooltip').tooltip
#				title: "# New Duplicates: "
#			@$('.bv_asDrawnDisplayChangeCountTooltip').tooltip
#				title: "# As Drawn Display Change: "
#			@$('.bv_existingDuplicateCountTooltip').tooltip
#				title: "# Existing Duplicates: "
#			@$('.bv_settingsHashTooltip').tooltip
#				title: "Settings Hash: "
#			@$('.bv_dryRunStatusTooltip').tooltip
#				title: "Dry-Run Status: "
#			@$('.bv_dryRunStartTooltip').tooltip
#				title: "Dry-Run Start: "
#			@$('.bv_dryRunCompleteTooltip').tooltip
#				title: "Dry-Run Complete: "
#			@$('.bv_standardizationStatusTooltip').tooltip
#				title: "Standardization Status: "
#				container: ".bv_standardizationStatusTooltip"
#			@$('.bv_standardizationStartTooltip').tooltip
#				title: "Standardization Start: "
#			@$('.bv_standardizationCompleteTooltip').tooltip
#				title: "Standardization Complete: "

		@

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
					fnRowCallback: (row, data, index) =>
						$('.bv_parentStructure', row).html "<img src='/cmpdreg/structureimage/parent/"+data[0]+"'>"
						data[1] = "<img src='/cmpdreg/structureimage/parent/"+data[0]+"'>"
						$('.bv_standardizedStructure', row).html "<img src='/cmpdreg/structureimage/standardization/"+data[0]+"'>"
						data[2] = "<img src='/cmpdreg/structureimage/standardization/"+data[0]+"'>"
						$('.bv_asDrawnStructure', row).html "<img src='/cmpdreg/structureimage/originallydrawnas/"+data[0]+"'>"
						data[3] = "<img src='/cmpdreg/structureimage/originallydrawnas/"+data[0]+"'>"
					oLanguage:
						sSearch: "Filter results: " #rename summary table's search bar

			#TODO decide btw tooltips (flickers for columns that are hidden on initial load (iow have horizontal scroll) and popovers (will sort column too when press on it and not in right location when have horizontal scroll)
			#https://github.com/twbs/bootstrap/issues/15590
			#TODO maybe just have one info icon that's a popover and a list of descriptions
#			@$('.bv_structuresStandardizedCountPopover').popover
#				content: "# Structures Standardized: "
#			@$("body").tooltip selector: '.bv_structuresStandardizedCountPopover'
#			@$('.bv_changedStructureCountPopover').popover
#				content: "# Structures Changed: "
#			@$("body").tooltip selector: '.bv_changedStructureCountPopover'
#			@$('.bv_displayChangeCountPopover').popover
#				content: "# Display Change: "
#			@$("body").tooltip selector: '.bv_displayChangeCountPopover'
#			@$('.bv_newDuplicateCountPopover').popover
#				content: "# New Duplicates: "
#			@$("body").tooltip selector: '.bv_newDuplicateCountPopover'
#			@$('.bv_asDrawnDisplayChangeCountPopover').popover
#				content: "# As Drawn Display Change: "
#			@$("body").tooltip selector: '.bv_asDrawnDisplayChangeCountPopover'
#			@$('.bv_existingDuplicateCountPopover').popover
#				content: "# Existing Duplicates: "
#			@$("body").tooltip selector: '.bv_existingDuplicateCountPopover'
#			@$('.bv_settingsHashPopover').popover
#				content: "Settings Hash: "
#			@$("body").tooltip selector: '.bv_settingsHashPopover'
#			@$('.bv_dryRunStatusPopover').popover
#				content: "Dry-Run Status: "
#			@$("body").tooltip selector: '.bv_dryRunStatusPopover'
#			@$('.bv_dryRunStartPopover').popover
#				content: "Dry-Run Start: "
#			@$("body").tooltip selector: '.bv_dryRunStartPopover'
#			@$('.bv_dryRunCompletePopover').popover
#				content: "Dry-Run Complete: "
#			@$("body").tooltip selector: '.bv_dryRunCompletePopover'
#			@$('.bv_standardizationStatusPopover').popover
#				content: "Standardization Status: "
#			@$("body").tooltip selector: '.bv_standardizationStatusPopover'
#			@$('.bv_standardizationStartPopover').popover
#				content: "Standardization Start: "
#			@$("body").tooltip selector: '.bv_standardizationStartPopover'
#			@$('.bv_standardizationCompletePopover').popover
#				content: "Standardization Complete: "
#			@$("body").tooltip selector: '.bv_standardizationCompletePopover'

#			@$('.bv_structuresStandardizedCountTooltip').tooltip
#				title: "# Structures Standardized: "
#			@$('.bv_changedStructureCountTooltip').tooltip
#				title: "# Structures Changed: "
#			@$('.bv_displayChangeCountTooltip').tooltip
#				title: "# Display Change: "
#			@$('.bv_newDuplicateCountTooltip').tooltip
#				title: "# New Duplicates: "
#			@$('.bv_asDrawnDisplayChangeCountTooltip').tooltip
#				title: "# As Drawn Display Change: "
#			@$('.bv_existingDuplicateCountTooltip').tooltip
#				title: "# Existing Duplicates: "
#			@$('.bv_settingsHashTooltip').tooltip
#				title: "Settings Hash: "
#			@$('.bv_dryRunStatusTooltip').tooltip
#				title: "Dry-Run Status: "
#			@$('.bv_dryRunStartTooltip').tooltip
#				title: "Dry-Run Start: "
#			@$('.bv_dryRunCompleteTooltip').tooltip
#				title: "Dry-Run Complete: "
#			@$('.bv_standardizationStatusTooltip').tooltip
#				title: "Standardization Status: "
#				container: ".bv_standardizationStatusTooltip"
#			@$('.bv_standardizationStartTooltip').tooltip
#				title: "Standardization Start: "
#			@$('.bv_standardizationCompleteTooltip').tooltip
#				title: "Standardization Complete: "

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
					@$('.bv_standardizationCompleteChangedStructureCount').html report.changedStructureCount
					@$('.bv_standardizationCompleteDisplayChangeCount').html report.displayChangeCount
					@$('.bv_standardizationCompleteNewDuplicateCount').html report.newDuplicateCount
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
					@$(".bv_standardizationDryRunReport").show()
					@standardizationDryRunReportSummaryTableController = new StandardizationDryRunReportSummaryTableController
						collection: new Backbone.Collection dryRunReport
					@$(".bv_standardizationDryRunReport").html @standardizationDryRunReportSummaryTableController.render().el
				else
					@$(".bv_standardizationDryRunReport").hide()
			error: (err) =>
				console.log "error getting dry run report"
				#TODO: error handling

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
