class window.ProtocolSearch extends Backbone.Model
	defaults:
		protocolCode: null

class window.ProtocolSimpleSearchController extends AbstractFormController
	template: _.template($("#ProtocolSimpleSearchView").html())
	genericSearchUrl: "/api/protocols/genericSearch/"
	codeNameSearchUrl: "/api/protocols/codename/"

	initialize: ->
		@searchUrl = @genericSearchUrl

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
		$(".bv_protSearchTerm").val ""
		if protocolSearchTerm isnt ""
			$(".bv_noMatchesFoundMessage").addClass "hide"
			$(".bv_protocolBrowserSearchInstructions").addClass "hide"
			$(".bv_searchProtocolsStatusIndicator").removeClass "hide"
			if !window.conf.browser.enableSearchAll and protocolSearchTerm is "*"
				$(".bv_moreSpecificProtocolSearchNeeded").removeClass "hide"
			else
				$(".bv_searchingProtocolsMessage").removeClass "hide"
				$(".bv_protSearchTerm").html protocolSearchTerm
				$(".bv_moreSpecificProtocolSearchNeeded").addClass "hide"
				@doSearch protocolSearchTerm

	doSearch: (protocolSearchTerm) =>
		@trigger 'find'
		# disable the search text field while performing a search
		@$(".bv_protocolSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true

		unless protocolSearchTerm is ""
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
				complete: =>
					# re-enable the search text field regardless of if any results found
					@$(".bv_protocolSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false


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
		date = @model.getCreationDate()
		if date.isNew()
			date = "not recorded"
		else
			date = UtilityFunctions::convertMSToYMDDate(date.get('dateValue'))

		toDisplay =
			protocolName: @model.get('lsLabels').pickBestName().get('labelText')
			protocolCode: @model.get('codeName')
			protocolKind: @model.get('lsKind')
			scientist: @model.getScientist().get('codeValue')
			assayStage: @model.getAssayStage().get("codeValue")
			status: @model.getStatus().get("codeValue")
			experimentCount: @model.get('experimentCount')
			creationDate: date
		$(@el).html(@template(toDisplay))

		@

class window.ProtocolSummaryTableController extends Backbone.View
	initialize: ->

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#ProtocolSummaryTableView').html())
		$(@el).html @template
		if @collection.models.length is 0
			@$(".bv_noMatchesFoundMessage").removeClass "hide"
			# display message indicating no results were found
		else
			@$(".bv_noMatchesFoundMessage").addClass "hide"
			@collection.each (prot) =>
				if window.conf.entity?.hideStatuses?
					hideStatusesList = window.conf.entity.hideStatuses
				#non-admin users can't see protocols with statuses in hideStatusesList
				unless (hideStatusesList? and hideStatusesList.length > 0 and hideStatusesList.indexOf(prot.getStatus().get 'codeValue') > -1 and !UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, ["admin"]) or prot.get('codeName') is "PROT-Screen"
					prsc = new ProtocolRowSummaryController
						model: prot
					prsc.on "gotClick", @selectedRowChanged

					@$("tbody").append prsc.render().el
			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar
		@

class window.ProtocolBrowserController extends Backbone.View
	#template: _.template($("#ProtocolBrowserView").html())
	events:
		"click .bv_deleteProtocol": "handleDeleteProtocolClicked"
		"click .bv_editProtocol": "handleEditProtocolClicked"
		"click .bv_duplicateProtocol": "handleDuplicateProtocolClicked"
		"click .bv_createExperiment": "handleCreateExperimentClicked"
		"click .bv_confirmDeleteProtocolButton": "handleConfirmDeleteProtocolClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	initialize: ->
		template = _.template( $("#ProtocolBrowserView").html() );
		$(@el).empty()
		$(@el).html template
		@searchController = new ProtocolSimpleSearchController
			model: new ProtocolSearch()
			el: @$('.bv_protocolSearchController')
		@searchController.render()
		@searchController.on "searchReturned", @setupProtocolSummaryTable
		#@searchController.on "resetSearch", @destroyProtocolSummaryTable

	setupProtocolSummaryTable: (protocols) =>
		@destroyProtocolSummaryTable()
		$(".bv_searchingProtocolsMessage").addClass "hide"
		if protocols is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if protocols.length is 0
			@$(".bv_noMatchesFoundMessage").removeClass "hide"
			@$(".bv_protocolTableController").html ""
		else
			$(".bv_searchProtocolsStatusIndicator").addClass "hide"
			@$(".bv_protocolTableController").removeClass "hide"
			@protocolSummaryTable = new ProtocolSummaryTableController
				collection: new ProtocolList protocols

			@protocolSummaryTable.on "selectedRowUpdated", @selectedProtocolUpdated
			$(".bv_protocolTableController").html @protocolSummaryTable.render().el



	selectedProtocolUpdated: (protocol) =>
		@trigger "selectedProtocolUpdated"
		if protocol.get('lsKind') is "Parent Bio Activity"
			#get parent protocol to return childProtocols as well
			@getParentProtocol(protocol.get('codeName'))
		else if protocol.get('lsKind') is "Bio Activity"
			@protocolController = new PrimaryScreenProtocolController
				model: new PrimaryScreenProtocol protocol.attributes
				readOnly: true
			@showMasterView()
		else
			@protocolController = new ProtocolBaseController
				model: protocol
				readOnly: true
			@showMasterView()

	showMasterView: =>
		protocol = @protocolController.model
		$('.bv_protocolBaseController').html @protocolController.render().el
		$(".bv_protocolBaseController").removeClass("hide")
		$(".bv_protocolBaseControllerContainer").removeClass("hide")
		if protocol.getStatus().get('codeValue') is "deleted"
			@$('.bv_deleteProtocol').hide()
			@$('.bv_editProtocol').hide()
			@$('.bv_duplicateProtocol').hide()
		else
			@$('.bv_editProtocol').show()
			@$('.bv_duplicateProtocol').show()
			@$('.bv_deleteProtocol').show()
	#TODO: make deleting protocol privilege a config
#			if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, ["admin"]
#				@$('.bv_deleteProtocol').show()
#	#			if window.AppLaunchParams.loginUser.username is @protocolController.model.get("recordedBy")
#	#				console.log "user is protocol creator"
#			else
#				@$('.bv_deleteProtocol').hide()

	getParentProtocol: (codeName) =>
		$.ajax
			type: 'GET'
			url: "/api/protocols/parentProtocol/codename/"+codeName
			dataType: 'json'
			error: (err) ->
				alert 'Error - Could not get parent protocol ' + codeName
			success: (json) =>
				if json.length == 0
					alert 'Could not get parent protocol ' + codeName
				else
					@protocolController = new ParentProtocolController
						model: new ParentProtocol json
						readOnly: true
					@showMasterView()

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
			url: "/api/protocols/browser/#{@protocolController.model.get("id")}",
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
		protocolKind = @protocolController.model.get('lsKind')
		if protocolKind is "Bio Activity"
			window.open("/entity/copy/primary_screen_protocol/#{@protocolController.model.get("codeName")}",'_blank');
		else if protocolKind is "Parent Bio Activity"
			window.open("/entity/copy/parent_protocol/#{@protocolController.model.get("codeName")}",'_blank');
		else
			window.open("/entity/copy/protocol_base/#{@protocolController.model.get("codeName")}",'_blank');

	handleCreateExperimentClicked: =>
		protocolKind = @protocolController.model.get('lsKind')
		if protocolKind is "Bio Activity"
			window.open("/primary_screen_experiment/createFrom/#{@protocolController.model.get("codeName")}",'_blank')
		if protocolKind is "Parent Bio Activity"
			window.open("/parent_experiment/createFrom/#{@protocolController.model.get("codeName")}",'_blank')
		else
			window.open("/experiment_base/createFrom/#{@protocolController.model.get("codeName")}",'_blank')

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
