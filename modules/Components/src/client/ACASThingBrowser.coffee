class ThingSearch extends Backbone.Model
	defaults:
		protocolCode: null
		ThingCode: null

class ThingSimpleSearchController extends AbstractFormController
	template: _.template($("#ThingSimpleSearchView").html())
	genericSearchUrl: '/api/advancedSearch/things/'
	thingAttributeReservedWords: ["codeName", "id", "recordedBy", "recordedDate", "modifiedBy", "modifiedDate", "lsType", "lsKind", "lsTransaction"]
	events:
		'keyup .bv_thingSearchTerm': 'updateThingSearchTerm'
		'click .bv_doSearch': 'handleDoSearchClicked'

	initialize: (options) ->
		@configs = options.configs

	render: =>
		$(@el).empty()
		templateVariables = 
			thingName: @model.getThingKindDisplayName()
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
		thingSearchTerm = $.trim(@$(".bv_thingSearchTerm").val())
		@$(".bv_exptSearchTerm").val ""
		if thingSearchTerm isnt ""
			if !window.conf.browser.enableSearchAll and thingSearchTerm is "*"
				@trigger "moreSpecificSearchRequired"
			else
				@$(".bv_exptSearchTerm").html _.escape(thingSearchTerm)
				@doSearch thingSearchTerm

	doSearch: (thingSearchTerm) =>
		# disable the search text field while performing a search
		@$(".bv_thingSearchTerm").attr "disabled", true
		@$(".bv_doSearch").attr "disabled", true
		@trigger 'find'
		unless thingSearchTerm is ""
			defaultQueryTerms =
				queryString: "#{thingSearchTerm}"
				queryDTO:
					maxResults: @options.maxResults
					lsType: @model.get("lsType")
					lsKind: @model.get("lsKind")
					recordedBy: "#{thingSearchTerm}"
					codeName: {
						operator: "~"
					},
					labels: [ 

					]
					values: [

					]
				returnDTO: {
					thingValues: []
					thingAttributes: ["id", "codeName"]
				}
									
			queryTerms = @getQueryTerms(defaultQueryTerms, thingSearchTerm)

			for queryValue in @configs
				valDef = @model.getValueInfo(queryValue.key)

				# Anything that is in the reserved words list is not a value but rather an lsthing attribute so we just add it to the thingAttributes list
				if queryValue.key in @thingAttributeReservedWords
					# Only add it to the thingattributes if it is not already there
					if queryValue.key not in queryTerms.returnDTO.thingAttributes
						queryTerms.returnDTO.thingAttributes.push(queryValue.key)
					continue

				if valDef?
					queryTerms.returnDTO.thingValues.push	
						stateType: valDef.stateType
						stateKind: valDef.stateKind
						valueType: valDef.type
						valueKind: valDef.kind
						key: queryValue.key
				else
					# If the key is an ls label
					labDef = @model.getLabelInfo(queryValue.key)
					if labDef?
						queryTerms.returnDTO.thingValues.push	
							labelType: labDef.type
							labelKind: labDef.kind
							key: queryValue.key


			$.ajax
				type: 'POST'
				url: "#{@genericSearchUrl}#{@model.get("lsType")}/#{@model.get("lsKind")}?format=flat"
				dataType: 'json',
				contentType: 'application/json'
				data: JSON.stringify(queryTerms)
				success: (response) =>
					@trigger "searchReturned", response
				error: (result) =>
					@trigger "searchReturned", null
				complete: =>
					# re-enable the search text field regardless of if any results found
					@$(".bv_thingSearchTerm").attr "disabled", false
					@$(".bv_doSearch").attr "disabled", false

	getQueryTerms: (queryTerms, searchTerm) ->
		for queryValue in @configs
			# Code Name and Recorded By are part of the defaults set them as isSearchable false
			if @thingAttributeReservedWords.includes(queryValue.key)
				queryValue.isSearchable = false
	
			# Default is all display values are searchable so if the attribute is missing or set to
			# anything other than false, then it is searchable
			isSearchable = (!queryValue.isSearchable? || queryValue.isSearchable != false)
			if queryValue.key == "recordedDate"
				@addRecordedDateToQuery(queryTerms, searchTerm)
			else
				#If the key is an ls value
				valDef = @model.getValueInfo(queryValue.key)
				if valDef?
						searchOperator = "~"
						if queryValue.searchOperator?
							searchOperator = queryValue.searchOperator
						queryTerms.queryDTO.values.push	
							stateType: valDef.stateType
							stateKind: valDef.stateKind
							valueType: valDef.type
							valueKind: valDef.kind
							operator: searchOperator
				else
					# If the key is an ls label
					labDef = @model.getLabelInfo(queryValue.key)
					if labDef?
						searchOperator = "~"
						if queryValue.searchOperator?
							operator = queryValue.searchOperator
						queryTerms.queryDTO.labels.push	
							labelType: labDef.type
							labelKind: labDef.kind
							operator: searchOperator
		return queryTerms

	addRecordedDateToQuery: (queryTerms, searchTerm) ->
		# Default search for recordedDate is ISO without time
		# e.g. 2021-06-02
		dateParts = searchTerm .split('-')
		# Offset the user entered date by one month to account for month = 0 in javascript
		if typeof(dateParts[1]) != "undefined"
			dateParts[1] = dateParts[1]-1
		# Create a new date from the parts
		recordedDateGreaterThan = new Date(Date.UTC(...dateParts))

		# If the is a real date
		if !isNaN(recordedDateGreaterThan)
			# Offset a year month, or day depending on the parts the user entered for the less than date
			recordedDateLessThan = new Date(recordedDateGreaterThan.getTime())
			if dateParts.length == 1
				recordedDateLessThan.setFullYear(recordedDateLessThan.getFullYear() + 1);
			else if dateParts.length == 2
				recordedDateLessThan.setMonth(recordedDateLessThan.getMonth() + 1);
			else if dateParts.length == 3
				recordedDateLessThan.setDate(recordedDateLessThan.getDate() + 1)

			# Offset the UTC date by the current offset time
			msUTCOffset = recordedDateGreaterThan.getTimezoneOffset() * 60000
			recordedDateGreaterThan = recordedDateGreaterThan.getTime() + msUTCOffset
			recordedDateLessThan = recordedDateLessThan.getTime() + msUTCOffset

			# Add the recorded date query parameters
			queryTerms.queryDTO.recordedDateGreaterThan=recordedDateGreaterThan
			queryTerms.queryDTO.recordedDateLessThan=recordedDateLessThan

				
