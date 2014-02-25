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
		"keypress .bv_gidListString": "handleInputFieldChanged"
#		"keypress .bv_gidListString": "handleKeyInInputField"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_search').attr('disabled','disabled')

		@

	updateGIDsFromField: ->
		@collection.reset()
		@collection.addGIDsFromString @$('.bv_gidListString').val()

	handleInputFieldChanged: =>
		@updateGIDsFromField()
		if @collection.length == 0
			@$('.bv_search').attr('disabled','disabled')
		else
			@$('.bv_search').removeAttr('disabled')

#	handleKeyInInputField: (e) =>
#		console.log "got a key press"
#		if e.keyCode == 13
#			console.log "got enter press"
#			@handleSearchClicked()

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
		console.log json
		@resultController = new GeneIDQueryResultController
			model: new Backbone.Model json.results
			el: $('.bv_resultsView')
		@resultController.render()

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

