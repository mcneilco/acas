class window.Curve extends Backbone.Model

class window.CurveDetail extends Backbone.Model
	initialize: ->
		@fixCompositeClasses()
	fixCompositeClasses: =>
		if @get('fitSettings') not instanceof DoseResponseAnalysisParameters
			@set fitSettings: new DoseResponseAnalysisParameters(@get('fitSettings'))

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
		@url = "/api/curves/stubs/"+exptCode

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
		@$el.html @template()
		if @model?
			@drapc = new DoseResponseAnalysisParametersController
				model: @model.get('fitSettings')
				el: @$('.bv_analysisParameterForm')
			@drapc.render()

			@drpc = new DoseResponsePlotController
				model: new Backbone.Model @model.get('plotData')
				el: @$('.bv_plotWindowWrapper')
			@drpc.render()

			@$('.bv_reportedValues').html @model.get('reportedValues')
			@$('.bv_fitSummary').html @model.get('fitSummary')
			@$('.bv_parameterStdErrors').html @model.get('parameterStdErrors')
			@$('.bv_curveErrors').html @model.get('curveErrors')
			@$('.bv_category').html @model.get('category')
		else
			@$el.html "No curve selected"

	setModel: (model)->
		@model = model
		@render()

class window.DoseResponsePlotController extends AbstractFormController
	template: _.template($("#DoseResponsePlotView").html())
	render: =>
		@$el.empty()
		@$el.html @template()
		if @model?
			@$('.bv_plotWindow').attr('id', "bvID_plotWindow_" + @model.cid)
			@initJSXGraph(@model.get('points'), @model.get('curve'), @model.get('plotWindow'), @$('.bv_plotWindow').attr('id'))
			console.log @model
			@model.on "change", @handlePointsChanged
			@
		else
			@$el.html "Plot data not loaded"

	handlePointsChanged: =>
		console.log @model.get('points')

	initJSXGraph: (points, curve, plotWindow, divID) ->
		if typeof (brd) is "undefined"
				brd =JXG.JSXGraph.initBoard(divID,
					boundingbox: plotWindow
					axis: false #we do this later (log axis reasons)
					showCopyright: false
					zoom : {
						wheel: true
					},
				)
				ii = 0
				while ii < points.response_sv_id.length
					x = JXG.trunc(Math.log(points.dose[ii]), 4)
					y = points.response[ii]
					flag = points.flag[ii]
					if flag != "NA"
						p1 = brd.create("point", [
							x
							y
						],
							name: points.response_sv_id[ii]
							fixed: true
							size: 4
							face: "cross"
							strokecolor: "gray"
							withLabel: false
						)
					else
						p1 = brd.create("point", [
							x
							y
						],
							name: points.response_sv_id[ii]
							fixed: true
							size: 4
							face: "circle"
							strokecolor: "blue"
							withLabel: false

						)
					p1.idx = ii
					p1.model = @model
					p1.knockOutPoint = ->
						unless points.flag[@idx] != "NA"
							@setAttribute
								strokecolor: "gray"
								face: "cross"
							points.flag[@idx] = "user" # set flag to true to flag it?
						else
							@setAttribute
								strokecolor: "blue"
								face: "circle"
							points.flag[@idx] = "NA" # set flag to null to un-flag it?
						@model.set points: points
						#TODO make this a real model that we don't have to trigger a change event on
						@model.trigger 'change'
						return

					p1.xLabel = JXG.trunc(points.dose[ii], 4)
					p1.on "mouseup", p1.knockOutPoint, p1
					brd.highlightInfobox = (x, y, el) ->

						#brd.infobox.setText('<img src="http://www.freesmileys.org/smileys/big/big-smiley-face.gif" alt="Smiley face" width="42" height="42">');
						brd.infobox.setText "(" + el.xLabel + ", " + y + ")"
						return
					ii++
				x = brd.create("line", [
					[
						0
						0
					]
					[
						1
						0
					]
				],
					strokeColor: "#888888"
				)
				y = brd.create("axis", [
					[
						plotWindow[0] * 0.98
						0
					]
					[
						plotWindow[0] * 0.98
						1
					]
				])
				x.isDraggable = false

				# create the tick markers for the axis
				t = brd.create("ticks", [
					x
					1
				],

					# yes, show the labels
					drawLabels: true

				# yes, show the tick marker at zero (or, in this case: 1)
					drawZero: true
					generateLabelValue: (tick) ->

						# get the first defining point of the axis
						p1 = @line.point1

						# this works for the x-axis, for the y-axis you'll have to use usrCoords[2] (usrCoords[0] is the z-coordinate).
						Math.pow 10, tick.usrCoords[1] - p1.coords.usrCoords[1]
				)

				#LL4 <- function(x) drawMin + (drawMax - drawMin)/((1 + exp(-drawHill * (log(x/drawEC50))))^1)
				#brd.create('functiongraph', [function(x){return Math.sin(x);},-Math.PI,2*Math.PI]);
			else
				brd.removeObject window.curve  unless typeof (window.curve) is "undefined"

			if curve?
				Math.logArray = (input_array, base) ->
							output_array = []
							if input_array instanceof Array
								i = 0

								while i < input_array.length
									output_array.push Math.log(input_array[i], base)
									i++
								output_array
							else
								null

				window.curve = brd.create("curve", [
					Math.logArray(curve.dose)
					curve.response
				],
					strokeColor: "black"
					strokeWidth: 2
				)
				getMouseCoords = (e, i) ->
					cPos = brd.getCoordsTopLeftCorner(e, i)
					absPos = JXG.getPosition(e, i)
					dx = absPos[0] - cPos[0]
					dy = absPos[1] - cPos[1]
					new JXG.Coords(JXG.COORDS_BY_SCREEN, [
						dx
						dy
					], brd)

				down = (e) ->
					canCreate = true
					i = undefined
					coords = undefined
					el = undefined

					# index of the finger that is used to extract the coordinates
					i = 0  if e[JXG.touchProperty]
					coords = getMouseCoords(e, i)
					for el of brd.objects
						if JXG.isPoint(brd.objects[el]) and brd.objects[el].hasPoint(coords.scrCoords[1], coords.scrCoords[2])
							canCreate = false
							break
					if canCreate
						A = brd.create "point", [
							coords.usrCoords[1]
							coords.usrCoords[2]
						]

					return

				brd.on "down", down

			return

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
		$.ajax
			type: 'GET'
			url: "/api/curve/detail/" + who.model.get('curveid')
			dataType: 'json'
			success: @handleGetCurveDetailReturn
			error: (err) ->
				console.log 'got ajax error'

	handleGetCurveDetailReturn: (json) =>
		@curveEditorController.setModel new CurveDetail(json)

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

