class window.GeneIDQueryInputController extends Backbone.View
	template: _.template($("#GeneIDQueryInputView").html())

	events:
		"click .bv_search": "handleSearchClicked"
		"click .bv_gidNavAdvancedSearchButton": "handleAdvanceModeRequested"
		"keyup .bv_gidListString": "handleInputFieldChanged"
		"keydown .bv_gidListString": "handleKeyInInputField"
		"click .bv_aggregation_true": "handleAggregationChanged"
		"click .bv_aggregation_false": "handleAggregationChanged"
		"change .bv_displayNameSelect": "handleDisplayNameChanged"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupDisplayNameSelect()
		@$('.bv_search').attr('disabled','disabled')
		@$('.bv_gidACASBadgeTop').hide()
		@$('.bv_searchNavbar').hide()
		@handleAggregationChanged()

		@

	setupDisplayNameSelect: ->
		@displayNameList = new PickListList()
		@displayNameList.url = "/api/entitymeta/configuredEntityTypes/asCodes"
		@displayNameListController = new PickListSelectController
			el: @$(".bv_displayNameSelect")
			collection: @displayNameList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Entity Type (optional)"
			selectedCode: "unassigned"
		@displayName = "unassigned"


	handleDisplayNameChanged: ->
		@displayName = @displayNameListController.getSelectedCode()

	handleInputFieldChanged: =>
		if $.trim(@$('.bv_gidListString').val()).length > 1
			@$('.bv_search').removeAttr('disabled')
		else
			@$('.bv_search').attr('disabled','disabled')

	handleAggregationChanged: =>
		@aggregate = @$("input[name='bv_aggregation']:checked").val()

	handleKeyInInputField: (e) =>
		if e.keyCode == 13
			@handleSearchClicked()

	handleSearchClicked: =>
		@trigger 'search-requested', $.trim(@$('.bv_gidListString').val()), @displayName

	handleAdvanceModeRequested: =>
		@trigger 'requestAdvancedMode', $.trim(@$('.bv_gidListString').val()), @aggregate, @displayName


class window.GeneIDQueryResultController extends Backbone.View
	template: _.template($("#GeneIDQueryResultView").html())
	events:
		"click .bv_downloadCSV": "handleDownloadCSVClicked"
		"click .bv_addData": "handleAddDataClicked"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		if @model.get('data').iTotalRecords > 0
			@$('.bv_noResultsFound').hide()
			@setupHeaders()
			sortingType = String(window.conf.sar.sorting)
			@$('.bv_resultTable').dataTable
				aaData: @model.get('data').aaData
				aoColumns: @model.get('data').aoColumns
				bDeferRender: true
				bProcessing: true
				aoColumnDefs:[
					{sType: sortingType, aTargets: ["_all"]},
					# add ids as an html tag to each cell
					{fnCreatedCell: (nTd, sData, oData, iRow, iCol)=>
						val = @model.get('ids')[iRow][iCol]
						nTd.setAttribute('id',val)
					, aTargets: ["_all"]}
					]
				# uncomment the following line to disable sorting in the dataTable
				# bSort: false
			@displayName = @model.get('data').displayName
			if @displayName?
				$.get "/api/sarRender/title/" + @displayName, (json) =>
					@$('th.referenceCode').html(json.title)
			@modifyTableEntities()
			@$('.bv_resultTable').on "draw", @modifyTableEntities


		else
			@$('.bv_resultTable').hide()
			@$('.bv_noResultsFound').show()
			@$('.bv_gidDownloadCSV').hide()
			@$('.bv_addData').hide()

		@

	modifyTableEntities: =>
		#load sar rendering data
		@$('td.referenceCode').each ->
			$.ajax
				type: 'POST'
				url: "api/sarRender/render"
				dataType: 'json'
				data:
					displayName: @displayName
					referenceCode: $(@).html()
				success: (json) =>
					$(@).html(json.html)
					$(@).removeClass("referenceCode") #only need to modify once

	setupHeaders: ->
		_.each @model.get('data').groupHeaders, (header) =>
			@$('.bv_experimentNamesHeader').append '<th class="bv_headerCell" colspan="'+header.numberOfColumns+'">'+header.titleText+'</th>'
		_.each @model.get('data').aoColumns, (header) =>
			@$('.bv_columnNamesHeader').append '<th>placeholder</th>'

	handleDownloadCSVClicked: =>
		@$('.bv_searchStatusDropDown').modal
			backdrop: "static"
		@$('.bv_searchStatusDropDown').modal "show"
		@trigger 'downLoadCSVRequested'

	showCSVFileLink: (json) =>
		@$('.bv_searchStatusDropDown').modal "hide"
		@$('.bv_resultFileLink').attr 'href', json.fileURL
		@$('.bv_csvFileLinkModal').modal
			show: true

	handleAddDataClicked: =>
		@trigger 'addDataRequested'


