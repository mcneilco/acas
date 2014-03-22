class window.GeneID extends Backbone.Model
	defaults:
		gid: null

class window.GeneIDList extends Backbone.Collection
	model: GeneID

	addGIDsFromString: (listStr) ->
		unless $.trim(listStr) == ""
			gids = listStr.split ","
			for gid in gids
				@add new GeneID gid: $.trim(gid)

class window.GeneIDQueryInputController extends Backbone.View
	template: _.template($("#GeneIDQueryInputView").html())

	events:
		"click .bv_search": "handleSearchClicked"
		"change .bv_gidListString": "handleInputFieldChanged"
		"keydown .bv_gidListString": "handleKeyInInputField"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_search').attr('disabled','disabled')
		@$('.bv_gidACASBadgeTop').hide()


		@

	updateGIDsFromField: ->
		@collection.reset()
		@collection.addGIDsFromString @$('.bv_gidListString').val()

	handleInputFieldChanged: (e) =>
		@updateGIDsFromField()
		if @collection.length == 0
			@$('.bv_search').attr('disabled','disabled')
		else
			@$('.bv_search').removeAttr('disabled')

	handleKeyInInputField: (e) =>
		if e.keyCode == 13
			@handleSearchClicked()

	handleSearchClicked: =>
		@updateGIDsFromField()
		@trigger 'search-requested'



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
				collection: new GeneIDList()
				el: @$('.bv_inputView')
		@queryInputController.on 'search-requested', @handleSearchRequested
		@queryInputController.render()
		@setQueryOnlyMode()

	render: =>

		@

	handleSearchRequested: =>
		$.ajax
			type: 'POST'
			url: "api/geneDataQuery"
			data:
				geneIDs: @queryInputController.collection.toJSON()
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

	render: =>
		$(@el).empty()
		$(@el).html @template()
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
		@model.on "destroy", @remove, @

	render: =>
		$(@el).empty()
		$(@el).html @template()
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

	initialize: ->
		@filterOptions = @options.filterOptions

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
		@$('.bv_filterTerms').append erftc.render().el
		@on "updateFilterModels", erftc.updateModel

	updateCollection: ->
		@trigger "updateFilterModels"

class window.AdvancedExperimentResultsQueryController extends Backbone.View
	template: _.template($("#AdvancedExperimentResultsQueryView").html())
	events:
		"click .bv_next": "handleNextClicked"

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@gotoStepGetCodes()

	handleNextClicked: =>
		switch @nextStep
			when 'fromCodesToExptTree'
				@fromCodesToExptTree()

	gotoStepGetCodes: ->
		@nextStep = 'fromCodesToExptTree'
		@$('.bv_getCodesView').show()
		@$('.bv_getExperimentsView').hide()
		@$('.bv_getFiltersView').hide()
		@$('.bv_showResultsView').hide()

	fromCodesToExptTree: ->
		@searchCodes = $.trim @$('.bv_codesField').val()
		$.ajax
			type: 'POST'
			url: "api/getGeneExperiments"
			dataType: 'json'
			data:
				geneIDs: @searchCodes
			success: => @handleGetGeneExperimentsReturn
			error: (err) =>
				console.log 'got ajax error trying to get experiment tree'
				@serviceReturn = null

	handleGetGeneExperimentsReturn: (json) =>
		@etc = new ExperimentTreeController
			el: @$('.bv_getExperimentsView')
			model: new Backbone.Model json.results
		@etc.render()
		@$('.bv_getCodesView').hide()
		@$('.bv_getExperimentsView').show()
		@nextStep = 'fromExptTreeToFilters'


class window.GeneIDQueryAppController extends Backbone.View
	template: _.template($("#GeneIDQueryAppView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@gidqsc = new GeneIDQuerySearchController
			el: @$('.bv_queryView')
		@gidqsc.render()

#	#This is dev scaffolding for the experiment tree. Real code for basic query is above commented out
#	initialize: ->
#		$(@el).empty()
#		$(@el).html @template()
#		$.ajax
#			type: 'POST'
#			url: "api/getGeneExperiments"
#			dataType: 'json'
#			data:
#				geneIDs: "1234, 2345, 4444"
#			success: @handleGetGeneExperimentsReturn
#			error: (err) =>
#				console.log 'got ajax error'
#				@serviceReturn = null

	#This is dev scaffolding for the experiment tree. Real code for basic query is above commented out
#	initialize: ->
#		$(@el).empty()
#		$(@el).html @template()
#		$.ajax
#			type: 'POST'
#			url: "api/getExperimentSearchAttributes"
#			dataType: 'json'
#			data:
#				experimentCodes: ["EXPT-00000398", "EXPT-00000396", "EXPT-00000398"]
#			success: @handleGetExperimentSearchAttributesReturn
#			error: (err) =>
#				console.log 'got ajax error'
#				@serviceReturn = null

	handleGetGeneExperimentsReturn: (json) =>
		@etc = new ExperimentTreeController
			el: @$('.bv_exptTreeView')
			model: new Backbone.Model json.results
		@etc.render()

	handleGetExperimentSearchAttributesReturn: (json) =>
		@etc = new ExperimentResultFilterTermListController
			el: @$('.bv_attributeFilterView')
			collection: new Backbone.Collection()
			filterOptions: new Backbone.Collection json.results.experiments
		@etc.render()


