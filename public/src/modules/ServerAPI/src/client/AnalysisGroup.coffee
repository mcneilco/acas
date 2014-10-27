class window.AnalysisGroup extends Backbone.Model
	defaults:
		kind: ""
		recordedBy: ""
		recordedDate: null
		lsLabels: [] # will be converted into a LabelList()
		lsStates: [] # will be converted into a StateList()

	initialize: ->
		@.set @parse(@.attributes)
#		@fixCompositeClasses()

	parse: (resp) =>
		if resp.lsLabels?
			if resp.lsLabels not instanceof LabelList
				resp.lsLabels = new LabelList(resp.lsLabels)
				resp.lsLabels.on 'change', =>
					@trigger 'change'
		if resp.lsStates?
			if resp.lsStates not instanceof StateList
				resp.lsStates = new StateList(resp.lsStates)
				resp.lsStates.on 'change', =>
					@trigger 'change'
		resp


#	fixCompositeClasses: =>
#		if @has('lsLabels')
#			if @get('lsLabels') not instanceof LabelList
#				@set lsLabels: new LabelList(@get('lsLabels'))
#		if @has('lsStates')
#			if @get('lsStates') not instanceof StateList
#				@set lsStates: new StateList(@get('lsStates'))

class window.AnalysisGroupList extends Backbone.Collection
	model: AnalysisGroup