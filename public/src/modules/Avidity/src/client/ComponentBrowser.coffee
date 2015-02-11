class window.ComponentList extends Backbone.Collection
	model: (attrs, options) ->
		lsKind = attrs.lsKind
		lsKind = lsKind.replace /(^|[^a-z0-9-])([a-z])/g, (m, m1, m2, p) -> m1 + m2.toUpperCase()
		lsKind = lsKind.replace /\s/g, ''
#		pascalCaseLsKind = (lsKind).charAt(0).toUpperCase() + (lsKind).slice(1)
		component = lsKind + "Batch"
		new window[component] (attrs)


class window.ComponentSearch extends Backbone.Model
	defaults:
		componentCode: null

class window.ComponentSimpleSearchController extends AbstractFormController
	template: _.template($("#ComponentSimpleSearchView").html())
	genericSearchUrl: "/api/components/genericSearch/"
	codeNameSearchUrl: "/api/components/codename/"

	initialize: ->
		@searchUrl = @genericSearchUrl

	events:
		'keyup .bv_componentSearchTerm': 'updateComponentSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()

	updateComponentSearchTerm: (e) =>
		ENTER_KEY = 13
		componentSearchTerm = $.trim(@$(".bv_componentSearchTerm").val())
		if componentSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@handleDoSearchClicked()
		else
			@$(".bv_doSearch").attr("disabled", true)

	handleDoSearchClicked: =>
		$(".bv_componentTableController").addClass "hide"
		$(".bv_errorOccurredPerformingSearch").addClass "hide"
		componentSearchTerm = $.trim(@$(".bv_componentSearchTerm").val())
		$(".bv_searchTerm").val ""
		if componentSearchTerm isnt ""
			if @$(".bv_clearSearchIcon").hasClass "hide"
				@$(".bv_componentSearchTerm").attr("disabled", true)
				@$(".bv_doSearchIcon").addClass "hide"
				@$(".bv_clearSearchIcon").removeClass "hide"
				$(".bv_searchingMessage").removeClass "hide"
				$(".bv_componentBrowserSearchInstructions").addClass "hide"
				$(".bv_searchTerm").html componentSearchTerm

				@doSearch componentSearchTerm

			else
				@$(".bv_componentSearchTerm").val ""
				@$(".bv_componentSearchTerm").attr("disabled", false)
				@$(".bv_clearSearchIcon").addClass "hide"
				@$(".bv_doSearchIcon").removeClass "hide"
				$(".bv_searchingMessage").addClass "hide"
				$(".bv_componentBrowserSearchInstructions").removeClass "hide"
				$(".bv_searchStatusIndicator").removeClass "hide"

				@updateComponentSearchTerm()
				@trigger "resetSearch"

	doSearch: (componentSearchTerm) =>
		@trigger 'find'
		#$(".bv_componentTableController").html "Searching..."

		unless componentSearchTerm is ""
			$.ajax
				type: 'GET'
				url: @searchUrl + componentSearchTerm
				dataType: "json"
				data:
					testMode: false
			#fullObject: true
				success: (component) =>
					@trigger "searchReturned", component
				error: (result) =>
					@trigger "searchReturned", null


class window.ComponentRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: ->
		@template = _.template($('#ComponentRowSummaryView').html())

	render: =>
		lsKind = @model.get('lsKind')
		toDisplay =
			componentName: @model.get('lsLabels').pickBestName().get('labelText')
#			componentName: lsKind
			componentCode: @model.get('codeName')
			componentKind: @model.get('lsKind')
			scientist: @model.get('scientist').get('value')
			completionDate: @model.get('completion date').get('value')
		$(@el).html(@template(toDisplay))

		@

class window.ComponentSummaryTableController extends Backbone.View
	initialize: ->

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#ComponentSummaryTableView').html())
		$(@el).html @template
		console.dir @collection
		window.fooSearchResults = @collection
		if @collection.models.length is 0
			@$(".bv_noMatchesFoundMessage").removeClass "hide"
			# display message indicating no results were found
		else
			@$(".bv_noMatchesFoundMessage").addClass "hide"
			@collection.each (prot) =>
				prsc = new ComponentRowSummaryController
					model: prot
				prsc.on "gotClick", @selectedRowChanged

				@$("tbody").append prsc.render().el
			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar
		@

