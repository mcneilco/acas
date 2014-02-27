class window.GeneID extends Backbone.Model
	defaults:
		gid: null

class window.GeneIDList extends Backbone.Collection
	model: GeneID

	addGIDsFromString: (listStr) ->
		unless $.trim(listStr) == ""
			gids = listStr.split ","
			console.log gids.length
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
		console.log "in handleInputFieldChanged"
		console.log e
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


class window.GeneIDQueryAppController extends Backbone.View
	template: _.template($("#GeneIDQueryAppView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@gidqsc = new GeneIDQuerySearchController
			el: @$('.bv_queryView')
		@gidqsc.render()

