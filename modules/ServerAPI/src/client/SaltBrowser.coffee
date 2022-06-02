class SaltSearch extends Backbone.Model
	defaults:
		saltCode: null

class SaltSimpleSearchController extends AbstractFormController
	template: _.template($("#SaltSimpleSearchView").html())
	genericSearchUrl: "/api/cmpdRegAdmin/salts" 

	events:
		'keyup .bv_saltSearchTerm': 'updateSaltSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()

	updateSaltSearchTerm: (e) =>
		ENTER_KEY = 13
		saltSearchTerm = $.trim(@$(".bv_saltSearchTerm").val())
		if saltSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@handleDoSearchClicked()
		else
			@$(".bv_doSearch").attr("disabled", true)

	handleDoSearchClicked: =>
		$(".bv_saltTableController").addClass "hide"
		$(".bv_errorOccurredPerformingSearch").addClass "hide"
		saltSearchTerm = $.trim(@$(".bv_saltSearchTerm").val())
		$(".bv_exptSearchTerm").val ""
		if saltSearchTerm isnt ""
			$(".bv_noMatchingSaltsFoundMessage").addClass "hide"
			$(".bv_saltBrowserSearchInstructions").addClass "hide"
			$(".bv_searchSaltsStatusIndicator").removeClass "hide"
			if !window.conf.browser.enableSearchAll and saltSearchTerm is "*"
				$(".bv_moreSpecificSaltSearchNeeded").removeClass "hide"
			else 
				$(".bv_searchingSaltsMessage").removeClass "hide"
				$(".bv_exptSearchTerm").html _.escape(saltSearchTerm)
				$(".bv_moreSpecificSaltSearchNeeded").addClass "hide"
				@doSearch saltSearchTerm

	doSearch: (saltSearchTerm) => 
		@$(".bv_saltSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless saltSearchTerm is "" 
			$.ajax
				type: 'GET'
				url: @genericSearchUrl + "/search/" + saltSearchTerm
				contentType: "application/json"
				dataType: "json"
				success: (salt) =>
					@trigger "searchReturned", salt
				error: (result) =>
					@trigger "searchReturned", null
				complete: =>
					@$(".bv_saltSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false

class SaltRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#SaltRowSummaryView').html())

	render: =>
		toDisplay =
			saltName: @model.get('name')
			abbrev: @model.get('abbrev')
			molFormula: @model.get('formula')
			molWeight: @model.get('molWeight')
			charge: @model.get('charge')
		$(@el).html(@template(toDisplay))
		@

class SaltSummaryTableController extends Backbone.View
	initialize: ->

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#SaltSummaryTableView').html())
		$(@el).html @template
		if @collection.models.length is 0
			$(".bv_noMatchingSaltsFoundMessage").removeClass "hide"
		else
			$(".bv_noMatchingSaltsFoundMessage").addClass "hide"
			@collection.each (salt) =>
				prsc = new SaltRowSummaryController
					model: salt
				prsc.on "gotClick", @selectedRowChanged
				@$("tbody").append prsc.render().el

			@$("table").dataTable oLanguage:
				sSearch: "Filter results: "
		@


class SaltBrowserController extends Backbone.View
	events:
		"click .bv_deleteSalt": "handleDeleteSaltClicked" 
		"click .bv_editSalt": "handleEditSaltClicked"
		#"click .bv_confirmDeleteSaltButton": "handleConfirmDeleteSaltClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	initialize: ->
		template = _.template($("#SaltBrowserView").html())
		$(@el).empty()
		$(@el).html template
		@searchController = new SaltSimpleSearchController
			model: new SaltSearch()
			el: @$('.bv_saltSearchController')
		@searchController.render()
		@searchController.on "searchReturned", @setupSaltSummaryTable.bind(@)
		@$('.bv_queryToolDisplayName').html window.conf.service.result.viewer.displayName

	setupSaltSummaryTable: (salts) =>
		@destroySaltSummaryTable()

		$(".bv_searchingSaltsMessage").addClass "hide"
		if salts is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if salts.length is 0
			@$(".bv_noMatchingSaltsFoundMessage").removeClass "hide"
			@$(".bv_saltTableController").html ""
		else
			$(".bv_searchSaltsStatusIndicator").addClass "hide"
			@$(".bv_saltTableController").removeClass "hide"
			@saltSummaryTable = new SaltSummaryTableController
				collection: new SaltList salts
			@saltSummaryTable.on "selectedRowUpdated", @selectedSaltUpdated
			$(".bv_saltTableController").html @saltSummaryTable.render().el

	selectedSaltUpdated: (salt) =>
		@trigger "selectedSaltUpdated"
		@saltController = new SaltEditorController
			model: new Salt salt.attributes
			readOnly: true

		$('.bv_saltController').html @saltController.render().el
		$(".bv_saltController").removeClass("hide")
		$(".bv_saltControllerContainer").removeClass("hide")

		@$('.bv_editSalt').show()
		if window.conf.salt?.editingRoles?
			editingRoles = window.conf.salt.editingRoles.split(",")
			if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, editingRoles)
				@$('.bv_editSalt').hide()

		@$('.bv_deleteSalt').show()
		if window.conf.salt?.deletingRoles?
			deletingRoles= window.conf.salt.deletingRoles.split(",")
			if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, deletingRoles)
				@$('.bv_deleteSalt').hide()

				# Not Implemented Fully Yet
	handleDeleteSaltClicked: =>
		@$(".bv_saltUserName").html @saltController.model.escape("saltName")
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingSaltMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_saltDeletedSuccessfullyMessage").addClass "hide"
		$(".bv_confirmDeleteSalt").removeClass "hide"
		$('.bv_confirmDeleteSalt').modal({
			keyboard: false,
			backdrop: true
		})

	# Not Implemented Fully Yet
	#handleConfirmDeleteSaltClicked: =>
		# @$(".bv_deleteWarningMessage").addClass "hide"
		# @$(".bv_deletingStatusIndicator").removeClass "hide"
		# @$(".bv_deleteButtons").addClass "hide"
		# $.ajax(
		# 	url: "/api/cmpdRegAdmin/salts/#{@saltController.model.get("id")}", # NEED TO CHECK VALID ROUTE
		# 	type: 'DELETE', 
		# 	success: (result) =>
		# 		@$(".bv_okayButton").removeClass "hide"
		# 		@$(".bv_deletingStatusIndicator").addClass "hide"
		# 		@$(".bv_saltDeletedSuccessfullyMessage").removeClass "hide"
		# 		@searchController.handleDoSearchClicked()
		# 	error: (result) =>
		# 		@$(".bv_okayButton").removeClass "hide"
		# 		@$(".bv_deletingStatusIndicator").addClass "hide"
		# 		@$(".bv_errorDeletingSaltMessage").removeClass "hide"
		#

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteSalt").modal('hide')

	handleEditSaltClicked: =>
		# Need to Implement

	destroySaltSummaryTable: =>
		if @saltSummaryTable?
			@saltSummaryTable.remove()
		if @saltController?
			@saltController.remove()
		$(".bv_saltController").addClass("hide")
		$(".bv_saltControllerContainer").addClass("hide")
		$(".bv_noMatchingSaltsFoundMessage").addClass("hide")

	render: =>
		@