class window.GeneIDQuerySearchController extends Backbone.View
	template: _.template($("#GeneIDQuerySearchView").html())
	lastSearch: ""

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@queryInputController = new GeneIDQueryInputController
			el: @$('.bv_inputView')
		@queryInputController.on 'search-requested', @handleSearchRequested
		@queryInputController.on 'requestAdvancedMode', @requestFilterExperiments
		@queryInputController.render()
		@setQueryOnlyMode()
		@dataAdded = false

	requestFilterExperiments: (searchStr, aggregate, displayName) =>
		@trigger 'requestAdvancedMode', searchStr, aggregate, displayName

	handleSearchRequested: (searchStr, displayName) =>
		@displayName = displayName
		@lastSearch = searchStr
		@$('.bv_searchStatusDropDown').modal
			backdrop: "static"
		@$('.bv_searchStatusDropDown').modal "show"
		@fromSearchtoCodes()

	fromSearchtoCodes: ->
		searchString = @lastSearch
		searchTerms = searchString.split(/[^A-Za-z0-9_-]/) #split on whitespace except "-"
		searchTerms = _.filter(searchTerms, (x) -> x != "")
		if @displayName == "unassigned"
			@counter = 0
			@numTerms = searchTerms.length
			@searchResults = []
			for term in searchTerms
				$.ajax
					type: 'POST'
					url: "api/entitymeta/searchForEntities"
					dataType: 'json'
					data:
						requestText: term
					success: @handleEntitySearchReturn
					error: (err) =>
						@serviceReturn = null
		else
			requests = []
			for term in searchTerms
				requests.push
					requestName: term
			$.ajax
				type: 'POST'
				url: "api/entitymeta/referenceCodes"
				dataType: "json"
				data:
					displayName: @displayName
					requests: requests
				success: @knownDisplayNameReturn
				error: (err) =>
					@serviceReturn = null

	knownDisplayNameReturn: (json) =>
		refCodes = ""
		for result in json.results when result.referenceCode != ""
			refCodes += " "+ result.referenceCode
		@lastSearch = refCodes
		@getAllExperimentNames()

	handleEntitySearchReturn: (json) =>
		@counter = @counter + 1
		if json.results.length > 0
			console.log "found a match for term "+ json.results[0].requestText
			for result in json.results
				@searchResults.push
					displayName: result.displayName
					referenceCode: result.referenceCode
		if @counter >= @numTerms
			console.log "All searches returned, going to filter"
			@filterOnDisplayName()
			@getAllExperimentNames()

	filterOnDisplayName: ->
		displayNames = _.uniq(_.pluck(@searchResults, "displayName"))
		if displayNames.length <= 1
			@displayName = displayNames[0]
			@lastSearch = _.pluck(@searchResults,"referenceCode").join(" ")
			console.log "all search terms from same type/kind, going to get experiments"
			@getAllExperimentNames()
		else
			@$('.bv_searchStatusDropDown').modal "hide"
			jsonSearch =
				results: @searchResults
			@entityController = new ChooseEntityTypeController
				el: @$('.bv_chooseEntityView')
				model: new Backbone.Model jsonSearch
			@entityController.on 'entitySelected' , @refCodesToSearchStr
			console.log("multiple entity types found")
			# @searchCodes = _.pluck(@searchResults,"referenceCode").join(" ")
			# @fromCodesToExptTree()

	refCodesToSearchStr: (displayName) =>
		@displayName = displayName
		console.log "chosen entityType is "+ displayName
		@lastSearch = _.pluck(_.where(@searchResults, {displayName: displayName}), "referenceCode").join(" ")
		@getAllExperimentNames()


	getAllExperimentNames: ->
		if @lastSearch == ""
			@lastSearch = "NO RESULTS"
		$.ajax
			type: 'POST'
			url: "api/getGeneExperiments"
			dataType: 'json'
			data:
				geneIDs: @lastSearch
			success: @handleGetExperimentsReturn
			error: (err) =>
				@serviceReturn = null

	handleGetExperimentsReturn: (json) =>
		data = json.results.experimentData
		experimentCodeList = []
		experimentCodeList.push(expt.id) for expt in data
		@codesList =  experimentCodeList
		@runRequestedSearch()

	getQueryParams: ->
		searchFilter =
			booleanFilter: "and"
			advancedFilter: ""
		queryParams =
			batchCodes: @lastSearch
			experimentCodeList: @codesList
			searchFilters: searchFilter
			aggregate: @queryInputController.aggregate

	runRequestedSearch: ->
		$.ajax
			type: 'POST'
			url: "api/geneDataQueryAdvanced"
			dataType: 'json'
			data:
				queryParams: @getQueryParams()
				maxRowsToReturn: 10000
				user: window.AppLaunchParams.loginUserName
			success: @handleSearchReturn
			error: (err) =>
				@serviceReturn = null


	# handleSearchRequested: (searchStr) =>
	# 	@lastSearch = searchStr
	# 	@$('.bv_searchStatusDropDown').modal
	# 	backdrop: "static"
	# 	@$('.bv_searchStatusDropDown').modal "show"
	# 	$.ajax
	# 		type: 'POST'
	# 		url: "api/geneDataQuery"
	# 		data:
	# 			geneIDs: searchStr
	# 			maxRowsToReturn: 10000
	# 			user: window.AppLaunchParams.loginUserName
	# 		success: @handleSearchReturn
	# 		error: (err) =>
	# 			@serviceReturn = null
	# 		dataType: 'json'

	handleSearchReturn: (json) =>
		@$('.bv_searchStatusDropDown').modal "hide"
		@resultsJson = json.results
		@resultsJson.data.displayName = @displayName
		if !@dataAdded
			@resultController = new GeneIDQueryResultController
				model: new Backbone.Model json.results
				el: $('.bv_resultsView')
			@resultController.on 'downLoadCSVRequested', @handleDownLoadCSVRequested
			@resultController.on 'addDataRequested', @handleShowHideExperiments
		else
			@searchCodes = json.results.batchCodes.join() # update search parameters so csv gets correct data
			@experimentList = json.results.experimentCodeList
			@resultController.model.clear().set(json.results)
		@resultController.render()
		$('.bv_searchForm')
			.appendTo('.bv_searchNavbar')
		@$('.bv_addData').html "Show/Hide Data"
		@$('.bv_gidDownloadCSV').addClass('bv_gidDownloadCSVSimple')
		@$('.bv_addDataRequest').addClass('bv_addDataRequestSimple')
		@$('.bv_gidSearchStart').hide()
		@$('.bv_gidACASBadge').hide()
		@$('.bv_gidACASBadgeTop').show()
		@$('.bv_gidNavAdvancedSearchButton').removeClass 'gidAdvancedNavSearchButtonStart'
		@$('.bv_gidNavAdvancedSearchButton').addClass 'gidAdvancedNavSearchButtonTop'
		@$('.bv_searchNavbar').show()

		@setShowResultsMode()

	setQueryOnlyMode: =>
		@$('.bv_resultsView').hide()

	setShowResultsMode: =>
		@$('.bv_resultsView').show()

	handleDownLoadCSVRequested: =>
		$.ajax
			type: 'POST'
			url: "api/geneDataQueryAdvanced?format=csv"
			dataType: 'json'
			data:
				queryParams: @getQueryParams()
				maxRowsToReturn: 10000
				user: window.AppLaunchParams.loginUserName
			success: @resultController.showCSVFileLink
			error: (err) =>
				@serviceReturn = null


	handleShowHideExperiments: =>
		if !@dataAdded
			@dataAdded = true
			@addData = new ShowHideExpts
				model: new Backbone.Model @resultsJson
				el: @$('.bv_resultsView')
			@addData.on 'requestResults', @handleSearchReturn
		else
			@addData.model.clear().set(@resultsJson)
			@addData.render()



