class window.DoseResponseKnockoutPanelController extends Backbone.View
	template: _.template($("#DoseResponseKnockoutPanelView").html())

	render: =>
		@$el.empty()
		@$el.html @template()
		@setupKnockoutPicklist()
		@$('.bv_doseResponseKnockoutPanel').on "show", =>
			@$('.bv_dataDictPicklist').focus()
		@$('.bv_doseResponseKnockoutPanel').on "keypress", (key)=>
			if key.keyCode == 13
				@$('.bv_doseResponseKnockoutPanelOKBtn').click()
		@$('.bv_doseResponseKnockoutPanel').on "hidden", =>
			@handleDoseResponseKnockoutPanelHidden()
		@

	show: =>
		@$('.bv_doseResponseKnockoutPanel').modal
			backdrop: "static"
		@$('.bv_doseResponseKnockoutPanel').modal "show"

	setupKnockoutPicklist: =>
		@knockoutObservationList = new PickListList()
		@knockoutObservationList.url = "/api/codetables/user well flags/flag observation"
		@knockoutObservationListController = new PickListSelectController
			el: @$('.bv_dataDictPicklist')
			collection: @knockoutObservationList

	handleDoseResponseKnockoutPanelHidden: =>
		status = "knocked out"
		observation = @knockoutObservationListController.getSelectedCode()
		cause = "curvefit ko"
		comment = @knockoutObservationListController.getSelectedModel().get 'name'
		@trigger 'observationSelected', status, observation, cause, comment

