class AnalysisGroup extends Backbone.Model
	defaults:
		kind: ""
		recordedBy: ""
		recordedDate: null
		lsLabels: new LabelList()
		lsStates: new StateList()

	initialize: (options) ->
		@options = options
		@fixCompositeClasses()

	fixCompositeClasses: =>
		if @has('lsLabels')
			if @get('lsLabels') not instanceof LabelList
				@set lsLabels: new LabelList(@get('lsLabels'))
		if @has('lsStates')
			if @get('lsStates') not instanceof StateList
				@set lsStates: new StateList(@get('lsStates'))

class AnalysisGroupList extends Backbone.Collection
	model: AnalysisGroup