class window.ShowHideExpts extends Backbone.View
	template: _.template($("#AddDataView").html())
	events:
		"click .bv_searchClear": "handleSearchClear"
		"click .bv_addDataTree": "handleSelectionChanged"
		"click .bv_displayResults": "handleDisplayResuts"
		"click .bv_aggregation_true": "handleAggregationChanged"
		"click .bv_aggregation_false": "handleAggregationChanged"

	initialize: ->
		$(@el).append @template()
		@render()

	render: ->
		@$('.bv_searchStatusDropDown').modal
			backdrop: "static"
		@$('.bv_searchStatusDropDown').modal "show"
		@getBatchCodes()

	getBatchCodes: ->
		data = @model.get('data')
		allBatchCodes = []
		$(data.aaData).each (key,value) ->
			allBatchCodes.push(value.geneId)
		@allBatchCodes = allBatchCodes
		@gotoShowTree()

	gotoShowTree: ->
		$.ajax
			type: 'POST'
			url: "api/getGeneExperiments"
			dataType: 'json'
			data:
				geneIDs: @allBatchCodes
			success: @handleGetAddDataTreeReturn
			error: (err) =>
				@serviceReturn = null

	handleGetAddDataTreeReturn: (json) =>
		@$('.bv_searchStatusDropDown').modal "hide"
		if !@$('.bv_addDataModal').length #if the template hasn't been added
			$(@el).append @template()
		@$('.bv_addDataModal').modal
			backdrop: "static"
		@$('.bv_addDataModal').modal "show"
		@$('.bv_aggregation_true').prop("disabled",false)
		@$('.bv_aggregation_false').prop("disabled",false)
		if json.results.experimentData.length > 0
			results = json.results.experimentData
			@setupTree(results)

	setupTree: (results) ->
		@$('.bv_addDataTree').jstree
			core:
				data: results
			search:
				fuzzy: false
			plugins: [ "checkbox", "search" ]

		@$('.bv_addDataTree').bind "hover_node.jstree", (e, data) ->
			$(e.target).attr("title", data.node.original.description)

		to = false
		@$(".bv_searchVal").keyup =>
			clearTimeout to  if to
			to = setTimeout(->
				v = @$(".bv_searchVal").val()
				@$(".bv_tree").jstree(true).search v
				return
			, 250)
			return

		@aggregate = @model.get("aggregate")
		if @aggregate
			$(".bv_aggregation_true").prop("checked",true)

		expts = @model.get("experimentCodeList")
		@exptLength = expts.length
		@$(".bv_addDataTree").jstree('select_node',expts)


	handleAggregationChanged: =>
		@aggregate = @$("input[name='bv_aggregation']:checked").val()
		if @$('.bv_addDataTree').jstree('get_selected').length > 0
			@$('.bv_displayResults').prop("disabled",false)

	handleSearchClear: =>
		@$('.bv_searchVal').val("")

	getSelectedExperiments: ->
		@$('.bv_addDataTree').jstree('get_selected')

	handleSelectionChanged: =>
		@selected = @getSelectedExperiments()
		if @$('.bv_addDataTree').jstree('get_selected').length > 0
			@$('.bv_displayResults').prop("disabled",false)
		else
			@$('.bv_displayResults').prop("disabled",true)

	getQueryParams: ->
		queryParams =
			batchCodes: @allBatchCodes.join()
			experimentCodeList: @selected
			searchFilters: @model.get("searchFilters")
			aggregate: @aggregate

	handleDisplayResuts: ->
		@$('.bv_searchStatusDropDown').modal
			backdrop: "static"
		@$('.bv_searchStatusDropDown').modal "show"

		$.ajax
			type: 'POST'
			url: "api/geneDataQueryAdvanced"
			dataType: 'json'
			data:
				queryParams: @getQueryParams()
				maxRowsToReturn: 10000
				user: window.AppLaunchParams.loginUserName
			success: @handleAddDataReturn
			error: (err) =>
				@serviceReturn = null

	handleAddDataReturn: (json) =>
		@trigger 'requestResults', json







