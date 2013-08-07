class window.ProtocolValue extends Backbone.Model

class window.ProtocolValueList extends Backbone.Collection
	model: ProtocolValue

class window.ProtocolState extends Backbone.Model
	defaults:
		lsValues: new ProtocolValueList()

	initialize: ->
		if @has('lsValues')
			if @get('lsValues') not instanceof ProtocolValueList
				@set lsValues: new ProtocolValueList(@get('lsValues'))
		@get('lsValues').on 'change', =>
			@trigger 'change'

	parse: (resp) ->
		if resp.lsValues?
			if resp.lsValues not instanceof ProtocolValueList
				resp.lsValues = new ProtocolValueList(resp.lsValues)
				resp.lsValues.on 'change', =>
					@trigger 'change'
		resp

class window.ProtocolStateList extends Backbone.Collection
	model: ProtocolState

class window.Protocol extends Backbone.Model
	urlRoot: "/api/protocols"

	defaults:
		kind: ""
		recordedBy: ""
		shortDescription: ""
		lsLabels: new LabelList()
		lsStates: new ProtocolStateList()

	initialize: ->
		@fixCompositeClasses()
		@setupCompositeChangeTriggers()

	parse: (resp) =>
		if resp.lsLabels?
			if resp.lsLabels not instanceof LabelList
				resp.lsLabels = new LabelList(resp.lsLabels)
				resp.lsLabels.on 'change', =>
					@trigger 'change'
		if resp.lsStates?
			if resp.lsStates not instanceof ProtocolStateList
				resp.lsStates = new ProtocolStateList(resp.lsStates)
				resp.lsStates.on 'change', =>
					@trigger 'change'
		resp

	fixCompositeClasses: ->
		if @has('lsLabels')
			if @get('lsLabels') not instanceof LabelList
				@set lsLabels: new LabelList(@get('lsLabels'))
		if @has('lsStates')
			if @get('lsStates') not instanceof ProtocolStateList
				@set lsStates: new ProtocolStateList(@get('lsStates'))

	setupCompositeChangeTriggers: ->
		@get('lsLabels').on 'change', =>
			@trigger 'change'
		@get('lsStates').on 'change', =>
			@trigger 'change'

	isStub: ->
		return @get('lsLabels').length == 0 #protocol stubs won't have this
