class ThingSearch extends Backbone.Model
	defaults:
		protocolCode: null
		ThingCode: null

class ThingSimpleSearchController extends AbstractFormController
	template: _.template($("#ThingSimpleSearchView").html())
	genericSearchUrl: '/api/advancedSearch/things/'

	events:
		'keyup .bv_thingSearchTerm': 'updateThingSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'

	initialize: (options) ->
		@query = options.query

	render: =>
		$(@el).empty()
		templateVariables = 
			thingName: @model.getName()
		$(@el).html @template(templateVariables)

	updateThingSearchTerm: (e) =>
		ENTER_KEY = 13
		thingSearchTerm = $.trim(@$(".bv_thingSearchTerm").val())
		if thingSearchTerm isnt ""
			@$(".bv_doSearch").attr("disabled", false)
			if e.keyCode is ENTER_KEY
				$(':focus').blur()
				@handleDoSearchClicked()
		else
			@$(".bv_doSearch").attr("disabled", true)

	handleDoSearchClicked: =>
		@$(".bv_thingTableController").addClass "hide"
		@$(".bv_errorOccurredPerformingSearch").addClass "hide"
		thingSearchTerm = $.trim(@$(".bv_thingSearchTerm").val())
		@$(".bv_exptSearchTerm").val ""
		if thingSearchTerm isnt ""
			@$(".bv_noMatchingThingsFoundMessage").addClass "hide"
			@$(".bv_thingBrowserSearchInstructions").addClass "hide"
			@$(".bv_searchThingsStatusIndicator").removeClass "hide"
			if !window.conf.browser.enableSearchAll and thingSearchTerm is "*"
				@$(".bv_moreSpecificThingSearchNeeded").removeClass "hide"
			else
				@$(".bv_searchingThingsMessage").removeClass "hide"
				@$(".bv_exptSearchTerm").html thingSearchTerm
				@$(".bv_moreSpecificThingSearchNeeded").addClass "hide"
				@doSearch thingSearchTerm

	doSearch: (thingSearchTerm) =>
		# disable the search text field while performing a search
		@$(".bv_thingSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless thingSearchTerm is ""
			query =
				queryString: "#{thingSearchTerm}"
				queryDTO:
					lsType: @model.get("lsType")
					lsKind: @model.get("lsKind")
					codeName: {
						operator: "~"
					},
					labels: [ 

					]
					values: [

					]
			if @query?
				if @query.values?
					for queryValue in @query.values
						if queryValue.key?
							valDef = @model.getValueInfo(queryValue.key)
							if valDef?
								operator = "~"
								if queryValue.operator?
									operator = queryValue.operator
								query.queryDTO.values.push	
									stateType: valDef.stateType
									stateKind: valDef.stateKind
									valueType: valDef.type
									valueKind: valDef.kind
									operator: queryValue.operator
				if @query.labels?
					for queryValue in @query.labels
						if queryValue.key?
							labDef = @model.getLabelInfo(queryValue.key)
							if labDef?
								operator = "~"
								if queryValue.operator?
									operator = queryValue.operator
								query.queryDTO.labels.push	
									labelType: labDef.type
									labelKind: labDef.kind
									operator: queryValue.operator
				
			$.ajax
				type: 'POST'
				url: "#{@genericSearchUrl}#{@model.get("lsType")}/#{@model.get("lsKind")}?format=nestedfull"
				dataType: 'json',
				contentType: 'application/json'
				data: JSON.stringify(query)
				success: (thing) =>
					@trigger "searchReturned", thing.results
				error: (result) =>
					@trigger "searchReturned", null
				complete: =>
					# re-enable the search text field regardless of if any results found
					@$(".bv_thingSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false

class ACASThingBrowserCellController extends Backbone.View
	tagName: 'td'

	initialize: (options) ->
		@display = options.display

	render: =>
		$(@el).empty()

		value = @model.get(@display.key)
		if value instanceof Value
			content = value.get("value")
			if value.get("lsType") == "dateValue"  && !@display.formatter?
				content = UtilityFunctions::convertMSToYMDDate(content)
		else if value instanceof Label
			content = value.get("labelText")
		else
			content = value
		
		if @display.formatter?
			content = @display.formatter content

		$(@el).html content
		@

	handleCellClicked: =>
		@trigger 'cellClicked', @collection

class ACASThingBrowserRowSummaryController extends Backbone.View
	tagName: 'tr'
	className: 'dataTableRow'
	events:
		"click": "handleClick"

	handleClick: =>
		@trigger "gotClick", @model
		$(@el).closest("table").find("tr").removeClass "info"
		$(@el).addClass "info"

	initialize: (options)->
		@toDisplay = options.toDisplay

	render: =>
		for display in @toDisplay
			cellController = new ACASThingBrowserCellController
				display: display
				model: @model

			$(@el).append cellController.render().el
		@

class ThingSummaryTableController extends Backbone.View
	initialize: (options)->
		@toDisplay = options.toDisplay

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#ThingSummaryTableView').html())
		$(@el).html @template
		for display in @toDisplay
			@$(".bv_firstRow").append("<th style=\"width: 125px;\">#{display.name}</th>")

		if @collection.models.length is 0
			@$(".bv_noMatchingThingsFoundMessage").removeClass "hide"
			# display message indicating no results were found
		else
			@$(".bv_noMatchingThingsFoundMessage").addClass "hide"
			@collection.each (thing) =>
				prsc = new ACASThingBrowserRowSummaryController
					model: thing
					toDisplay: @toDisplay
				prsc.on "gotClick", @selectedRowChanged
				@$("tbody").append prsc.render().el

			@$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar

		@


class ACASThingBrowserController extends Backbone.View
	events:
		"click .bv_deleteThing": "handleDeleteThingClicked"
		"click .bv_editThing": "handleEditThingClicked"
		"click .bv_confirmDeleteThingButton": "handleConfirmDeleteThingClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	initialize: (options)->
		thingModel = new @modelClass
		@toDisplay = @toDisplay
		templateVariables = 
			thingName: thingModel.getName()
		template = _.template($("#ThingBrowserView").html())
		$(@el).empty()
		$(@el).html template(templateVariables)
		@searchController = new ThingSimpleSearchController
			model: thingModel
			query: @query
			el: @$('.bv_thingSearchController')
		@searchController.render()
		@searchController.on "searchReturned", @setupThingSummaryTable.bind(@)
		@$('.bv_queryToolDisplayName').html window.conf.service.result.viewer.displayName

	setupThingSummaryTable: (things) =>
		@destroyThingSummaryTable()

		$(".bv_searchingThingsMessage").addClass "hide"
		if things is null
			@$(".bv_errorOccurredPerformingSearch").removeClass "hide"

		else if things.length is 0
			@$(".bv_noMatchingThingsFoundMessage").removeClass "hide"
			@$(".bv_thingTableController").html ""
		else
			@$(".bv_searchThingsStatusIndicator").addClass "hide"
			@$(".bv_thingTableController").removeClass "hide"
			thingCollection =  Backbone.Collection.extend 
				model: @modelClass
			@thingSummaryTable = new ThingSummaryTableController
				collection: new thingCollection things
				toDisplay: @toDisplay

			@thingSummaryTable.on "selectedRowUpdated", @selectedThingUpdated
			$(".bv_thingTableController").html @thingSummaryTable.render().el

	selectedThingUpdated: (thing) =>
		@trigger "selectedThingUpdated"
		@thingController = new @controllerClass
			model: thing
			readOnly: true

		@$('.bv_thingController').html @thingController.render().el
		@$(".bv_thingController").removeClass("hide")
		@$(".bv_thingControllerContainer").removeClass("hide")

		@$('.bv_editThing').show()
		if window.conf.thing?.editingRoles?
			editingRoles = window.conf.thing.editingRoles.split(",")
			if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, editingRoles)
				@$('.bv_editThing').hide()

        # Not allowing deleting Thing right now
		if window.conf.thing?.deletingRoles?
			deletingRoles= window.conf.thing.deletingRoles.split(",")
			if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, deletingRoles)
				@$('.bv_deleteThing').hide()

	handleDeleteThingClicked: =>
		@$(".bv_thingUserName").html @thingController.model.get("codeName")
		@$(".bv_deleteButtons").removeClass "hide"
		@$(".bv_okayButton").addClass "hide"
		@$(".bv_errorDeletingThingMessage").addClass "hide"
		@$(".bv_deleteWarningMessage").removeClass "hide"
		@$(".bv_deletingStatusIndicator").addClass "hide"
		@$(".bv_thingDeletedSuccessfullyMessage").addClass "hide"
		@$(".bv_confirmDeleteThing").removeClass "hide"
		@$('.bv_confirmDeleteThing').modal({
			keyboard: false,
			backdrop: true
		})

	handleConfirmDeleteThingClicked: =>
		@$(".bv_deleteWarningMessage").addClass "hide"
		@$(".bv_deletingStatusIndicator").removeClass "hide"
		@$(".bv_deleteButtons").addClass "hide"
		$.ajax(
			url: "/api/things/#{@thingController.model.get("lsKind")}/#{@thingController.model.get("lsType")}/#{@thingController.model.get("id")}",
			type: 'DELETE',
			success: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_thingDeletedSuccessfullyMessage").removeClass "hide"
				@searchController.handleDoSearchClicked()
			error: (result) =>
				@$(".bv_okayButton").removeClass "hide"
				@$(".bv_deletingStatusIndicator").addClass "hide"
				@$(".bv_errorDeletingThingMessage").removeClass "hide"
		)

	handleCancelDeleteClicked: =>
		@$(".bv_confirmDeleteThing").modal('hide')

	handleEditThingClicked: =>
		# This relies on the item being configured in the ControllerRedirectConf configuration file
		window.open("/entity/edit/codeName/#{@thingController.model.get("codeName")}",'_blank');

	destroyThingSummaryTable: =>
		if @thingSummaryTable?
			@thingSummaryTable.remove()
		if @thingController?
			@thingController.remove()
		@$(".bv_thingController").addClass("hide")
		@$(".bv_thingControllerContainer").addClass("hide")
		@$(".bv_noMatchingThingsFoundMessage").addClass("hide")

	render: =>

		@
