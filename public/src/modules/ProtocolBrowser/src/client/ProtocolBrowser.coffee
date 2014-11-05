class window.ProtocolSearch extends Backbone.Model
	defaults:
		protocolCode: null

class window.ProtocolSimpleSearchController extends AbstractFormController
	template: _.template($("#ProtocolSimpleSearchView").html())
	genericSearchUrl: "/api/protocols/genericSearch/"
	codeNameSearchUrl: "/api/protocols/codename/"

	initialize: ->
		@includeDuplicateAndEdit = @options.includeDuplicateAndEdit
		@searchUrl = ""
		("@includeDuplicateAndEdit")
		console.log @includeDuplicateAndEdit
		if @includeDuplicateAndEdit
			@searchUrl = @genericSearchUrl
		else
			@searchUrl = @codeNameSearchUrl
		console.log @searchUrl


	events:
		'keyup .bv_protocolSearchTerm': 'updateProtocolSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()

	updateProtocolSearchTerm: (e) =>
		ENTER_KEY = 13
		protocolSearchTerm = $.trim(@$(".bv_protocolSearchTerm").val())
		if protocolSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@handleDoSearchClicked()
		else
			@$(".bv_doSearch").attr("disabled", true)

	handleDoSearchClicked: =>
		$(".bv_protocolTableController").addClass "hide"
		$(".bv_errorOccurredPerformingSearch").addClass "hide"
		protocolSearchTerm = $.trim(@$(".bv_protocolSearchTerm").val())
		$(".bv_searchTerm").val ""
		if protocolSearchTerm isnt ""
			if @$(".bv_clearSearchIcon").hasClass "hide"
				@$(".bv_protocolSearchTerm").attr("disabled", true)
				@$(".bv_doSearchIcon").addClass "hide"
				@$(".bv_clearSearchIcon").removeClass "hide"
				$(".bv_searchingMessage").removeClass "hide"
				$(".bv_protocolBrowserSearchInstructions").addClass "hide"
				$(".bv_searchTerm").html protocolSearchTerm

				@doSearch protocolSearchTerm

			else
				@$(".bv_protocolSearchTerm").val ""
				@$(".bv_protocolSearchTerm").attr("disabled", false)
				@$(".bv_clearSearchIcon").addClass "hide"
				@$(".bv_doSearchIcon").removeClass "hide"
				$(".bv_searchingMessage").addClass "hide"
				$(".bv_protocolBrowserSearchInstructions").removeClass "hide"
				$(".bv_searchStatusIndicator").removeClass "hide"

				@updateProtocolSearchTerm()
				@trigger "resetSearch"

	doSearch: (protocolSearchTerm) =>
		@trigger 'find'
		#$(".bv_protocolTableController").html "Searching..."

		unless protocolSearchTerm is ""
			console.log "doGenericProtocolSearch"
			console.log protocolSearchTerm
			$.ajax
				type: 'GET'
				url: @searchUrl + protocolSearchTerm
				dataType: "json"
				data:
					testMode: false
			#fullObject: true
				success: (protocol) =>
					@trigger "searchReturned", protocol
				error: (result) =>
					@trigger "searchReturned", null


class window.ProtocolRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#ProtocolRowSummaryView').html())

	render: =>
		toDisplay =
			protocolName: @model.get('lsLabels').pickBestName().get('labelText')
			protocolCode: @model.get('codeName')
			protocolKind: @model.get('lsKind')
			recordedBy: @model.get('recordedBy')
			status: @model.getStatus().get("stringValue")
#			analysisStatus: @model.getAnalysisStatus().get("stringValue")
			recordedDate: @model.get("recordedDate")
		$(@el).html(@template(toDisplay))

		@

class window.ProtocolSummaryTableController extends Backbone.View
	initialize: ->

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#ProtocolSummaryTableView').html())
		$(@el).html @template
		console.dir @collection
		window.fooSearchResults = @collection
		if @collection.models.length is 0
			@$(".bv_noMatchesFoundMessage").removeClass "hide"
			# display message indicating no results were found
		else
			@$(".bv_noMatchesFoundMessage").addClass "hide"
			@collection.each (prot) =>
				prsc = new ProtocolRowSummaryController
					model: prot
				prsc.on "gotClick", @selectedRowChanged

				@$("tbody").append prsc.render().el
		@