class window.DoseResponsePlotController extends AbstractFormController
	template: _.template($("#DoseResponsePlotView").html())
	initialize: ->
		@pointList = []

	render: =>
		@$el.empty()
		@$el.html @template()
		if @model?
			curvefitClassesCollection = new Backbone.Collection $.parseJSON window.conf.curvefit.modelfitparameter.classes
			curveFitClasses =  curvefitClassesCollection.findWhere({code: @model.get('curve').type})
			plotCurveClass =  window[curveFitClasses.get 'plotCurveClass']

			@$('.bv_plotWindow').attr('id', "bvID_plotWindow_" + @model.cid)
			@doseResponseKnockoutPanelController= new DoseResponseKnockoutPanelController
				el: @$('.bv_doseResponseKnockoutPanel')
			@doseResponseKnockoutPanelController.render()
			@initJSXGraph(@model.get('points'), @model.get('curve'), @model.get('plotWindow'), @$('.bv_plotWindow').attr('id'), plotCurveClass)
			@
		else
			@$el.html "Plot data not loaded"

	showDoseResponseKnockoutPanel: (selectedPoints) =>
		@doseResponseKnockoutPanelController.show()
		@doseResponseKnockoutPanelController.on 'observationSelected', (status, observation, cause, comment) =>
			@knockoutPoints(selectedPoints, status, observation, cause, comment)
		return

	knockoutPoints: (selectedPoints, status, observation, cause, comment) =>
		selectedPoints.forEach (selectedPoint) =>
			@points[selectedPoint.idx].algorithmFlagStatus = ""
			@points[selectedPoint.idx].algorithmFlagObservation = ""
			@points[selectedPoint.idx].algorithmFlagCause = ""
			@points[selectedPoint.idx].algorithmFlagComment = ""
			@points[selectedPoint.idx].preprocessFlagStatus = ""
			@points[selectedPoint.idx].preprocessFlagObservation = ""
			@points[selectedPoint.idx].preprocessFlagCause = ""
			@points[selectedPoint.idx].preprocessFlagComment = ""
			@points[selectedPoint.idx].userFlagStatus = status
			@points[selectedPoint.idx].userFlagObservation = observation
			@points[selectedPoint.idx].userFlagCause = cause
			@points[selectedPoint.idx].userFlagComment = comment

			selectedPoint.drawAsKnockedOut()
		@model.set points: @points
		@model.trigger 'change'
		return

	log10: (val) ->
		Math.log(val) / Math.LN10

	initJSXGraph: (points, curve, plotWindow, divID, plotCurveClass) =>
		@points = points
		log10 = @log10
		logDose = true
		if curve.type in ["Michaelis-Menten", "Substrate Inhibition"]
			logDose = false

		if typeof (brd) is "undefined"
			brd = JXG.JSXGraph.initBoard(divID,
				boundingbox: plotWindow
				axis: !logDose #we do this later (log axis causes)
				showCopyright: false
				zoom : {
					wheel: false
				},
			)

			promptForKnockout = (selectedPoints) =>
				@showDoseResponseKnockoutPanel selectedPoints

			includePoints = (selectedPoints) =>
				selectedPoints.forEach (selectedPoint) =>
					@points[selectedPoint.idx].algorithmFlagStatus = ""
					@points[selectedPoint.idx].algorithmFlagObservation = ""
					@points[selectedPoint.idx].algorithmFlagCause = ""
					@points[selectedPoint.idx].algorithmFlagComment = ""
					@points[selectedPoint.idx].preprocessFlagStatus = ""
					@points[selectedPoint.idx].preprocessFlagObservation = ""
					@points[selectedPoint.idx].preprocessFlagCause = ""
					@points[selectedPoint.idx].preprocessFlagComment = ""
					@points[selectedPoint.idx].userFlagStatus = ""
					@points[selectedPoint.idx].userFlagObservation = ""
					@points[selectedPoint.idx].userFlagCause = ""
					@points[selectedPoint.idx].userFlagComment = ""

					selectedPoint.drawAsIncluded()
				@model.set points: @points
				@model.trigger 'change'
				return

			ii = 0
			while ii < points.length
				x = if logDose then log10(points[ii].dose) else points[ii].dose
				y = points[ii].response
				userFlagStatus = points[ii].userFlagStatus
				preprocessFlagStatus = points[ii].preprocessFlagStatus
				algorithmFlagStatus = points[ii].algorithmFlagStatus
				userFlagComment = points[ii].userFlagObservation
				preprocessFlagComment = points[ii].preprocessFlagComment
				algorithmFlagComment = points[ii].algorithmFlagObservation
				userFlagCause = points[ii].userFlagCause
				algorithmFlagCause = points[ii].algorithmFlagCause
				preprocessFlagCause = points[ii].preprocessFlagCause
				if (userFlagStatus == "knocked out" || preprocessFlagStatus == "knocked out" || algorithmFlagStatus == "knocked out")
					color = switch
						when userFlagCause == "curvefit ko" then 'orange'
						when userFlagStatus == "knocked out" then 'red'
						when preprocessFlagStatus == "knocked out" then 'gray'
						when algorithmFlagStatus == "knocked out" then 'blue'

					p1 = brd.create("point", [x,y],
						name: points[ii].response_sv_id
						fixed: true
						size: 4
						face: "cross"
						strokecolor: color
						withLabel: false
					)
					p1.knockedOut = true

				else
					if userFlagStatus == 'hit' or algorithmFlagStatus == 'hit' or preprocessFlagStatus == 'hit'
						color = 'blue'
					else
						color = 'red'
					p1 = brd.create("point", [x,y],
						name: points[ii].response_sv_id
						fixed: true
						size: 4
						face: "circle"
						strokecolor: 'blue'
						withLabel: false
						fillcolor: color
					)
					p1.knockedOut = false

				p1.idx = ii
				p1.isDoseResponsePoint = true
				p1.isSelected = false
				p1.drawAsKnockedOut = ->
					@setAttribute
						strokecolor: "red"
						face: "cross"
						knockedOut: true
				p1.drawAsIncluded = ->
					@setAttribute
						strokecolor: "blue"
						face: "circle"
						knockedOut: false
				p1.handlePointClicked = ->
					if (!@knockedOut)
						promptForKnockout([@])
					else
						includePoints([@])
					return

				p1.on "up", p1.handlePointClicked, p1

				flagLabels = []
				if userFlagStatus == 'hit' or algorithmFlagStatus == 'hit' or preprocessFlagStatus == 'hit'
					flagLabels.push 'hit'
				if userFlagStatus == "knocked out"
					flagLabels.push userFlagComment
				if preprocessFlagStatus == "knocked out"
					flagLabels.push preprocessFlagComment
				if algorithmFlagStatus == "knocked out"
					flagLabels.push algorithmFlagComment

				if flagLabels.length > 0
					p1.flagLabel = flagLabels.join ', '
				else
					p1.flagLabel = ''

				p1.xLabel = JXG.trunc(points[ii].dose, 4)

				@pointList.push p1
				brd.highlightInfobox = (x, y, el) ->
					#brd.infobox.setText('<img src="http://www.freesmileys.org/smileys/big/big-smiley-face.gif" alt="Smiley face" width="42" height="42">');
					brd.infobox.setText "(" + el.xLabel + ", " + y + ", " + el.flagLabel + ")"
					brd.infobox.setProperty {strokeColor: 'black'}
					return
				ii++

			if logDose
				x = brd.create("line", [
					[0,0]
					[1,0]
				],
					strokeColor: "#888888"
				)
				y = brd.create("axis", [
					[plotWindow[0], 0]
					[plotWindow[0], 1]
				])
				x.isDraggable = false

				# create the tick markers for the axis
				t = brd.create("ticks", [x,1],
					# yes, show the labels
					drawLabels: true
				# yes, show the tick marker at zero (or, in this case: 1)
					drawZero: true
					generateLabelValue: (tick) ->
						# get the first defining point of the axis
						p1 = @line.point1
						# this works for the x-axis, for the y-axis you'll have to use usrCoords[2] (usrCoords[0] is the z-coordinate).
						#Xaxis in log scale
						Math.pow 10, tick.usrCoords[1] - p1.coords.usrCoords[1]
				)

		else
			brd.removeObject window.curve  unless typeof (window.curve) is "undefined"

		if curve?
			curvePlot = new plotCurveClass()
			curvePlot.render(brd, curve, plotWindow)

		getMouseCoords = (e) ->
			cPos = brd.getCoordsTopLeftCorner(e)
			absPos = JXG.getPosition(e)
			dx = absPos[0] - cPos[0]
			dy = absPos[1] - cPos[1]
			new JXG.Coords(JXG.COORDS_BY_SCREEN, [
				dx
				dy
			], brd)
		createSelection = (e) ->
			if !brd.elementsByName.selection?
				coords = getMouseCoords(e)
				a = brd.create 'point', [coords.usrCoords[1],coords.usrCoords[2]], {name:'selectionA', withLabel:false, visible:false, fixed:false}
				b = brd.create 'point', [coords.usrCoords[1],coords.usrCoords[2]], {name:'selectionB', visible:false, fixed:true}
				c = brd.create 'point', ["X(selectionA)",coords.usrCoords[2]], {name:'selectionC', visible:false}
				d = brd.create 'point', [coords.usrCoords[1],"Y(selectionA)"], {name:'selectionD', visible:false}
				selection = brd.create 'polygon', [b, c, a, d], {name: 'selection', hasInnerPoints: true}
				selection.update = ->
					if brd.elementsByName.selectionA.coords.usrCoords[2] < brd.elementsByName.selectionB.coords.usrCoords[2]
						@setAttribute
							fillcolor: 'red'
						selection.knockoutMode = true
					else
						@setAttribute
							fillcolor: '#00FF00'
						selection.knockoutMode = false
				selection.on 'update', selection.update, selection
				brd.mouseUp = ->
					selection = brd.elementsByName.selection
					if selection?
						knockoutMode = selection.knockoutMode
						brd.removeObject(selection)
						brd.removeObject(brd.elementsByName.selectionC)
						brd.removeObject(brd.elementsByName.selectionD)
						brd.removeObject(brd.elementsByName.selectionB)
						brd.removeObject(brd.elementsByName.selectionA)
						selected = selection.selected
						if selected?
							if selected.length > 0
								if knockoutMode
									promptForKnockout(selected)
								else
									includePoints(selected)

				brd.on 'up', brd.mouseUp, brd
				brd.followSelection = (e) ->
					if brd.elementsByName.selection
						coords = getMouseCoords(e)
						brd.elementsByName.selectionA.setPosition(JXG.COORDS_BY_USER, coords.usrCoords)
						selection = brd.elementsByName.selection
						selection.update()
						selectionCoords = [selection.vertices[0].coords.usrCoords,
						                   selection.vertices[1].coords.usrCoords,
						                   selection.vertices[2].coords.usrCoords,
						                   selection.vertices[3].coords.usrCoords]
						#Sort by response desc (south is on the top)
						sorted = _.sortBy selection.vertices.slice(0,4), (vertex) -> vertex.coords.usrCoords[2]
						#Sort north and south by response (order will then be 0 = west 1 = east)
						south = _.sortBy sorted.slice(0,2), (vertex) -> vertex.coords.usrCoords[1]
						north = _.sortBy sorted.slice(2,4), (vertex) -> vertex.coords.usrCoords[1]
						northWest = north[0].coords.usrCoords
						northEast = north[1].coords.usrCoords
						southWest = south[0].coords.usrCoords
						southEast = south[1].coords.usrCoords
						selected = []
						doseResponsePoints = _.where(brd.elementsByName, {isDoseResponsePoint: true, isSelected: false})
						doseResponsePoints.forEach (point) ->
							if point.coords.usrCoords[1] > northWest[1] & point.coords.usrCoords[2] < northWest[2] & point.coords.usrCoords[1] < northEast[1] & point.coords.usrCoords[2] < northEast[2] & point.coords.usrCoords[1] > southWest[1] & point.coords.usrCoords[1] > southWest[1] & point.coords.usrCoords[2] > southWest[2] & point.coords.usrCoords[1] < southEast[1] & point.coords.usrCoords[2] > southWest[2]
								selected.push(point)
						selection.selected = selected

				brd.on 'move', brd.followSelection, brd
				return
		brd.on "down", createSelection
		return

