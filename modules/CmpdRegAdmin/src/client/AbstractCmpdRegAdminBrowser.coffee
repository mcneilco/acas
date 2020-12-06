############################################################################
# models
############################################################################
class window.CmpdRegAdminSearch extends Backbone.Model
	defaults:
		name: null
		code: null
		id: null

############################################################################
class window.CmpdRegAdminList extends Backbone.Collection
	model: CmpdRegAdminSearch

############################################################################
# controllers
############################################################################
class window.CmpdRegAdminSimpleSearchController extends AbstractFormController
	###
  	Instantiating controller must provide urlRoot and toDisplay in options
	###

	initialize: ->
		@searchUrl = ""
		@searchUrl = @options.urlRoot + '/search/'

	events:
		'keyup .bv_cmpdRegAdminSearchTerm': 'updateCmpdRegAdminSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'
		"click .bv_createNewCmpdRegAdminBtn": "handleCreateNewCmpdRegAdminClicked"

	render: =>
		console.log "rendering SimpleSearchController"
		template = _.template($("#CmpdRegAdminSimpleSearchView").html())
		$(@el).empty()
		console.log @options.toDisplay
		$(@el).html(template(@options.toDisplay))
		@

	updateCmpdRegAdminSearchTerm: (e) =>
		ENTER_KEY = 13
		cmpdRegAdminSearchTerm = $.trim(@$(".bv_cmpdRegAdminSearchTerm").val())
		if cmpdRegAdminSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@trigger 'searchRequested'
		else
			@$(".bv_doSearch").attr("disabled", true)

	doSearch: (cmpdRegAdminSearchTerm) =>
