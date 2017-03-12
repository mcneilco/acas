class window.Container extends Backbone.Model
	lsProperties: {}
	className: "Container"

	defaults: () =>
#attrs =
		@set lsType: "container"
		@set lsKind: "container"
		#		@set lsKind: this.className #TODO figure out instance classname and replace --- here's a hack that does it-ish
		@set corpName: ""
		@set recordedBy: window.AppLaunchParams.loginUser.username
		@set recordedDate: new Date().getTime()
		@set shortDescription: " "
		@set lsLabels: new LabelList()
		@set lsStates: new StateList()
#		@set firstLsThings: new FirstLsThingItxList()
#		@set secondLsThings: new SecondLsThingItxList()

	initialize: ->
		@.set @parse(@.attributes)

	parse: (resp) =>
		if resp?
			if resp == 'not unique lsContainer name'
				@createDefaultLabels()
				@createDefaultStates()
				@trigger 'saveFailed'
				return
			else
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
				@.set resp
				@createDefaultLabels()
				@createDefaultStates()
#				@createDefaultFirstLsThingItx()
#				@createDefaultSecondLsThingItx()
		else
			@createDefaultLabels()
			@createDefaultStates()
#			@createDefaultFirstLsThingItx()
#			@createDefaultSecondLsThingItx()
		resp

	prepareToSave: ->
		rBy = @get('recordedBy')
		rDate = new Date().getTime()
		@set recordedDate: rDate
		@set modifiedDate: rDate
		@get('lsLabels').each (lab) =>
			if (lab.get('ignored') || lab.get('labelText')=="") && lab.isNew()
				@get('lsLabels').remove lab
			else
				@setRByAndRDate lab
		@get('lsStates').each (state) =>
			@setRByAndRDate state
			state.get('lsValues').each (val) =>
				@setRByAndRDate val

	setRByAndRDate: (data) ->
		if @isNew() and @has('recordedBy')
			rBy = @get('recordedBy')
		else
			rBy = window.AppLaunchParams.loginUser.username
		if data.isNew()
			rDate = new Date().getTime()
			unless data.get('recordedBy') != ""
				data.set recordedBy: rBy
			unless data.get('recordedDate') != null
				data.set recordedDate: rDate

	createDefaultLabels: =>
# loop over defaultLabels
# getorCreateLabel
# add key as attribute of model
		if @lsProperties.defaultLabels?
			for dLabel in @lsProperties.defaultLabels
				newLabel = @get('lsLabels').getOrCreateLabelByTypeAndKind dLabel.type, dLabel.kind
				@listenTo newLabel, 'createNewLabel', @createNewLabel
				@set dLabel.key, newLabel
				#			if newLabel.get('preferred') is undefined
				newLabel.set preferred: dLabel.preferred

	createNewLabel: (lKind, newText) =>
		dLabel = _.where(@lsProperties.defaultLabels, {key: lKind})[0]
		oldLabel = @get(lKind)
		@unset(lKind)
		newLabel = @get('lsLabels').getOrCreateLabelByTypeAndKind dLabel.type, dLabel.kind
		newLabel.set
			labelText: newText
			preferred: oldLabel.get 'preferred'
		@set lKind, newLabel


	createDefaultStates: =>
		if @lsProperties.defaultValues?
			for dValue in @lsProperties.defaultValues
#Adding the new state and value to @
				newValue = @get('lsStates').getOrCreateValueByTypeAndKind dValue.stateType, dValue.stateKind, dValue.type, dValue.kind
				@listenTo newValue, 'createNewValue', @createNewValue
				#setting unitType and unitKind in the state, if units are given
				if dValue.unitKind? and newValue.get('unitKind') is undefined
					newValue.set unitKind: dValue.unitKind
				if dValue.unitType? and newValue.get('unitType') is undefined
					newValue.set unitType: dValue.unitType
				if dValue.codeKind? and newValue.get('codeKind') is undefined
					newValue.set codeKind: dValue.codeKind
				if dValue.codeType? and newValue.get('codeType') is undefined
					newValue.set codeType: dValue.codeType
				if dValue.codeOrigin? and newValue.get('codeOrigin') is undefined
					newValue.set codeOrigin: dValue.codeOrigin

				#Setting dValue.key attribute in @ to point to the newValue
				@set dValue.key, newValue

				if dValue.value? and (newValue.get(dValue.type) is undefined)
					newValue.set dValue.type, dValue.value
				#setting top level model attribute's value to equal valueType's value
				# (ie set "value" to equal value in "stringValue")
				@get(dValue.key).set("value", newValue.get(dValue.type))

	createNewValue: (vKind, newVal) =>
		valInfo = _.where(@lsProperties.defaultValues, {key: vKind})[0]
		@unset(vKind)
		newValue = @get('lsStates').getOrCreateValueByTypeAndKind valInfo['stateType'], valInfo['stateKind'], valInfo['type'], valInfo['kind']
		newValue.set valInfo['type'], newVal
		newValue.set
			unitKind: valInfo['unitKind']
			unitType: valInfo['unitType']
			codeKind: valInfo['codeKind']
			codeType: valInfo['codeType']
			codeOrigin: valInfo['codeOrigin']
			value: newVal
		@set vKind, newValue

	createDefaultFirstLsThingItx: =>