class ACASThingBrowserCellController extends Backbone.View
	tagName: 'td'

	initialize: (options) ->
		@configs = options.configs

	render: =>
		$(@el).empty()

		if @model instanceof Backbone.Model

			# The model could be a thing or just a backbone model with key value pairs
			value = @model.get(@configs.key)
			# Render Thing Value
			if value instanceof Value
				content = value.get("value")
				# If it's a string then escape it
				if typeof(content) == "string"
					content = value.escape(content)
			# Render Thing Label
			else if value instanceof Label
				content = value.escape("labelText")
			# Render key value backbone model
			else 
				# This is not a Thing Value or Label so assume it's just a backbone model with key/value pairs
				# If the thing model class was passed in then we can use it to determine if this is a date value we should parse
				content = @model.get(@configs.key)
				if typeof(content) == "string"
					content = @model.escape(@configs.key)
		else
			# This is strictly a key/pair object
			content = @model[@configs.key]

		if @options.thingModelExample?
			modelValue = this.options.thingModelExample.get(@configs.key)
			if modelValue instanceof Value && modelValue.get("lsType") == "dateValue" && !@configs.formatter?
				content = UtilityFunctions::convertMSToYMDDate(content)
		
		if @configs.formatter?
			content = @configs.formatter content

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
		@configs = options.configs

	render: =>
		for config in @configs
			cellController = new ACASThingBrowserCellController
				configs: config
				model: @model
				thingModelExample: @options.thingModelExample

			$(@el).append cellController.render().el
		@