# disable the search text field while performing a search
		@$(".bv_cmpdRegAdminSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless cmpdRegAdminSearchTerm is ""
			$.ajax
				type: 'GET'
				url: @searchUrl + cmpdRegAdminSearchTerm
				dataType: "json"
				data:
					testMode: false

#fullObject: true
				success: (cmpdRegAdmin) =>
					@trigger "searchReturned", cmpdRegAdmin
				error: (result) =>
					@trigger "searchReturned", null
				complete: =>
# re-enable the search text field regardless of if any results found
					@$(".bv_cmpdRegAdminSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false

	handleCreateNewCmpdRegAdminClicked: =>
		@trigger 'createNewCmpdRegAdmin'

############################################################################
class window.CmpdRegAdminRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#CmpdRegAdminRowSummaryView').html())
		if @options.showIgnore?
			@showIgnore = @options.showIgnore
		else
			@showIgnore = false

	render: =>
		toDisplay =
			code: @model.get('code')
			name: @model.get('name')

		$(@el).html(@template(toDisplay))
		if @showIgnore
			ignored = if @model.get('ignore')? then @model.get('ignore') else false

			@$(".bv_cmpdRegAdminIgnore").show()
			@$(".bv_cmpdRegAdminIgnore").html ignored.toString()
		else
			@$(".bv_cmpdRegAdminIgnore").hide()
		@

############################################################################
class window.CmpdRegAdminSummaryTableController extends Backbone.View
	initialize: ->
		if @options.showIgnore?
			@showIgnore = @options.showIgnore
		else
			@showIgnore = false

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#CmpdRegAdminSummaryTableView').html())
		$(@el).html @template(@options.toDisplay)
		#will always be instantiated with at least one model in collection
		@collection.each (admin) =>
			prsc = new CmpdRegAdminRowSummaryController
				model: admin
				showIgnore: @showIgnore
			prsc.on "gotClick", @selectedRowChanged
			@$("tbody").append prsc.render().el

		@$("table").dataTable oLanguage:
			sSearch: "Filter results: " #rename summary table's search bar

		if @showIgnore
			@$(".bv_ignoredHeader").show()
		else
			@$(".bv_ignoredHeader").hide()

		@

############################################################################
class window.AbstractCmpdRegAdminBrowserController extends Backbone.View
	###
  	Instantiating controller must provide:
  		entityType
  		entityClass
  		entityControllerClass
  		moduleLaunchName
  ###
	includeDuplicateAndEdit: false
	events:
		"click .bv_deleteCmpdRegAdmin": "handleDeleteCmpdRegAdminClicked"
		"click .bv_editCmpdRegAdmin": "handleEditCmpdRegAdminClicked"
		"click .bv_confirmDeleteCmpdRegAdminButton": "handleConfirmDeleteCmpdRegAdminClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"


	initialize: ->
		template = _.template( $("#AbstractCmpdRegAdminBrowserView").html());
		$(@el).empty()
		@toDisplay =
			entityTypeToDisplay: if @entityTypeToDisplay? then @entityTypeToDisplay else @entityType
			entityTypePluralToDisplay: if @entityTypePluralToDisplay? then @entityTypePluralToDisplay else @entityTypePlural
			entityTypeUpper: @entityTypeUpper
			entityTypeUpperPlural: @entityTypeUpperPlural
		$(@el).html(template(@toDisplay))
		unless @showIgnore?
			@showIgnore = false
		@searchController = new CmpdRegAdminSimpleSearchController
			model: new CmpdRegAdminSearch()
			el: @$('.bv_cmpdRegAdminSearchController')
			urlRoot: "/api/CmpdRegAdmin/#{@entityTypePlural}"
			toDisplay: @toDisplay
		@searchController.render()
		@searchController.on "searchRequested", @handleSearchRequested
		@searchController.on "searchReturned", @setupCmpdRegAdminSummaryTable
		@searchController.on "createNewCmpdRegAdmin", @handleCreateNewCmpdRegAdminClicked
	#@searchController.on "resetSearch", @destroyCmpdRegAdminSummaryTable

	setupCmpdRegAdminSummaryTable: (cmpdRegAdmins) =>
		@destroyCmpdRegAdminSummaryTable()

		@$(".bv_searchingCmpdRegAdminsMessage").addClass "hide"
		if cmpdRegAdmins is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if cmpdRegAdmins.length is 0
			@$(".bv_noMatchingCmpdRegAdminsFoundMessage").removeClass "hide"
			@$(".bv_cmpdRegAdminTableController").html ""
		else
			@$(".bv_searchCmpdRegAdminsStatusIndicator").addClass "hide"
			@$(".bv_cmpdRegAdminTableController").removeClass "hide"
			@cmpdRegAdminSummaryTable = new CmpdRegAdminSummaryTableController
				collection: new CmpdRegAdminList cmpdRegAdmins
				toDisplay: @toDisplay
				showIgnore: @showIgnore

			@cmpdRegAdminSummaryTable.on "selectedRowUpdated", @selectedCmpdRegAdminUpdated
			@$(".bv_cmpdRegAdminTableController").html @cmpdRegAdminSummaryTable.render().el

	selectedCmpdRegAdminUpdated: (cmpdRegAdmin) =>
		@trigger "selectedCmpdRegAdminUpdated"
		if @cmpdRegAdminController?
			@cmpdRegAdminController.undelegateEvents()
		@cmpdRegAdminController = new window[@entityControllerClass]
			model: new window[@entityClass] cmpdRegAdmin.attributes
			readOnly: true

		@$('.bv_cmpdRegAdminController').html @cmpdRegAdminController.render().el
		@$(".bv_cmpdRegAdminController").removeClass("hide")
		@$(".bv_cmpdRegAdminControllerContainer").removeClass("hide")
		@$('.bv_editCmpdRegAdmin').show()
		@$('.bv_deleteCmpdRegAdmin').show()

	handleSearchRequested: =>
		@$(".bv_cmpdRegAdminTableController").addClass "hide"
		@$(".bv_errorOccurredPerformingSearch").addClass "hide"
		cmpdRegAdminSearchTerm = $.trim(@$(".bv_cmpdRegAdminSearchTerm").val())
		if cmpdRegAdminSearchTerm isnt ""
			@$(".bv_noMatchingCmpdRegAdminsFoundMessage").addClass "hide"
			@$(".bv_cmpdRegAdminBrowserSearchInstructions").addClass "hide"
			@$(".bv_searchCmpdRegAdminsStatusIndicator").removeClass "hide"
			if !window.conf.browser.enableSearchAll and cmpdRegAdminSearchTerm is "*"
				@$(".bv_moreSpecificCmpdRegAdminSearchNeeded").removeClass "hide"
			else
				@$(".bv_searchingCmpdRegAdminsMessage").removeClass "hide"
				@$(".bv_cmpdRegAdminSearchTerm").html cmpdRegAdminSearchTerm
				@$(".bv_moreSpecificCmpdRegAdminSearchNeeded").addClass "hide"
				@searchController.doSearch cmpdRegAdminSearchTerm
		
	handleDeleteCmpdRegAdminClicked: =>
		@$(".bv_cmpdRegAdminCodeName").html @cmpdRegAdminController.model.get("code")
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingCmpdRegAdminMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_cmpdRegAdminDeletedSuccessfullyMessage").addClass "hide"
		@$(".bv_confirmDeleteCmpdRegAdmin").removeClass "hide"
		@$('.bv_confirmDeleteCmpdRegAdmin').modal({
			keyboard: false,
			backdrop: true
		})

	handleConfirmDeleteCmpdRegAdminClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		$.ajax(
			url: "/api/cmpdRegAdmin/#{@entityTypePlural}/#{@cmpdRegAdminController.model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_cmpdRegAdminDeletedSuccessfullyMessage").removeClass "hide"
				@handleSearchRequested()
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingCmpdRegAdminMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteCmpdRegAdmin").modal('hide')

	handleEditCmpdRegAdminClicked: =>
		@createCmpdRegAdminController @cmpdRegAdminController.model

	destroyCmpdRegAdminSummaryTable: =>
		if @cmpdRegAdminSummaryTable?
			@cmpdRegAdminSummaryTable.remove()
		if @cmpdRegAdminController?
			@cmpdRegAdminController.remove()
			
		@$(".bv_cmpdRegAdminController").addClass("hide")
		@$(".bv_cmpdRegAdminControllerContainer").addClass("hide")
		@$(".bv_noMatchingCmpdRegAdminsFoundMessage").addClass("hide")

	render: =>
		@

	handleCreateNewCmpdRegAdminClicked: =>
		@createCmpdRegAdminController new window[@entityClass]()

	createCmpdRegAdminController: (mdl) =>
		@$('.bv_cmpdRegAdminBrowserWrapper').hide()
		@$('.bv_cmpdRegAdminControllerWrapper').show()
		if @cmpdRegAdminController?
			@cmpdRegAdminController.undelegateEvents()
			@$(".bv_cmpdRegAdminControllerWrapper").html ""
		@cmpdRegAdminController = new window[@entityControllerClass]
			model: mdl
		@cmpdRegAdminController.on 'backToBrowser', @handleBackToCmpdRegAdminBrowserClicked
		@cmpdRegAdminController.on 'amDirty', =>
			@trigger 'amDirty'
		@cmpdRegAdminController.on 'amClean', =>
			@trigger 'amClean'
		@$(".bv_cmpdRegAdminControllerWrapper").append @cmpdRegAdminController.render().el
		@cmpdRegAdminController.$('.bv_backToCmpdRegAdminBrowserBtn').show()

	handleBackToCmpdRegAdminBrowserClicked: =>
		@$('.bv_cmpdRegAdminBrowserWrapper').show()
		@$('.bv_cmpdRegAdminControllerWrapper').hide()
		@handleSearchRequested()
		@trigger 'amClean'