class window.CurveDetail extends Backbone.Model
	url: ->
		return "/api/curve/detail/" + @id
	initialize: ->
		@fixCompositeClasses()

	fixCompositeClasses: =>
		if @get('fitSettings') not instanceof DoseResponseAnalysisParameters
			@get('fitSettings')
			@set fitSettings: new DoseResponseAnalysisParameters(@get('fitSettings'))

	parse: (resp) =>
		curvefitClassesCollection = new Backbone.Collection $.parseJSON window.conf.curvefit.modelfitparameter.classes
		curveFitClasses =  curvefitClassesCollection.findWhere({code: resp.renderingHint})
		if curveFitClasses?
			parametersClass =  curveFitClasses.get 'parametersClass'
			drapType = window[parametersClass]
		if resp.fitSettings not instanceof drapType
			resp.fitSettings = new drapType(resp.fitSettings)
		return resp

class window.CurveEditorController extends Backbone.View
	template: _.template($("#CurveEditorView").html())
	defaults:
		locked: false

	events:
		'click .bv_reset': 'handleResetClicked'
		'click .bv_update': 'handleUpdateClicked'
		'click .bv_approve': 'handleApproveClicked'
		'click .bv_reject': 'handleRejectClicked'

	initialize: =>
		if @options.locked
			@locked = @options.locked

	render: =>
		@$el.empty()
		if @model?
			@$el.html @template()
			if @locked
				@$('.bv_update').attr 'disabled', 'disabled'

			curvefitClassesCollection = new Backbone.Collection $.parseJSON window.conf.curvefit.modelfitparameter.classes
			curveFitClasses =  curvefitClassesCollection.findWhere({code: @model.get('renderingHint')})
			if curveFitClasses?
				controllerClass =  curveFitClasses.get 'parametersController'
				drapcType = window[controllerClass]
			@drapc = new drapcType
				model: @model.get('fitSettings')
				el: @$('.bv_analysisParameterForm')
			@drapc.setFormTitle "Fit Criteria"

			@drapc.render()

			@stopListening @drapc.model, 'change'
			@listenTo @drapc.model, 'change', @handleParametersChanged

			@drpc = new DoseResponsePlotController
				model: new Backbone.Model @model.get('plotData')
				el: @$('.bv_plotWindowWrapper')
			@drpc.render()

			@stopListening @drpc.model, 'change'
			@listenTo @drpc.model, 'change', @handlePointsChanged

			@$('.bv_compoundCode').html @model.get('compoundCode')
			@$('.bv_reportedValues').html @model.get('reportedValues')
			@$('.bv_fitSummary').html @model.get('fitSummary')
			@$('.bv_parameterStdErrors').html @model.get('parameterStdErrors')
			@$('.bv_curveErrors').html @model.get('curveErrors')
			@$('.bv_category').html @model.get('category')
			if @model.get('algorithmFlagStatus') == ''
				@$('.bv_pass').show()
				@$('.bv_fail').hide()
			else
				@$('.bv_pass').hide()
				@$('.bv_fail').show()

			if @model.get('userFlagStatus') == ''
				@$('.bv_na').show()
				@$('.bv_thumbsUp').hide()
				@$('.bv_thumbsDown').hide()
			else
				if @model.get('userFlagStatus') == 'approved'
					@$('.bv_na').hide()
					@$('.bv_thumbsUp').show()
					@$('.bv_thumbsDown').hide()
				else
					@$('.bv_na').hide()
					@$('.bv_thumbsUp').hide()
					@$('.bv_thumbsDown').show()
		else
			@$el.html "No curve selected"

	setModel: (model)->
		if @model?
			@deleteRsession()
		@model = model

		@render()
		UtilityFunctions::showProgressModal @$('.bv_statusDropDown')
		@model.on 'sync', @handleModelSync

	handleModelSync: =>
		UtilityFunctions::hideProgressModal @$('.bv_statusDropDown')
		@render()

	handlePointsChanged: =>
		UtilityFunctions::showProgressModal @$('.bv_statusDropDown')
		@model.save({action: 'pointsChanged', user: window.AppLaunchParams.loginUserName}, {success :@handleUpdateSuccess, error: @handleUpdateError})

	handleParametersChanged: =>
		if @drapc.model.isValid()
			UtilityFunctions::showProgressModal @$('.bv_statusDropDown')
			@model.save({action: 'parametersChanged', user: window.AppLaunchParams.loginUserName}, {success :@handleUpdateSuccess, error: @handleUpdateError})

	handleResetClicked: =>
		UtilityFunctions::showProgressModal @$('.bv_statusDropDown')
		@deleteRsession()
		@model.fetch
			success: @handleUpdateSuccess
			error: @handleUpdateError

	handleUpdateClicked: =>
		UtilityFunctions::showProgressModal @$('.bv_statusDropDown')
		@oldID =  @model.get 'curveid'
		@model.save({action: 'save', user: window.AppLaunchParams.loginUserName}, {success :@handleSaveSuccess, error: @handleSaveError})

	handleApproveClicked: =>
		UtilityFunctions::showProgressModal @$('.bv_statusDropDown')
		@model.save({action: 'userFlagStatus', userFlagStatus: 'approved', user: window.AppLaunchParams.loginUserName}
			success :@handleUpdateSuccess
			error: @handleUpdateError)

	handleRejectClicked: =>
		UtilityFunctions::showProgressModal @$('.bv_statusDropDown')
		@model.save({action: 'userFlagStatus', userFlagStatus: 'rejected', user: window.AppLaunchParams.loginUserName}
			success :@handleUpdateSuccess
			error: @handleUpdateError)

	handleResetError: =>
		UtilityFunctions::hideProgressModal @$('.bv_statusDropDown')
		@trigger 'curveUpdateError'

	handleSaveError: =>
		UtilityFunctions::hideProgressModal @$('.bv_statusDropDown')
		@trigger 'curveUpdateError'

	handleUpdateError: =>
		UtilityFunctions::hideProgressModal @$('.bv_statusDropDown')
		@trigger 'curveUpdateError'

	handleSaveSuccess: =>
		@handleModelSync()
		newID = @model.get 'curveid'
		dirty = @model.get 'dirty'
		category = @model.get 'category'
		userFlagStatus = @model.get 'userFlagStatus'
		algorithmFlagStatus = @model.get 'algorithmFlagStatus'
		@trigger 'curveDetailSaved', @oldID, newID, dirty, category, userFlagStatus, algorithmFlagStatus

	handleUpdateSuccess: =>
		@handleModelSync()
		curveid = @model.get 'curveid'
		dirty = @model.get 'dirty'
		@trigger 'curveDetailUpdated', curveid, dirty

	deleteRsession: =>
		@model.save({action: 'deleteSession', user: window.AppLaunchParams.loginUserName})

