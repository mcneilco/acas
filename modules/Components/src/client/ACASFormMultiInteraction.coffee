class window.ACASFormMultiInteractionController extends Backbone.View
	###
		Launched by ACASFormMultiInteractionListController to control one element/row in the list
	###

	template: _.template($("#ACASFormMultiInteractionView").html())

	events: ->
		"click .bv_removeInteractionButton": "handleRemoveInteractionButtonClicked"

	initialize: ->
		options =
			modelKey: @options.interactionKey
			thingType: @options.thingType
			thingKind: @options.thingKind
			labelType: @options.labelType
			queryUrl: @options.queryUrl
			placeholder: @options.placeholder
			extendedLabel: @options.extendedLabel
			inputClass: @options.inputClass
			formLabel: @options.formLabel
			required: @options.required
			thingRef: @options.thingRef
			insertUnassigned: @options.insertUnassigned
		@interactionController = new ACASFormLSThingInteractionFieldController options

	render: ->
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_multiInteraction').html @interactionController.render().el
		@interactionController.renderModelContent()
		@

	handleRemoveInteractionButtonClicked: ->
		@interactionController.setEmptyValue()
		$(@el).hide()


class window.ACASFormMultiInteractionListController extends ACASFormAbstractFieldController
	###
  	Launching controller must instantiate with the full field conf including modelDefaults, not just the fieldDefinition.
  	Controls a flexible-length list of LsThingInteraction input fields within ACASFormLSThingInteractionFieldControllers with an add button.
	###
	template: _.template($("#ACASFormMultiInteractionListView").html())

	events: ->
		"click .bv_addInteractionButton": "handleAddInteractionButtonClicked"

	initialize: ->
		super()
		@opts = @options
		if @opts.firstItx
			@itxClass = FirstThingItx
			@thingItxRef = 'firstLsThings'
		else
			@itxClass = SecondThingItx
			@thingItxRef = 'secondLsThings'

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@

	renderModelContent: ->
		@render()
		multiInteractions = @thingRef.get(@thingItxRef).getItxByTypeAndKind(@opts.modelDefaults.itxType, @opts.modelDefaults.itxKind)
		_.each multiInteractions, (interaction) =>
			@addOneInteraction(interaction)

	handleAddInteractionButtonClicked: =>
		@addNewInteraction()

	addNewInteraction: (skipAmDirtyTrigger) =>
		keyBase = @modelKey
		newModel = new @itxClass
			lsType: @opts.modelDefaults.itxType
			lsKind: @opts.modelDefaults.itxKind
		currentMultiInteractions = @thingRef.get(@thingItxRef).filter (interaction) ->
			interaction.has('key') and (interaction.get('key').indexOf(keyBase) > -1)
		newKey = keyBase + currentMultiInteractions.length
		newModel.set key: newKey
		@thingRef.set newKey, newModel
		@thingRef.get(@thingItxRef).add newModel
		@addOneInteraction(newModel)
		unless skipAmDirtyTrigger is true
			newModel.trigger 'amDirty'

	addOneInteraction: (interaction) ->
		interactionOpts = @opts
		interactionOpts.interactionKey = interaction.get('key')
		multiInteractionController = new ACASFormMultiInteractionController interactionOpts
		@$('.bv_multiInteractions').append multiInteractionController.render().el
		multiInteractionController.on 'updateState', =>
			@trigger 'updateState'



