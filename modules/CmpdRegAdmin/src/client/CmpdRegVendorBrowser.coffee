############################################################################
# models
############################################################################
class window.VendorSearch extends Backbone.Model
	defaults:
		name: null
		code: null
		id: null

############################################################################
class window.VendorList extends Backbone.Collection
	model: VendorSearch


############################################################################
# controllers
############################################################################

class window.VendorSimpleSearchController extends AbstractFormController
	template: _.template($("#VendorSimpleSearchView").html())
	genericSearchUrl: "/api/CmpdRegAdmin/vendors/search/"

	initialize: ->
		@searchUrl = ""
		@searchUrl = @genericSearchUrl

	events:
		'keyup .bv_vendorSearchTerm': 'updateVendorSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'
		"click .bv_createNewVendorBtn": "handleCreateNewVendorClicked"		

	render: =>
		$(@el).empty()
		$(@el).html @template()

	updateVendorSearchTerm: (e) =>
		ENTER_KEY = 13
		vendorSearchTerm = $.trim(@$(".bv_vendorSearchTerm").val())
		if vendorSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@handleDoSearchClicked()
		else
			@$(".bv_doSearch").attr("disabled", true)

	handleDoSearchClicked: =>
		$(".bv_vendorTableController").addClass "hide"
		$(".bv_errorOccurredPerformingSearch").addClass "hide"
		vendorSearchTerm = $.trim(@$(".bv_vendorSearchTerm").val())
		if vendorSearchTerm isnt ""
			$(".bv_noMatchingVendorsFoundMessage").addClass "hide"
			$(".bv_vendorBrowserSearchInstructions").addClass "hide"
			$(".bv_searchVendorsStatusIndicator").removeClass "hide"
			if !window.conf.browser.enableSearchAll and vendorSearchTerm is "*"
				$(".bv_moreSpecificVendorSearchNeeded").removeClass "hide"
			else
				$(".bv_searchingVendorsMessage").removeClass "hide"
				$(".bv_vendorSearchTerm").html vendorSearchTerm
				$(".bv_moreSpecificVendorSearchNeeded").addClass "hide"
				@doSearch vendorSearchTerm

	doSearch: (vendorSearchTerm) =>
