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
		'click .bv_showAll': 'handleShowAllClicked'

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

	handleShowAllClicked: =>
		$(".bv_protocolTableController").addClass "hide"
		$(".bv_errorOccurredPerformingSearch").addClass "hide"
		protocolSearchTerm = "*"
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
		if @model.get('lsLabels') not instanceof LabelList
			@model.set 'lsLabels',  new LabelList @model.get('lsLabels')
		subclass = @model.get('subclass')
		if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
			if @model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
				code = @model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
			else
				code = @model.get("codeName")
		else
			code = @model.get('codeName')

		toDisplay =
			protocolName: @model.get('lsLabels').pickBestName().get('labelText')
			protocolCode: code
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
				canViewDeleted = @canViewDeleted(prot)
				if prot.getStatus().get('codeValue') is 'deleted'
					if canViewDeleted
						prsc = new ProtocolRowSummaryController
							model: prot
						prsc.on "gotClick", @selectedRowChanged
						@$("tbody").append prsc.render().el
				else
					prsc = new ProtocolRowSummaryController
						model: prot
					prsc.on "gotClick", @selectedRowChanged
					@$("tbody").append prsc.render().el
			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar
		@

	canViewDeleted: (prot) ->
		if window.conf.entity?.viewDeletedRoles?
			rolesToTest = []
			for role in window.conf.entity.viewDeletedRoles.split(",")
				role = $.trim(role)
				if role is 'entityScientist'
					if (window.AppLaunchParams.loginUserName is prot.getScientist().get('codeValue'))
						return true
				else if role is 'projectAdmin'
					projectAdminRole =
						lsType: "Project"
						lsKind: prot.getProjectCode().get('codeValue')
						roleName: "Administrator"
					if UtilityFunctions::testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [projectAdminRole])
						return true
				else
					rolesToTest.push role
			if rolesToTest.length is 0
				return false
			if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, rolesToTest
				return true
		return false

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
			if window.conf.protocol?.mainControllerClassName? and window.conf.protocol.mainControllerClassName is "EnhancedProtocolBaseController"
				protocolListClass = "EnhancedProtocolList"
			else
				protocolListClass = "ProtocolList"
			@protocolSummaryTable = new ProtocolSummaryTableController
				collection: new window[protocolListClass] protocols

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
		else if protocol.get('lsKind') is "study"
			@protocolController = new StudyTrackerProtocolController
				model: new StudyTrackerProtocol protocol.attributes
				readOnly: true
			@showMasterView()
		else
			if window.conf.protocol?.mainControllerClassName?
				protControllerClassName = window.conf.protocol.mainControllerClassName
			else
				protControllerClassName = "ProtocolBaseController"
			@protocolController = new window[protControllerClassName]
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
			@$('.bv_createExperiment').hide()
		else
			@$('.bv_duplicateProtocol').show()
			@$('.bv_createExperiment').show()
			if @canEdit()
				@$('.bv_editProtocol').show()
				@$('.bv_duplicateProtocol').show()
				@$('.bv_createExperiment').show()
			else
				@$('.bv_editProtocol').hide()
				@$('.bv_duplicateProtocol').hide()
				@$('.bv_createExperiment').hide()
			if @canDelete()
				@$('.bv_deleteProtocol').show()
			else
				@$('.bv_deleteProtocol').hide()

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

	canEdit: ->
		if @protocolController.model.getScientist().get('codeValue') is "unassigned"
			return true
		else
			if window.conf.entity?.editingRoles?
				rolesToTest = []
				for role in window.conf.entity.editingRoles.split(",")
					role = $.trim(role)
					if role is 'entityScientist'
						if (window.AppLaunchParams.loginUserName is @protocolController.model.getScientist().get('codeValue'))
							return true
					else if role is 'projectAdmin'
						projectAdminRole =
							lsType: "Project"
							lsKind: @protocolController.model.getProjectCode().get('codeValue')
							roleName: "Administrator"
						if UtilityFunctions::testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [projectAdminRole])
							return true
					else
						rolesToTest.push role
				if rolesToTest.length is 0
					return false
				unless UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, rolesToTest
					return false
			return true

	canDelete: ->
		if window.conf.entity?.deletingRoles?
			rolesToTest = []
			for role in window.conf.entity.deletingRoles.split(",")
				role = $.trim(role)
				if role is 'entityScientist'
					if (window.AppLaunchParams.loginUserName is @protocolController.model.getScientist().get('codeValue'))
						return true
				else if role is 'projectAdmin'
					projectAdminRole =
						lsType: "Project"
						lsKind: @protocolController.model.getProjectCode().get('codeValue')
						roleName: "Administrator"
					if UtilityFunctions::testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [projectAdminRole])
						return true
				else
					rolesToTest.push role
			if rolesToTest.length is 0
				return false
			unless UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, rolesToTest
				return false
		return true

	handleDeleteProtocolClicked: =>
		if @protocolController.model.get('lsLabels') not instanceof LabelList
			@protocolController.model.set 'lsLabels',  new LabelList @protocolController.model.get('lsLabels')
		subclass = @protocolController.model.get('subclass')
		if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
			if @protocolController.model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
				code = @protocolController.model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
			else
				code = @protocolController.model.get("codeName")
		else
			code = @protocolController.model.get('codeName')
		@$(".bv_protocolCodeName").html code
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
		if @protocolController.model.get('lsLabels') not instanceof LabelList
			@protocolController.model.set 'lsLabels',  new LabelList @protocolController.model.get('lsLabels')
		subclass = @protocolController.model.get('subclass')
		if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
			if @protocolController.model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
				code = @protocolController.model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
			else
				code = @protocolController.model.get("codeName")
		else
			code = @protocolController.model.get('codeName')

		window.open("/entity/edit/codeName/#{code}",'_blank');

	handleDuplicateProtocolClicked: =>
		protocolKind = @protocolController.model.get('lsKind')
		if @protocolController.model.get('lsLabels') not instanceof LabelList
			@protocolController.model.set 'lsLabels',  new LabelList @protocolController.model.get('lsLabels')
		subclass = @protocolController.model.get('subclass')
		if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
			if @protocolController.model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
				code = @protocolController.model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
			else
				code = @protocolController.model.get("codeName")
		else
			code = @protocolController.model.get('codeName')

		if protocolKind is "Bio Activity"
			window.open("/entity/copy/primary_screen_protocol/#{code}",'_blank');
		else if protocolKind is "Parent Bio Activity"
			window.open("/entity/copy/parent_protocol/#{code}",'_blank');
		else if protocolKind is "study"
			window.open("/entity/copy/study_tracker_protocol/#{code}",'_blank');
		else
			window.open("/entity/copy/protocol_base/#{code}",'_blank');

	handleCreateExperimentClicked: =>
		protocolKind = @protocolController.model.get('lsKind')
		if @protocolController.model.get('lsLabels') not instanceof LabelList
			@protocolController.model.set 'lsLabels',  new LabelList @protocolController.model.get('lsLabels')
		subclass = @protocolController.model.get('subclass')
		if window.conf.entity?.saveInitialsCorpName? and window.conf.entity.saveInitialsCorpName is true
			if @protocolController.model.get('lsLabels').getLabelByTypeAndKind("corpName", subclass + ' corpName').length > 0
				code = @protocolController.model.get('lsLabels').getLabelByTypeAndKind('corpName', subclass + ' corpName')[0].get('labelText')
			else
				code = @protocolController.model.get("codeName")
		else
			code = @protocolController.model.get('codeName')

		if protocolKind is "Bio Activity"
			window.open("/primary_screen_experiment/createFrom/#{code}",'_blank')
		else if protocolKind is "Parent Bio Activity"
			window.open("/parent_experiment/createFrom/#{code}",'_blank')
		else if protocolKind is "study"
			window.open("/study_tracker_experiment/createFrom/#{code}",'_blank')
		else
			window.open("/experiment_base/createFrom/#{code}",'_blank')

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
