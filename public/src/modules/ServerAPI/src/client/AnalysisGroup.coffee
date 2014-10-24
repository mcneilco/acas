class window.AnalysisGroup extends Backbone.Model
	defaults:
		kind: ""
		recordedBy: ""
		recordedDate: null
		lsLabels: [] # will be converted into a LabelList()
		lsStates: [] # will be converted into a StateList()

	initialize: ->
		@fixCompositeClasses()

	fixCompositeClasses: =>
		if @has('lsLabels')
			if @get('lsLabels') not instanceof LabelList
				@set lsLabels: new LabelList(@get('lsLabels'))
		if @has('lsStates')
			if @get('lsStates') not instanceof StateList
				@set lsStates: new StateList(@get('lsStates'))

class window.AnalysisGroupList extends Backbone.Collection
	model: AnalysisGroup