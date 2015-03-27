class window.ThingItx extends Backbone.Model
	className: "ThingItx"

	defaults: () =>
		@set lsType: "interaction"
		@set lsKind: "interaction"
		@set lsTypeAndKind: @_lsTypeAndKind()
		@set recordedBy: window.AppLaunchParams.loginUser.username
		@set recordedDate: new Date().getTime()

	_lsTypeAndKind: ->
		@get('lsType') + '_' + @get('lsKind')

	reformatBeforeSaving: ->
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

class window.FirstThingItx extends ThingItx
	defaults: () =>
		super()
		@set firstLsThing: {}

	setItxThing: (thing) =>
		@set firstLsThing: thing

class window.SecondThingItx extends ThingItx
	defaults: () =>
		super()
		@set secondLsThing: {}

	setItxThing: (thing) =>
		@set secondLsThing: thing

class window.LsThingItxList extends Backbone.Collection
	getItxByTypeAndKind: (type, kind) ->
		@filter (itx) ->
			(not itx.get('ignored')) and (itx.get('lsType')==type) and (itx.get('lsKind')==kind)

	getOrCreateItxByTypeAndKind: (itxType, itxKind) ->
		itxs = @getItxByTypeAndKind itxType, itxKind
		itx = itxs[0] #TODO should do something smart if there are more than one
		unless itx?
			itx = new @model
				lsType: itxType
				lsKind: itxKind
				lsTypeAndKind: "#{itxType}_#{itxKind}"
			@.add itx
			itx.on 'change', =>
				@trigger('change')
		return itx

	reformatBeforeSaving: ->
		@each((model) ->
			console.log model
			model.reformatBeforeSaving()
		)

class window.FirstLsThingItxList extends LsThingItxList
	model: FirstThingItx

class window.SecondLsThingItxList extends LsThingItxList
	model: SecondThingItx