# loop over defaultFirstLsThingItx
# add key as attribute of model
		if @lsProperties.defaultFirstLsThingItx?
			for itx in @lsProperties.defaultFirstLsThingItx
				thingItx = @get('firstLsThings').getItxByTypeAndKind itx.itxType, itx.itxKind
				unless thingItx?
					thingItx = @get('firstLsThings').createItxByTypeAndKind itx.itxType, itx.itxKind
				@set itx.key, thingItx

	createDefaultSecondLsThingItx: =>
# loop over defaultSecondLsThingItx
# add key as attribute of model
		if @lsProperties.defaultSecondLsThingItx?
			for itx in @lsProperties.defaultSecondLsThingItx
				thingItx = @get('secondLsThings').getOrCreateItxByTypeAndKind itx.itxType, itx.itxKind
				@set itx.key, thingItx

	reformatBeforeSaving: =>
		if @lsProperties.defaultLabels?
			for dLabel in @lsProperties.defaultLabels
				@unset(dLabel.key)

#		if @lsProperties.defaultFirstLsThingItx?
#			for itx in @lsProperties.defaultFirstLsThingItx
#				@unset(itx.key)
#
#		if @get('firstLsThings')? and @get('firstLsThings') instanceof FirstLsThingItxList
#			@get('firstLsThings').reformatBeforeSaving()
#
#		if @lsProperties.defaultSecondLsThingItx?
#			for itx in @lsProperties.defaultSecondLsThingItx
#				@unset(itx.key)
#
#		if @get('secondLsThings')? and @get('secondLsThings') instanceof SecondLsThingItxList
#			@get('secondLsThings').reformatBeforeSaving()

		if @lsProperties.defaultValues?
			for dValue in @lsProperties.defaultValues
				if @get(dValue.key)?
					if @get(dValue.key).get('value') is undefined
						lsStates = @get('lsStates').getStatesByTypeAndKind dValue.stateType, dValue.stateKind
						value = lsStates[0].getValuesByTypeAndKind dValue.type, dValue.kind
						lsStates[0].get('lsValues').remove value
					@unset(dValue.key)

		if @attributes.attributes?
			delete @attributes.attributes
		if @attributes.collection?
			delete @attributes.collection
		for i of @attributes
			if _.isFunction(@attributes[i])
				delete @attributes[i]
			else if !isNaN(i)
				delete @attributes[i]

#	deleteInteractions : =>
#		delete @attributes.firstLsThings
#		delete @attributes.secondLsThings

	duplicate: =>
		copiedContainer = @.clone()
		copiedContainer.unset 'codeName'
		labels = copiedContainer.get('lsLabels')
		labels.each (label) =>
			@resetClonedAttrs label
		states = copiedContainer.get('lsStates')
		@resetStatesAndVals states
		copiedContainer.set
			version: 0
		@resetClonedAttrs(copiedContainer)
		copiedContainer.get('notebook').set value: ""
		copiedContainer.get('scientist').set value: "unassigned"
		copiedContainer.get('completion date').set value: null

#		delete copiedContainer.attributes.firstLsThings

#		secondItxs = copiedThing.get('secondLsThings')
#		secondItxs.each (itx) =>
#			@resetClonedAttrs(itx)
#			itxStates = itx.get('lsStates')
#			@resetStatesAndVals itxStates
		copiedContainer

	resetStatesAndVals: (states) =>
		states.each (st) =>
			@resetClonedAttrs(st)
			values = st.get('lsValues')
			if values?
				ignoredVals = values.filter (val) ->
					val.get('ignored')
				for val in ignoredVals
					igVal = st.getValueById(val.get('id'))[0]
					values.remove igVal
				values.each (sv) =>
					@resetClonedAttrs(sv)

	resetClonedAttrs: (clone) =>
		clone.unset 'id'
		clone.unset 'lsTransaction'
		clone.unset 'modifiedDate'
		clone.set
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
			version: 0

	getStateValueHistory: (vKind) =>
		valInfo = _.where(@lsProperties.defaultValues, {key: vKind})[0]
		@get('lsStates').getStateValueHistory valInfo['stateType'], valInfo['stateKind'], valInfo['type'], valInfo['kind']
