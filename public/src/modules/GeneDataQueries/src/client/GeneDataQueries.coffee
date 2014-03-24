class window.GeneIDQueryInputController extends Backbone.View
	template: _.template($("#GeneIDQueryInputView").html())

	events:
		"click .bv_search": "handleSearchClicked"
		"click .bv_gidNavAdvancedSearchButton": "handleAdvanceModeRequested"
		"keyup .bv_gidListString": "handleInputFieldChanged"
		"keydown .bv_gidListString": "handleKeyInInputField"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_search').attr('disabled','disabled')
		@$('.bv_gidACASBadgeTop').hide()

		@

	handleInputFieldChanged: =>
		if $.trim(@$('.bv_gidListString').val()).length > 1
			@$('.bv_search').removeAttr('disabled')
		else
			@$('.bv_search').attr('disabled','disabled')

	handleKeyInInputField: (e) =>
		if e.keyCode == 13
			@handleSearchClicked()

	handleSearchClicked: =>
		@trigger 'search-requested', $.trim(@$('.bv_gidListString').val())

	handleAdvanceModeRequested: =>
		@trigger 'requestAdvancedMode'

class window.GeneIDQueryResultController extends Backbone.View
	template: _.template($("#GeneIDQueryResultView").html())

	render: =>
		$(@el).empty()
		$(@el).html @template()
		if @model.get('data').iTotalRecords > 0
			@$('.bv_noResultsFound').hide()
			@setupHeaders()
			@$('.bv_resultTable').dataTable
				aaData: @model.get('data').aaData
				aoColumns: @model.get('data').aoColumns
				bDeferRender: true
				bProcessing: true
		else
			@$('.bv_resultTable').hide()
			@$('.bv_noResultsFound').show()

		@

	setupHeaders: ->
		_.each @model.get('data').groupHeaders, (header) =>
			@$('.bv_experimentNamesHeader').append '<th colspan="'+header.numberOfColumns+'">'+header.titleText+'</th>'
		_.each @model.get('data').aoColumns, (header) =>
			@$('.bv_columnNamesHeader').append '<th>placeholder</th>'

