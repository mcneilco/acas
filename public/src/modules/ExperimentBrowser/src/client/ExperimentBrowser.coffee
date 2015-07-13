class window.ExperimentSearch extends Backbone.Model
	defaults:
		protocolCode: null
		experimentCode: null

class window.ExperimentSearchController extends AbstractFormController
	template: _.template($("#ExperimentSearchView").html())

	events:
		'change .bv_protocolName': 'updateModel'
		'change .bv_experimentCode': 'updateModel'
		'keyup .bv_experimentCode': 'updateExperimentCode'
		'click .bv_find': 'handleFindClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupProtocolSelect()


	updateModel: =>
		@model.set
			protocolCode: @$('.bv_protocolName').val()
			experimentCode: UtilityFunctions::getTrimmedInput @$('.bv_experimentCode')

	updateExperimentCode: =>
		experimentCode = $.trim(@$(".bv_experimentCode").val())
		unless experimentCode is ""
			@$(".bv_protocolKind").prop("disabled", true)
			@$(".bv_protocolName").prop("disabled", true)
		else
			@$(".bv_protocolKind").prop("disabled", false)
			@$(".bv_protocolName").prop("disabled", false)

	handleFindClicked: =>
		@trigger 'find'
		protocolCode = $(".bv_protocolName").val()
		#$(".bv_searchStatusIndicator").removeClass "hide"
		experimentCode = $.trim(@$(".bv_experimentCode").val())
		unless experimentCode is ""
			@doGenericExperimentSearch(experimentCode)
		else
			$.ajax
				type: 'GET'
			#url: "api/experiments/protocolCodename/#{protocolCode}"
				url: "api/experimentsForProtocol/#{protocolCode}"
				data:
					testMode: false
				success: (experiments) =>
					@setupExperimentSummaryTable experiments

	###$.get("/api/experiments/protocolCodename/#{protocolCode}", ( experiments ) =>
		@setupExperimentSummaryTable experiments
	)
	###

	###
	$.get( "/api/ExperimentsForProtocol", ( experiments ) =>
		@setupExperimentSummaryTable experiments
	)
	###


	doGenericExperimentSearch: (searchTerm) =>
		$.ajax
			type: 'GET'
			url: "/api/experiments/genericSearch/#{searchTerm}"
			dataType: "json"
			data:
				testMode: false
				fullObject: true
			success: (experiment) =>
				@setupExperimentSummaryTable [experiment]

	setupProtocolSelect: ->
		@protocolList = new PickListList()
		@protocolList.url = "/api/protocolKindCodes/"
		@protocolListController = new PickListSelectController
			el: @$('.bv_protocolKind')
			collection: @protocolList
			insertFirstOption: new PickList
				code: "any"
				name: "any"
			selectedCode: null



		@protocolNameList = new PickListList()
		@protocolNameList.url = "/api/protocolCodes/"
		@protocolNameListController = new PickListSelectController
			el: @$('.bv_protocolName')
			collection: @protocolNameList
			insertFirstOption: new PickList
				code: "any"
				name: "any"
			selectedCode: null

		$(@protocolListController.el).on "change", =>
			@protocolNameList.url = "/api/protocolCodes?protocolKind=#{$(@protocolListController.el).val()}"
			@protocolNameList.reset()
			@protocolNameList.fetch()


	selectedExperimentUpdated: (experiment) =>
		@trigger "selectedExperimentUpdated"
		experimentController = new ExperimentBaseController
			model: experiment
			el: $('.bv_experimentBaseController')
		#protocolFilter: "?protocolKind=FLIPR"
		experimentController.render()
		$(".bv_experimentBaseController").show()


	setupExperimentSummaryTable: (experiments) =>
		#@$(".bv_searchStatusIndicator").addClass "hide"
		$(".bv_experimentTableController").removeClass "hide"
		@experimentSummaryTable = new ExperimentSummaryTableController
			el: $(".bv_experimentTableController")
			collection: new ExperimentList experiments

		@experimentSummaryTable.on "selectedRowUpdated", @selectedExperimentUpdated

		@experimentSummaryTable.render()

class window.ExperimentSearch extends Backbone.Model
	defaults:
		protocolCode: null
		experimentCode: null

