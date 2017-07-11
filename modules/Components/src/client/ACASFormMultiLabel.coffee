class window.ACASFormMultiLabelController extends Backbone.View
	###
		Launched by ACASFormMultiLabelListController to control one element/row in the list
	###

	template: _.template($("#ACASFormMultiLabelView").html())

	events: ->
		"click .bv_removeLabelButton": "handleRemoveLabelButtonClicked"

	initialize: ->
		options =
			modelKey: @options.labelKey
			inputClass: @options.inputClass
			formLabel: @options.formLabel
			placeholder: @options.placeholder
			required: @options.required
			url: @options.url
			thingRef: @options.thingRef
			insertUnassigned: @options.insertUnassigned
		@lc = new ACASFormLSLabelFieldController options

	render: ->
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_multiLabel').html @lc.render().el
		@lc.renderModelContent()
		@

	handleRemoveLabelButtonClicked: ->
		@lc.setEmptyValue()
		$(@el).hide()


class window.ACASFormMultiLabelListController extends ACASFormAbstractFieldController
	###
  	Launching controller must instantiate with the full field conf including modelDefaults, not just the fieldDefinition.
  	Controls a flexible-length list of LSLabel input fields within ACASFormMultiLabelControllers with an add button.
	###
	template: _.template($("#ACASFormMultiLabelListView").html())

	events: ->
		"click .bv_addLabelButton": "handleAddLabelButtonClicked"

	initialize: ->
		super()
		@opts = @options

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@

	renderModelContent: ->
		@render()
		multiLabels = @thingRef.get('lsLabels').getLabelByTypeAndKind(@opts.modelDefaults.type, @opts.modelDefaults.kind)
		_.each multiLabels, (label) =>
			@addOneLabel(label)

	handleAddLabelButtonClicked: =>
		@addNewLabel()

	addNewLabel: (skipAmDirtyTrigger) =>
		keyBase = @modelKey
		newModel = new Label
			lsType: @opts.modelDefaults.type
			lsKind: @opts.modelDefaults.kind
			preferred: @opts.modelDefaults.preferred
		currentMultiLabels = @thingRef.get('lsLabels').filter (label) ->
			label.has('key') and (label.get('key').indexOf(keyBase) > -1)
		newKey = keyBase + currentMultiLabels.length
		newModel.set key: newKey
		@thingRef.set newKey, newModel
		@thingRef.get('lsLabels').add newModel
		@addOneLabel(newModel)
		unless skipAmDirtyTrigger is true
			newModel.trigger 'amDirty'

	addOneLabel: (label) ->
		labelOpts = @opts
		labelOpts.labelKey = label.get('key')
		lc = new ACASFormMultiLabelController labelOpts
		console.log label.get('key')
		@$('.bv_multiLabels').append lc.render().el
		lc.on 'updateState', =>
			@trigger 'updateState'