class window.Curve extends Backbone.Model


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

	getCurveByID: (curveID) =>
		curve = @.findWhere({curveid: curveID})
		return curve

	getIndexByCurveID: (curveID) =>
		curve = @getCurveByID(curveID)
		index = @.indexOf(curve)
		return index

	updateCurveSummary: (oldID, newCurveID, dirty, category, userFlagStatus, algorithmFlagStatus) =>
		curve = @getCurveByID(oldID)
		curve.set
			curveid: newCurveID
			dirty: dirty
			userFlagStatus: userFlagStatus
			algorithmFlagStatus: algorithmFlagStatus
			category: category

	updateDirtyFlag: (curveid, dirty) =>
		curve = @getCurveByID(curveid)
		curve.set
			dirty: dirty

	updateUserFlagStatus: (curveid, userFlagStatus) =>
		curve = @getCurveByID(curveid)
		curve.set
			userFlagStatus: userFlagStatus


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


class window.CurveEditorDirtyPanelController extends Backbone.View
	template: _.template($("#CurveEditorDirtyPanelView").html())

	render: =>
		@$el.empty()
		@$el.html @template()
		@$('.bv_curveEditorDirtyPanel').on "show", =>
			@$('.bv_curveEditorDirtyPanelOKBtn').focus()
		@$('.bv_curveEditorDirtyPanel').on "keypress", (key)=>
			if key.keyCode == 13
				@$('.bv_curveEditorDirtyPanelOKBtn').click()
		@$('.bv_doseResponseKnockoutPanel').on "hidden", =>
			#placeholder
		@

	show: =>
		@$('.bv_curveEditorDirtyPanel').modal
			backdrop: "static"
		@$('.bv_curveEditorDirtyPanel').modal "show"

