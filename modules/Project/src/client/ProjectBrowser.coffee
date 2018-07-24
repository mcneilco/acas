class window.ProjectSearch extends Backbone.Model
	defaults:
		protocolCode: null
		projectCode: null

class window.ProjectSearch extends Backbone.Model
	defaults:
		protocolCode: null
		projectCode: null

class window.ProjectSimpleSearchController extends AbstractFormController
	template: _.template($("#ProjectSimpleSearchView").html())
	genericSearchUrl: "/api/genericSearch/projects/"
#	codeNameSearchUrl: "/api/projects/codename/"

	initialize: ->
		@includeDuplicateAndEdit = @options.includeDuplicateAndEdit
		@searchUrl = ""
		if @includeDuplicateAndEdit
			@searchUrl = @genericSearchUrl
		else
			@searchUrl = @codeNameSearchUrl


	events:
		'keyup .bv_projectSearchTerm': 'updateProjectSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()

	updateProjectSearchTerm: (e) =>
		ENTER_KEY = 13
		projectSearchTerm = $.trim(@$(".bv_projectSearchTerm").val())
		if projectSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@handleDoSearchClicked()
		else
			@$(".bv_doSearch").attr("disabled", true)

	handleDoSearchClicked: =>
		$(".bv_projectTableController").addClass "hide"
		$(".bv_errorOccurredPerformingSearch").addClass "hide"
		projectSearchTerm = $.trim(@$(".bv_projectSearchTerm").val())
		$(".bv_exptSearchTerm").val ""
		if projectSearchTerm isnt ""
			$(".bv_noMatchingProjectsFoundMessage").addClass "hide"
			$(".bv_projectBrowserSearchInstructions").addClass "hide"
			$(".bv_searchProjectsStatusIndicator").removeClass "hide"
			if !window.conf.browser.enableSearchAll and projectSearchTerm is "*"
				$(".bv_moreSpecificProjectSearchNeeded").removeClass "hide"
			else
				$(".bv_searchingProjectsMessage").removeClass "hide"
				$(".bv_exptSearchTerm").html projectSearchTerm
				$(".bv_moreSpecificProjectSearchNeeded").addClass "hide"
				@doSearch projectSearchTerm

	doSearch: (projectSearchTerm) =>