class window.ProtocolBrowserController extends Backbone.View
	#template: _.template($("#ProtocolBrowserView").html())
	includeDuplicateAndEdit: true
	events:
		"click .bv_deleteProtocol": "handleDeleteProtocolClicked"
		"click .bv_editProtocol": "handleEditProtocolClicked"
		"click .bv_duplicateProtocol": "handleDuplicateProtocolClicked"
		"click .bv_confirmDeleteProtocolButton": "handleConfirmDeleteProtocolClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	initialize: ->
		template = _.template( $("#ProtocolBrowserView").html(),  {includeDuplicateAndEdit: @includeDuplicateAndEdit} );
		$(@el).empty()
		$(@el).html template
		@searchController = new ProtocolSimpleSearchController
			model: new ProtocolSearch()
			el: @$('.bv_protocolSearchController')
			includeDuplicateAndEdit: @includeDuplicateAndEdit
		@searchController.render()
		@searchController.on "searchReturned", @setupProtocolSummaryTable
		@searchController.on "resetSearch", @destroyProtocolSummaryTable

	setupProtocolSummaryTable: (protocols) =>
		$(".bv_searchingMessage").addClass "hide"
		if protocols is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if protocols.length is 0
			@$(".bv_noMatchesFoundMessage").removeClass "hide"
			@$(".bv_protocolTableController").html ""
		else
			$(".bv_searchStatusIndicator").addClass "hide"
			@$(".bv_protocolTableController").removeClass "hide"
			@protocolSummaryTable = new ProtocolSummaryTableController
				collection: new ProtocolList protocols

			@protocolSummaryTable.on "selectedRowUpdated", @selectedProtocolUpdated
			$(".bv_protocolTableController").html @protocolSummaryTable.render().el



			unless @includeDuplicateAndEdit
#				if protocols[0].get('lsKind') is "flipr screening assay"
#					console.log "is ps prot"
#					@selectedProtocolUpdated new PrimaryScreenProtocol protocols[0]
#				else
#					console.log "is base prot"
				@selectedProtocolUpdated new Protocol protocols[0]

	selectedProtocolUpdated: (protocol) =>
		@trigger "selectedProtocolUpdated"
		if protocol.get('lsKind') is "flipr screening assay"
			@protocolController = new PrimaryScreenProtocolController
				model: new PrimaryScreenProtocol protocol.attributes
		else
			@protocolController = new ProtocolBaseController
				model: protocol

		$('.bv_protocolBaseController').html @protocolController.render().el
		@protocolController.displayInReadOnlyMode()
		$(".bv_protocolBaseController").removeClass("hide")
		$(".bv_protocolBaseControllerContainer").removeClass("hide")

	handleDeleteProtocolClicked: =>
		@$(".bv_protocolCodeName").html @protocolController.model.get("codeName")
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingProtocolMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_protocolDeletedSuccessfullyMessage").addClass "hide"
		$(".bv_confirmDeleteProtocol").removeClass "hide"
		$('.bv_confirmDeleteProtocol').modal({
			keyboard: false,
			backdrop: true
		})

	handleConfirmDeleteProtocolClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		$.ajax(
			url: "api/protocols/#{@protocolController.model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_protocolDeletedSuccessfullyMessage").removeClass "hide"
				@searchController.handleDoSearchClicked()
		#@destroyProtocolSummaryTable()
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingProtocolMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteProtocol").modal('hide')

	handleEditProtocolClicked: =>
		window.open("/entity/edit/codeName/#{@protocolController.model.get("codeName")}",'_blank');

	handleDuplicateProtocolClicked: =>
		window.open("/api/protocols/duplicate/#{@protocolController.model.get("codeName")}",'_blank');

	destroyProtocolSummaryTable: =>
		if @protocolSummaryTable?
			@protocolSummaryTable.remove()
		if @protocolController?
			@protocolController.remove()
		$(".bv_protocolBaseController").addClass("hide")
		$(".bv_protocolBaseControllerContainer").addClass("hide")
		$(".bv_noMatchesFoundMessage").addClass("hide")

	render: =>

		@
