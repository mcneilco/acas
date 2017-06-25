class window.ACASFormStateDisplayUpdateRowController extends Backbone.View
	tagName: 'tr'

	render: =>
		@collection.each (val) =>
			value = val.get(val.get('lsType'))
			$(@el).append "<td>#{value}</td>"
			console.log @el

		@



class window.ACASFormStateDisplayUpdateController extends Backbone.View

	template: _.template($("#ACASFormStateDisplayUpdateView").html())

	initialize: ->
		@thingRef = @options.thingRef
		@tableDef = @options.tableDef
		@tableSetupComplete = false
		@callWhenSetupComplete = null

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@applyOptions()
		@tableSetupComplete = true

		@

	renderModelContent: =>
		if @tableSetupComplete
			@completeRenderModelContent()
		else
			@callWhenSetupComplete = @completeRenderModelContent

	completeRenderModelContent: ->
		for state in @getCurrentStates()
			rowController = new ACASFormStateDisplayUpdateRowController
				collection: state.get 'lsValues'
			@$("tbody").append rowController.render().el
			console.log @$("tbody")

	applyOptions: ->
		if @tableDef?.tableLabel?
			@setTableLabel @tableDef.tableLabel
		if @tableDef?.tableLabelClass?
			@addFormLabelClass @options.tableDef.tableLabelClass

	setTableLabel: (value) ->
		@$('.bv_tableLabel').html value

	addTableLabelClass: (value) ->
		@$('.bv_tableLabel').addClass value

	removeTableLabelClass: (value) ->
		@$('.bv_tableLabel').removeClass value

	getCurrentStates: ->
		@thingRef.get('lsStates').getStatesByTypeAndKind @tableDef.stateType, @tableDef.stateKind

#TODO Build header row
#TODO value editor
#TODO show/hide edited states
#TODO option to set order of values
#TODO implement enable/disable editing