class window.GeneIDQuerySearchController extends Backbone.View
	template: _.template($("#GeneIDQuerySearchView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@queryInputController = new GeneIDQueryInputController
				el: @$('.bv_inputView')
		@queryInputController.on 'search-requested', @handleSearchRequested
		@queryInputController.on 'requestAdvancedMode', =>
			@trigger 'requestAdvancedMode'
		@queryInputController.render()
		@setQueryOnlyMode()

	handleSearchRequested: (searchStr) =>
		$.ajax
			type: 'POST'
			url: "api/geneDataQuery"
			data:
				geneIDs: searchStr
				maxRowsToReturn: 10000
				user: window.AppLaunchParams.loginUserName
			success: @handleSearchReturn
			error: (err) =>
				console.log 'got ajax error'
				@serviceReturn = null
			dataType: 'json'

	handleSearchReturn: (json) =>
		@resultController = new GeneIDQueryResultController
			model: new Backbone.Model json.results
			el: $('.bv_resultsView')
		@resultController.render()
		$('.bv_searchForm')
			.appendTo('.bv_toolbar')
		@$('.bv_gidSearchStart').hide()
		@$('.bv_gidACASBadge').hide()
		@$('.bv_gidACASBadgeTop').show()
		@$('.bv_gidNavAdvancedSearchButton').removeClass 'gidNavAdvancedSearchButtonBottom'
		@$('.bv_gidNavHelpButton').addClass 'pull-right'
		@$('.bv_gidNavAdvancedSearchButton').addClass 'gidNavAdvancedSearchButtonTop'
		@$('.bv_toolbar').removeClass 'gidNavWellBottom'
		@$('.bv_toolbar').addClass 'gidNavWellTop'
		@$('.bv_group_toolbar').removeClass 'navbar-fixed-bottom'
		@$('.bv_group_toolbar').addClass 'navbar-fixed-top'

		@setShowResultsMode()

	setQueryOnlyMode: =>
		@$('.bv_resultsView').hide()

	setShowResultsMode: =>
		@$('.bv_resultsView').show()


################  Advanced-mode queries ################

class window.ExperimentTreeController extends Backbone.View
	template: _.template($("#ExperimentTreeView").html())
	events:
		"click .bv_searchClear": "handleSearchClear"
		"click .bv_tree": "handleSelectionChanged"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@trigger 'disableNext'
		@setupTree()
		
		@
	
	setupTree: ->
		@$('.bv_tree').jstree
			core:
				data: @model.get('experimentData')
			plugins: [ "checkbox","search"]

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

class window.ExperimentResultFilterTermController extends Backbone.View
	template: _.template($("#ExperimentResultFilterTermView").html())
	tagName: "div"
	className: "form-inline"
	events:
		"change .bv_experiment": "setKindOptions"
		"change .bv_kind": "setOperatorOptions"
		"click .bv_delete": "clear"

	initialize: ->
		@filterOptions = @options.filterOptions
		@model.set termName: @options.termName
		@model.on "destroy", @remove, @

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_termName').html @model.get('termName')
		@filterOptions.each (expt) =>
			code = expt.get('experimentCode')
			@$('.bv_experiment').append '<option val="'+code+'">'+code+'</option>'
		@setKindOptions()
		@setOperatorOptions()

		@

	setKindOptions: =>
		currentExpt = @getSelectedExperiment()
		kinds = _.pluck currentExpt.get('valueKinds'), 'lsKind'
		@$('.bv_kind').empty()
		for kind in kinds
			@$('.bv_kind').append '<option val="'+kind+'">'+kind+'</option>'

	setOperatorOptions: =>
		switch @getSelectedValueType()
			when "numericValue"
				@$('.bv_operator_number').addClass('bv_operator').show()
				@$('.bv_operator_bool').removeClass('bv_operator').hide()
				@$('.bv_operator_string').removeClass('bv_operator').hide()
				@$('.bv_filterValue').show()
			when "booleanValue"
				@$('.bv_operator_number').removeClass('bv_operator').hide()
				@$('.bv_operator_bool').addClass('bv_operator').show()
				@$('.bv_operator_string').removeClass('bv_operator').hide()
				@$('.bv_filterValue').hide()
			when "stringValue"
				@$('.bv_operator_number').removeClass('bv_operator').hide()
				@$('.bv_operator_bool').removeClass('bv_operator').hide()
				@$('.bv_operator_string').addClass('bv_operator').show()
				@$('.bv_filterValue').show()

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
		@addOne()

		@

	addOne: =>
		newModel = new Backbone.Model()
		@collection.add newModel
		erftc = new ExperimentResultFilterTermController
			model: newModel
			filterOptions: @filterOptions
			termName: @TERM_NUMBER_PREFIX+@nextTermNumber++
		@$('.bv_filterTerms').append erftc.render().el
		@on "updateFilterModels", erftc.updateModel

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
			collection: new Backbone.Collection()
			filterOptions: @filterOptions
		@erftlc.render()
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
		@gotoStepGetCodes()

	handleNextClicked: =>
		switch @nextStep
			when 'fromCodesToExptTree'
				@fromCodesToExptTree()
			when 'fromExptTreeToFilters'
				@fromExptTreeToFilters()
			when 'fromFiltersToResults'
				@fromFiltersToResults()
			when 'gotoRestart'
				@trigger 'requestRestartAdvancedQuery'

	gotoStepGetCodes: ->
		@nextStep = 'fromCodesToExptTree'
		@$('.bv_getCodesView').show()
		@$('.bv_getExperimentsView').hide()
		@$('.bv_getFiltersView').hide()
		@$('.bv_advResultsView').hide()
		@$('.bv_cancel').html 'Cancel'
		@$('.bv_noExperimentsFound').hide()

	fromCodesToExptTree: ->
		@searchCodes = $.trim @$('.bv_codesField').val()
		$.ajax
			type: 'POST'
			url: "api/getGeneExperiments"
			dataType: 'json'
			data:
				geneIDs: @searchCodes
			success: @handleGetGeneExperimentsReturn
			error: (err) =>
				console.log 'got ajax error trying to get experiment tree'
				@serviceReturn = null

	handleGetGeneExperimentsReturn: (json) =>
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

	fromExptTreeToFilters: ->
		@experimentList = @etc.getSelectedExperiments()
		$.ajax
			type: 'POST'
			url: "api/getExperimentSearchAttributes"
			dataType: 'json'
			data:
				experimentCodes: @experimentList
			success: @handleGetExperimentSearchAttributesReturn
			error: (err) =>
				console.log 'got ajax error'
				@serviceReturn = null

	handleGetExperimentSearchAttributesReturn: (json) =>
		@erfc = new ExperimentResultFilterController
			el: @$('.bv_getFiltersView')
			filterOptions: new Backbone.Collection json.results.experiments
		@erfc.render()
		@$('.bv_getExperimentsView').hide()
		@$('.bv_getFiltersView').show()
		@nextStep = 'fromFiltersToResults'

	fromFiltersToResults: ->
		queryParams =
			batchCodes: @searchCodes
			experimentCodeList: @experimentList
			searchFilters: @erfc.getSearchFilters()
		$.ajax
			type: 'POST'
			url: "api/geneDataQueryAdvanced"
			dataType: 'json'
			data:
				queryParams: queryParams
				maxRowsToReturn: 10000
				user: window.AppLaunchParams.loginUserName
			success: @handleSearchReturn
			error: (err) =>
				console.log 'got ajax error'
				@serviceReturn = null

	handleSearchReturn: (json) =>
		@resultController = new GeneIDQueryResultController
			model: new Backbone.Model json.results
			el: $('.bv_advResultsView')
		@resultController.render()
		@$('.bv_getFiltersView').hide()
		@$('.bv_advResultsView').show()
		@nextStep = 'gotoRestart'
		@trigger 'requestNextChangeToNewQuery'

class window.GeneIDQueryAppController extends Backbone.View
	template: _.template($("#GeneIDQueryAppView").html())
	events:
		"click .bv_next": "handleNextClicked"
		"click .bv_cancel": "handleCancelClicked"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@startBasicQueryWizard()

	startBasicQueryWizard: =>
		@aerqc = new GeneIDQuerySearchController
			el: @$('.bv_basicQueryView')
		@aerqc.render()
		@$('.bv_advancedQueryContainer').hide()
		@$('.bv_basicQueryView').show()
		@aerqc.on 'requestAdvancedMode', =>
			@startAdvanceedQueryWizard()

	startAdvanceedQueryWizard: =>
		@$('.bv_next').html "Next"
		@$('.bv_next').removeAttr 'disabled'
		@aerqc = new AdvancedExperimentResultsQueryController
			el: @$('.bv_advancedQueryView')
		@aerqc.on 'enableNext', =>
			@$('.bv_next').removeAttr 'disabled'
		@aerqc.on 'disableNext', =>
			@$('.bv_next').attr 'disabled', 'disabled'
		@aerqc.on 'requestNextChangeToNewQuery', =>
			@$('.bv_next').html "New Query"
		@aerqc.on 'requestRestartAdvancedQuery', =>
			@startAdvanceedQueryWizard()
		@aerqc.render()
		@$('.bv_basicQueryView').hide()
		@$('.bv_advancedQueryContainer').show()

	handleNextClicked: =>
		if @aerqc?
			@aerqc.handleNextClicked()

	handleCancelClicked: =>
		@startBasicQueryWizard()

