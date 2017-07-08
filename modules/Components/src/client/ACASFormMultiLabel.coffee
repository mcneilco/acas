class window.ACASFormMultiLabelListController extends ACASFormAbstractFieldController
	template: _.template($("#ACASFormMultiLabelListView").html())
	#model should be a collection of LSLabels i.e. Labels
	#instantiate me with the full conf, not just the fieldDefinition

	initialize: ->
		super()
		@opts = @options
		multiLabels = @thingRef.get('lsLabels').getLabelByTypeAndKind(@opts.modelDefaults.type, @opts.modelDefaults.kind)
		_.each multiLabels, (label) =>
			@addOneLabel(label)
		#TODO: initialize the first new label- do I have to?
#		opts.modelKey = opts.key + 0

	events: ->
		"click .bv_addLabelButton": "handleAddLabelButtonClicked"

	handleAddLabelButtonClicked: =>
		@addNewLabel()

	addNewLabel: (skipAmDirtyTrigger) =>
		keyBase = @modelKey
		newModel = new Label
			lsType: @opts.modelDefaults.type
			lsKind: @opts.modelDefaults.kind
			preferred: @opts.modelDefaults.preferred
		#count up number of current labels
		#TODO: can this be replaced with some get collection??
		currentMultiLabels = @thingRef.get('lsLabels').filter (label) ->
			label.has('key') and (label.get('key').indexOf(keyBase) > -1)
		console.log currentMultiLabels
		newKey = keyBase + currentMultiLabels.length
		newModel.set key: newKey
		@thingRef.set newKey, newModel
		@thingRef.get('lsLabels').add newModel
		@addOneLabel(newModel)
		unless skipAmDirtyTrigger is true
			newModel.trigger 'amDirty'

	addOneLabel: (label) ->
		opts =
			modelKey: label.get('key')
			inputClass: @opts.inputClass
			formLabel: @opts.formLabel
			placeholder: @opts.placeholder
			required: @opts.required
			url: @opts.url
			thingRef: @thingRef
			insertUnassigned:@opts.insertUnassigned
			model: label
		lc = new ACASFormMultiLabelRowController opts
		console.log lc
		console.log lc.getModel()
		@$('.bv_multiLabels').append lc.render().el
		lc.renderModelContent()
		lc.on 'updateState', =>
			@trigger 'updateState'

class window.ACASFormMultiLabelRowController extends ACASFormLSLabelFieldController
	###
		Launching controller must:
		- Initialize the model with an LSLabel
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###

	template: _.template($("#ACASFormMultiLabelRowView").html())