class ThingSummaryTableController extends Backbone.View
	initialize: (options)->
		@configs = options.configs
		@columnFilters = options.columnFilters
		@maxResults = options.maxResults

	selectedRowChanged: (row) =>
		@trigger "selectedRowUpdated", row

	render: =>
		@template = _.template($('#ThingSummaryTableView').html())
		$(@el).html @template
		for config in @configs
			@$(".bv_firstRow").append("<th style=\"width: 125px;\">#{config.name}</th>")

		# Add empty tr in thead for filter use
		if @columnFilters? && @columnFilters
			for config in @configs
			 	# Remove space from key name
				filterClass = "bv_filter_" + config.key.replace(/\s/g, '')
				@$(".bv_colFilters").append("<th style=\"width: 125px;\" class=\"bv_thingBrowserFilter "+filterClass+"\"></th>")
		
		if @collection.length is 0
			@$(".bv_noMatchingThingsFoundMessage").removeClass "hide"
			# display message indicating no results were found
		else
			@$(".bv_noMatchingThingsFoundMessage").addClass "hide"
			exampleModel = new @options.thingModelClass()
			@collection.forEach (flattenedThing) =>
				prsc = new ACASThingBrowserRowSummaryController
					model: flattenedThing
					thingModelExample: exampleModel
					configs: @configs
				prsc.on "gotClick", @selectedRowChanged
				@$("tbody").append prsc.render().el

			$.fn.dataTableExt.oApi.fnGetColumnData = (oSettings, iColumn, bUnique, bFiltered, bIgnoreEmpty) ->
				# check that we have a column id
				if typeof iColumn == 'undefined'
					return new Array
				# by default we only want unique data
				if typeof bUnique == 'undefined'
					bUnique = true
				# by default we do want to only look at filtered data
				if typeof bFiltered == 'undefined'
					bFiltered = true
				# by default we do not want to include empty values
				if typeof bIgnoreEmpty == 'undefined'
					bIgnoreEmpty = true
				# list of rows which we're going to loop through
				aiRows = undefined
				# use only filtered rows
				if bFiltered == true
					aiRows = oSettings.aiDisplay
				else
					aiRows = oSettings.aiDisplayMaster
				# all row numbers
				# set up data array   
				asResultData = new Array
				i = 0
				c = aiRows.length
				while i < c
					iRow = aiRows[i]
					aData = @fnGetData(iRow)
					sValue = aData[iColumn]
					# ignore empty values?
					if bIgnoreEmpty == true and sValue.length == 0
						i++
						continue
					else if bUnique == true and jQuery.inArray(sValue, asResultData) > -1
						i++
						continue
					else
						asResultData.push sValue
					i++

				# Sort lexicographically before returning
				asResultData.sort (a, b)->
					return a.toLowerCase().localeCompare(b.toLowerCase());
				
			
			fnCreateSelect = (aData) ->
				r = '<select><option value=""></option>'
				i = undefined
				iLen = aData.length
				i = 0
				while i < iLen
					r += '<option value="' + aData[i] + '">' + aData[i] + '</option>'
					i++
				r + '</select>'
				
			oTable = @$("table").dataTable oLanguage:
				sSearch: "Filter results: " #rename summary table's search bar

			if @columnFilters? && @columnFilters
				configs = @configs
				this.$('thead tr.bv_colFilters th').each (i) ->
					# Default is to add a filter to each column
					# So only skip filtering if filter is false
					if !configs[i].filter? || configs[i].filter
						@innerHTML = fnCreateSelect(oTable.fnGetColumnData(i))
						$('select', this).change ->
							oTable.fnFilter "^"+$(this).val()+"$", i, true
							return
						return

		@