########################################################
################  Advanced-mode queries ################
########################################################






class window.ExperimentTreeController extends Backbone.View
	template: _.template($("#ExperimentTreeView").html())
	events:
		"click .bv_searchClear": "handleSearchClear"
		"click .bv_tree": "handleSelectionChanged"
		"click .bv_aggregation_true": "handleAggregationChanged"
		"click .bv_aggregation_false": "handleAggregationChanged"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@trigger 'disableNext'
		@setupTree()
		@handleAggregationChanged()

		@

	setupTree: ->
		@$('.bv_tree').jstree
			core:
				data: @model.get('experimentData')
			search:
				fuzzy: false
			plugins: [ "checkbox", "search"]

		@$('.bv_tree').bind "hover_node.jstree", (e, data) ->
			$(e.target).attr("title", data.node.original.description)

		to = false
		@$(".bv_searchVal").keyup =>
			clearTimeout to  if to
			to = setTimeout(->
				v = @$(".bv_searchVal").val()
				@$(".bv_tree").jstree(true).search v
				return
			, 250)
			return

	handleSearchClear: =>
		@$('.bv_searchVal').val("")

	getSelectedExperiments: ->
		@$('.bv_tree').jstree('get_selected')

	handleSelectionChanged: =>
		selected = @getSelectedExperiments()
		if selected.length > 0
			@trigger 'enableNext'
		else
			@trigger 'disableNext'

	handleAggregationChanged: =>
		@aggregate = @$("input[name='bv_aggregation']:checked").val()

class window.ExperimentResultFilterTerm extends Backbone.Model
	defaults: ->
		filterValue: ""

	validate: (attrs) ->
		errors = []
		if (attrs.filterValue is "" and attrs.lsType != 'booleanValue') or (attrs.filterValue is null and attrs.lsType != 'booleanValue')
			errors.push
				attribute: 'filterValue'
				message: "Filter value must be set"
		if errors.length > 0
			return errors
		else
			return null

class window.ExperimentResultFilterTermList extends Backbone.Collection
	model: ExperimentResultFilterTerm

	validateCollection: ->
		modelErrors = []
		@.each (model) =>
			modelErrors.push model.validationError...
		modelErrors


class window.ExperimentResultFilterTermController extends AbstractFormController
	template: _.template($("#ExperimentResultFilterTermView").html())
	tagName: "div"
	className: "form-inline"
	events:
		"change .bv_experiment": "setKindOptions"
		"change .bv_kind": "setOperatorOptions"
		"click .bv_delete": "clear"
		"change .bv_filterValue": "attributeChanged"

	initialize: ->
		@errorOwnerName = 'ExperimentResultFilterTermController'
		@setBindings()
		@filterOptions = @options.filterOptions
		@model.set termName: @options.termName
		@model.on "destroy", @remove, @

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_termName').html @model.get('termName')
		@filterOptions.each (expt) =>
			code = expt.get('experimentCode')
			ename = expt.get('experimentName')
			@$('.bv_experiment').append '<option value="'+code+'">'+ename+'</option>'
		@setKindOptions()
		@setOperatorOptions()

		@

	setKindOptions: =>
		currentExpt = @getSelectedExperiment()
		kinds = _.pluck currentExpt.get('valueKinds'), 'lsKind'
		@$('.bv_kind').empty()
		for kind in kinds
			@$('.bv_kind').append '<option value="'+kind+'">'+kind+'</option>'
		@setOperatorOptions()

	setOperatorOptions: =>
		switch @getSelectedValueType()
			when "numericValue"
				@$('.bv_operator_number').addClass('bv_operator').show()
				@$('.bv_operator_bool').removeClass('bv_operator').hide()
				@$('.bv_operator_string').removeClass('bv_operator').hide()
				@$('.bv_filterValue').show()
				@$('.bv_filterValue').val("")
				@$('.bv_filterValue').change()
				@updateModel()
			when "booleanValue"
				@$('.bv_operator_number').removeClass('bv_operator').hide()
				@$('.bv_operator_bool').addClass('bv_operator').show()
				@$('.bv_operator_string').removeClass('bv_operator').hide()
				@$('.bv_filterValue').hide()
				@$('.bv_filterValue').val("")
				@$('.bv_filterValue').change()
				@updateModel()
			when "stringValue"
				@$('.bv_operator_number').removeClass('bv_operator').hide()
				@$('.bv_operator_bool').removeClass('bv_operator').hide()
				@$('.bv_operator_string').addClass('bv_operator').show()
				@$('.bv_filterValue').show()
				@$('.bv_filterValue').val("")
				@$('.bv_filterValue').change()
				@updateModel()

	getSelectedExperiment: ->
		exptCode = @$('.bv_experiment').val()
		currentExpt = @filterOptions.filter (expt) ->
			expt.get('experimentCode') == exptCode
		currentExpt[0]

	getSelectedValueType: ->
		currentExpt = @getSelectedExperiment()
		kind =  @$('.bv_kind').val()
		currentAttr = _.filter currentExpt.get('valueKinds'), (k) ->
			k.lsKind == kind
		currentAttr[0].lsType

	updateModel: =>
		@model.set
			experimentCode: @$('.bv_experiment').val()
			lsKind: @$('.bv_kind').val()
			lsType: @getSelectedValueType()
			operator: @$('.bv_operator').val()
			filterValue: $.trim(@$('.bv_filterValue').val())

	clear: =>
		@model.destroy()
		@trigger 'checkCollection'

	validationError: =>
		super()
		@trigger 'disableNext'

	clearValidationErrorStyles: =>
		super()
		@trigger 'enableNext'


