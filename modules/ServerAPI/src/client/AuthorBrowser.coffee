class window.AuthorSearch extends Backbone.Model
	defaults:
		protocolCode: null
		authorCode: null

class window.AuthorSearch extends Backbone.Model
	defaults:
		protocolCode: null
		authorCode: null

class window.AuthorSimpleSearchController extends AbstractFormController
	template: _.template($("#AuthorSimpleSearchView").html())
	genericSearchUrl: "/api/genericSearch/authors"

	events:
		'keyup .bv_authorSearchTerm': 'updateAuthorSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'
		'click .bv_showAll': 'handleShowAllClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()

	updateAuthorSearchTerm: (e) =>
		ENTER_KEY = 13
		authorSearchTerm = $.trim(@$(".bv_authorSearchTerm").val())
		if authorSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@handleDoSearchClicked()
		else
			@$(".bv_doSearch").attr("disabled", true)

	handleShowAllClicked: =>
		$(".bv_authorTableController").addClass "hide"
		$(".bv_errorOccurredPerformingSearch").addClass "hide"
		authorSearchTerm = "*"
		$(".bv_exptSearchTerm").val ""
		if authorSearchTerm isnt ""
			$(".bv_noMatchingAuthorsFoundMessage").addClass "hide"
			$(".bv_authorBrowserSearchInstructions").addClass "hide"
			$(".bv_searchAuthorsStatusIndicator").removeClass "hide"
			if !window.conf.browser.enableSearchAll and authorSearchTerm is "*"
				$(".bv_moreSpecificAuthorSearchNeeded").removeClass "hide"
			else
				$(".bv_searchingAuthorsMessage").removeClass "hide"
				$(".bv_exptSearchTerm").html authorSearchTerm
				$(".bv_moreSpecificAuthorSearchNeeded").addClass "hide"
				@doSearch authorSearchTerm

	handleDoSearchClicked: =>
		$(".bv_authorTableController").addClass "hide"
		$(".bv_errorOccurredPerformingSearch").addClass "hide"
		authorSearchTerm = $.trim(@$(".bv_authorSearchTerm").val())
		$(".bv_exptSearchTerm").val ""
		if authorSearchTerm isnt ""
			$(".bv_noMatchingAuthorsFoundMessage").addClass "hide"
			$(".bv_authorBrowserSearchInstructions").addClass "hide"
			$(".bv_searchAuthorsStatusIndicator").removeClass "hide"
			if !window.conf.browser.enableSearchAll and authorSearchTerm is "*"
				$(".bv_moreSpecificAuthorSearchNeeded").removeClass "hide"
			else
				$(".bv_searchingAuthorsMessage").removeClass "hide"
				$(".bv_exptSearchTerm").html authorSearchTerm
				$(".bv_moreSpecificAuthorSearchNeeded").addClass "hide"
				@doSearch authorSearchTerm

	doSearch: (authorSearchTerm) =>
		# disable the search text field while performing a search
		@$(".bv_authorSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless authorSearchTerm is ""
			$.ajax
				type: 'POST'
				url: @genericSearchUrl
				contentType: "application/json"
				dataType: "json"
				data:
					JSON.stringify
						queryString: authorSearchTerm
				success: (author) =>
					@trigger "searchReturned", author
				error: (result) =>
					@trigger "searchReturned", null
				complete: =>
					# re-enable the search text field regardless of if any results found
					@$(".bv_authorSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false



class window.AuthorRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#AuthorRowSummaryView').html())

	render: =>
		toDisplay =
			userName: @model.get('userName')
			firstName: @model.get('firstName')
			lastName: @model.get('lastName')
			emailAddress: @model.get('emailAddress')
		$(@el).html(@template(toDisplay))

		@

class window.AuthorSummaryTableController extends Backbone.View
	initialize: ->

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#AuthorSummaryTableView').html())
		$(@el).html @template
		if @collection.models.length is 0
			$(".bv_noMatchingAuthorsFoundMessage").removeClass "hide"
			# display message indicating no results were found
		else
			$(".bv_noMatchingAuthorsFoundMessage").addClass "hide"
			@collection.each (auth) =>
				prsc = new AuthorRowSummaryController
					model: auth
				prsc.on "gotClick", @selectedRowChanged
				@$("tbody").append prsc.render().el

			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar

		@


class window.AuthorBrowserController extends Backbone.View
	events:
		"click .bv_deleteAuthor": "handleDeleteAuthorClicked"
		"click .bv_editAuthor": "handleEditAuthorClicked"
		"click .bv_confirmDeleteAuthorButton": "handleConfirmDeleteAuthorClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	initialize: ->
		template = _.template($("#AuthorBrowserView").html())
		$(@el).empty()
		$(@el).html template
		@searchController = new AuthorSimpleSearchController
			model: new AuthorSearch()
			el: @$('.bv_authorSearchController')
		@searchController.render()
		@searchController.on "searchReturned", @setupAuthorSummaryTable
		@$('.bv_queryToolDisplayName').html window.conf.service.result.viewer.displayName

	setupAuthorSummaryTable: (authors) =>
		@destroyAuthorSummaryTable()

		$(".bv_searchingAuthorsMessage").addClass "hide"
		if authors is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if authors.length is 0
			@$(".bv_noMatchingAuthorsFoundMessage").removeClass "hide"
			@$(".bv_authorTableController").html ""
		else
			$(".bv_searchAuthorsStatusIndicator").addClass "hide"
			@$(".bv_authorTableController").removeClass "hide"
			@authorSummaryTable = new AuthorSummaryTableController
				collection: new AuthorList authors

			@authorSummaryTable.on "selectedRowUpdated", @selectedAuthorUpdated
			$(".bv_authorTableController").html @authorSummaryTable.render().el

	selectedAuthorUpdated: (author) =>
		@trigger "selectedAuthorUpdated"
		@authorController = new AuthorEditorController
			model: new Author author.attributes
			readOnly: true

		$('.bv_authorController').html @authorController.render().el
		$(".bv_authorController").removeClass("hide")
		$(".bv_authorControllerContainer").removeClass("hide")

		@$('.bv_editAuthor').show()
		if window.conf.author?.editingRoles?
			editingRoles = window.conf.author.editingRoles.split(",")
			if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, editingRoles)
				@$('.bv_editAuthor').hide()

		@$('.bv_deleteAuthor').show()
		if window.conf.author?.deletingRoles?
			deletingRoles= window.conf.author.deletingRoles.split(",")
			if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, deletingRoles)
				@$('.bv_deleteAuthor').hide()

	handleDeleteAuthorClicked: =>
		@$(".bv_authorUserName").html @authorController.model.get("userName")
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingAuthorMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_authorDeletedSuccessfullyMessage").addClass "hide"
		$(".bv_confirmDeleteAuthor").removeClass "hide"
		$('.bv_confirmDeleteAuthor').modal({
			keyboard: false,
			backdrop: true
		})

	handleConfirmDeleteAuthorClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		$.ajax(
			url: "/api/authors/#{@authorController.model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_authorDeletedSuccessfullyMessage").removeClass "hide"
				@searchController.handleDoSearchClicked()
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingAuthorMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteAuthor").modal('hide')

	handleEditAuthorClicked: =>
		window.open("/author/codeName/#{@authorController.model.get("userName")}",'_blank');

	destroyAuthorSummaryTable: =>
		if @authorSummaryTable?
			@authorSummaryTable.remove()
		if @authorController?
			@authorController.remove()
		$(".bv_authorController").addClass("hide")
		$(".bv_authorControllerContainer").addClass("hide")
		$(".bv_noMatchingAuthorsFoundMessage").addClass("hide")

	render: =>

		@
