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
		@set firstLsThings: new FirstLsThingItxList()
		@set secondLsThings: new SecondLsThingItxList()

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

				if resp.firstLsThings?
					if resp.firstLsThings not instanceof FirstLsThingItxList
						resp.firstLsThings = new FirstLsThingItxList(resp.firstLsThings)
					resp.firstLsThings.on 'change', =>
						@trigger 'change'
				if resp.secondLsThings?
					if resp.secondLsThings not instanceof SecondLsThingItxList
						resp.secondLsThings = new SecondLsThingItxList(resp.secondLsThings)
					resp.secondLsThings.on 'change', =>
						@trigger 'change'
				if resp.lsTags?
					if resp.lsTags not instanceof TagList
						resp.lsTags = new TagList(resp.lsTags)
					resp.lsTags.on 'change', =>
						@trigger 'change'
				@.set resp
				@createDefaultLabels()
				@createDefaultStates()
				@createDefaultFirstLsThingItx()
				@createDefaultSecondLsThingItx()
		else
			@createDefaultLabels()
			@createDefaultStates()
			@createDefaultFirstLsThingItx()
			@createDefaultSecondLsThingItx()
		resp

	createDefaultLabels: =>
		# loop over defaultLabels
		# getorCreateLabel
		# add key as attribute of model
		if @lsProperties.defaultLabels?
			for dLabel in @lsProperties.defaultLabels
				newLabel = @get('lsLabels').getOrCreateLabelByTypeAndKind dLabel.type, dLabel.kind
				@set dLabel.key, newLabel
				#			if newLabel.get('preferred') is undefined
				newLabel.set preferred: dLabel.preferred


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
				@get(dValue.kind).set("value", newValue.get(dValue.type))

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

	getAnalyticalFiles: (fileTypes) => #TODO: rename from analytical files to attachFiles or something more generic
		#get list of possible kinds of analytical files
		attachFileList = new AttachFileList()
		for type in fileTypes
			analyticalFileState = @get('lsStates').getOrCreateStateByTypeAndKind "metadata", @get('lsKind')+" batch"
			analyticalFileValues = analyticalFileState.getValuesByTypeAndKind "fileValue", type.code
			if analyticalFileValues.length > 0 and type.code != "unassigned"
				#create new attach file model with fileType set to lsKind and fileValue set to fileValue
				#add new afm to attach file list
				for file in analyticalFileValues
					unless file.get('ignored')
						afm = new AttachFile
							fileType: type.code
							fileValue: file.get('fileValue')
							id: file.get('id')
							comments: file.get('comments')
						attachFileList.add afm

		attachFileList

	reformatBeforeSaving: =>
		if @lsProperties.defaultLabels?
			for dLabel in @lsProperties.defaultLabels
				@unset(dLabel.key)

		if @lsProperties.defaultFirstLsThingItx?
			for itx in @lsProperties.defaultFirstLsThingItx
				@unset(itx.key)

		if @get('firstLsThings')? and @get('firstLsThings') instanceof FirstLsThingItxList
			@get('firstLsThings').reformatBeforeSaving()

		if @lsProperties.defaultSecondLsThingItx?
			for itx in @lsProperties.defaultSecondLsThingItx
				@unset(itx.key)

		if @get('secondLsThings')? and @get('secondLsThings') instanceof SecondLsThingItxList
			@get('secondLsThings').reformatBeforeSaving()

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
		for i of @attributes
			if _.isFunction(@attributes[i])
				delete @attributes[i]
			else if !isNaN(i)
				delete @attributes[i]

	deleteInteractions : =>
		delete @attributes.firstLsThings
		delete @attributes.secondLsThings

	duplicate: =>
		copiedThing = @.clone()
		copiedThing.unset 'codeName'
		labels = copiedThing.get('lsLabels')
		labels.each (label) =>
			@resetClonedAttrs label
		states = copiedThing.get('lsStates')
		@resetStatesAndVals states
		copiedThing.set
			version: 0
		@resetClonedAttrs(copiedThing)
		copiedThing.get('notebook').set value: ""
		copiedThing.get('scientist').set value: "unassigned"
		copiedThing.get('completion date').set value: null

		delete copiedThing.attributes.firstLsThings

		secondItxs = copiedThing.get('secondLsThings')
		secondItxs.each (itx) =>
			@resetClonedAttrs(itx)
			itxStates = itx.get('lsStates')
			@resetStatesAndVals itxStates
		copiedThing

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