class window.ComponentBrowserController extends Backbone.View
	#template: _.template($("#ComponentBrowserView").html())
	events:
		"click .bv_deleteComponent": "handleDeleteComponentClicked"
		"click .bv_editComponent": "handleEditComponentClicked"
		"click .bv_duplicateParent": "handleDuplicateParentClicked"
		"click .bv_confirmDeleteComponentButton": "handleConfirmDeleteComponentClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	initialize: ->
		template = _.template( $("#ComponentBrowserView").html() );
		$(@el).empty()
		$(@el).html template
		@searchController = new ComponentSimpleSearchController
			model: new ComponentSearch()
			el: @$('.bv_componentSearchController')
		@searchController.render()
		@searchController.on "searchReturned", @setupComponentSummaryTable
		@searchController.on "resetSearch", @destroyComponentSummaryTable

	setupComponentSummaryTable: (components) =>
		$(".bv_searchingMessage").addClass "hide"
		if components is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if components.length is 0
			@$(".bv_noMatchesFoundMessage").removeClass "hide"
			@$(".bv_componentTableController").html ""
		else
			$(".bv_searchStatusIndicator").addClass "hide"
			@$(".bv_componentTableController").removeClass "hide"
			@componentSummaryTable = new ComponentSummaryTableController
				collection: new ComponentList components

			@componentSummaryTable.on "selectedRowUpdated", @selectedComponentUpdated
			$(".bv_componentTableController").html @componentSummaryTable.render().el



	selectedComponentUpdated: (batchModel) =>
		@getSelectedComponentParent(batchModel)

	getSelectedComponentParent: (batchModel) ->
		lsKind = batchModel.get('lsKind')
		lsKind = lsKind.replace /(^|[^a-z0-9-])([a-z])/g, (m, m1, m2, p) -> m1 + m2.toUpperCase()
		lsKind = lsKind.replace /\s/g, ''
		camelCaseLsKind = lsKind.charAt(0).toLowerCase()+lsKind.slice(1,)
		batchCodeName = batchModel.get('codeName')
		parentCodeName = batchCodeName.split("-")[0]

		$.ajax
			type: 'GET'
			url: "/api/"+camelCaseLsKind+"Parents/codename/"+parentCodeName
			dataType: 'json'
			error: (err) ->
				alert 'Could not get parent component'
			success: (json) =>
				if json.length == 0
					alert 'Could not get parent for code in this URL, creating new one'
				else
					#TODO Once server is upgraded to not wrap in an array, use the commented out line. It is consistent with specs and tests
					parentModel = new window[lsKind+"Parent"] json
					parentModel.set parentModel.parse(parentModel.attributes)
				@setupComponentController(lsKind, parentModel, batchCodeName, batchModel)

	setupComponentController: (lsKind, parentModel, batchCodeName, batchModel) =>
		@componentController = new window[lsKind+"Controller"]
			model: parentModel
			batchCodeName: batchCodeName
			batchModel: batchModel
			readOnly: true
		$('.bv_componentController').html @componentController.render().el
#		@componentController.displayInReadOnlyMode()
		$(".bv_componentController").removeClass("hide")
		$(".bv_componentControllerContainer").removeClass("hide")


	handleDeleteComponentClicked: =>
		@$(".bv_componentCodeName").html @componentController.model.get("codeName")
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingComponentMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_componentDeletedSuccessfullyMessage").addClass "hide"
		$(".bv_confirmDeleteComponent").removeClass "hide"
		$('.bv_confirmDeleteComponent').modal({
			keyboard: false,
			backdrop: true
		})

	handleConfirmDeleteComponentClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		$.ajax(
			url: "api/components/browser/#{@componentController.model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_componentDeletedSuccessfullyMessage").removeClass "hide"
				@searchController.handleDoSearchClicked()
		#@destroyComponentSummaryTable()
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingComponentMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteComponent").modal('hide')

	handleEditComponentClicked: =>
		window.open("/entity/edit/codeName/#{@componentController.batchCodeName}",'_blank');
#		window.open("/entity/edit/codeName/#{@componentController.model.get("codeName")}",'_blank');

	handleDuplicateParentClicked: =>
		componentKind = @componentController.model.get('lsKind')
		if componentKind is "cationic block"
			window.open("/entity/copy/cationic_block/#{@componentController.model.get("codeName")}",'_blank');
		else if componentKind is "linker small molecule"
			window.open("/entity/copy/linker_small_molecule/#{@componentController.model.get("codeName")}",'_blank');
		else if componentKind is "protein"
			window.open("/entity/copy/protein/#{@componentController.model.get("codeName")}",'_blank');
		else if componentKind is "spacer"
			window.open("/entity/copy/spacer/#{@componentController.model.get("codeName")}",'_blank');

	destroyComponentSummaryTable: =>
		if @componentSummaryTable?
			@componentSummaryTable.remove()
		if @componentController?
			@componentController.remove()
		$(".bv_componentController").addClass("hide")
		$(".bv_componentControllerContainer").addClass("hide")
		$(".bv_noMatchesFoundMessage").addClass("hide")

	render: =>

		@