class window.CurveSummaryController extends Backbone.View
	template: _.template($("#CurveSummaryView").html())
	tagName: 'div'
	className: 'bv_curveSummary'
	defaults:
		locked: false
	events:
		'click .bv_group_thumbnail': 'setSelected'
		'click .bv_userApprove': 'userApprove'
		'click .bv_userReject': 'userReject'
		'click .bv_userNA': 'userNA'

	initialize: ->
		curvefitClassesCollection = new Backbone.Collection $.parseJSON window.conf.curvefit.modelfitparameter.classes
		curveFitClasses =  curvefitClassesCollection.findWhere({code: @model.get('curveAttributes').renderingHint})
		renderCurvePath =  curveFitClasses.get 'renderCurvePath'
		console.log renderCurvePath
		if renderCurvePath?
			console.log renderCurvePath
			@renderCurvePath = renderCurvePath
		else
			@renderCurvePath = 'dr'
		@model.on 'change', @render
		if @options.locked
			@locked = @options.locked


	render: =>
		@$el.empty()
		@model.url = '/api/curve/stub/' + @model.get 'curveid'
		if window.AppLaunchParams.testMode
			curveUrl = "/src/modules/curveAnalysis/spec/testFixtures/testThumbs/"
			curveUrl += @model.get('curveid')+".png"
		else
			curveUrl = "/api/curve/render/#{@renderCurvePath}/?legend=false&showGrid=true&height=120&width=250&curveIds="
			curveUrl += @model.get('curveid') + "&showAxes=true&axes=y&labelAxes=false"
		@$el.html @template
			curveUrl: curveUrl

		if @locked
			@$('.bv_flagUser').attr 'disabled', 'disabled'

		if @model.get('algorithmFlagStatus') == 'no fit'
			@$('.bv_pass').hide()
			@$('.bv_fail').show()
		else
			@$('.bv_pass').show()
			@$('.bv_fail').hide()
		if @model.get('userFlagStatus') == ''
			@$('.bv_na').show()
			@$('.bv_thumbsUp').hide()
			@$('.bv_thumbsDown').hide()
			@$('.bv_flagUser').removeClass('btn-success')
			@$('.bv_flagUser').removeClass('btn-danger')
			@$('.bv_flagUser').addClass('btn-grey')
		else
			if @model.get('userFlagStatus') == 'approved'
				@$('.bv_na').hide()
				@$('.bv_thumbsUp').show()
				@$('.bv_thumbsDown').hide()
				@$('.bv_flagUser').addClass('btn-success')
				@$('.bv_flagUser').removeClass('btn-danger')
				@$('.bv_flagUser').removeClass('btn-grey')
			else
				@$('.bv_na').hide()
				@$('.bv_thumbsUp').hide()
				@$('.bv_thumbsDown').show()
				@$('.bv_flagUser').removeClass('btn-success')
				@$('.bv_flagUser').addClass('btn-danger')
				@$('.bv_flagUser').removeClass('btn-grey')
		if @model.get 'dirty'
			@$('.bv_dirty').show()
		else
			@$('.bv_dirty').hide()

		@$('.bv_compoundCode').html @model.get('curveAttributes').compoundCode
