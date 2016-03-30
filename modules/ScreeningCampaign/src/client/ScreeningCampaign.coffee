class window.ParentExperiment extends Experiment

	initialize: ->
		super()
		@set lsType: "Parent"
		@set lsKind: "Bio Activity"
		#TODO: set protocol here
#		@set protocol:

class window.LinkedExperimentRowSummaryController extends ExperimentRowSummaryController
	events:
		"dblclick": "handleClick"

	initialize: ->
		@template = _.template($('#LinkedExperimentRowSummaryView').html())

	render: =>
		super()
		@$('.bv_experimentCodeLink').attr 'href', "/entity/edit/codeName/#{@model.get("codeName")}"

		@

class window.LinkedExperimentSummaryTableController extends ExperimentSummaryTableController

	render: =>
		@template = _.template($('#ExperimentSummaryTableView').html())
		$(@el).html @template
		if @collection.models.length is 0
			$(".bv_noMatchingExperimentsFoundMessage"+@domSuffix).removeClass "hide"
			# display message indicating no results were found
		else
			$(".bv_noMatchingExperimentsFoundMessage"+@domSuffix).addClass "hide"
			@collection.each (exp) =>
				hideStatusesList = null
				if window.conf.entity?.hideStatuses?
					hideStatusesList = window.conf.entity.hideStatuses
				#non-admin users can't see experiments with statuses in hideStatusesList
				unless (hideStatusesList? and hideStatusesList.length > 0 and hideStatusesList.indexOf(exp.getStatus().get 'codeValue') > -1 and !(UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, ["admin"]))
					ersc = new LinkedExperimentRowSummaryController
						model: exp
					ersc.on "gotClick", @selectedRowChanged
					@$("tbody").append ersc.render().el

			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar

		@


class window.LinkedExperimentsController extends ExperimentBrowserController

	initialize: =>
		template = _.template( $("#LinkedExperimentsView").html(),  {includeDuplicateAndEdit: true} );
		$(@el).empty()
		$(@el).html template
		@setupPrimaryExperimentSearchController()
		@setupAddedPrimaryExperimentsTableController()

	setupPrimaryExperimentSearchController: =>
		@primaryExperimentSearchController = new ExperimentSimpleSearchController
			model: new ExperimentSearch()
			el: @$('.bv_primaryExperimentSearchController')
			includeDuplicateAndEdit: true #only set this to be true so that search will use genericSearchUrl instead of codeNameSearchUrl
			domSuffix: 'PrimaryExpt'
		@primaryExperimentSearchController.render()
		@primaryExperimentSearchController.on "searchReturned", @setupPrimaryExperimentSummaryTable

	setupPrimaryExperimentSummaryTable: (experiments) =>
		@destroyPrimaryExperimentSummaryTable()

		@$(".bv_searchingExperimentsMessagePrimaryExpt").addClass "hide"
		if experiments is null
			@$(".bv_errorOccurredPerformingSearchPrimaryExpt").removeClass "hide"

		else if experiments.length is 0
			@$(".bv_noMatchingExperimentsFoundMessagePrimaryExpt").removeClass "hide"
			@$(".bv_experimentTableControllerPrimaryExpt").html ""
		else
			@$(".bv_searchExperimentsStatusIndicatorPrimaryExpt").addClass "hide"
			@$(".bv_experimentTableControllerPrimaryExpt").removeClass "hide"
			@primaryExperimentSummaryTable = new LinkedExperimentSummaryTableController
				collection: new ExperimentList experiments
				domSuffix: "PrimaryExpt"

			@primaryExperimentSummaryTable.on "selectedRowUpdated", @selectedExperimentUpdated
			@$(".bv_experimentTableControllerPrimaryExpt").html @primaryExperimentSummaryTable.render().el

	destroyPrimaryExperimentSummaryTable: =>
		if @primaryExperimentSummaryTable?
			@primaryExperimentSummaryTable.remove()
#		if @primaryExperimentSearchController?
#			@primaryExperimentSearchController.remove()
		@$(".bv_noMatchingExperimentsFoundMessagePrimaryExpt").addClass("hide")

	setupAddedPrimaryExperimentsTableController: =>
		@addedPrimaryExperimentsTableController = new LinkedExperimentSummaryTableController
			collection: new ExperimentList()
			domSuffix: "AddedPrimaryExpt"

		@addedPrimaryExperimentsTableController.on "selectedRowUpdated", @selectedExperimentUpdated
		@$(".bv_addedPrimaryExperimentsTableController").html @addedPrimaryExperimentsTableController.render().el


	selectedExperimentUpdated: (experiment) =>
		console.log "double clicked on experiment"
		console.log experiment
		console.log @addedPrimaryExperimentsTableController
		console.log @addedPrimaryExperimentsTableController.$("table")

		@addedPrimaryExperimentsTableController.$("table").row.add(experiment)


class window.ScreeningCampaignModuleController extends AbstractFormController
	template: _.template($("#ScreeningCampaignModuleView").html())
	moduleLaunchName: "screening_campaign"

	initialize: =>
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					$.ajax
						type: 'GET'
						url: "/api/experiments/codename/"+window.AppLaunchParams.moduleLaunchParams.code
						dataType: 'json'
						error: (err) ->
							alert 'Could not get experiment for code in this URL, creating new one'
							@completeInitialization()
						success: (json) =>
							if json.length == 0
								alert 'Could not get experiment for code in this URL, creating new one'
							else
								lsType = json.lsType
								lsKind = json.lsKind
								if lsType is "Parent" and lsKind is "Bio Activity"
									expt = new ParentExperiment json
									expt.set expt.parse(expt.attributes)
									if window.AppLaunchParams.moduleLaunchParams.copy
										@model = expt.duplicateEntity()
									else
										@model = expt
								else
									alert 'Could not get parent experiment for code in this URL. Creating new parent experiment'
							@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	completeInitialization: =>
		unless @model?
			@model = new ParentExperiment()
		$(@el).html @template()
		@setupExperimentBaseController()
		@setupLinkedExperimentsController()
		@listenTo @model, 'sync', @modelSyncCallback
		@listenTo @model, 'change', @modelChangeCallback

	setupExperimentBaseController: ->
		if @experimentBaseController?
			@experimentBaseController.remove()
		@experimentBaseController = new ExperimentBaseController
			model: @model
			el: @$('.bv_screeningCampaignGeneralInfo')
			protocolFilter: @protocolFilter
			protocolKindFilter: @protocolKindFilter
		@experimentBaseController.$('.bv_experimentNameLabel').html "*Parent Experiment Name"
		@experimentBaseController.$('.bv_group_protocolCode').hide()
		@experimentBaseController.on 'amDirty', =>
			@trigger 'amDirty'
		@experimentBaseController.on 'amClean', =>
			@trigger 'amClean'
		@experimentBaseController.on 'reinitialize', @reinitialize

	setupLinkedExperimentsController: ->
		if @linkedExptsController?
			@linkedExptsController.undelegateEvents()
		@linkedExptsController = new LinkedExperimentsController
			el: @$('.bv_screeningCampaignLinkedExperiments')
		@linkedExptsController.on 'amDirty', =>
			@trigger 'amDirty'
		@linkedExptsController.on 'amClean', =>
			@trigger 'amClean'
#		@linkedExptsController.on 'updateState', @updateAnalysisClobValue
		@linkedExptsController.render()