class ACASThingBrowserController extends Backbone.View
	events:
		"click .bv_deleteThing": "handleDeleteThingClicked"
		"click .bv_editThing": "handleEditThingClicked"
		"click .bv_confirmDeleteThingButton": "handleConfirmDeleteThingClicked"
		"click .bv_cancelDelete": "handleCancelDeleteClicked"

	initialize: (options)->
		thingModel = new @modelClass
		@configs = @configs
		@columnFilters = @columnFilters
		templateVariables = 
			thingName: thingModel.getThingKindDisplayName()
		template = _.template($("#ThingBrowserView").html())
		$(@el).empty()
		$(@el).html template(templateVariables)
		@searchController = new ThingSimpleSearchController
			model: thingModel
			query: @query
			configs: @configs
			maxResults: @maxResults
			el: @$('.bv_thingSearchController')
		@searchController.render()
		@searchController.on "searchReturned", @setupThingSummaryTable.bind(@)
		@searchController.on "find", @searchingStarted.bind(@)
		@searchController.on "moreSpecificSearchRequired", @moreSpecificSearchRequired.bind(@)
		@$('.bv_queryToolDisplayName').html window.conf.service.result.viewer.displayName

	showOne: (cl) =>
		cls = ["bv_noMatchingThingsFoundMessage", "bv_moreSpecificThingSearchNeeded", "bv_errorOccurredPerformingSearch", "bv_thingBrowserSearchInstructions", "bv_searchingThingsMessage"]
		for c in cls
			@$("." + c).addClass("hide")
		if cl?
			@$("." + cl).removeClass("hide")
		@$(".bv_thingTableController").addClass("hide")
		@$(".bv_searchThingsStatusIndicator").removeClass("hide")

	moreSpecificSearchRequired: =>
		@showOne("bv_moreSpecificThingSearchNeeded")

	searchingStarted: =>
		@destroyThingSummaryTable()
		@showOne("bv_searchingThingsMessage")

	setupThingSummaryTable: (response) =>
		results = response.results

		if response.maxResults <= response.numberOfResults
			msg = "Browser results were limited to the first " + response.maxResults + " entries out of " + response.numberOfResults + " results"
			@$('.bv_maxThingBrowserSearchResultsReached').html msg
			@$(".bv_maxThingBrowserSearchResultsReached").removeClass("hide")
		else 
			@$(".bv_maxThingBrowserSearchResultsReached").addClass("hide")

		if results is null
			@showOne("bv_errorOccurredPerformingSearch")

		else if results.length is 0
			@showOne("bv_noMatchingThingsFoundMessage")
		else
			@$(".bv_searchThingsStatusIndicator").addClass "hide"
			@$(".bv_thingTableController").removeClass "hide" 

			@thingSummaryTable = new ThingSummaryTableController
				collection: results
				thingModelClass: @modelClass
				configs: @configs
				columnFilters: @columnFilters
				maxResults: @maxResults

			@thingSummaryTable.on "selectedRowUpdated", @selectedThingUpdated
			@$(".bv_thingTableController").html @thingSummaryTable.render().el

	selectedThingUpdated: (thing) =>
		@$('.bv_thingControllerWrapper').append("<div class='bv_thingController'></div>")
		@trigger "selectedThingUpdated"

		# If thing is thing class then we pass it to the thing controller, if not then we fetch it from the server and pass it to the thing controller
		if thing instanceof Thing
			@thingController = new @controllerClass
				model: thing
				configs: @configs
				el: @$('.bv_thingController')
			@renderController()
		else
			c = new @modelClass(thing.attributes)
			c.fetch
				success: (model, response, options) =>
					@thingController = new @controllerClass
						model: model
						configs: @configs
						el: @$('.bv_thingController')
					@renderController()
				error: (model, response, options) =>
					@$('.bv_thingController').html "Error fetching thing"

	renderController: () =>
		@thingController.render()
		@$(".bv_thingController").removeClass("hide")
		@$(".bv_thingControllerContainer").removeClass("hide")

		@$('.bv_editThing').show()
		if window.conf.thing?.editingRoles?
			editingRoles = window.conf.thing.editingRoles.split(",")
			if !UtilityFunctions::testUserHasRole(window.AppLaunchParams.loginUser, editingRoles)
				@$('.bv_editThing').hide()

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