class window.ExperimentSimpleSearchController extends AbstractFormController
	template: _.template($("#ExperimentSimpleSearchView").html())
	genericSearchUrl: "/api/experiments/genericSearch/"
	codeNameSearchUrl: "/api/experiments/codename/"

	initialize: ->
		@includeDuplicateAndEdit = @options.includeDuplicateAndEdit
		@searchUrl = ""
		if @includeDuplicateAndEdit
			@searchUrl = @genericSearchUrl
		else
			@searchUrl = @codeNameSearchUrl


	events:
		'keyup .bv_experimentSearchTerm': 'updateExperimentSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()

	updateExperimentSearchTerm: (e) =>
		ENTER_KEY = 13
		experimentSearchTerm = $.trim(@$(".bv_experimentSearchTerm").val())
		if experimentSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@handleDoSearchClicked()
		else
			@$(".bv_doSearch").attr("disabled", true)

	handleDoSearchClicked: =>
		$(".bv_experimentTableController").addClass "hide"
		$(".bv_errorOccurredPerformingSearch").addClass "hide"
		experimentSearchTerm = $.trim(@$(".bv_experimentSearchTerm").val())
		$(".bv_searchTerm").val ""
		if experimentSearchTerm isnt ""
			$(".bv_noMatchingExperimentsFoundMessage").addClass "hide"
			$(".bv_experimentBrowserSearchInstructions").addClass "hide"
			$(".bv_searchExperimentsStatusIndicator").removeClass "hide"
			if !window.conf.browser.enableSearchAll and experimentSearchTerm is "*"
				$(".bv_moreSpecificExperimentSearchNeeded").removeClass "hide"
			else
				$(".bv_searchingExperimentsMessage").removeClass "hide"
				$(".bv_searchTerm").html experimentSearchTerm
				$(".bv_moreSpecificExperimentSearchNeeded").addClass "hide"
				@doSearch experimentSearchTerm

	doSearch: (experimentSearchTerm) =>
		# disable the search text field while performing a search
		@$(".bv_experimentSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless experimentSearchTerm is ""
			$.ajax
				type: 'GET'
				url: @searchUrl + experimentSearchTerm
				dataType: "json"
				data:
					testMode: false
			#fullObject: true
				success: (experiment) =>
					@trigger "searchReturned", experiment
				error: (result) =>
					@trigger "searchReturned", null
				complete: =>
					# re-enable the search text field regardless of if any results found
					@$(".bv_experimentSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false



class window.ExperimentRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#ExperimentRowSummaryView').html())

	render: =>
		date = @model.getCompletionDate()
		if date.isNew()
			date = "not recorded"
		else
			date = UtilityFunctions::convertMSToYMDDate(date.get('dateValue'))

		experimentBestName = @model.get('lsLabels').pickBestName()
		if experimentBestName
			experimentBestName = @model.get('lsLabels').pickBestName().get('labelText')
#		protocolBestName = @model.get('protocol').get('lsLabels').pickBestName()
#		if protocolBestName
#			protocolBestName = @model.get('protocol').get('lsLabels').pickBestName().get('labelText')
		toDisplay =
			experimentName: experimentBestName
			experimentCode: @model.get('codeName')
			protocolCode: @model.get('protocol').get("codeName")
#			protocolName: protocolBestName
			scientist: @model.getScientist().get('codeValue')
			status: @model.getStatus().get("codeValue")
			analysisStatus: @model.getAnalysisStatus().get("codeValue")
			completionDate: date
		$(@el).html(@template(toDisplay))

		@

class window.ExperimentSummaryTableController extends Backbone.View
	initialize: ->

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#ExperimentSummaryTableView').html())
		$(@el).html @template
		if @collection.models.length is 0
			$(".bv_noMatchingExperimentsFoundMessage").removeClass "hide"
			# display message indicating no results were found
		else
			$(".bv_noMatchingExperimentsFoundMessage").addClass "hide"
			@collection.each (exp) =>
				hideStatusesList = window.conf.entity.hideStatuses
				#non-admin users can't see experiments with statuses in hideStatusesList
				unless (hideStatusesList? and hideStatusesList.length > 0 and hideStatusesList.indexOf(exp.getStatus().get 'codeValue') > -1 and UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, ["admin"])
					ersc = new ExperimentRowSummaryController
						model: exp
					ersc.on "gotClick", @selectedRowChanged
					@$("tbody").append ersc.render().el

			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar

		@


class window.ExperimentBrowserController extends Backbone.View
	#template: _.template($("#ExperimentBrowserView").html())
	includeDuplicateAndEdit: true
	events:
		"click .bv_deleteExperiment": "handleDeleteExperimentClicked"
		"click .bv_editExperiment": "handleEditExperimentClicked"
		"click .bv_duplicateExperiment": "handleDuplicateExperimentClicked"
		"click .bv_confirmDeleteExperimentButton": "handleConfirmDeleteExperimentClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	initialize: ->
		template = _.template( $("#ExperimentBrowserView").html(),  {includeDuplicateAndEdit: @includeDuplicateAndEdit} );
		$(@el).empty()
		$(@el).html template
		@searchController = new ExperimentSimpleSearchController
			model: new ExperimentSearch()
			el: @$('.bv_experimentSearchController')
			includeDuplicateAndEdit: @includeDuplicateAndEdit
		@searchController.render()
		@searchController.on "searchReturned", @setupExperimentSummaryTable
		#@searchController.on "resetSearch", @destroyExperimentSummaryTable

	setupExperimentSummaryTable: (experiments) =>
		@destroyExperimentSummaryTable()

		$(".bv_searchingExperimentsMessage").addClass "hide"
		if experiments is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if experiments.length is 0
			@$(".bv_noMatchingExperimentsFoundMessage").removeClass "hide"
			@$(".bv_experimentTableController").html ""
		else
			$(".bv_searchExperimentsStatusIndicator").addClass "hide"
			@$(".bv_experimentTableController").removeClass "hide"
			@experimentSummaryTable = new ExperimentSummaryTableController
				collection: new ExperimentList experiments

			@experimentSummaryTable.on "selectedRowUpdated", @selectedExperimentUpdated
			$(".bv_experimentTableController").html @experimentSummaryTable.render().el

	selectedExperimentUpdated: (experiment) =>
		@trigger "selectedExperimentUpdated"
		if experiment.get('lsKind') is "Bio Activity"
			@experimentController = new ExperimentBaseController
				protocolKindFilter: "?protocolKind=Bio Activity"
				model: new PrimaryScreenExperiment experiment.attributes
				readOnly: true
		else
			@experimentController = new ExperimentBaseController
				model: new Experiment experiment.attributes
				readOnly: true

		$('.bv_experimentBaseController').html @experimentController.render().el
		$(".bv_experimentBaseController").removeClass("hide")
		$(".bv_experimentBaseControllerContainer").removeClass("hide")
		if experiment.getStatus().get('codeValue') is "deleted"
			@$('.bv_deleteExperiment').hide()
			@$('.bv_editExperiment').hide() #TODO for future releases, add in hiding duplicateExperiment
		else
			@$('.bv_editExperiment').show()
			@$('.bv_deleteExperiment').show()
			#TODO: make deleting experiment privilege a config
#			if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, ["admin"]
#				@$('.bv_deleteExperiment').show() #TODO for future releases, add in showing duplicateExperiment
#	#			if window.AppLaunchParams.loginUser.username is @protocolController.model.get("recordedBy")
#	#				console.log "user is protocol creator"
#			else
#				@$('.bv_deleteExperiment').hide()

	handleDeleteExperimentClicked: =>
		@$(".bv_experimentCodeName").html @experimentController.model.get("codeName")
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingExperimentMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_experimentDeletedSuccessfullyMessage").addClass "hide"
		$(".bv_confirmDeleteExperiment").removeClass "hide"
		$('.bv_confirmDeleteExperiment').modal({
			keyboard: false,
			backdrop: true
		})

	handleConfirmDeleteExperimentClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		$.ajax(
			url: "/api/experiments/#{@experimentController.model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_experimentDeletedSuccessfullyMessage").removeClass "hide"
				@searchController.handleDoSearchClicked()
		#@destroyExperimentSummaryTable()
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingExperimentMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteExperiment").modal('hide')

	handleEditExperimentClicked: =>
		window.open("/entity/edit/codeName/#{@experimentController.model.get("codeName")}",'_blank');

	handleDuplicateExperimentClicked: =>
		experimentKind = @experimentController.model.get('lsKind')
		if experimentKind is "Bio Activity"
			window.open("/entity/copy/primary_screen_experiment/#{@experimentController.model.get("codeName")}",'_blank');
		else
			window.open("/entity/copy/experiment_base/#{@experimentController.model.get("codeName")}",'_blank');

	destroyExperimentSummaryTable: =>
		if @experimentSummaryTable?
			@experimentSummaryTable.remove()
		if @experimentController?
			@experimentController.remove()
		$(".bv_experimentBaseController").addClass("hide")
		$(".bv_experimentBaseControllerContainer").addClass("hide")
		$(".bv_noMatchingExperimentsFoundMessage").addClass("hide")

	render: =>

		@

class window.ExperimentDetailController extends Backbone.View
	template: _.template($("#ExperimentDetailsView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()



	render: =>

		@