#		@model.on 'change', @render
		@

	approveUncurated: =>
		if @model.get("userFlagStatus") == ""
			@userApprove()

	userApprove: ->
		@approveReject("approved")

	userReject: ->
		@approveReject("rejected")

	userNA: ->
		@approveReject("")

	approveReject: (decision) ->
		if !@model.get 'dirty'
			@setUserFlagStatus(decision)
		else
			@trigger 'showCurveEditorDirtyPanel'

	setUserFlagStatus: (userFlagStatus) =>
		@disableSummary()
		@model.save(userFlagStatus: userFlagStatus, user: window.AppLaunchParams.loginUserName, {
			wait: true,
			success: =>
				@enableSummary()
				if @$el.hasClass('selected')
					@trigger 'selected', @
			error: =>
				$('.bv_badCurveUpdate').modal
					backdrop: "static"
				$('.bv_badCurveUpdate').modal "show"
		})

	disableSummary: ->
		@undelegateEvents()
		@$el.fadeTo(100, 0.2)


	enableSummary: ->
		@delegateEvents()
		@$el.fadeTo(100, 1)


	setSelected: =>
		if !@$el.hasClass('selected')
			@$el.addClass 'selected'
			@trigger 'selected', @

	styleSelected: ->
		if !@$el.hasClass('selected')
			@$el.addClass 'selected'

	clearSelected: (who) =>
		if who?
			if who.model.cid == @.model.cid
				return
		@$el.removeClass 'selected'

