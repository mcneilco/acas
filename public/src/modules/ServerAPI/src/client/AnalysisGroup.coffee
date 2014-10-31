class window.AnalysisGroup extends Backbone.Model
	defaults: ->
		kind: ""
		recordedBy: ""
		recordedDate: null
		lsLabels: new LabelList() # will be converted into a LabelList()
		lsStates: new StateList() # will be converted into a StateList()

	initialize: ->
		@.set @parse(@.attributes)

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

class window.AnalysisGroupList extends Backbone.Collection
	model: AnalysisGroup