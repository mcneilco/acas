class window.Curve extends Backbone.Model
	defaults:
		curveid: ""
		algorithmApproved: null
		userApproved: null
		category: ""

class window.CurveList extends Backbone.Collection
	model: Curve

	getCategories: ->
		cats = _.unique @.pluck('category')
		catList = new Backbone.Collection()
		_.each cats, (cat) ->
			catList.add
				code: cat
				name: cat
		catList

class window.CurveCurationSet extends Backbone.Model
	defaults:
		sortOptions: new Backbone.Collection()
		curves: new CurveList()
	setExperimentCode: (exptCode) ->
		@url = "/api/curves/stub/"+exptCode

	parse: (resp) =>
		if resp.curves?
			if resp.curves not instanceof CurveList
				resp.curves = new CurveList(resp.curves)
				resp.curves.on 'change', =>
					@trigger 'change'
		if resp.sortOptions?
			if resp.sortOptions not instanceof Backbone.Collection
				resp.sortOptions = new Backbone.Collection(resp.sortOptions)
				resp.sortOptions.on 'change', =>
					@trigger 'change'
		resp

class window.CurveSummaryController extends Backbone.View
	template: _.template($("#CurveSummaryView").html())
	tagName: 'div'
	className: 'bv_curveSummary'

	events:
		'click': 'setSelected'

	render: =>
		@$el.empty()
		if window.AppLaunchParams.testMode
			curveUrl = "/src/modules/curveAnalysis/spec/testFixtures/testThumbs/"
			curveUrl += @model.get('curveid')+".png"
		else
			curveUrl = window.conf.service.rapache.fullpath+"/curve/render/?legend=false&curveIds="
			curveUrl += @model.get('curveid')+"&height=200&width=250&axes=false"
		@$el.html @template
			curveUrl: curveUrl
		if @model.get('algorithmApproved')
			@$('.bv_thumbnail').addClass 'algorithmApproved'
			@$('.bv_thumbnail').removeClass 'algorithmNotApproved'
		else
			@$('.bv_thumbnail').removeClass 'algorithmApproved'
			@$('.bv_thumbnail').addClass 'algorithmNotApproved'
		if @model.get('userApproved')
			@$('.bv_thumbsUp').show()
			@$('.bv_thumbsDown').hide()
		else
			@$('.bv_thumbsUp').hide()
			if @model.get('userApproved') == null
				@$('.bv_thumbsDown').hide()
			else
				@$('.bv_thumbsDown').show()
		@$('.bv_compoundCode').html @model.get('curveAttributes').compoundCode
		@

	setSelected: =>
		@$el.addClass 'selected'
		@trigger 'selected', @

	clearSelected: (who) =>
		if who?
			if who.model.cid == @.model.cid
				return
		@$el.removeClass 'selected'


class window.CurveSummaryListController extends Backbone.View
	template: _.template($("#CurveSummaryListView").html())

	initialize: ->
		@filterKey = 'all'
		@sortKey = 'none'
		@sortAscending = true

	render: =>
		@$el.empty()
		@$el.html @template()

		if @filterKey != 'all'
			toRender = new Backbone.Collection @collection.filter (cs) =>
				cs.get('category') == @filterKey
		else
			toRender = @collection

		unless @sortKey == 'none'
			toRender = toRender.sortBy (curve) =>
				attributes = curve.get('curveAttributes')
				attributes[@sortKey]
			unless @sortAscending
				toRender = toRender.reverse()
			toRender = new Backbone.Collection toRender

		toRender.each (cs) =>
			csController = new CurveSummaryController(model: cs)
			@$('.bv_curveSummaries').append(csController.render().el)
			csController.on 'selected', @selectionUpdated
			@on 'clearSelected', csController.clearSelected

		@

	selectionUpdated: (who) =>
		@trigger 'clearSelected', who
		@trigger 'selectionUpdated', who

	filter: (key) ->
		@filterKey = key
		@render()

	sort: (key, ascending) ->
		@sortKey = key
		@sortAscending = ascending
		@render()



class window.CurveEditorController extends Backbone.View
	template: _.template($("#CurveEditorView").html())

	render: =>
		@$el.empty()
		if @model?
			if @model.get('curveid') != ""
				curveUrl = window.conf.service.rshiny.fullpath+"/fit/?curveIds="
				curveUrl += @model.get('curveid')

		@$el.html @template
			curveUrl: curveUrl
		@
		@$('.bv_loading').show()
		@$('.bv_shinyContainer').load =>
			@$('.bv_loading').hide()


	setModel: (model)->
		@model = model
		@render()

	shinyLoaded: =>


class window.CurveCuratorController extends Backbone.View
	template: _.template($("#CurveCuratorView").html())
	events:
		'change .bv_filterBy': 'handleFilterChanged'
		'change .bv_sortBy': 'handleSortChanged'
		'click .bv_sortDirection_ascending': 'handleSortChanged'
		'click .bv_sortDirection_descending': 'handleSortChanged'

	render: =>
		@$el.empty()
		@$el.html @template()
		if @model?
			@curveListController = new CurveSummaryListController
				el: @$('.bv_curveList')
				collection: @model.get 'curves'
			@curveListController.render()
			@curveListController.on 'selectionUpdated', @curveSelectionUpdated

			@curveEditorController = new CurveEditorController
				el: @$('.bv_curveEditor')

			if @model.get('sortOptions').length > 0
				@sortBySelect = new PickListSelectController
					collection: @model.get 'sortOptions'
					el: @$('.bv_sortBy')
					selectedCode: (@model.get 'sortOptions')[0]
					autoFetch: false
			else
				@sortBySelect = new PickListSelectController
					collection: @model.get 'sortOptions'
					el: @$('.bv_sortBy')
					insertFirstOption: new PickList
						code: "none"
						name: "No Sort"
					selectedCode: "none"
					autoFetch: false
			@sortBySelect.render()

			@filterBySelect = new PickListSelectController
				collection: @model.get('curves').getCategories()
				el: @$('.bv_filterBy')
				insertFirstOption: new PickList
					code: "all"
					name: "Show All"
				selectedCode: "all"
				autoFetch: false
			@filterBySelect.render()

			if(@curveListController.sortAscending)
				@$('.bv_sortDirection_ascending').attr( "checked", true );
			else
				@$('.bv_sortDirection_descending').attr( "checked", true );

			@handleSortChanged()
			@$('.bv_curveSummaries .bv_curveSummary').eq(0).click()

		@

	getCurvesFromExperimentCode: (exptCode) ->
		@model = new CurveCurationSet
		@model.setExperimentCode exptCode
		@model.fetch
			success: =>
				@render()

	curveSelectionUpdated: (who) =>
		@curveEditorController.setModel who.model

	handleFilterChanged: =>
		@curveListController.filter @$('.bv_filterBy').val()

	handleSortChanged: =>
		sortBy = @$('.bv_sortBy').val()
		if(sortBy == "none")
			@$("input[name='bv_sortDirection']").prop('disabled', true);
		else
			@$("input[name='bv_sortDirection']").prop('disabled', false);
		sortDirection = if @$("input[name='bv_sortDirection']:checked").val() == "descending" then false else true
		@curveListController.sort sortBy, sortDirection