class window.ExperimentResultFilterTermListController extends Backbone.View
	template: _.template($("#ExperimentResultFilterTermListView").html())
	events:
		"click .bv_addTerm": "addOne"

	TERM_NUMBER_PREFIX: "Q"

	initialize: ->
		@filterOptions = @options.filterOptions
		@nextTermNumber = 1

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.on 'change', @checkCollection


		@

	addOne: =>
		newModel = new ExperimentResultFilterTerm()
		@collection.add newModel
		erftc = new ExperimentResultFilterTermController
			model: newModel
			filterOptions: @filterOptions
			termName: @TERM_NUMBER_PREFIX+@nextTermNumber++
		@$('.bv_filterTerms').append erftc.render().el
		@on "updateFilterModels", erftc.updateModel
		erftc.on 'checkCollection', =>
			@checkCollection()
		erftc.on 'disableNext', =>
			@trigger 'disableNext'
		erftc.on 'enableNext', =>
			@trigger 'enableNext'
		if erftc.model.validationError.length > 0
			@trigger 'disableNext'
		else
			@trigger 'enableNext'

	checkCollection: =>
		if @collection.validateCollection().length > 0
			@trigger 'disableNext'
		else
			@trigger 'enableNext'

	updateCollection: ->
		@trigger "updateFilterModels"


class window.ExperimentResultFilterController extends Backbone.View
	template: _.template($("#ExperimentResultFilterView").html())
	events:
		"click .bv_booleanFilter_and": "handleBooleanFilterChanged"
		"click .bv_booleanFilter_or": "handleBooleanFilterChanged"
		"click .bv_booleanFilter_advanced": "handleBooleanFilterChanged"

	initialize: ->
		@filterOptions = @options.filterOptions

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@erftlc = new ExperimentResultFilterTermListController
			el: @$('.bv_filterTermList')
			collection: new ExperimentResultFilterTermList()
#			collection: new Backbone.Collection()
			filterOptions: @filterOptions
		@erftlc.render()
		@erftlc.on 'enableNext', =>
			@trigger 'enableNext'
		@erftlc.on 'disableNext', =>
			@trigger 'disableNext'

		@handleBooleanFilterChanged()

		@

	getSearchFilters: ->
		@erftlc.updateCollection()
		filtersAtters =
			booleanFilter: @$("input[name='bv_booleanFilter']:checked").val()
			advancedFilter: $.trim @$('.bv_advancedBooleanFilter').val()
			filters: @erftlc.collection.toJSON()
		filtersAtters

	handleBooleanFilterChanged: =>
		if @$("input[name='bv_booleanFilter']:checked").val() == 'advanced'
			@$('.bv_advancedBoolContainer').show()
		else
			@$('.bv_advancedBoolContainer').hide()