class window.CurveSummaryListController extends Backbone.View
	template: _.template($("#CurveSummaryListView").html())
	defaults:
		locked: false
	initialize: ->
		if @options.locked
			@locked = @options.locked
		@filterKey = 'all'
		@sortKey = 'none'
		@sortAscending = true
		@firstRun = true
		if @options.selectedCurve?
			@initiallySelectedCurveID = @options.selectedCurve
		else
			@initiallySelectedCurveID = "NA"
		@on 'handleApproveUncurated', @handleApproveUncurated

	render: =>
		@$el.empty()
		@$el.html @template()
		@curveEditorDirtyPanel = new CurveEditorDirtyPanelController
			el: @$('.bv_curveEditorDirtyPanel')
		@curveEditorDirtyPanel.render()

		if @filterKey != 'all'
			@toRender = new Backbone.Collection @collection.filter (cs) =>
				cs.get('category') == @filterKey
		else
			@toRender = @collection

		unless @sortKey == 'none'
			@toRender = @toRender.sortBy (curve) =>
				attributes = curve.get('curveAttributes')
				attributes[@sortKey]
			unless @sortAscending
				@toRender = @toRender.reverse()
			@toRender = new Backbone.Collection @toRender

		i = 1
		@csControllers = []
		@toRender.each (cs) =>
			csController = new CurveSummaryController
				model: cs
				locked: @locked
			csController.on "approveUncurated", csController.approveUncurated
			@csControllers.push csController
			@$('.bv_curveSummaries').append(csController.render().el)
			csController.on 'selected', @selectionUpdated
			csController.on 'showCurveEditorDirtyPanel', @showCurveEditorDirtyPanel
			@on 'clearSelected', csController.clearSelected
			if @firstRun && @initiallySelectedCurveID?
				if @initiallySelectedCurveID == cs.get 'curveid'
					@selectedcid = cs.cid
			if @selectedcid?
				if csController.model.cid == @selectedcid
					if !@firstRun
						csController.styleSelected()
					else
						csController.setSelected()
			else
				if @firstRun && i==1
					@selectedcid = cs.id
					csController.setSelected()
			i = 2

		@firstRun = false
		@

	anyDirty: =>
		collection = @toRender
		dirty = collection.findWhere(dirty: true)
		return dirty?

	selectionUpdated: (who) =>
		if !@anyDirty()
			@selectedcid = who.model.cid
			@trigger 'clearSelected', who
			@trigger 'selectionUpdated', who
		else
			who.clearSelected()
			@showCurveEditorDirtyPanel()

	handleApproveUncurated: ->
		for curveSummaryController in @csControllers
			curveSummaryController.trigger 'approveUncurated'


	showCurveEditorDirtyPanel: =>
		@curveEditorDirtyPanel.show()

	filter: (key) ->
		@filterKey = key
		@render()

	sort: (key, ascending) ->
		@sortKey = key
		@sortAscending = ascending
		@render()

