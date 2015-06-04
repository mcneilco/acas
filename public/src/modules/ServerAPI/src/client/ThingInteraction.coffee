class window.ThingItx extends Backbone.Model
	className: "ThingItx"

	defaults: () =>
		@set lsType: "interaction"
		@set lsKind: "interaction"
		@set lsTypeAndKind: @_lsTypeAndKind()
		@set lsStates: new StateList()
		@set recordedBy: window.AppLaunchParams.loginUser.username
		@set recordedDate: new Date().getTime()

	_lsTypeAndKind: ->
		@get('lsType') + '_' + @get('lsKind')

	initialize: ->
		@set @parse(@attributes)

	parse: (resp) =>
		if resp.lsStates?
			if resp.lsStates not instanceof StateList
				resp.lsStates = new StateList(resp.lsStates)
			resp.lsStates.on 'change', =>
				@trigger 'change'
		resp

	reformatBeforeSaving: =>
		if @attributes.attributes?
			delete @attributes.attributes
		for i of @attributes
			if _.isFunction(@attributes[i])
				delete @attributes[i]
			else if !isNaN(i)
				delete @attributes[i]

		delete @attributes._changing
		delete @attributes._previousAttributes
		delete @attributes.cid
		delete @attributes.changed
		delete @attributes._pending
		delete @attributes.collection

class window.FirstThingItx extends ThingItx
	className: "FirstThingItx"

	defaults: () =>
		super()
		@set firstLsThing: {}

	setItxThing: (thing) =>
		@set firstLsThing: thing

class window.SecondThingItx extends ThingItx
	className: "SecondThingItx"

	defaults: () =>
		super()
		@set secondLsThing: {}

	setItxThing: (thing) =>
		@set secondLsThing: thing

class window.LsThingItxList extends Backbone.Collection
	getItxByTypeAndKind: (type, kind) ->
		@filter (itx) ->
			(not itx.get('ignored')) and (itx.get('lsType')==type) and (itx.get('lsKind')==kind)

	createItxByTypeAndKind: (itxType, itxKind) ->
		itx = new @model
			lsType: itxType
			lsKind: itxKind
			lsTypeAndKind: "#{itxType}_#{itxKind}"
		@.add itx
		itx.on 'change', =>
			@trigger('change')
		return itx

	getOrderedItxList: (type, kind) ->
		itxs = @getItxByTypeAndKind(type, kind)
		orderedItx = []
		i = 1
		while i <= itxs.length
			nextItx =  _.filter itxs, (itx) ->
				order = itx.get('lsStates').getOrCreateValueByTypeAndKind 'metadata', 'composition', 'numericValue', 'order'
				order.get('numericValue') == i
			orderedItx.push nextItx...
			i++
		orderedItx

	reformatBeforeSaving: =>
		@each((model) ->
			model.reformatBeforeSaving()
		)

class window.FirstLsThingItxList extends LsThingItxList
	model: FirstThingItx

class window.SecondLsThingItxList extends LsThingItxList
	model: SecondThingItx