# disable the search text field while performing a search
		@$(".bv_projectSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless projectSearchTerm is ""
			$.ajax
				type: 'GET'
				url: @searchUrl + projectSearchTerm
				dataType: "json"
				data:
					testMode: false
					lsType: "project"
					lsKind: "project"

#fullObject: true
				success: (project) =>
					@trigger "searchReturned", project
				error: (result) =>
					@trigger "searchReturned", null
				complete: =>
# re-enable the search text field regardless of if any results found
					@$(".bv_projectSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false



class window.ProjectRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#ProjectRowSummaryView').html())

	render: =>
		projectBestName = @model.get('lsLabels').pickBestName()
		if projectBestName
			projectBestName = @model.get('lsLabels').pickBestName().get('labelText')

		startDate = @model.get('start date').get('value')
		if startDate?
			startDate = moment(startDate).format("YYYY-MM-DD")
		else
			startDate = ""

		projectLeadersValues = @model.getProjectLeaders()
		projLeaders = ""
		_.each projectLeadersValues, (leader) =>
			unless projLeaders is ""
				projLeaders += ", "
			projLeaders += leader.get('codeValue')

		toDisplay =
			projectCode: @model.get('codeName')
			projectName: projectBestName
			isRestricted: @model.get('is restricted').get('value')
			projectLeaders: projLeaders
			startDate: startDate
			status: @model.get('project status').get('value')
		$(@el).html(@template(toDisplay))

		@

class window.ProjectSummaryTableController extends Backbone.View
	initialize: ->

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#ProjectSummaryTableView').html())
		$(@el).html @template
		if @collection.models.length is 0
			$(".bv_noMatchingProjectsFoundMessage").removeClass "hide"
			# display message indicating no results were found
		else
			$(".bv_noMatchingProjectsFoundMessage").addClass "hide"
			@collection.each (proj) =>
				prsc = new ProjectRowSummaryController
					model: proj
				prsc.on "gotClick", @selectedRowChanged
				@$("tbody").append prsc.render().el

			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar

		@


class window.ProjectBrowserController extends Backbone.View
	#template: _.template($("#ProjectBrowserView").html())
	includeDuplicateAndEdit: true
	events:
		"click .bv_deleteProject": "handleDeleteProjectClicked"
		"click .bv_editProject": "handleEditProjectClicked"
		"click .bv_duplicateProject": "handleDuplicateProjectClicked"
		"click .bv_confirmDeleteProjectButton": "handleConfirmDeleteProjectClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	initialize: ->
		template = _.template( $("#ProjectBrowserView").html(),  {includeDuplicateAndEdit: @includeDuplicateAndEdit} );
		$(@el).empty()
		$(@el).html template
		@searchController = new ProjectSimpleSearchController
			model: new ProjectSearch()
			el: @$('.bv_projectSearchController')
			includeDuplicateAndEdit: @includeDuplicateAndEdit
		@searchController.render()
		@searchController.on "searchReturned", @setupProjectSummaryTable
		#@searchController.on "resetSearch", @destroyProjectSummaryTable
		@$('.bv_queryToolDisplayName').html window.conf.service.result.viewer.displayName

	setupProjectSummaryTable: (projects) =>
		@destroyProjectSummaryTable()

		$(".bv_searchingProjectsMessage").addClass "hide"
		if projects is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if projects.length is 0
			@$(".bv_noMatchingProjectsFoundMessage").removeClass "hide"
			@$(".bv_projectTableController").html ""
		else
			$(".bv_searchProjectsStatusIndicator").addClass "hide"
			@$(".bv_projectTableController").removeClass "hide"
			@projectSummaryTable = new ProjectSummaryTableController
				collection: new ProjectList projects

			@projectSummaryTable.on "selectedRowUpdated", @selectedProjectUpdated
			$(".bv_projectTableController").html @projectSummaryTable.render().el

	selectedProjectUpdated: (project) =>
		@trigger "selectedProjectUpdated"
		@projectController = new ProjectController
			model: new Project project.attributes
			readOnly: true

		$('.bv_projectController').html @projectController.render().el
		$(".bv_projectController").removeClass("hide")
		$(".bv_projectControllerContainer").removeClass("hide")
		if project.get('project status').get('value') is "deleted"
			@$('.bv_deleteProject').hide()
			@$('.bv_editProject').hide() #TODO for future releases, add in hiding duplicateProject
		else
			@$('.bv_editProject').show()
			@$('.bv_deleteProject').show()
#TODO: make deleting project privilege a config
#			if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, ["admin"]
#				@$('.bv_deleteProject').show() #TODO for future releases, add in showing duplicateProject
#	#			if window.AppLaunchParams.loginUser.username is @protocolController.model.get("recordedBy")
#	#				console.log "user is protocol creator"
#			else
#				@$('.bv_deleteProject').hide()

	handleDeleteProjectClicked: =>
		@$(".bv_projectCodeName").html @projectController.model.get("codeName")
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingProjectMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_projectDeletedSuccessfullyMessage").addClass "hide"
		$(".bv_confirmDeleteProject").removeClass "hide"
		$('.bv_confirmDeleteProject').modal({
			keyboard: false,
			backdrop: true
		})

	handleConfirmDeleteProjectClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		$.ajax(
			url: "/api/projects/#{@projectController.model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_projectDeletedSuccessfullyMessage").removeClass "hide"
				@searchController.handleDoSearchClicked()
#@destroyProjectSummaryTable()
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingProjectMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteProject").modal('hide')

	handleEditProjectClicked: =>
		window.open("/project/codeName/#{@projectController.model.get("codeName")}",'_blank');

	handleDuplicateProjectClicked: =>
		projectKind = @projectController.model.get('lsKind')
		if projectKind is "Bio Activity"
			window.open("/entity/copy/primary_screen_project/#{@projectController.model.get("codeName")}",'_blank');
		else
			window.open("/entity/copy/project/#{@projectController.model.get("codeName")}",'_blank');

	destroyProjectSummaryTable: =>
		if @projectSummaryTable?
			@projectSummaryTable.remove()
		if @projectController?
			@projectController.remove()
		$(".bv_projectController").addClass("hide")
		$(".bv_projectControllerContainer").addClass("hide")
		$(".bv_noMatchingProjectsFoundMessage").addClass("hide")

	render: =>

		@