class window.AdvancedExperimentResultsQueryController extends Backbone.View
	template: _.template($("#AdvancedExperimentResultsQueryView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@dataAdded = false
		@$('.bv_getExperimentsView').hide()
		@$('.bv_getFiltersView').hide()
		@$('.bv_advResultsView').hide()
		@$('.bv_noExperimentsFound').hide()
		# @gotoStepGetCodes()
		@fromSearchtoCodes()

	handleNextClicked: =>
		switch @nextStep
			# when 'fromCodesToExptTree'
			# 	@fromCodesToExptTree()
			when 'fromExptTreeToFilters'
				@fromExptTreeToFilters()
			when 'fromFiltersToResults'
				@fromFiltersToResults()
			when 'gotoRestart'
				@trigger 'requestRestartAdvancedQuery'

	# gotoStepGetCodes: ->
	# 	@nextStep = 'fromCodesToExptTree'
	# 	@$('.bv_getCodesView').show()
	# 	@$('.bv_getExperimentsView').hide()
	# 	@$('.bv_getFiltersView').hide()
	# 	@$('.bv_advResultsView').hide()
	# 	@$('.bv_cancel').html 'Cancel'
	# 	@$('.bv_noExperimentsFound').hide()


	fromSearchtoCodes: ->
		@displayName = @model.get('displayName')
		searchString = @model.get('searchStr')
		searchTerms = searchString.split(/[^A-Za-z0-9_-]/) #split on whitespace except "-"
		searchTerms = _.filter(searchTerms, (x) -> x != "")
		if searchTerms.length == 0
			@fromCodesToExptTree()
			@$('.bv_searchStatusDropDown').modal
				backdrop: "static"
			@$('.bv_searchStatusDropDown').modal "show"
		if @displayName == "unassigned"
			@counter = 0
			@numTerms = searchTerms.length
			@searchResults = []
			for term in searchTerms
				$.ajax
					type: 'POST'
					url: "api/entitymeta/searchForEntities"
					dataType: 'json'
					data:
						requestText: term
					success: @handleEntitySearchReturn
					error: (err) =>
						@serviceReturn = null
		else
			requests = []
			for term in searchTerms
			  requests.push
			    requestName: term
			$.ajax
			  type: 'POST'
			  url: "api/entitymeta/referenceCodes"
			  dataType: "json"
			  data:
			    displayName: @displayName
			    requests: requests
			  success: @knownDisplayNameReturn
			  error: (err) =>
			    @serviceReturn = null

	knownDisplayNameReturn: (json) =>
		refCodes = ""
		for result in json.results when result.referenceCode != ""
			refCodes += " "+ result.referenceCode
		@searchCodes = refCodes
		if @searchCodes == "" then @searchCodes = "NO RESULTS"
		console.log "search Codes is: "+ @searchCodes
		@fromCodesToExptTree()



	handleEntitySearchReturn: (json) =>
		@counter = @counter + 1
		if json.results.length > 0
			console.log "found a match for term "+ json.results[0].requestText
			for result in json.results
				@searchResults.push
					displayName: result.displayName
					referenceCode: result.referenceCode
		if @counter >= @numTerms
			console.log "All searches returned, going to filter"
			@filterOnDisplayName()


	filterOnDisplayName: ->
		displayNames = _.uniq(_.pluck(@searchResults, "displayName"))
		if displayNames.length <= 1
			@displayName = displayNames[0]
			@searchCodes = _.pluck(@searchResults,"referenceCode").join(" ")
			console.log "all search terms from same type/kind, going to get experiments"
			@fromCodesToExptTree()
		else
			@$('.bv_searchStatusDropDown').modal "hide"
			jsonSearch =
				results: @searchResults
			@entityController = new ChooseEntityTypeController
				el: @$('.bv_chooseEntityView')
				model: new Backbone.Model jsonSearch
			@entityController.on 'entitySelected' , @refCodesToSearchStr

	refCodesToSearchStr: (displayName) =>
		@displayName = displayName
		console.log "chosen entityType is "+ displayName
		@searchCodes = _.pluck(_.where(@searchResults, {displayName: displayName}), "referenceCode").join(" ")
		@fromCodesToExptTree()


	fromCodesToExptTree: ->
		if not @searchCodes?
			@searchCodes = @model.get('searchStr')
		$.ajax
			type: 'POST'
			url: "api/getGeneExperiments"
			dataType: 'json'
			data:
				geneIDs: @searchCodes
			success: @handleGetGeneExperimentsReturn
			error: (err) =>
				@serviceReturn = null

	handleGetGeneExperimentsReturn: (json) =>
		@$('.bv_searchStatusDropDown').modal "hide"
		@trigger 'nextToFilterOnVals'
		if json.results.experimentData.length > 0
			@etc = new ExperimentTreeController
				el: @$('.bv_getExperimentsView')
				model: new Backbone.Model json.results
			@etc.on 'enableNext', =>
				@trigger 'enableNext'
			@etc.on 'disableNext', =>
				@trigger 'disableNext'
			@etc.render()
			@$('.bv_getCodesView').hide()
			@$('.bv_getExperimentsView').show()
			@nextStep = 'fromExptTreeToFilters'
		else
			@$('.bv_noExperimentsFound').show()
			@trigger 'changeNextToNewQuery'
			@nextStep = 'gotoRestart'

	# only availible during tree view - skips filters step
	handleResultsClicked: ->
		@$('.bv_getExperimentsView').hide()
		@trigger 'nextToGotoResults'
		@experimentList = @etc.getSelectedExperiments()
		@fromFiltersToResults()

	fromExptTreeToFilters: ->
		@experimentList = @etc.getSelectedExperiments()
		@$('.bv_searchStatusDropDown').modal
		backdrop: "static"
		@$('.bv_searchStatusDropDown').modal "show"
		$.ajax
			type: 'POST'
			url: "api/getExperimentSearchAttributes"
			dataType: 'json'
			data:
				experimentCodes: @experimentList
			success: @handleGetExperimentSearchAttributesReturn
			error: (err) =>
				@serviceReturn = null

	handleGetExperimentSearchAttributesReturn: (json) =>
		@$('.bv_searchStatusDropDown').modal "hide"
		@trigger 'nextToGotoResults'
		@erfc = new ExperimentResultFilterController
			el: @$('.bv_getFiltersView')
			filterOptions: new Backbone.Collection json.results.experiments
		@erfc.render()
		@erfc.on 'disableNext', =>
			@trigger 'disableNext'
		@erfc.on 'enableNext', =>
			@trigger 'enableNext'
		@$('.bv_getExperimentsView').hide()
		@$('.bv_getFiltersView').show()
		@nextStep = 'fromFiltersToResults'

	getQueryParams: ->
		noFilters =
			booleanFilter: "and"
			advancedFilter: ""
		searchFilters = if @erfc? then @erfc.getSearchFilters() else noFilters

		queryParams =
			batchCodes: @searchCodes
			experimentCodeList: @experimentList
			searchFilters: searchFilters
			aggregate: @model.get('aggregate')

	fromFiltersToResults: ->
		@$('.bv_searchStatusDropDown').modal
			backdrop: "static"
		@$('.bv_searchStatusDropDown').modal "show"
		$.ajax
			type: 'POST'
			url: "api/geneDataQueryAdvanced"
			dataType: 'json'
			data:
				queryParams: @getQueryParams()
				maxRowsToReturn: 10000
				user: window.AppLaunchParams.loginUserName
			success: @handleSearchReturn
			error: (err) =>
				@serviceReturn = null

	handleSearchReturn: (json) =>
		@$('.bv_searchStatusDropDown').modal "hide"
		@resultsJson = json.results
		@resultsJson.data.displayName = @displayName
		if !@dataAdded
			@resultController = new GeneIDQueryResultController
				model: new Backbone.Model json.results
				el: $('.bv_advResultsView')
			@resultController.on 'downLoadCSVRequested', @handleDownLoadCSVRequested
			@resultController.on 'addDataRequested', @handleAddDataRequested
		else
			@searchCodes = json.results.batchCodes.join() # update search parameters so csv gets correct data
			@experimentList = json.results.experimentCodeList
			@resultController.model.clear().set(json.results)
		@resultController.render()
		@$('.bv_getFiltersView').hide()
		@$('.bv_advResultsView').show()
		@nextStep = 'gotoRestart'
		@trigger 'requestShowResultsMode'

	handleDownLoadCSVRequested: =>
		$.ajax
			type: 'POST'
			url: "api/geneDataQueryAdvanced?format=csv"
			dataType: 'json'
			data:
				queryParams: @getQueryParams()
				maxRowsToReturn: 10000
				user: window.AppLaunchParams.loginUserName
			success: @resultController.showCSVFileLink
			error: (err) =>
				@serviceReturn = null

	handleAddDataRequested: =>
		if !@dataAdded
			@dataAdded = true
			@addData = new AddDataToReport
				model: new Backbone.Model @resultsJson
				el: @$('.bv_addDataView')
			@addData.on 'requestResults', @handleSearchReturn
		else
			@addData.model.clear().set(@resultsJson)
			@addData.render()


class window.ChooseEntityTypeController extends Backbone.View
	template: _.template($("#ChooseEntityTypeView").html())
	events:
		"click .bv_continue": "handleContinue"
		"click .bv_entityTypeRadio": "handleSelectionChanged"

	initialize: ->
		$(@el).empty()
		$(@el).append @template()
		entityTypes = _.uniq(_.pluck(@model.get('results'),'displayName'))
		for type in entityTypes
			button = @$('.entityTypeRadio').clone().removeClass('entityTypeRadio')
			button.contents().attr("value",type).html(type)
			button.appendTo('.entityTypes')
		@$('.entityTypeRadio').remove()
		@render()

	render: ->
		@$('.bv_chooseEntityTypeModal').modal
			backdrop: "static"
		@$('.bv_chooseEntityTypeModal').modal "show"

	handleSelectionChanged: ->
		@$('.bv_continue').prop("disabled",false)
		@displayName = @$("input[name='bv_entityType']:checked").val()

	handleContinue: ->
		@trigger 'entitySelected', @displayName


class window.AddDataToReport extends Backbone.View
	template: _.template($("#AddDataView").html())
	events:
		"click .bv_searchClear": "handleSearchClear"
		"click .bv_addDataTree": "handleSelectionChanged"
		"click .bv_displayResults": "handleDisplayResuts"

	initialize: ->
		$(@el).empty()
		$(@el).append @template()
		@render()

	render: ->
		@$('.bv_searchStatusDropDown').modal
			backdrop: "static"
		@$('.bv_searchStatusDropDown').modal "show"
		@getBatchCodes()

	getBatchCodes: ->
		data = @model.get('data')
		allBatchCodes = []
		$(data.aaData).each (key,value) ->
			allBatchCodes.push(value.geneId)
		@allBatchCodes = allBatchCodes
		@gotoShowTree()

	gotoShowTree: ->
		$.ajax
			type: 'POST'
			url: "api/getGeneExperiments"
			dataType: 'json'
			data:
				geneIDs: @allBatchCodes
			success: @handleGetAddDataTreeReturn
			error: (err) =>
				@serviceReturn = null

	handleGetAddDataTreeReturn: (json) =>
		@$('.bv_searchStatusDropDown').modal "hide"
		if !@$('.bv_addDataModal').length #if the template hasn't been added
			$(@el).append @template()
		@$('.bv_addDataModal').modal
			backdrop: "static"
		@$('.bv_addDataModal').modal "show"
		if json.results.experimentData.length > 0
			results = json.results.experimentData
			@setupTree(results)

	setupTree: (results) ->
		@$('.bv_addDataTree').jstree
			core:
				data: results
			search:
				fuzzy: false
			plugins: [ "checkbox", "search" ]

		@$('.bv_addDataTree').bind "hover_node.jstree", (e, data) ->
			$(e.target).attr("title", data.node.original.description)

		to = false
		@$(".bv_searchVal").keyup =>
			clearTimeout to  if to
			to = setTimeout(->
				v = @$(".bv_searchVal").val()
				@$(".bv_tree").jstree(true).search v
				return
			, 250)
			return

		aggregate = @model.get("aggregate")
		if aggregate
			$(".bv_aggregation_true").prop("checked",true)

		expts = @model.get("experimentCodeList")
		@exptLength = expts.length
		@$(".bv_addDataTree").jstree('open_node',expts)
		@$(".bv_addDataTree").jstree('select_node',expts)
		@$(".bv_addDataTree").jstree('disable_node',expts)
		parents =[]
		parents.push(@$(".bv_addDataTree").jstree('get_parent',i)) for i in expts when @$(".bv_addDataTree").jstree('is_leaf',i)
		@$(".bv_addDataTree").jstree('disable_node',parents)

	handleSearchClear: =>
		@$('.bv_searchVal').val("")

	getSelectedExperiments: ->
		@$('.bv_addDataTree').jstree('get_selected')

	handleSelectionChanged: =>
		@selected = @getSelectedExperiments()
		if @selected.length > @exptLength
			@$('.bv_displayResults').prop("disabled",false)
		else
			@$('.bv_displayResults').prop("disabled",true)

	getQueryParams: ->
		queryParams =
			batchCodes: @allBatchCodes.join()
			experimentCodeList: @selected
			searchFilters: @model.get("searchFilters")
			aggregate: @model.get("aggregate")

	handleDisplayResuts: ->
		@$('.bv_searchStatusDropDown').modal
			backdrop: "static"
		@$('.bv_searchStatusDropDown').modal "show"

		$.ajax
			type: 'POST'
			url: "api/geneDataQueryAdvanced"
			dataType: 'json'
			data:
				queryParams: @getQueryParams()
				maxRowsToReturn: 10000
				user: window.AppLaunchParams.loginUserName
			success: @handleAddDataReturn
			error: (err) =>
				@serviceReturn = null

	handleAddDataReturn: (json) =>
		@trigger 'requestResults', json


class window.GeneIDQueryAppController extends Backbone.View
	template: _.template($("#GeneIDQueryAppView").html())
	events:
		"click .bv_next": "handleNextClicked"
		"click .bv_toResults": "handleResultsClicked"
		"click .bv_cancel": "handleCancelClicked"
		"click .bv_gidNavHelpButton": "handleHelpClicked"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		$(@el).addClass 'GeneIDQueryAppController'
		@startBasicQueryWizard()

	startBasicQueryWizard: =>
		@aerqc = new GeneIDQuerySearchController
			el: @$('.bv_basicQueryView')
		@aerqc.render()
		@$('.bv_advancedQueryContainer').hide()
		@$('.bv_advancedQueryNavbar').hide()
		@$('.bv_basicQueryView').show()
		@aerqc.on 'requestAdvancedMode', @startAdvancedQueryWizard

	startAdvancedQueryWizard: (searchStr, aggregate, displayName) =>
		console.log("The search text is: " + searchStr + "\n Aggregate is: " + aggregate + "\n displayName is: "+ displayName)
		searchParams =
			searchStr: searchStr
			aggregate: aggregate
			displayName: displayName
		@$('.bv_next').html "Next"
		@$('.bv_next').removeAttr 'disabled'
		@$('.bv_addData').hide()
		@$('.bv_advancedQueryContainer').addClass 'gidAdvancedQueryContainerPadding'
		@$('.bv_controlButtonContainer').addClass 'gidAdvancedSearchButtons'
		@$('.bv_controlButtonContainer').removeClass 'gidAdvancedSearchButtonsResultsView'
		@$('.bv_controlButtonContainer').removeClass 'gidAdvancedSearchButtonsNewQuery'
		@aerqc = new AdvancedExperimentResultsQueryController
			el: @$('.bv_advancedQueryView')
			model: new Backbone.Model searchParams
		@aerqc.on 'enableNext', =>
			@$('.bv_next').removeAttr 'disabled'
			@$('.bv_toResults').removeAttr 'disabled'
		@aerqc.on 'disableNext', =>
			@$('.bv_next').attr 'disabled', 'disabled'
			@$('.bv_toResults').attr 'disabled', 'disabled'
		@aerqc.on 'nextToFilterOnVals', =>
			@$('.bv_next').html "Filter on Values"
		@aerqc.on 'nextToGotoResults', =>
			@$('.bv_next').html "Go to Results"
			@$('.bv_toResults').hide()
			@$('.gidAdvancedSearchButtons').addClass('gidAdvancedSearchButtonsStepThree')
			@$('.gidAdvancedSearchButtons').removeClass('gidAdvancedSearchButtonsNewQuery')
		@aerqc.on 'requestShowResultsMode', =>
			@$('.bv_next').html "New Query"
			@$('.bv_addData').show()
			@$('.bv_advancedQueryContainer').removeClass 'gidAdvancedQueryContainerPadding'
			@$('.bv_controlButtonContainer').removeClass 'gidAdvancedSearchButtons'
			@$('.bv_controlButtonContainer').addClass 'gidAdvancedSearchButtonsResultsView'
		@aerqc.on 'requestRestartAdvancedQuery', =>
			@$('.bv_toResults').show()
			@$('.gidAdvancedSearchButtonsResultsView').removeClass 'gidAdvancedSearchButtonsStepThree'
			@$('.gidAdvancedSearchButtonsResultsView').addClass 'gidAdvancedSearchButtonsNewQuery'
			@startBasicQueryWizard()
		@aerqc.on 'changeNextToNewQuery', =>
			@$('.bv_next').html "New Query"
			@$('.bv_toResults').hide()
			@$('.bv_controlButtonContainer').removeClass 'gidAdvancedSearchButtons'
			@$('.bv_controlButtonContainer').addClass 'gidAdvancedSearchButtonsNewQuery'
		@aerqc.render()
		@$('.bv_basicQueryView').hide()
		@$('.bv_advancedQueryContainer').show()
		@$('.bv_advancedQueryNavbar').show()

	handleNextClicked: =>
		if @aerqc?
			@aerqc.handleNextClicked()

	handleResultsClicked: =>
		if @aerqc?
			@aerqc.handleResultsClicked()

	handleCancelClicked: =>
		@$('.bv_toResults').show()
		@$('.gidAdvancedSearchButtonsResultsView').removeClass 'gidAdvancedSearchButtonsStepThree'
		@$('.gidAdvancedSearchButtonsResultsView').addClass 'gidAdvancedSearchButtonsNewQuery'
		@startBasicQueryWizard()

	handleHelpClicked: =>
		@$('.bv_helpModal').modal
			backdrop: "static"
		@$('.bv_helpModal').modal "show"