# disable the search text field while performing a search
		@$(".bv_vendorSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless vendorSearchTerm is ""
			$.ajax
				type: 'GET'
				url: @searchUrl + vendorSearchTerm
				dataType: "json"
				data:
					testMode: false

#fullObject: true
				success: (vendor) =>
					@trigger "searchReturned", vendor
				error: (result) =>
					@trigger "searchReturned", null
				complete: =>
# re-enable the search text field regardless of if any results found
					@$(".bv_vendorSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false

	handleCreateNewVendorClicked: =>
		@trigger 'createNewVendor'

############################################################################
class window.VendorRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#VendorRowSummaryView').html())

	render: =>
		toDisplay =
			code: @model.get('code')
			name: @model.get('name')
		$(@el).html(@template(toDisplay))

		@

############################################################################
class window.VendorSummaryTableController extends Backbone.View
	initialize: ->

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#VendorSummaryTableView').html())
		$(@el).html @template
		if @collection.models.length is 0
			$(".bv_noMatchingVendorsFoundMessage").removeClass "hide"
			# display message indicating no results were found
		else
			$(".bv_noMatchingVendorsFoundMessage").addClass "hide"
			@collection.each (vend) =>
				prsc = new VendorRowSummaryController
					model: vend
				prsc.on "gotClick", @selectedRowChanged
				@$("tbody").append prsc.render().el

			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar

		@

############################################################################
class window.VendorBrowserController extends Backbone.View
	#template: _.template($("#VendorBrowserView").html())
	includeDuplicateAndEdit: false
	events:
		"click .bv_deleteVendor": "handleDeleteVendorClicked"
		"click .bv_editVendor": "handleEditVendorClicked"
		"click .bv_confirmDeleteVendorButton": "handleConfirmDeleteVendorClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	moduleLaunchName: "vendor_browser"

	initialize: ->
		template = _.template( $("#VendorBrowserView").html());
		$(@el).empty()
		$(@el).html template
		@searchController = new VendorSimpleSearchController
			model: new VendorSearch()
			el: @$('.bv_vendorSearchController')
		@searchController.render()
		@searchController.on "searchReturned", @setupVendorSummaryTable
		@searchController.on "createNewVendor", @handleCreateNewVendorClicked
		#@searchController.on "resetSearch", @destroyVendorSummaryTable

	setupVendorSummaryTable: (vendors) =>
		@destroyVendorSummaryTable()

		$(".bv_searchingVendorsMessage").addClass "hide"
		if vendors is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if vendors.length is 0
			@$(".bv_noMatchingVendorsFoundMessage").removeClass "hide"
			@$(".bv_vendorTableController").html ""
		else
			$(".bv_searchVendorsStatusIndicator").addClass "hide"
			@$(".bv_vendorTableController").removeClass "hide"
			@vendorSummaryTable = new VendorSummaryTableController
				collection: new VendorList vendors

			@vendorSummaryTable.on "selectedRowUpdated", @selectedVendorUpdated
			$(".bv_vendorTableController").html @vendorSummaryTable.render().el

	selectedVendorUpdated: (vendor) =>
		@trigger "selectedVendorUpdated"
		if @vendorController?
			@vendorController.undelegateEvents()
		@vendorController = new VendorController
			model: new Vendor vendor.attributes
			readOnly: true

		$('.bv_vendorController').html @vendorController.render().el
		$(".bv_vendorController").removeClass("hide")
		$(".bv_vendorControllerContainer").removeClass("hide")
		@$('.bv_editVendor').show()
		@$('.bv_deleteVendor').show()

	handleDeleteVendorClicked: =>
		@$(".bv_vendorCodeName").html @vendorController.model.get("code")
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingVendorMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_vendorDeletedSuccessfullyMessage").addClass "hide"
		$(".bv_confirmDeleteVendor").removeClass "hide"
		$('.bv_confirmDeleteVendor').modal({
			keyboard: false,
			backdrop: true
		})

	handleConfirmDeleteVendorClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		$.ajax(
			url: "/api/cmpdRegAdmin/vendors/#{@vendorController.model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_vendorDeletedSuccessfullyMessage").removeClass "hide"
				@searchController.handleDoSearchClicked()
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingVendorMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteVendor").modal('hide')

	handleEditVendorClicked: =>
		@createVendorController @vendorController.model

	destroyVendorSummaryTable: =>
		if @vendorSummaryTable?
			@vendorSummaryTable.remove()
		if @vendorController?
			@vendorController.remove()
		$(".bv_vendorController").addClass("hide")
		$(".bv_vendorControllerContainer").addClass("hide")
		$(".bv_noMatchingVendorsFoundMessage").addClass("hide")

	render: =>

		@

	handleCreateNewVendorClicked: =>
		@createVendorController new Vendor()
	
	createVendorController: (mdl) =>
		@$('.bv_vendorBrowserWrapper').hide()
		@$('.bv_vendorControllerWrapper').show()
		if @vendorController?
			@vendorController.undelegateEvents()
			@$(".bv_vendorControllerWrapper").html ""
		@vendorController = new VendorController
			model: mdl
		@vendorController.on 'backToBrowser', @handleBackToVendorBrowserClicked
		@vendorController.on 'amDirty', =>
			@trigger 'amDirty'
		@vendorController.on 'amClean', =>
			@trigger 'amClean'
		@$(".bv_vendorControllerWrapper").append @vendorController.render().el
		@vendorController.$('.bv_backToVendorBrowserBtn').show()

	handleBackToVendorBrowserClicked: =>
		@$('.bv_vendorBrowserWrapper').show()
		@$('.bv_vendorControllerWrapper').hide()
		@searchController.handleDoSearchClicked()
		@trigger 'amClean'
