class window.ThingItx extends Backbone.Model
	className: "ThingItx"

	defaults: () ->
		lsType: "interaction"
		lsKind: "interaction"
		lsTypeAndKind: @_lsTypeAndKind()
		lsStates: new StateList()
		recordedBy: window.AppLaunchParams.loginUser.username
		recordedDate: new Date().getTime()

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
		delete @getItxThing().version

class window.FirstThingItx extends ThingItx
	className: "FirstThingItx"

	defaults: ->
		_(super()).extend(
			firstLsThing: {}
		)
	getItxThing: ->
		@get 'firstLsThing'

	setItxThing: (thing) ->
		@set firstLsThing: thing

class window.SecondThingItx extends ThingItx
	className: "SecondThingItx"

	defaults: ->
		_(super()).extend(
			secondLsThing: {}
		)

	getItxThing: ->
		@get 'secondLsThing'

	setItxThing: (thing) ->
		@set secondLsThing: thing

class window.LsThingItxList extends Backbone.Collection
	model: "ThingItx"
	getAllItxByTypeAndKind: (type, kind) -> #returns all itxs of given type/kind, including ignored itxs
		@filter (itx) ->
			(itx.get('lsType')==type) and (itx.get('lsKind')==kind)

	getItxByTypeAndKind: (type, kind) ->
		@filter (itx) ->
			(not itx.get('ignored')) and (itx.get('lsType')==type) and (itx.get('lsKind')==kind)

	createItxByTypeAndKind: (itxType, itxKind) ->
		itx = new @model
			lsType: itxType
			lsKind: itxKind
			lsTypeAndKind: "#{itxType}_#{itxKind}"
		@add itx
		itx.on 'change', =>
			@trigger('change')
		return itx

	getOrCreateItxByTypeAndKind: (itxType, itxKind) ->
		itx = @getItxByTypeAndKind itxType, itxKind
		if itx.length > 0
			return itx[0]
		else
			return @createItxByTypeAndKind itxType, itxKind

	getItxByItxThingTypeAndKind: (itxType, itxKind, itxThing, itxThingType, itxThingKind) ->
		#function for getting first/second lsThing by it's type and kind
		#example itxThing: firstLsThing, secondLsThing
		itxArray = @getItxByTypeAndKind(itxType, itxKind)
		itxByItxThing = _.filter itxArray, (itx) ->
			if itx.get(itxThing) instanceof Backbone.Model
				(itx.get(itxThing).get('lsType') == itxThingType) and (itx.get(itxThing).get('lsKind') == itxThingKind)
			else
				(itx.get(itxThing).lsType == itxThingType) and (itx.get(itxThing).lsKind == itxThingKind)
		return itxByItxThing

	getOrderedItxList: (type, kind) ->
		itxs = @getItxByTypeAndKind(type, kind)
		orderedItx = []
		i = 1
		while i <= itxs.length+1
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