#class window.DocumentModel extends Thing
#	urlRoot:"/api/things/legalDocument/MTA"
#	className: "DocumentManagerTermType"
#	initialize: ->
#		@.set
#			lsType: "legalDocument"
#			lsKind: "MTA"
#		super()
#
#	lsProperties:
#		defaultLabels: [
#			key: 'document name'
#			type: 'name'
#			kind: 'document name'
#			preferred: true
##			labelText: "" #gets created when createDefaultLabels is called
#		]
#		defaultValues: [
#			key: 'document file'
#			stateType: 'metadata'
#			stateKind: 'documentMetadata'
#			type: 'fileValue'
#			kind: 'document file'
#		,
#			key: 'owner'
#			stateType: 'metadata'
#			stateKind: 'legalDocument metadata'
#			type: 'stringValue'
#			kind: 'owner'
#		,
#			key: 'amount'
#			stateType: 'metadata'
#			stateKind: 'documentMetadata'
#			type: 'numberValue'
#			kind: 'amount'
#		,
#			key: 'active'
#			stateType: 'metadata'
#			stateKind: 'documentMetadata'
#			type: 'stringValue'
#			kind: 'active'
#		,
#			key: 'restricted material name'
#			stateType: 'array'
#			stateKind: 'restricted materials'
#			type: 'stringValue'
#			kind: 'restricted material name'
#		]
#		defaultFirstLsThingItx: [
#
#		]
#		defaultSecondLsThingItx: [
#			key: 'contactInteraction'
#			itxType: 'incorporates'
#			itxKind: 'document_contact'
#		,
#			key: 'termInteraction'
#			itxType: 'incorporates'
#			itxKind: 'document_term'
#		,
#			key: 'projectInteraction'
#			itxType: 'incorporates'
#			itxKind: 'document_project'
#		]
#
#
#	validate: (attrs) ->
#		console.log "attrs"
#		console.log attrs
#		errors = []
#		if attrs["document name"]?
#			documentTitle = attrs["document name"].get('labelText')
#			if documentTitle is "" or documentTitle is undefined
#				errors.push
#					attribute: 'documentTitle'
#					message: "Title must be set"
#		if attrs.documentType?
#			documentType = attrs.documentType.get('value')
#			if documentType is "unassigned" or documentType is undefined
#				errors.push
#					attribute: 'documentType'
#					message: "Type must be set"
#		if attrs.documentOwner?
#			documentOwner = attrs.documentOwner.get('value')
#			if documentOwner is "unassigned" or documentOwner is undefined
#				errors.push
#					attribute: 'documentOwner'
#					message: "Owner must be set"
#		if attrs.documentProject?
#			documentProject = attrs.documentProject.get('value')
#			if documentProject is "unassigned" or documentProject is undefined
#				errors.push
#					attribute: 'documentProject'
#					message: "Type must be set"
#		if attrs.documentAmount?
#			documentAmount = attrs.documentAmount.get('value')
#			if documentAmount is "" or documentAmount is undefined
#				errors.push
#					attribute: 'documentAmount'
#					message: "Amount must be set"
#		if attrs.documentContact?
#			documentContact = attrs.documentContact.get('value')
#			if documentContact is "unassigned" or documentContact is undefined
#				errors.push
#					attribute: 'documentContact'
#					message: "Contact must be set"
#
#		if errors.length > 0
#			return errors
#		else
#			return null
#
#	prepareToSave: ->
#		rBy = @get('recordedBy')
#		rDate = new Date().getTime()
#		@set recordedDate: rDate
#		@get('lsStates').each (state) ->
#			unless state.get('recordedBy') != ""
#				state.set recordedBy: rBy
#			unless state.get('recordedDate') != null
#				state.set recordedDate: rDate
#			state.get('lsValues').each (val) ->
#				unless val.get('recordedBy') != ""
#					val.set recordedBy: rBy
#				unless val.get('recordedDate') != null
#					val.set recordedDate: rDate
#
#		@get('lsLabels').each (label) ->
#			unless label.get('recordedBy') != ""
#				label.set recordedBy: rBy
#			unless label.get('recordedDate') != null
#				label.set recordedDate: rDate
#
#		delete @attributes._changing
#		delete @attributes._previousAttributes
#		delete @attributes.cid
#		delete @attributes.changed
#		delete @attributes._pending
#		delete @attributes.lsProperties
#		delete @attributes.urlRoot
#		delete @attributes.className
#		delete @attributes.validationError
#		delete @attributes.idAttribute