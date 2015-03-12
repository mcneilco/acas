class window.Thing extends Backbone.Model
	lsProperties: {}
	className: "Thing"
#	urlRoot: "/api/things"

	defaults: () =>
		#attrs =
		@set lsType: "thing"
		@set lsKind: "thing"
#		@set lsKind: this.className #TODO figure out instance classname and replace --- here's a hack that does it-ish
		@set corpName: ""
		@set recordedBy: window.AppLaunchParams.loginUser.username
		@set recordedDate: new Date().getTime()
		@set shortDescription: " "
		@set lsLabels: new LabelList()
		@set lsStates: new StateList()


	initialize: ->
		@.set @parse(@.attributes)

	parse: (resp) =>
		if resp?
			if resp == 'not unique lsThing name'
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

				resp

	createDefaultLabels: =>
		# loop over defaultLabels
		# getorCreateLabel
		# add key as attribute of model
		for dLabel in @lsProperties.defaultLabels
			newLabel = @get('lsLabels').getOrCreateLabelByTypeAndKind dLabel.type, dLabel.kind
			@set dLabel.key, newLabel
#			if newLabel.get('preferred') is undefined
			newLabel.set preferred: dLabel.preferred


	createDefaultStates: =>
		for dValue in @lsProperties.defaultValues
			#Adding the new state and value to @
			newValue = @get('lsStates').getOrCreateValueByTypeAndKind dValue.stateType, dValue.stateKind, dValue.type, dValue.kind

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
			@get(dValue.kind).set("value", newValue.get(dValue.type))


	getAnalyticalFiles: (fileTypes) =>
		#get list of possible kinds of analytical files
		attachFileList = new AttachFileList()
		for type in fileTypes
			analyticalFileState = @get('lsStates').getOrCreateStateByTypeAndKind "metadata", @get('lsKind')+" batch"
			analyticalFileValues = analyticalFileState.getValuesByTypeAndKind "fileValue", type.code
			if analyticalFileValues.length > 0 and type.code != "unassigned"
				#create new attach file model with fileType set to lsKind and fileValue set to fileValue
				#add new afm to attach file list
				for file in analyticalFileValues
					if file.get('ignored') is false
						afm = new AttachFile
							fileType: type.code
							fileValue: file.get('fileValue')
							id: file.get('id')
							comments: file.get('comments')
						attachFileList.add afm

		attachFileList


	reformatBeforeSaving: =>
		for dLabel in @lsProperties.defaultLabels
			@unset(dLabel.key)

		for dValue in @lsProperties.defaultValues
			if @get(dValue.key)?
				if @get(dValue.key).get('value') is undefined
					lsStates = @get('lsStates').getStatesByTypeAndKind dValue.stateType, dValue.stateKind
					value = lsStates[0].getValuesByTypeAndKind dValue.type, dValue.kind
					lsStates[0].get('lsValues').remove value
				@unset(dValue.key)
		if @attributes.attributes?
			delete @attributes.attributes
		for i of @attributes
			if _.isFunction(@attributes[i])
				delete @attributes[i]
			else if !isNaN(i)
				delete @attributes[i]

	duplicate: =>
		copiedThing = @.clone()
#		copiedThing.unset 'lsLabels'
		copiedThing.unset 'lsStates'
		copiedThing.unset 'id'
		copiedThing.unset 'codeName'
		copiedStates = new StateList()
		origStates = @get('lsStates')
		origStates.each (st) ->
			copiedState = new State(_.clone(st.attributes))
			copiedState.unset 'id'
			copiedState.unset 'lsTransactions'
			copiedState.unset 'lsValues'
			copiedValues = new ValueList()
			origValues = st.get('lsValues')
			origValues.each (sv) ->
				copiedVal = new Value(sv.attributes)
				copiedVal.unset 'id'
				copiedVal.unset 'lsTransaction'
				copiedValues.add(copiedVal)
			copiedState.set lsValues: copiedValues
			copiedStates.add(copiedState)
		copiedThing.set
#			lsLabels: new LabelList()
			lsStates: copiedStates
			recordedBy: window.AppLaunchParams.loginUser.username
			recordedDate: new Date().getTime()
			version: 0
		copiedThing.get('notebook').set value: ""
		copiedThing.get('scientist').set value: "unassigned"
		copiedThing.get('completion date').set value: null
		copiedThing.createDefaultLabels()

		copiedThing