class window.CurveCuratorController extends Backbone.View
	template: _.template($("#CurveCuratorView").html())
	defaults:
		locked: false

	events:
		'change .bv_filterBy': 'handleFilterChanged'
		'change .bv_sortBy': 'handleSortChanged'
		'click .bv_sortDirection_ascending': 'handleSortChanged'
		'click .bv_sortDirection_descending': 'handleSortChanged'
		'click .bv_approve_uncurated': 'handleApproveUncuratedClicked'

	render: =>
		@$el.empty()
		@$el.html @template()

		if @model?
			if @locked
				@$('.bv_approve_uncurated').attr 'disabled', 'disabled'
			@curveListController = new CurveSummaryListController
				el: @$('.bv_curveList')
				collection: @model.get 'curves'
				selectedCurve: @initiallySelectedCurveID
				locked: @locked
			@curveListController.on 'selectionUpdated', @curveSelectionUpdated
			@curveEditorController = new CurveEditorController
				el: @$('.bv_curveEditor')
				locked: @locked
			@curveEditorController.on 'curveDetailSaved', @handleCurveDetailSaved
			@curveEditorController.on 'curveDetailUpdated', @handleCurveDetailUpdated
			@curveEditorController.on 'curveUpdateError', @handleCurveUpdateError

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

		@

	handleApproveUncuratedClicked: =>
		@curveListController.trigger 'handleApproveUncurated'

	handleCurveDetailSaved: (oldID, newID, dirty, category, userFlagStatus, algorithmFlagStatus) =>
		@curveListController.collection.updateCurveSummary(oldID, newID, dirty, category, userFlagStatus, algorithmFlagStatus)

	handleCurveDetailUpdated: (curveid, dirty) =>
		@curveListController.collection.updateDirtyFlag(curveid, dirty)

	handleCurveUpdateError: =>
		@$('.bv_badCurveUpdate').modal
			backdrop: "static"
		@$('.bv_badCurveUpdate').modal "show"

	getCurvesFromExperimentCode: (exptCode, curveID) =>
		@initiallySelectedCurveID = curveID
		@model = new CurveCurationSet
		@model.setExperimentCode exptCode
		@model.fetch
			success: =>
				@trigger 'getCurvesSuccessful'
				@render()
			error: (model, response, options) =>
				@showBadExperimentModal(response.responseText)

	showBadExperimentModal: (text)->
		UtilityFunctions::hideProgressModal $('.bv_loadCurvesModal')
		console.log text
		console.log $('.bv_badExperimentCode .modal-body')
		console.log $('.bv_badExperimentCode').find('.modal-body').html()
		if text?
			@$('.bv_badExperimentCode').find('.modal-body').html(text+'<div><br></div>')
		UtilityFunctions::showProgressModal $('.bv_badExperimentCode')

	handleWarnUserLockedExperiment: (exptCode, curveID)->
		UtilityFunctions::hideProgressModal $('.bv_loadCurvesModal')
		@$('.bv_experimentLocked').modal "show"
		@$('.bv_experimentLocked').on "hidden", =>
			@getCurvesFromExperimentCode(exptCode, curveID)

	checkLocked: (experiment, status) =>
		expt = [experiment]
		lockFilters = $.parseJSON window.conf.experiment.lockwhenapproved.filter
		experimentMatchesAFilter = false
		_.each lockFilters, (filter) ->
			test = _.where(expt, filter)
			if test.length > 0
				experimentMatchesAFilter = true
		shouldLock = (status == 'approved') & experimentMatchesAFilter
		return shouldLock

	setupCurator: (exptCode, curveID)=>
		$.ajax
			type: 'GET'
			url: "/api/experiments/"+exptCode+"/exptvalues/bystate/metadata/experiment metadata/byvalue/codeValue/experiment status"
			dataType: 'json'
			success: (json) =>
				if json.length == 0
					@showBadExperimentModal()
				else
					experiment = json[0].lsState.experiment
					status = json[0].codeValue
					shouldLock = @checkLocked(experiment, status)
					if shouldLock
						@locked = true
						@handleWarnUserLockedExperiment(exptCode, curveID)
					else
						@locked = false
						@getCurvesFromExperimentCode(exptCode, curveID)
			error: (err) =>
				@showBadExperimentModal

	curveSelectionUpdated: (who) =>
		UtilityFunctions::showProgressModal @$('.bv_curveCuratorDropDown')
		curveDetail = new CurveDetail id: who.model.get('curveid')
		curveDetail.fetch
			success: =>
				UtilityFunctions::hideProgressModal @$('.bv_curveCuratorDropDown')
				@curveEditorController.setModel curveDetail
			error: =>
				UtilityFunctions::hideProgressModal @$('.bv_curveCuratorDropDown')
				@$('.bv_badCurveID').modal
					backdrop: "static"
				@$('.bv_badCurveID').modal "show"

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
