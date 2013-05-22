class window.ProtocolValue extends Backbone.Model

class window.ProtocolValueList extends Backbone.Collection
	model: ProtocolValue

class window.ProtocolState extends Backbone.Model
	defaults:
		protocolValues: new ProtocolValueList()

	initialize: ->
		if @has('protocolValues')
			if @get('protocolValues') not instanceof ProtocolValueList
				@set protocolValues: new ProtocolValueList(@get('protocolValues'))
		@get('protocolValues').on 'change', =>
			@trigger 'change'

	parse: (resp) ->
		if resp.protocolValues?
			if resp.protocolValues not instanceof ProtocolValueList
				resp.protocolValues = new ProtocolValueList(resp.protocolValues)
				resp.protocolValues.on 'change', =>
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
		protocolLabels: new LabelList()
		protocolStates: new ProtocolStateList()

	initialize: ->
		@fixCompositeClasses()
		@setupCompositeChangeTriggers()

	parse: (resp) =>
		if resp.protocolLabels?
			if resp.protocolLabels not instanceof LabelList
				resp.protocolLabels = new LabelList(resp.protocolLabels)
				resp.protocolLabels.on 'change', =>
					@trigger 'change'
		if resp.protocolStates?
			if resp.protocolStates not instanceof ProtocolStateList
				resp.protocolStates = new ProtocolStateList(resp.protocolStates)
				resp.protocolStates.on 'change', =>
					@trigger 'change'
		resp

	fixCompositeClasses: ->
		if @has('protocolLabels')
			if @get('protocolLabels') not instanceof LabelList
				@set protocolLabels: new LabelList(@get('protocolLabels'))
		if @has('protocolStates')
			if @get('protocolStates') not instanceof ProtocolStateList
				@set protocolStates: new ProtocolStateList(@get('protocolStates'))

	setupCompositeChangeTriggers: ->
		@get('protocolLabels').on 'change', =>
			@trigger 'change'
		@get('protocolStates').on 'change', =>
			@trigger 'change'

	isStub: ->
		return @get('protocolLabels').length == 0 #protocol stubs won't have this
