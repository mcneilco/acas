class window.AnalysisGroupValue extends Backbone.Model
	defaults:
		valueKind: ""
		valueType: ""
		value: ""
		comments: ""
		ignored: false

class window.AnalysisGroupValueList extends Backbone.Collection
	model: AnalysisGroupValue

class window.AnalysisGroupState extends Backbone.Model
	defaults:
		analysisGroupValues: new AnalysisGroupValueList()
		recordedBy: ''
		stateType: 'results'
		stateKind: 'Document for Batch'
	initialize: ->
		if @has('analysisGroupValues')
			if @get('analysisGroupValues') not instanceof AnalysisGroupValueList
				@set analysisGroupValues: new AnalysisGroupValueList(@get('analysisGroupValues'))

	getValuesByTypeAndKind: (type, kind) ->
		@get('analysisGroupValues').filter (value) ->
			(not value.get('ignored')) and (value.get('valueType')==type) and (value.get('valueKind')==kind)

class window.AnalysisGroupStateList extends Backbone.Collection
	model: AnalysisGroupState


class window.AnalysisGroup extends Backbone.Model
	defaults:
		kind: ""
		recordedBy: ""
		recordedDate: null
		analysisGroupLabels: new LabelList()
		analysisGroupStates: new AnalysisGroupStateList()

	initialize: ->
		@fixCompositeClasses()

	fixCompositeClasses: =>
		if @has('analysisGroupLabels')
			if @get('analysisGroupLabels') not instanceof LabelList
				@set analysisGroupLabels: new LabelList(@get('analysisGroupLabels'))
		if @has('analysisGroupStates')
			if @get('analysisGroupStates') not instanceof AnalysisGroupStateList
				@set analysisGroupStates: new AnalysisGroupStateList(@get('analysisGroupStates'))

class window.AnalysisGroupList extends Backbone.Collection
	model: AnalysisGroup