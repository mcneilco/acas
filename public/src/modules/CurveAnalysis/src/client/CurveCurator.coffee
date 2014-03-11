class window.Curve extends Backbone.Model
	defaults:
		curveid: ""
		algorithmApproved: null
		userApproved: null
		category: ""

class window.CurveList extends Backbone.Collection
	model: Curve

	setExperimentCode: (exptCode) ->
		@.url = "/api/curves/stub/"+exptCode


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

	render: =>
		@$el.empty()
		@$el.html @template()
		console.log @collection
		@collection.each (cs) =>
			csController = new CurveSummaryController(model: cs)
			@$('.bv_curveSummaries').append(csController.render().el)
			csController.on 'selected', @selectionUpdated
			@on 'clearSelected', csController.clearSelected

		@

	selectionUpdated: (who) =>
		@trigger 'clearSelected', who
		@trigger 'selectionUpdated', who


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

	initialize: ->
		@collection = new CurveList()

	render: =>
		@$el.empty()
		@$el.html @template()
		@curveListController = new CurveSummaryListController
			el: @$('.bv_curveList')
			collection: @collection
		@curveListController.render()
		@curveListController.on 'selectionUpdated', @curveSelectionUpdated

		@curveEditorController = new CurveEditorController
			el: @$('.bv_curveEditor')
		@curveEditorController.render()

		@$('.bv_curveSummaries .bv_curveSummary').eq(0).click()

		@

	getCurvesFromExperimentCode: (exptCode) ->
		@collection.setExperimentCode exptCode
		@collection.fetch
			success: =>
				@render()

	curveSelectionUpdated: (who) =>
		@curveEditorController.setModel who.model

