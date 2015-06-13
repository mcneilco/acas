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
		@$('.bv_searchNavbar').hide()

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
	events:
		"click .bv_downloadCSV": "handleDownloadCSVClicked"

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
				scrollX: true

				aoColumnDefs: [
					{sType: "lsThing", aTargets: ["_all"]},
					{sWidth: "400px", aTargets:["curveId"]}
				]

#	uncomment the following line to disable sorting in the dataTable
#				bSort: false
		else
			@$('.bv_resultTable').hide()
			@$('.bv_noResultsFound').show()
			@$('.bv_gidDownloadCSV').hide()

		@

	setupHeaders: ->
		_.each @model.get('data').groupHeaders, (header) =>
			@$('.bv_experimentNamesHeader').append '<th colspan="'+header.numberOfColumns+'">'+header.titleText+'</th>'
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


class window.GeneIDQuerySearchController extends Backbone.View
	template: _.template($("#GeneIDQuerySearchView").html())
	lastSearch: ""

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
		@lastSearch = searchStr
		@$('.bv_searchStatusDropDown').modal
		backdrop: "static"
		@$('.bv_searchStatusDropDown').modal "show"
		$.ajax
			type: 'POST'
			url: "api/geneDataQuery"
			data:
				geneIDs: searchStr
				maxRowsToReturn: 10000
				user: window.AppLaunchParams.loginUserName
			success: @handleSearchReturn
			error: (err) =>
				@serviceReturn = null
			dataType: 'json'

	handleSearchReturn: (json) =>
		@$('.bv_searchStatusDropDown').modal "hide"
		@resultController = new GeneIDQueryResultController
			model: new Backbone.Model json.results
			el: $('.bv_resultsView')
		@resultController.render()
		@resultController.on 'downLoadCSVRequested', @handleDownLoadCSVRequested
		$('.bv_searchForm')
			.appendTo('.bv_searchNavbar')
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
			url: "api/geneDataQuery?format=csv"
			dataType: 'json'
			data:
				geneIDs: @lastSearch
				maxRowsToReturn: 10000
				user: window.AppLaunchParams.loginUserName
			success: @resultController.showCSVFileLink
			error: (err) =>
				@serviceReturn = null



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
		@$('.bv_searchStatusDropDown').modal
			backdrop: "static"
		@$('.bv_searchStatusDropDown').modal "show"
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
		queryParams =
			batchCodes: @searchCodes
			experimentCodeList: @experimentList
			searchFilters: @erfc.getSearchFilters()

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
		@resultController = new GeneIDQueryResultController
			model: new Backbone.Model json.results
			el: $('.bv_advResultsView')
		@resultController.on 'downLoadCSVRequested', @handleDownLoadCSVRequested
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


class window.GeneIDQueryAppController extends Backbone.View
	template: _.template($("#GeneIDQueryAppView").html())
	events:
		"click .bv_next": "handleNextClicked"
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
		@aerqc.on 'requestAdvancedMode', =>
			@startAdvanceedQueryWizard()

	startAdvanceedQueryWizard: =>
		@$('.bv_next').html "Next"
		@$('.bv_next').removeAttr 'disabled'
		@$('.bv_advancedQueryContainer').addClass 'gidAdvancedQueryContainerPadding'
		@$('.bv_controlButtonContainer').addClass 'gidAdvancedSearchButtons'
		@$('.bv_controlButtonContainer').removeClass 'gidAdvancedSearchButtonsResultsView'
		@$('.bv_controlButtonContainer').removeClass 'gidAdvancedSearchButtonsNewQuery'
		@aerqc = new AdvancedExperimentResultsQueryController
			el: @$('.bv_advancedQueryView')
		@aerqc.on 'enableNext', =>
			@$('.bv_next').removeAttr 'disabled'
		@aerqc.on 'disableNext', =>
			@$('.bv_next').attr 'disabled', 'disabled'
		@aerqc.on 'requestShowResultsMode', =>
			@$('.bv_next').html "New Query"
			@$('.bv_advancedQueryContainer').removeClass 'gidAdvancedQueryContainerPadding'
			@$('.bv_controlButtonContainer').removeClass 'gidAdvancedSearchButtons'
			@$('.bv_controlButtonContainer').addClass 'gidAdvancedSearchButtonsResultsView'
		@aerqc.on 'requestRestartAdvancedQuery', =>
			@startAdvanceedQueryWizard()
		@aerqc.on 'changeNextToNewQuery', =>
			@$('.bv_next').html "New Query"
			@$('.bv_controlButtonContainer').removeClass 'gidAdvancedSearchButtons'
			@$('.bv_controlButtonContainer').addClass 'gidAdvancedSearchButtonsNewQuery'
		@aerqc.render()
		@$('.bv_basicQueryView').hide()
		@$('.bv_advancedQueryContainer').show()
		@$('.bv_advancedQueryNavbar').show()

	handleNextClicked: =>
		if @aerqc?
			@aerqc.handleNextClicked()

	handleCancelClicked: =>
		@startBasicQueryWizard()

	handleHelpClicked: =>
		@$('.bv_helpModal').modal
			backdrop: "static"
		@$('.bv_helpModal').modal "show"

