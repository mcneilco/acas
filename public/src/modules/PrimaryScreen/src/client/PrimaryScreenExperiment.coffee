
class window.PrimaryAnalysisRead extends Backbone.Model
	defaults:
		readNumber: 1
		readPosition: ""
		readName: "unassigned"
		activity: false

	validate: (attrs) =>
		errors = []
		# Possible issue: this lets letters following the numbers pass, like "12341a"
		readPositionIsNumeric = not _.isNaN(parseInt(attrs.readPosition)) or not _.isNaN(parseInt(attrs.readPosition.slice(1)))
		if (not readPositionIsNumeric or attrs.readPosition is "" or attrs.readPosition is null or attrs.readPosition is undefined) and attrs.readName.slice(0,5) != "Calc:"
			errors.push
				attribute: 'readPosition'
				message: "Read position must be a number"
		if attrs.readName is "unassigned" or attrs.readName is ""
			errors.push
				attribute: 'readName'
				message: "Read name must be assigned"
		if errors.length > 0
			return errors
		else
			return null

class window.PrimaryAnalysisTimeWindow extends Backbone.Model
	defaults:
		position: 1
		statistic: "max"
		windowStart: ""
		windowEnd: ""
		unit: "s"

	validate: (attrs) =>
		errors = []
		ws = attrs.windowStart
		if _.isNaN(ws) or ws is "" or ws is null or ws is undefined or isNaN(ws)
			errors.push
				attribute: 'timeWindowStart'
				message: "Window Start must be a number"
		we = attrs.windowEnd
		if _.isNaN(we) or we is "" or we is null or we is undefined or isNaN(we)
			errors.push
				attribute: 'timeWindowEnd'
				message: "Window End must be a number"
		if errors.length > 0
			return errors
		else
			return null

class window.StandardCompound extends Backbone.Model
	defaults:
		standardNumber: 1
		batchCode: ""
		concentration: ""
		concentrationUnits: "uM"
		standardType: ""

	validate: (attrs) =>
		errors = []
		batchCode = attrs.batchCode
		if batchCode is "" or batchCode is undefined or batchCode is "invalid" or batchCode is null
			errors.push
				attribute: 'batchCode'
				message: "A registered batch number must be provided."
		# concentration is allowed to be "" for vehicle controls
		conc = attrs.concentration
		if _.isNaN(conc) or conc is null or conc is undefined or isNaN(conc)
			errors.push
				attribute: 'concentration'
				message: "Concentration must be a number"
		st = attrs.standardType
		if st is "" or st is null or st is undefined
			errors.push
				attribute: 'standardType'
				message: "Standard Type must be selected"
		if errors.length > 0
			return errors
		else
			return null

class window.Additive extends Backbone.Model
	defaults:
		additiveNumber: 1
		batchCode: ""
		concentration: ""
		concentrationUnits: "uM"
		additiveType: ""
	validate: (attrs) =>
		errors = []
		# Add later: batch code validation? or not?
		addType = attrs.additiveType
		if addType is "" or addType is null or addType is undefined
			errors.push
				attribute: 'additiveType'
				message: "Additive Type must be selected"
		if errors.length > 0
			return errors
		else
			return null


class window.ControlSetting extends Backbone.Model
	defaults:
		standardNumber: "1"
		defaultValue: ""

	validate: (attrs) =>
		errors = []
		if attrs.standardNumber is "unassigned" or attrs.standardNumber is null
			errors.push
				attribute: 'standardNumber'
				message: "Standard must be assigned"
		if _.isNaN(attrs.defaultValue)
			errors.push
				attribute: 'defaultValue'
				message: 'Default value must be a number'
		if attrs.defaultValue is "" and attrs.standardNumber is 'input value'
			errors.push
				attribute: 'defaultValue'
				message: 'Default value must be defined'
		if errors.length > 0
			return errors
		else
			return null

class window.TransformationRule extends Backbone.Model
	defaults:
		transformationRule: "unassigned"

	validate: (attrs) =>
		errors = []
		if attrs.transformationRule is "unassigned" or attrs.transformationRule is null
			errors.push
				attribute: 'transformationRule'
				message: "Transformation Rule must be assigned"

		if errors.length > 0
			return errors
		else
			return null

class window.Normalization extends Backbone.Model
	defaults:
		normalizationRule: "unassigned"
		positiveControl: new ControlSetting()
		negativeControl: new ControlSetting()

	initialize: ->
		@.set @parse(@.attributes)

	parse: (resp) =>
		if resp.positiveControl?
			if resp.positiveControl not instanceof ControlSetting
				resp.positiveControl = new ControlSetting(resp.positiveControl)
			resp.positiveControl.on 'change', =>
				@trigger 'change'
			resp.positiveControl.on 'amDirty', =>
				@trigger 'amDirty'
		if resp.negativeControl?
			if resp.negativeControl not instanceof ControlSetting
				resp.negativeControl = new ControlSetting(resp.negativeControl)
			resp.negativeControl.on 'change', =>
				@trigger 'change'
			resp.negativeControl.on 'amDirty', =>
				@trigger 'amDirty'

	validate: (attrs) =>
		errors = []
		if attrs.normalizationRule is "unassigned" or attrs.normalizationRule is null
			errors.push
				attribute: 'normalizationRule'
				message: "Normalization Rule must be assigned"
		if errors.length > 0
			return errors
		else
			return null

class window.PrimaryAnalysisReadList extends Backbone.Collection
	model: PrimaryAnalysisRead

	validateCollection: (matchReadName) =>
		modelErrors = []
		usedReadNames = {}
		if @.length != 0
			for index in [0..@.length-1]
				model = @.at(index)
				indivModelErrors = model.validate(model.attributes) # note: can't call model.isValid() because if invalid, the function will trigger validationError, which adds the class "error" to the invalid attributes
				if indivModelErrors != null
					for error in indivModelErrors
						unless (matchReadName and error.attribute == 'readPosition')
							modelErrors.push
								attribute: error.attribute+':eq('+index+')'
								message: error.message
				currentReadName = model.get('readName')
				if currentReadName of usedReadNames
					modelErrors.push
						attribute: 'readName:eq('+index+')'
						message: "Read name can not be chosen more than once"
					modelErrors.push
						attribute: 'readName:eq('+usedReadNames[currentReadName]+')'
						message: "Read name can not be chosen more than once"
				else
					usedReadNames[currentReadName] = index
		return modelErrors

class window.PrimaryAnalysisTimeWindowList extends Backbone.Collection
	model: PrimaryAnalysisTimeWindow

	validateCollection: =>
		modelErrors = []
		@each (model, index) ->
			# note: can't call model.isValid() because if invalid, the function will trigger validationError,
			# which adds the class "error" to the invalid attributes
			indivModelErrors = model.validate(model.attributes)
			if indivModelErrors?
				for error in indivModelErrors
					unless (matchReadName and error.attribute == 'readPosition')
						modelErrors.push
							attribute: error.attribute+':eq('+index+')'
							message: error.message
		return modelErrors

class window.StandardCompoundList extends Backbone.Collection
	model: StandardCompound

	validateCollection: =>
		modelErrors = []
		@each (model, index) =>
			# note: can't call model.isValid() because if invalid, the function will trigger validationError,
			# which adds the class "error" to the invalid attributes
			indivModelErrors = model.validate(model.attributes)
			if indivModelErrors?
				for error in indivModelErrors
					modelErrors.push
						attribute: error.attribute+':eq('+index+')'
						message: error.message
		return modelErrors

class window.AdditiveList extends Backbone.Collection
	model: Additive

	validateCollection: =>
		modelErrors = []
		@each (model, index) =>
# note: can't call model.isValid() because if invalid, the function will trigger validationError,
# which adds the class "error" to the invalid attributes
			indivModelErrors = model.validate(model.attributes)
			if indivModelErrors?
				for error in indivModelErrors
					modelErrors.push
						attribute: error.attribute+':eq('+index+')'
						message: error.message
		return modelErrors

class window.TransformationRuleList extends Backbone.Collection
	model: TransformationRule


	validateCollection: =>
		modelErrors = []
		usedRules ={}
		if @.length != 0
			for index in [0..@.length-1]
				model = @.at(index)
				indivModelErrors = model.validate(model.attributes)
				if indivModelErrors != null
					for error in indivModelErrors
						modelErrors.push
							attribute: error.attribute+':eq('+index+')'
							message: error.message
				currentRule = model.get('transformationRule')
				if currentRule of usedRules
					modelErrors.push
						attribute: 'transformationRule:eq('+index+')'
						message: "Transformation Rules can not be chosen more than once"
					modelErrors.push
						attribute: 'transformationRule:eq('+usedRules[currentRule]+')'
						message: "Transformation Rules can not be chosen more than once"
				else
					usedRules[currentRule] = index
		modelErrors


class window.PrimaryScreenAnalysisParameters extends Backbone.Model
	defaults: ->
		instrumentReader: "unassigned"
		signalDirectionRule: "unassigned"
		aggregateBy: "unassigned"
		aggregationMethod: "unassigned"
		normalization: new Normalization()
		assayVolume: null
		transferVolume: null
		dilutionFactor: null
		hitEfficacyThreshold: null
		hitSDThreshold: null
		thresholdType: null
		volumeType: "dilution"
		htsFormat: true
		autoHitSelection: false
		matchReadName: false
		fluorescentStart: null
		fluorescentEnd: null
		fluorescentStep: null
		latePeakTime: null
		primaryAnalysisReadList: new PrimaryAnalysisReadList()
		transformationRuleList: new TransformationRuleList()
		primaryAnalysisTimeWindowList: new PrimaryAnalysisTimeWindowList()
		standardCompoundList: new StandardCompoundList()
		additiveList: new AdditiveList()


	initialize: ->
		@.set @parse(@.attributes)

	parse: (resp) =>
		if resp.primaryAnalysisReadList?
			if resp.primaryAnalysisReadList not instanceof PrimaryAnalysisReadList
				resp.primaryAnalysisReadList = new PrimaryAnalysisReadList(resp.primaryAnalysisReadList)
			resp.primaryAnalysisReadList.on 'change', =>
				@trigger 'change'
			resp.primaryAnalysisReadList.on 'amDirty', =>
				@trigger 'amDirty'
		if resp.primaryAnalysisTimeWindowList?
			if resp.primaryAnalysisTimeWindowList not instanceof PrimaryAnalysisTimeWindowList
				resp.primaryAnalysisTimeWindowList = new PrimaryAnalysisTimeWindowList(resp.primaryAnalysisTimeWindowList)
			resp.primaryAnalysisTimeWindowList.on 'change', =>
				@trigger 'change'
			resp.primaryAnalysisTimeWindowList.on 'amDirty', =>
				@trigger 'amDirty'
		if resp.transformationRuleList?
			if resp.transformationRuleList not instanceof TransformationRuleList
				resp.transformationRuleList = new TransformationRuleList(resp.transformationRuleList)
			resp.transformationRuleList.on 'change', =>
				@trigger 'change'
			resp.transformationRuleList.on 'amDirty', =>
				@trigger 'amDirty'
		if resp.standardCompoundList?
			if resp.standardCompoundList not instanceof StandardCompoundList
				resp.standardCompoundList = new StandardCompoundList(resp.standardCompoundList)
			resp.standardCompoundList.on 'change', =>
				@trigger 'change'
			resp.standardCompoundList.on 'amDirty', =>
				@trigger 'amDirty'
		if resp.additiveList?
			if resp.additiveList not instanceof AdditiveList
				resp.additiveList = new AdditiveList(resp.additiveList)
			resp.additiveList.on 'change', =>
				@trigger 'change'
			resp.additiveList.on 'amDirty', =>
				@trigger 'amDirty'
		if resp.normalization?
			if resp.normalization not instanceof Normalization
				resp.normalization = new Normalization(resp.normalization)
			resp.normalization.on 'change', =>
				@trigger 'change'
			resp.normalization.on 'amDirty', =>
				@trigger 'amDirty'
		resp

	validate: (attrs) =>
		errors = []
		readErrors = @get('primaryAnalysisReadList').validateCollection(attrs.matchReadName)
		errors.push readErrors...
		timeWindowErrors = @get('primaryAnalysisTimeWindowList').validateCollection()
		errors.push timeWindowErrors...
		transformationErrors = @get('transformationRuleList').validateCollection()
		errors.push transformationErrors...
		standardCompoundErrors = @get('standardCompoundList').validateCollection()
		errors.push standardCompoundErrors...
		additiveErrors = @get('additiveList').validateCollection()
		errors.push additiveErrors...
		if attrs.instrumentReader is "unassigned" or attrs.instrumentReader is null
			errors.push
				attribute: 'instrumentReader'
				message: "Instrument Reader must be assigned"
		if attrs.signalDirectionRule is "unassigned" or attrs.signalDirectionRule is null
			errors.push
				attribute: 'signalDirectionRule'
				message: "Signal Direction Rule must be assigned"
		if attrs.aggregateBy is "unassigned" or attrs.aggregateBy is null
			errors.push
				attribute: 'aggregateBy'
				message: "Aggregate By must be assigned"
		if attrs.aggregationMethod is "unassigned" or attrs.aggregationMethod is null
			errors.push
				attribute: 'aggregationMethod'
				message: "Aggregation method must be assigned"
		if not attrs.normalization? or attrs.normalization.get('normalizationRule') is "unassigned"
			errors.push
				attribute: 'normalizationRule'
				message: "Normalization rule must be assigned"
		if attrs.autoHitSelection
			if attrs.thresholdType == "sd" && _.isNaN(attrs.hitSDThreshold)
				errors.push
					attribute: 'hitSDThreshold'
					message: "SD threshold must be a number"
			if attrs.thresholdType == "efficacy" && _.isNaN(attrs.hitEfficacyThreshold)
				errors.push
					attribute: 'hitEfficacyThreshold'
					message: "Efficacy threshold must be a number"
		if _.isNaN(attrs.assayVolume)
			errors.push
				attribute: 'assayVolume'
				message: "Assay volume must be a number"
		if (attrs.assayVolume == "" or attrs.assayVolume == null) and (attrs.transferVolume != "" and attrs.transferVolume != null)
			errors.push
				attribute: 'assayVolume'
				message: "Assay volume must be assigned"
		if attrs.volumeType == "dilution" && _.isNaN(attrs.dilutionFactor)
			errors.push
				attribute: 'dilutionFactor'
				message: "Dilution factor must be a number"
		if attrs.volumeType == "transfer" and _.isNaN(attrs.transferVolume)
			errors.push
				attribute: 'transferVolume'
				message: "Transfer volume must be a number"
		if _.isNaN(attrs.fluorescentStart)
			errors.push
				attribute: 'fluorescentStart'
				message: "Fluorescent Start must be a number"
		if _.isNaN(attrs.fluorescentEnd)
			errors.push
				attribute: 'fluorescentEnd'
				message: "Fluorescent End must be a number"
		if _.isNaN(attrs.fluorescentStep)
			errors.push
				attribute: 'fluorescentStep'
				message: "Fluorescent Step must be a number"
		if _.isNaN(attrs.latePeakTime)
			errors.push
				attribute: 'latePeakTime'
				message: "Late Peak Time must be a number"
		if errors.length > 0
			return errors
		else
			return null

	autocalculateVolumes: ->
		dilutionFactor = @.get('dilutionFactor')
		transferVolume = @.get('transferVolume')
		assayVolume = @.get('assayVolume')
		if @.get('volumeType')=='dilution'
			if isNaN(dilutionFactor) or dilutionFactor=="" or dilutionFactor == 0 or isNaN(assayVolume) or assayVolume==""
				transferVolume = ""
			else
				transferVolume = assayVolume/dilutionFactor
			@.set transferVolume: transferVolume
			return transferVolume
		else
			if isNaN(transferVolume) or transferVolume=="" or transferVolume == 0 or isNaN(assayVolume) or assayVolume==""
				dilutionFactor = ""
			else
				dilutionFactor = assayVolume/transferVolume
			@.set dilutionFactor: dilutionFactor
			return dilutionFactor


class window.PrimaryScreenExperiment extends Experiment

	initialize: ->
		super()
		@.set lsType: "Biology"
		@.set lsKind: "Bio Activity"

	getDryRunStatus: ->
		status = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "codeValue", "dry run status"
		if !status.has('codeValue')
			status.set codeValue: "not started"
			status.set codeType: "dry run"
			status.set codeKind: "status"
			status.set codeOrigin: "ACAS DDICT"

		status

	getDryRunResultHTML: ->
		result = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "dry run result html"
		if !result.has('clobValue')
			result.set clobValue: ""

		result


	getAnalysisResultHTML: ->
		result = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "analysis result html"
		if !result.has('clobValue')
			result.set clobValue: ""

		result

	getModelFitStatus: ->
		status = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "codeValue", "model fit status"
		if !status.has('codeValue')
			status.set codeValue: "not started"

		status

	getModelFitResultHTML: ->
		result = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "clobValue", "model fit result html"
		if !result.has('clobValue')
			result.set clobValue: ""

		result

	getModelFitType: ->
		type = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment metadata", "codeValue", "model fit type"
		if !type.has('codeValue')
			type.set codeValue: "unassigned"
			type.set codeType: "model fit"
			type.set codeKind: "type"
			type.set codeOrigin: "ACAS DDICT"

		type

#	copyProtocolAttributes: (protocol) =>
#		modelFitStatus = @getModelFitStatus().get('codeValue')
#		super(protocol)
#		@getModelFitStatus().set codeValue: modelFitStatus

class window.PrimaryAnalysisTimeWindowController extends AbstractFormController
	template: _.template($("#PrimaryAnalysisTimeWindowView").html())
	tagName: "div"
	className: "form-inline"
	events:
		"keyup .bv_timeWindowStart": "attributeChanged"
		"keyup .bv_timeWindowEnd": "attributeChanged"
		"change .bv_timeStatistic": "attributeChanged"
		"click .bv_delete": "clear"

	initialize: ->
		@errorOwnerName = 'PrimaryAnalysisTimeWindowController'
		@setBindings()
		@model.on "destroy", @remove, @

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@$('.bv_timePosition').html('T'+@model.get('position'))
		@setUpStatisticSelect()
		@

	setUpStatisticSelect: ->
		@timeStatisticList = new PickListList()
		@timeStatisticList.url = "/api/codetables/analysis parameter/statistic"
		@timeStatisticListController = new PickListSelectController
			el: @$('.bv_timeStatistic')
			collection: @timeStatisticList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Statistic"
			selectedCode: @model.get('statistic')


	updateModel: =>
		@model.set
			windowStart: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_timeWindowStart'))
			windowEnd: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_timeWindowEnd'))
			statistic: @timeStatisticListController.getSelectedCode()
		@trigger 'updateState'

	clear: =>
		@model.destroy()
		@attributeChanged()

class window.StandardCompoundController extends AbstractFormController
	template: _.template($("#StandardCompoundView").html())
	tagName: "div"
	className: "form-inline"
	events:
		"keyup .bv_batchCode": "handleBatchChanged"
		"keyup .bv_concentration": "attributeChanged"
		"change .bv_standardType": "attributeChanged"
		"click .bv_delete": "clear"

	initialize: ->
		@errorOwnerName = 'StandardCompoundController'
		@setBindings()
		@model.on "destroy", @remove, @

	render: =>
		$(@el).empty()

		$(@el).html @template(@model.attributes)
		@$('.bv_standardNumber').html('S'+@model.get('standardNumber'))
		@setUpStandardTypeSelect()
		@

	setUpStandardTypeSelect: ->
		@standardTypeList = new PickListList()
		@standardTypeList.url = "/api/codetables/analysis parameter/standard type"
		@standardTypeListController = new PickListSelectController
			el: @$('.bv_standardType')
			collection: @standardTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Standard Type"
			selectedCode: @model.get('standardType')


	updateModel: =>
		concentration = UtilityFunctions::getTrimmedInput @$('.bv_concentration')
		if concentration isnt ""
			concentration = parseFloat(concentration)
		@model.set
			concentration: concentration
			standardType: @standardTypeListController.getSelectedCode()
		@trigger 'updateState'

	clear: =>
		@model.destroy()
		@attributeChanged()

	handleBatchChanged: ->
		batchCode = UtilityFunctions::getTrimmedInput @$('.bv_batchCode')
		@getPreferredBatchId(batchCode)

	getPreferredBatchId: (batchId) ->
		if batchId == ""
			@model.set batchCode: ""
			@attributeChanged()
			return
		else
			@requestData =
				requests: [
					{requestName: batchId}
				]
			$.ajax
				type: 'POST'
				url: "/api/preferredBatchId"
				data: @requestData
				success: (json) =>
					@handlePreferredBatchIdReturn(json)
				error: (err) =>
					@serviceReturn = null
				dataType: 'json'

	handlePreferredBatchIdReturn: (json) =>
		if json.results?.length > 0
			results = (json.results)[0]
			preferredName = results.preferredName
			requestName = results.requestName
			if preferredName == requestName
				@model.set batchCode: preferredName
			else if preferredName == ""
				@model.set batchCode: "invalid"
			else
				@$('.bv_batchCode').val(preferredName)
				@model.set batchCode: preferredName
			@attributeChanged()

class window.AdditiveController extends AbstractFormController
	template: _.template($("#AdditiveView").html())
	tagName: "div"
	className: "form-inline"
	events:
		"keyup .bv_batchCode": "attributeChanged"
		"keyup .bv_concentration": "attributeChanged"
		"change .bv_additiveType": "attributeChanged"
		"click .bv_delete": "clear"

	initialize: ->
		@errorOwnerName = 'AdditiveController'
		@setBindings()
		@model.on "destroy", @remove, @

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@$('.bv_additiveNumber').html('A'+@model.get('additiveNumber'))
		@setUpAdditiveTypeSelect()
		@

	setUpAdditiveTypeSelect: ->
		@additiveTypeList = new PickListList()
		@additiveTypeList.url = "/api/codetables/analysis parameter/additive type"
		@additiveTypeListController = new PickListSelectController
			el: @$('.bv_additiveType')
			collection: @additiveTypeList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Additive Type"
			selectedCode: @model.get('additiveType')


	updateModel: =>
		@model.set
			batchCode: UtilityFunctions::getTrimmedInput @$('.bv_batchCode')
			concentration: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_concentration'))
			additiveType: @additiveTypeListController.getSelectedCode()
		@trigger 'updateState'

	clear: =>
		@model.destroy()
		@attributeChanged()

class window.PrimaryAnalysisReadController extends AbstractFormController
	template: _.template($("#PrimaryAnalysisReadView").html())
	tagName: "div"
	className: "form-inline"
	events:
		"keyup .bv_readPosition": "attributeChanged"
		"change .bv_readName": "handleReadNameChanged"
		"click .bv_activity": "handleActivityChanged"
		"click .bv_delete": "clear"

	initialize: ->
		@errorOwnerName = 'PrimaryAnalysisReadController'
		@setBindings()
		@model.on "destroy", @remove, @



	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@$('.bv_readNumber').html('R'+@model.get('readNumber'))
		@setUpReadNameSelect()
		@hideReadPosition(@model.get('readName'))

		@

	setUpReadNameSelect: ->
		@readNameList = new PickListList()
		@readNameList.url = "/api/codetables/reader data/read name"
		@readNameListController = new PickListSelectController
			el: @$('.bv_readName')
			collection: @readNameList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Read Name"
			selectedCode: @model.get('readName')

	hideReadPosition: (readName) ->
		isCalculatedRead = readName.slice(0,5) == "Calc:"
		if isCalculatedRead is true
			@$('.bv_readPosition').val('')
			@$('.bv_readPosition').hide()
			@$('.bv_readPositionHolder').show()
		else
			@$('.bv_readPosition').show()
			@$('.bv_readPositionHolder').hide()

	setUpReadPosition: (matchReadNameChecked) ->
		if matchReadNameChecked
			@$('.bv_readPosition').attr('disabled','disabled')
		else
			@$('.bv_readPosition').removeAttr('disabled')


	updateModel: =>
		@model.set
			readPosition: UtilityFunctions::getTrimmedInput @$('.bv_readPosition')
		@trigger 'updateState'

	handleReadNameChanged: =>
		readName = @readNameListController.getSelectedCode()
		@hideReadPosition(readName)
		@model.set
			readName: readName
		@attributeChanged()

	handleActivityChanged: =>
		activity = @$('.bv_activity').is(":checked")
		@model.set
			activity: activity
		@attributeChanged()
		@trigger 'updateAllActivities'

	clear: =>
		@model.destroy()
		@attributeChanged()

class window.TransformationRuleController extends AbstractFormController
	template: _.template($("#TransformationRuleView").html())
	events:
		"change .bv_transformationRule": "attributeChanged"
		"click .bv_deleteRule": "clear"

	initialize: ->
		@errorOwnerName = 'TransformationRuleController'
		@setBindings()
		@model.on "destroy", @remove, @


	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setUpTransformationRuleSelect()

		@

	updateModel: =>
		@model.set transformationRule: @transformationListController.getSelectedCode()
		@trigger 'updateState'


	setUpTransformationRuleSelect: ->
		@transformationList = new PickListList()
		@transformationList.url = "/api/codetables/analysis parameter/transformation"
		@transformationListController = new PickListSelectController
			el: @$('.bv_transformationRule')
			collection: @transformationList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Transformation Rule"
			selectedCode: @model.get('transformationRule')


	clear: =>
		@model.destroy()
		@attributeChanged()

class window.ControlSettingController extends AbstractFormController
	# Must be initialized with the option standardsList
	template: _.template($("#ControlSettingView").html())
	events:
		"change .bv_standardNumber": "attributeChanged"
		"keyup .bv_defaultValue": "attributeChanged"

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setupStandardsListSelect(@standardsList)
		@$('.control-label').html @controlLabel
		@

	initialize: (options) ->
		@errorOwnerName = 'ControlSettingController'
		@setBindings()
		@standardNumberList = null # is a PickListList
		if not options.standardsList?
			throw "ControlSettingController missing standardsList in options"
		@standardsList = options.standardsList
		if not options.controlLabel?
			throw "ControlSettingController missing controlLabel in options"
		@controlLabel = options.controlLabel
		@standardsList.on 'change reset add remove', =>
			@setupStandardsListSelect @standardsList

	updateModel: =>
		defaultValue = UtilityFunctions::getTrimmedInput @$('.bv_defaultValue')
		if defaultValue isnt ""
			defaultValue = parseFloat(defaultValue)
		selectedStandard = @standardsListSelectController.getSelectedCode()
		@model.set
			defaultValue: defaultValue
			standardNumber: selectedStandard
		if selectedStandard is 'input value'
			@$('.bv_defaultValue').removeClass('hide')
		else
			@$('.bv_defaultValue').addClass('hide')
		@trigger 'updateState'

	setupStandardsListSelect: (standardsList) =>
		standardsSelectArray = standardsList.map (model) =>
			code: model.get('standardNumber').toString()
			name: "S#{model.get('standardNumber')} #{model.get('batchCode')} @ #{model.get('concentration')} uM"
		standardsSelectArray.push
			code: "input value"
			name: "Input Value"
		if @standardNumberList?
			@standardNumberList.reset standardsSelectArray
		else
			@standardNumberList = new PickListList standardsSelectArray
		if not @standardsListSelectController?
			@standardsListSelectController = new PickListSelectController
				el: @$('.bv_standardNumber')
				collection: @standardNumberList
				insertFirstOption: new PickList
					code: "unassigned"
					name: "Select Standard"
				selectedCode: @model.get('standardNumber')
				autoFetch: false

class window.NormalizationController extends AbstractFormController
	# Must be initialized with the option standardsList
	template: _.template($("#NormalizationView").html())
	events:
		"change .bv_normalizationRule": "attributeChanged"

	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setupNormalizationSelect()
		@setupPositiveControlSettingController()
		@setupNegativeControlSettingController()
		@

	initialize: (options) ->
		@errorOwnerName = 'NormalizationController'
		@setBindings()
		if options.standardsList?
			@standardsList = options.standardsList
		else
			throw "NormalizationController missing standardsList in options"

	updateModel: =>
		@model.set normalizationRule: @normalizationListController.getSelectedCode()
		@trigger 'updateState'

	setupNormalizationSelect: ->
		@normalizationList = new PickListList()
		@normalizationList.url = "/api/codetables/analysis parameter/normalization method"
		@normalizationListController = new PickListSelectController
			el: @$('.bv_normalizationRule')
			collection: @normalizationList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Normalization Rule"
			selectedCode: @model.get('normalizationRule')

	setupPositiveControlSettingController: ->
		@positiveControlController = new ControlSettingController
			el: @$('.bv_normalizationPositiveControl')
			model: @model.get('positiveControl')
			standardsList: @standardsList
			controlLabel: '*Positive Control'
		@positiveControlController.render()
		@positiveControlController.on 'updateState', =>
			@trigger 'updateState'

	setupNegativeControlSettingController: ->
		@negativeControlController = new ControlSettingController
			el: @$('.bv_normalizationNegativeControl')
			model: @model.get('negativeControl')
			standardsList:	@standardsList
			controlLabel: '*Negative Control'
		@negativeControlController.render()
		@negativeControlController.on 'updateState', =>
			@trigger 'updateState'


class window.PrimaryAnalysisTimeWindowListController extends AbstractFormController
	template: _.template($("#PrimaryAnalysisTimeWindowListView").html())
	nextPositionNumber: 1
	events:
		"click .bv_addTimeWindowButton": "addNewWindow"

	initialize: =>
		@collection.on 'remove', @handleModelRemoved

	handleModelRemoved: =>
		@renumberTimeWindows
		@collection.trigger 'change'

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (timeWindow) =>
			@addOneWindow(timeWindow)
		@

	addNewWindow: (skipAmDirtyTrigger) =>
		newModel = new PrimaryAnalysisTimeWindow()
		@collection.add newModel
		@addOneWindow(newModel)
		unless skipAmDirtyTrigger is true
			newModel.trigger 'amDirty'

	addOneWindow: (timeWindow) ->
		timeWindow.set position: @nextPositionNumber
		@nextPositionNumber++
		parc = new PrimaryAnalysisTimeWindowController
			model: timeWindow
		@$('.bv_timeWindowInfo').append parc.render().el
		parc.on 'updateState', =>
			@trigger 'updateState'
		parc.on 'updateAllActivities', @updateAllActivities

	renumberTimeWindows: =>
		@nextPositionNumber = 1
		index = 0
		while index < @collection.length
			windowNumber = 'T' + @nextPositionNumber.toString()
			@collection.at(index).set position: @nextPositionNumber
			@$('.bv_timePosition:eq('+index+')').html(windowNumber)
			index++
			@nextPositionNumber++

class window.StandardCompoundListController extends AbstractFormController
	template: _.template($("#StandardCompoundListView").html())
	nextPositionNumber: 1
	events:
		"click .bv_addStandardCompoundButton": "addNewStandard"

	initialize: =>
		@collection.on 'remove', @handleModelRemoved

	handleModelRemoved: =>
		@renumberStandards
		@collection.trigger 'change'

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (standard) =>
			@addOneStandard(standard)
		if @collection.length == 0
			@addNewStandard(true)
		@

	addNewStandard: (skipAmDirtyTrigger) =>
		newModel = new StandardCompound
		@collection.add newModel
		@addOneStandard(newModel)
		unless skipAmDirtyTrigger is true
			newModel.trigger 'amDirty'

	addOneStandard: (standard) ->
		standard.set standardNumber: @nextPositionNumber
		@nextPositionNumber++
		scc = new StandardCompoundController
			model: standard
		@$('.bv_standardCompoundInfo').append scc.render().el
		scc.on 'updateState', =>
			@trigger 'updateState'
		scc.on 'updateAllActivities', @updateAllActivities

	renumberStandards: =>
		@nextPositionNumber = 1
		@collection.each (standard, index) =>
			standardNumber = 'S' + @nextPositionNumber.toString()
			standard.set standardNumber: @nextPositionNumber
			@$('.bv_timePosition:eq('+index+')').html(standardNumber)
			@nextPositionNumber++



class window.AdditiveListController extends AbstractFormController
	template: _.template($("#AdditiveListView").html())
	nextPositionNumber: 1
	events:
		"click .bv_addAdditiveButton": "addNewAdditive"

	initialize: =>
		@collection.on 'remove', @renumberAdditives
		@collection.on 'remove', => @collection.trigger 'change'


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (additive) =>
			@addOneAdditive(additive)
		if @collection.length == 0
			@addNewAdditive(true)
		@

	addNewAdditive: (skipAmDirtyTrigger) =>
		newModel = new Additive
		@collection.add newModel
		@addOneAdditive(newModel)
		unless skipAmDirtyTrigger is true
			newModel.trigger 'amDirty'

	addOneAdditive: (additive) ->
		additive.set additiveNumber: @nextPositionNumber
		@nextPositionNumber++
		scc = new AdditiveController
			model: additive
		@$('.bv_additiveInfo').append scc.render().el
		scc.on 'updateState', =>
			@trigger 'updateState'

	renumberAdditives: =>
		@nextPositionNumber = 1
		@collection.each (additive, index) =>
			additiveNumber = 'A' + @nextPositionNumber.toString()
			additive.set additiveNumber: @nextPositionNumber
			@$('.bv_additiveNumber:eq('+index+')').html(additiveNumber)
			@nextPositionNumber++

class window.PrimaryAnalysisReadListController extends AbstractFormController
	template: _.template($("#PrimaryAnalysisReadListView").html())
	matchReadNameChecked: false
	nextReadNumber: 1
	events:
		"click .bv_addReadButton": "addNewRead"

	initialize: =>
		@collection.on 'remove', @checkActivity
		@collection.on 'remove', @renumberReads
		@collection.on 'remove', => @collection.trigger 'change'


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (read) =>
			@addOneRead(read)
		if @collection.length == 0
			@addNewRead(true)
		@checkActivity()

		@

	addNewRead: (skipAmDirtyTrigger) =>
		newModel = new PrimaryAnalysisRead()
		@collection.add newModel
		@addOneRead(newModel)
		if @collection.length ==1
			@checkActivity()
		unless skipAmDirtyTrigger is true
			newModel.trigger 'amDirty'

	addOneRead: (read) ->
		read.set readNumber: @nextReadNumber
		@nextReadNumber++
		parc = new PrimaryAnalysisReadController
			model: read
		@$('.bv_readInfo').append parc.render().el
		parc.setUpReadPosition(@matchReadNameChecked)
		parc.on 'updateState', =>
			@trigger 'updateState'
		parc.on 'updateAllActivities', @updateAllActivities

	matchReadNameChanged: (matchReadName) =>
		@matchReadNameChecked = matchReadName
		if @matchReadNameChecked
			@$('.bv_readPosition').val('')
			@$('.bv_readPosition').attr('disabled','disabled')
			@collection.each (read) =>
				read.set readPosition: ''
		else
			@$('.bv_readPosition').removeAttr('disabled')

	checkActivity: => #check that at least one activity is set
		index = @collection.length-1
		activitySet = false
		while index >= 0 and activitySet == false
			if @collection.at(index).get('activity') == true
				activitySet = true
			if index == 0
				@$('.bv_activity:eq(0)').attr('checked','checked')
				@collection.at(index).set activity: true
			index = index - 1

	renumberReads: =>
		@nextReadNumber = 1
		index = 0
		while index < @collection.length
			readNumber = 'R'+@nextReadNumber.toString()
			@collection.at(index).set readNumber: @nextReadNumber
			@$('.bv_readNumber:eq('+index+')').html(readNumber)
			index++
			@nextReadNumber++

	updateAllActivities: =>
		index = @collection.length-1
		while index >=0
			activity = @$('.bv_activity:eq('+index+')').is(":checked")
			@collection.at(index).set activity: activity
			index--

class window.TransformationRuleListController extends AbstractFormController
	template: _.template($("#TransformationRuleListView").html())
	events:
		"click .bv_addTransformationButton": "addNewRule"

	initialize: =>
		@collection.on 'remove', @checkNumberOfRules
		@collection.on 'remove', => @collection.trigger 'amDirty'
		@collection.on 'remove', => @collection.trigger 'change'


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (rule) =>
			@addOneRule(rule)
		if @collection.length == 0
			@addNewRule(true)
		@

	addNewRule: (skipAmDirtyTrigger)=>
		newModel = new TransformationRule()
		@collection.add newModel
		@addOneRule(newModel)
		unless skipAmDirtyTrigger is true
			newModel.trigger 'amDirty'


	addOneRule: (rule) ->
		trc = new TransformationRuleController
			model: rule
		@$('.bv_transformationInfo').append trc.render().el
		trc.on 'updateState', =>
			@trigger 'updateState'


	checkNumberOfRules: => #ensures that there is always one rule
		if @collection.length == 0
			@addNewRule()

class window.PrimaryScreenAnalysisParametersController extends AbstractParserFormController
	template: _.template($("#PrimaryScreenAnalysisParametersView").html())
	autofillTemplate: _.template($("#PrimaryScreenAnalysisParametersAutofillView").html())


	events:
		"change .bv_instrumentReader": "attributeChanged"
		"change .bv_signalDirectionRule": "attributeChanged"
		"change .bv_aggregateBy": "attributeChanged"
		"change .bv_aggregationMethod": "attributeChanged"
		"keyup .bv_assayVolume": "handleAssayVolumeChanged"
		"keyup .bv_dilutionFactor": "handleDilutionFactorChanged"
		"keyup .bv_transferVolume": "handleTransferVolumeChanged"
		"keyup .bv_hitEfficacyThreshold": "attributeChanged"
		"keyup .bv_hitSDThreshold": "attributeChanged"
		"change .bv_thresholdTypeEfficacy": "handleThresholdTypeChanged"
		"change .bv_thresholdTypeSD": "handleThresholdTypeChanged"
		"change .bv_volumeTypeTransfer": "handleVolumeTypeChanged"
		"change .bv_volumeTypeDilution": "handleVolumeTypeChanged"
		"change .bv_autoHitSelection": "handleAutoHitSelectionChanged"
		"change .bv_htsFormat": "attributeChanged"
		"click .bv_matchReadName": "handleMatchReadNameChanged"
		"keyup .bv_fluorescentStart": "attributeChanged"
		"keyup .bv_fluorescentEnd": "attributeChanged"
		"keyup .bv_fluorescentStep": "attributeChanged"
		"keyup .bv_latePeakTime": "attributeChanged"




	initialize: ->
		@errorOwnerName = 'PrimaryScreenAnalysisParametersController'
		super()
		@model.bind 'amDirty', => @trigger 'amDirty', @
		@setupInstrumentReaderSelect()
		@setupSignalDirectionSelect()
		@setupAggregateBySelect()
		@setupAggregationMethodSelect()




	render: =>
		@$('.bv_autofillSection').empty()
		@$('.bv_autofillSection').html @autofillTemplate(@model.attributes)
		@$("[data-toggle=popover]").popover();
		@$("body").tooltip selector: '.bv_popover'

		@setupInstrumentReaderSelect()
		@setupSignalDirectionSelect()
		@setupAggregateBySelect()
		@setupAggregationMethodSelect()
		@handleAutoHitSelectionChanged(true)
		@setupReadListController()
		@setupTimeWindowListController()
		@setupStandardCompoundListController()
		@setupAdditiveListController()
		@setupNormalizationController()
		@setupTransformationRuleListController()
		@handleMatchReadNameChanged(true)

		@


	setupInstrumentReaderSelect: ->
		@instrumentList = new PickListList()
		@instrumentList.url = "/api/codetables/equipment/instrument reader"
		@instrumentListController = new PickListSelectController
			el: @$('.bv_instrumentReader')
			collection: @instrumentList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Instrument"
			selectedCode: @model.get('instrumentReader')

	setupSignalDirectionSelect: ->
		@signalDirectionList = new PickListList()
		@signalDirectionList.url = "/api/codetables/analysis parameter/signal direction"
		@signalDirectionListController = new PickListSelectController
			el: @$('.bv_signalDirectionRule')
			collection: @signalDirectionList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Signal Direction"
			selectedCode: @model.get('signalDirectionRule')

	setupAggregateBySelect: ->
		@aggregateByList = new PickListList()
		@aggregateByList.url = "/api/codetables/analysis parameter/aggregate by"
		@aggregateByListController = new PickListSelectController
			el: @$('.bv_aggregateBy')
			collection: @aggregateByList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Aggregate By"
			selectedCode: @model.get('aggregateBy')

	setupAggregationMethodSelect: ->
		@aggregationMethodList = new PickListList()
		@aggregationMethodList.url = "/api/codetables/analysis parameter/aggregation method"
		@aggregationMethodListController = new PickListSelectController
			el: @$('.bv_aggregationMethod')
			collection: @aggregationMethodList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Aggregation Method"
			selectedCode: @model.get('aggregationMethod')

	setupReadListController: ->
		@readListController= new PrimaryAnalysisReadListController
			el: @$('.bv_readList')
			collection: @model.get('primaryAnalysisReadList')
		@readListController.render()
		@readListController.on 'updateState', =>
			@trigger 'updateState'

	setupTimeWindowListController: ->
		@timeWindowListController= new PrimaryAnalysisTimeWindowListController
			el: @$('.bv_timeWindowList')
			collection: @model.get('primaryAnalysisTimeWindowList')
		@timeWindowListController.render()
		@timeWindowListController.on 'updateState', =>
			@trigger 'updateState'

	setupStandardCompoundListController: ->
		@standardCompoundListController= new StandardCompoundListController
			el: @$('.bv_standardCompoundList')
			collection: @model.get('standardCompoundList')
		@standardCompoundListController.render()
		@standardCompoundListController.on 'updateState', =>
			@trigger 'updateState'

	setupAdditiveListController: ->
		@additiveListController= new AdditiveListController
			el: @$('.bv_additiveList')
			collection: @model.get('additiveList')
		@additiveListController.render()
		@additiveListController.on 'updateState', =>
			@trigger 'updateState'

	setupNormalizationController: ->
		@normalizationController = new NormalizationController
			el: @$('.bv_normalization')
			model: @model.get('normalization')
			standardsList: @model.get('standardCompoundList')
		@normalizationController.render()
		@normalizationController.on 'updateState', =>
			@trigger 'updateState'

	setupTransformationRuleListController: ->
		@transformationRuleListController= new TransformationRuleListController
			el: @$('.bv_transformationList')
			collection: @model.get('transformationRuleList')
		@transformationRuleListController.render()
		@transformationRuleListController.on 'updateState', =>
			@trigger 'updateState'



	updateModel: =>
		htsFormat = @$('.bv_htsFormat').is(":checked")
		@model.set
			instrumentReader: @instrumentListController.getSelectedCode()
			signalDirectionRule: @signalDirectionListController.getSelectedCode()
			aggregateBy: @aggregateByListController.getSelectedCode()
			aggregationMethod: @aggregationMethodListController.getSelectedCode()
			hitEfficacyThreshold: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_hitEfficacyThreshold'))
			hitSDThreshold: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_hitSDThreshold'))
			assayVolume: UtilityFunctions::getTrimmedInput @$('.bv_assayVolume')
			transferVolume: UtilityFunctions::getTrimmedInput @$('.bv_transferVolume')
			dilutionFactor: UtilityFunctions::getTrimmedInput @$('.bv_dilutionFactor')
			fluorescentStart: UtilityFunctions::getTrimmedInput @$('.bv_fluorescentStart')
			fluorescentEnd: UtilityFunctions::getTrimmedInput @$('.bv_fluorescentEnd')
			fluorescentStep: UtilityFunctions::getTrimmedInput @$('.bv_fluorescentStep')
			latePeakTime: UtilityFunctions::getTrimmedInput @$('.bv_latePeakTime')
			htsFormat: htsFormat
		if @model.get('assayVolume') != ""
			@model.set assayVolume: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_assayVolume'))
		if @model.get('transferVolume') != ""
			@model.set transferVolume: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_transferVolume'))
		if @model.get('dilutionFactor') != ""
			@model.set dilutionFactor: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_dilutionFactor'))
		if @model.get('fluorescentStart') != ""
			@model.set fluorescentStart: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_fluorescentStart'))
		if @model.get('fluorescentEnd') != ""
			@model.set fluorescentEnd: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_fluorescentEnd'))
		if @model.get('fluorescentStep') != ""
			@model.set fluorescentStep: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_fluorescentStep'))
		if @model.get('latePeakTime') != ""
			@model.set latePeakTime: parseFloat(UtilityFunctions::getTrimmedInput @$('.bv_latePeakTime'))
		@trigger 'updateState'



	handleAssayVolumeChanged: =>
		@attributeChanged()
		volumeType = @$("input[name='bv_volumeType']:checked").val()
		if volumeType == "dilution"
			@handleDilutionFactorChanged(true)
		else
			@handleTransferVolumeChanged()


	handleTransferVolumeChanged: =>
		@attributeChanged()
		dilutionFactor = @model.autocalculateVolumes()
		@$('.bv_dilutionFactor').val(dilutionFactor)

	handleDilutionFactorChanged: (indirectChange) =>
		#indirectChange = true if the dilution factor input is being changed because transfer or assay volume is changed
		@attributeChanged()
		transferVolume = @model.autocalculateVolumes()
		@$('.bv_transferVolume').val(transferVolume)
		if indirectChange is true
			if transferVolume=="" or transferVolume == null
				@$('.bv_dilutionFactor').val(@model.get('dilutionFactor'))


	handleThresholdTypeChanged: =>
		thresholdType = @$("input[name='bv_thresholdType']:checked").val()
		@model.set thresholdType: thresholdType
		if thresholdType=="efficacy"
			@$('.bv_hitSDThreshold').attr('disabled','disabled')
			@$('.bv_hitEfficacyThreshold').removeAttr('disabled')
		else
			@$('.bv_hitEfficacyThreshold').attr('disabled','disabled')
			@$('.bv_hitSDThreshold').removeAttr('disabled')
		@attributeChanged()

	handleAutoHitSelectionChanged: (skipUpdate) =>
		autoHitSelection = @$('.bv_autoHitSelection').is(":checked")
		@model.set autoHitSelection: autoHitSelection
		if autoHitSelection
			@$('.bv_thresholdControls').show()
		else
			@$('.bv_thresholdControls').hide()
		unless skipUpdate is true
			@attributeChanged()

	handleVolumeTypeChanged: (skipUpdate) =>
		volumeType = @$("input[name='bv_volumeType']:checked").val()
		@model.set volumeType: volumeType
		if volumeType=="transfer"
			@$('.bv_dilutionFactor').attr('disabled','disabled')
			@$('.bv_transferVolume').removeAttr('disabled')
		else
			@$('.bv_transferVolume').attr('disabled','disabled')
			@$('.bv_dilutionFactor').removeAttr('disabled')
		if @model.get('transferVolume') == "" or @model.get('assayVolume')== ""
			@handleDilutionFactorChanged(true)
		unless skipUpdate is true
			@attributeChanged()

	handleMatchReadNameChanged: (skipUpdate) =>
		matchReadName = @$('.bv_matchReadName').is(":checked")
		@model.set matchReadName: matchReadName
		@readListController.matchReadNameChanged(matchReadName)
		unless skipUpdate is true
			@attributeChanged()

	enableAllInputs: ->
		super()
		if @$('.bv_matchReadName').is(":checked")
			@$('.bv_readPosition').attr 'disabled','disabled'
		@$('.bv_loadAnother').prop('disabled', false)
		if @model.get('volumeType') is "transfer"
			@$('.bv_dilutionFactor').attr 'disabled', 'disabled'
		else
			@$('.bv_transferVolume').attr 'disabled', 'disabled'

class window.AbstractUploadAndRunPrimaryAnalsysisController extends BasicFileValidateAndSaveController
	#	See UploadAndRunPrimaryAnalsysisController for example required initialization function

	initialize: ->
		@allowedFileTypes = ['zip']
		@loadReportFile = true
		super()
		@$('.bv_resultStatus').html("Upload Data and Analyze")
		@$('.bv_reportFileDirections').html('To upload an <b>optional well flagging file</b>, click the "Browse Files…" button and select a file.')
#		@$("label[for='.bv_attachReportFile']").innerHTML('Attach optional well flagging file')
		@$('.bv_attachReportCheckboxText').html('Attach optional well flagging file')

	completeInitialization: ->
		@analysisParameterController.on 'valid', @handleMSFormValid
		@analysisParameterController.on 'invalid', @handleMSFormInvalid
		@analysisParameterController.on 'notifyError', @notificationController.addNotification
		@analysisParameterController.on 'clearErrors', @notificationController.clearAllNotificiations
		@analysisParameterController.on 'amDirty', =>
			@trigger 'amDirty'
		@analyzedPreviously = @options.analyzedPreviously
		@analysisParameterController.render()
		if @analyzedPreviously
			@$('.bv_loadAnother').html("Re-Analyze")
		@handleMSFormInvalid() #start invalid since file won't be loaded

	handleMSFormValid: =>
		if @parseFileUploaded
			@handleFormValid()

	handleMSFormInvalid: =>
		@handleFormInvalid()

	handleFormValid: ->
		if @analysisParameterController.isValid()
			super()

	handleValidationReturnSuccess: (json) =>
		super(json)
		if not json.hasError
			resultStatus = "Dry Run Results: Success"
			if json.hasWarning
				resultStatus += " but with warnings"
		else
			resultStatus = "Dry Run Results: Failed"
		@$('.bv_resultStatus').html(resultStatus)
		@analysisParameterController.disableAllInputs()

	handleSaveReturnSuccess: (json) =>
		super(json)
		@$('.bv_loadAnother').html("Re-Analyze")
		@trigger 'analysis-completed'

	backToUpload: =>
		super()
		@$('.bv_resultStatus').html("Upload Data and Analyze")
		@$('.bv_resultStatus').show()

	loadAnother: =>
		if @analyzedPreviously
			if !confirm("Re-analyzing the data will delete the previously saved results.")
				return
		super()
		@$('.bv_resultStatus').html("Upload Data and Analyze")
		@$('.bv_resultStatus').show()

	showFileSelectPhase: ->
		super()
		@$('.bv_resultStatus').show()
		if @analysisParameterController?
			@analysisParameterController.enableAllInputs()

	showFileUploadCompletePhase: ->
		@analyzedPreviously = true
		super()

	disableAllInputs: ->
		@analysisParameterController.disableAllInputs()

	disableAll: =>
		@analysisParameterController.disableAllInputs()
		@$('.bv_next').attr('disabled','disabled')
		@$('.bv_next').prop('disabled', true)
		@$('.bv_back').attr('disabled','disabled')
		@$('.bv_back').prop('disabled', true)
		@$('.bv_loadAnother').removeAttr('disabled')
		@$('.bv_loadAnother').attr('disabled','disabled')

	enableFields: =>
		@$('.bv_back').removeAttr('disabled')
		@$('.bv_back').prop('disabled', false)
		@$('.bv_next').removeAttr('disabled')
		@$('.bv_next').prop('disabled', false)
		if @$('.bv_outerContainer .bv_flowControl .bv_nextControlContainer').css('display') != 'none' #file is not yet uploaded
			@analysisParameterController.enableAllInputs()
		else
			if @analysisParameterController.model.isValid()
				@$('.bv_loadAnother').removeAttr('disabled')
				@$('.bv_loadAnother').prop('disabled', false)
			else
				@$('.bv_loadAnother').removeAttr('disabled')
				@$('.bv_loadAnother').attr('disabled','disabled')

	validateParseFile: =>
		@analysisParameterController.updateModel()
		unless !@analysisParameterController.isValid()
			@additionalData =
				inputParameters: JSON.stringify @analysisParameterController.model
				primaryAnalysisExperimentId: @experimentId
				testMode: false
			super()

	setUser: (user) ->
		@userName = user

	setExperimentId: (expId) ->
		@experimentId = expId

	updateAnalysisParamModel: (model) ->
		@analysisParameterController.model = model.getAnalysisParameters()
		@analysisParameterController.render()

class window.UploadAndRunPrimaryAnalsysisController extends AbstractUploadAndRunPrimaryAnalsysisController
	initialize: ->
		@fileProcessorURL = "/api/primaryAnalysis/runPrimaryAnalysis"
		@errorOwnerName = 'UploadAndRunPrimaryAnalsysisController'
		@allowedFileTypes = ['zip']
		@maxFileSize = 200000000
		@loadReportFile = false
		super()
		#		@$('.bv_moduleTitle').html("Upload Data and Analyze")
		@$('.bv_moduleTitle').hide()
		@analysisParameterController = new PrimaryScreenAnalysisParametersController
			model: @options.paramsFromExperiment
			el: @$('.bv_additionalValuesForm')
		@completeInitialization()

class window.PrimaryScreenAnalysisController extends Backbone.View
	template: _.template($("#PrimaryScreenAnalysisView").html())

	initialize: ->
		@model.on "saveSuccess", @handleExperimentSaved
		@model.on 'statusChanged', @handleStatusChanged
		@model.on 'changeProtocolParams', @handleAnalysisParamsChanged
		@dataAnalysisController = null
		$(@el).empty()
		$(@el).html @template()
		if @model.isNew()
			@setExperimentNotSaved()
		else
			@setExperimentSaved()
			@setupDataAnalysisController(@options.uploadAndRunControllerName)
			@checkForSourceFile()

	render: =>
		@showExistingResults()

	showExistingResults: ->
		dryRunStatus = @model.getDryRunStatus()
		if dryRunStatus != null
			dryRunStatus = dryRunStatus.get('codeValue')
		else
			dryRunStatus = "not started"
		analysisStatus = @model.getAnalysisStatus()
		if analysisStatus != null
			analysisStatus = analysisStatus.get('codeValue')
		else
			analysisStatus = "not started"
#		@$('.bv_analysisStatus').html(analysisStatus)

		#running statuses
		if dryRunStatus is "running"
			if analysisStatus is "running" # invalid state
				@showWarningStatus(dryRunStatus, analysisStatus)
			else
				statusId = @model.getDryRunStatus().get('id')
				@trigger "dryRunRunning"
				@checkStatus(statusId, "dryRun")
		else if analysisStatus is "running"
			if dryRunStatus is "not started" # invalid state
				@showWarningStatus(dryRunStatus, analysisStatus)
			else #valid
				statusId = @model.getAnalysisStatus().get('id')
				@trigger 'analysisRunning'
				@checkStatus(statusId, "analysis")

		#show analysis result clob
		else if analysisStatus is "complete" or analysisStatus is "failed"
			@showAnalysisResults(analysisStatus)

		else
			if dryRunStatus is "not started"
				@showUploadWrapper()
			else
				@showDryRunResults(dryRunStatus)

	showWarningStatus: (dryRunStatus, analysisStatus) ->
		resultStatus = "An error has occurred. Dry Run: "+dryRunStatus+ ". Analysis: "+ analysisStatus+"."
		resultHTML = "An error has occurred."
		@trigger "warning"
		@$('.bv_resultStatus').html(resultStatus)
		@$('.bv_htmlSummary').html(resultHTML)

	checkStatus: (statusId, analysisStep) =>
		$.ajax
			type: 'GET'
			url: "/api/experiments/values/"+statusId
			dataType: 'json'
			error: (err) ->
				alert 'Error - Could not get requested status value.'
			success: (json) =>
				if json.length == 0
					alert 'Success but could not get requested status value.'
				else
					statusValue = new Value json
					status = statusValue.get('codeValue')
					if status is "running"
						setTimeout(@checkStatus, 5000, statusId, analysisStep)
						if analysisStep is "dryRun"
							resultStatus = "Dry Run Results: Dry run in progress."
							resultHTML = ""
						else
							resultStatus = "Upload Results: Upload in progress."
							resultHTML = @model.getDryRunResultHTML().get('clobValue')
						@$('.bv_resultStatus').html(resultStatus)
						@$('.bv_htmlSummary').html(resultHTML)
						if @dataAnalysisController?
							@dataAnalysisController.showFileUploadPhase()

					else
						#TODO: need to get updated state and show
						@showUpdatedModel =>
							@showUpdatedStatus(analysisStep)

	showUpdatedModel: (callback) =>
		$.ajax
			type: 'GET'
			url: "/api/experiments/codename/"+@model.get('codeName')
			dataType: 'json'
			error: (err) ->
				alert 'Could not get experiment for codeName of the model'
			success: (json) =>
				if json.length == 0
					alert 'Could not get experiment for codeName of the model'
				else
					exp = new PrimaryScreenExperiment json
					exp.set exp.parse(exp.attributes)
					@model = exp
					@dataAnalysisController.updateAnalysisParamModel(@model)
					callback.call()

	showUpdatedStatus: (analysisStep)->
		if analysisStep is "dryRun"
			@trigger "dryRunDone"
			@showDryRunResults(@model.getDryRunStatus().get('codeValue'))
		else
			@trigger "analysisDone"
			@showAnalysisResults(@model.getAnalysisStatus().get('codeValue'))

	showAnalysisResults: (analysisStatus) ->
		if analysisStatus is "complete"
			resultStatus = "Upload Results: Success"
		else
			resultStatus = "Upload Results: Failed due to errors"
		resultHTML = @model.getAnalysisResultHTML().get('clobValue')
		if @dataAnalysisController?
			@dataAnalysisController.showFileUploadCompletePhase()
			@dataAnalysisController.disableAllInputs()
		@$('.bv_resultStatus').html(resultStatus)
		@$('.bv_htmlSummary').html(resultHTML)

	showDryRunResults: (dryRunStatus) ->
		resultHTML = @model.getDryRunResultHTML().get('clobValue')
		if @dataAnalysisController?
			@dataAnalysisController.parseFileUploaded = true
			@dataAnalysisController.filePassedValidation = true
			@dataAnalysisController.showFileUploadPhase()
			@dataAnalysisController.handleFormValid()
			@dataAnalysisController.disableAllInputs()
		if dryRunStatus is "complete"
			resultStatus = "Dry Run Results: Success" #warnings are not stored so status will just be successful even if there are warnings
		else
			resultStatus = "Dry Run Results: Failed"
			@$('.bv_save').attr('disabled', 'disabled')
			@$('.bv_save').prop('disabled', true);
		@$('.bv_resultStatus').html(resultStatus)
		@$('.bv_htmlSummary').html(resultHTML)

	showUploadWrapper: ->
		resultStatus = "Upload Data and Analyze"
		resultHTML = ""
		@$('.bv_resultStatus').html(resultStatus)
		@$('.bv_htmlSummary').html(resultHTML)

	setExperimentNotSaved: ->
		@$('.bv_fileUploadWrapper').hide()
		@$('.bv_resultsContainer').hide()
		@$('.bv_saveExperimentToAnalyze').show()

	setExperimentSaved: =>
		@$('.bv_saveExperimentToAnalyze').hide()
		@$('.bv_fileUploadWrapper').show()

	handleExperimentSaved: =>
		@setExperimentSaved()
		unless @dataAnalysisController?
			@setupDataAnalysisController(@options.uploadAndRunControllerName)
#		@model.getStatus().on 'change', @handleStatusChanged

	handleAnalysisComplete: =>
		# Results are shown analysis controller, so redundant here until experiment is reloaded, which resets analysis controller
		@$('.bv_resultsContainer').hide()
		@trigger 'analysis-completed'

	handleStatusChanged: =>
		if @dataAnalysisController != null
			if @model.isEditable()
				@dataAnalysisController.enableFields()
			else
				@dataAnalysisController.disableAll()
				@$('.bv_loadAnother').attr('disabled', 'disabled')
				@$('.bv_loadAnother').prop('disabled', true)

	handleAnalysisParamsChanged: =>
		if @dataAnalysisController?
			@dataAnalysisController.undelegateEvents()
		@setupDataAnalysisController(@options.uploadAndRunControllerName)
		@setExperimentNotSaved()
		@$('.bv_saveExperimentToAnalyze').html("Analysis parameters have changed. To analyze data, save the experiment first.")

	setupDataAnalysisController: (dacClassName) ->
		newArgs =
			el: @$('.bv_fileUploadWrapper')
			paramsFromExperiment:	@model.getAnalysisParameters()
			analyzedPreviously: @model.getAnalysisStatus().get('codeValue')!="not started"
		@dataAnalysisController = new window[dacClassName](newArgs)
		@dataAnalysisController.setUser(window.AppLaunchParams.loginUserName)
		@dataAnalysisController.setExperimentId(@model.id)
		@dataAnalysisController.on 'analysis-completed', @handleAnalysisComplete
		@dataAnalysisController.on 'amDirty', =>
			@trigger 'amDirty'
		@dataAnalysisController.on 'amClean', =>
			@trigger 'amClean'
#		@showExistingResults()

	checkForSourceFile: ->
		sourceFile = @model.getSourceFile()
		if sourceFile? and @dataAnalysisController.parseFileNameOnServer is ""
			sourceFileValue = sourceFile.get('fileValue')
			displayName = sourceFile.get('comments')
			unless displayName? #TODO: delete this once SEL saves file names in the comments
				displayName = sourceFile.get('fileValue').split("/")
				displayName = displayName[displayName.length-1]
			@dataAnalysisController.$('.bv_fileChooserContainer').html '<div style="margin-top:5px;"><a style="margin-left:20px;" href="'+window.conf.datafiles.downloadurl.prefix+sourceFileValue+'">'+displayName+'</a><button type="button" class="btn btn-danger bv_deleteSavedSourceFile pull-right" style="margin-bottom:20px;margin-right:20px;">Delete</button></div>'
			#TODO: should find file name in comments
			@dataAnalysisController.handleParseFileUploaded(sourceFile.get('fileValue'))
			@dataAnalysisController.$('.bv_deleteSavedSourceFile').on 'click', =>
				@dataAnalysisController.parseFileController.render()
				@dataAnalysisController.handleParseFileRemoved()
#			@dataAnalysisController.$('.bv_fileChooserContainer').html '<div style="margin-top:5px;"><a href="'+window.conf.datafiles.downloadurl.prefix+sourceFileValue+'">'+@model.get('structural file').get('comments')+'</a></div>'
#			@dataAnalysisController.parseFileController.lsFileChooser.fileUploadComplete(null,result:[name:sourceFile.get('fileValue')])


# This wraps all the tabs
class window.AbstractPrimaryScreenExperimentController extends Backbone.View
	template: _.template($("#PrimaryScreenExperimentView").html())

	initialize: ->
		if @model?
			@completeInitialization()
		else
			if window.AppLaunchParams.moduleLaunchParams?
				if window.AppLaunchParams.moduleLaunchParams.moduleName == @moduleLaunchName
					if window.AppLaunchParams.moduleLaunchParams.createFromOtherEntity
						@createExperimentFromProtocol(window.AppLaunchParams.moduleLaunchParams.code)
						@completeInitialization()
					else
						$.ajax
							type: 'GET'
							url: "/api/experiments/codename/"+window.AppLaunchParams.moduleLaunchParams.code
							dataType: 'json'
							error: (err) ->
								alert 'Could not get experiment for code in this URL, creating new one'
								@completeInitialization()
							success: (json) =>
								if json.length == 0
									alert 'Could not get experiment for code in this URL, creating new one'
								else
#								exp = new PrimaryScreenExperiment json
									lsKind = json.lsKind
									if lsKind is "Bio Activity"
										exp = new PrimaryScreenExperiment json
										exp.set exp.parse(exp.attributes)
										if window.AppLaunchParams.moduleLaunchParams.copy
											@model = exp.duplicateEntity()
										else
											@model = exp
									else
										alert 'Could not get primary screen experiment for code in this URL. Creating new primary screen experiment'
								@completeInitialization()
				else
					@completeInitialization()
			else
				@completeInitialization()

	createExperimentFromProtocol: (code) ->
		@model = new PrimaryScreenExperiment()
		@model.set protocol: new PrimaryScreenProtocol
			codeName: code
		@setupExperimentBaseController()
		@experimentBaseController.getAndSetProtocol(code, true)

	completeInitialization: =>
		unless @model?
			@model = new PrimaryScreenExperiment()

		$(@el).html @template()
		@setupExperimentBaseController()
		@model.on 'sync', @handleExperimentSaved
		@analysisController = new PrimaryScreenAnalysisController
			model: @model
			el: @$('.bv_primaryScreenDataAnalysis')
			uploadAndRunControllerName: @uploadAndRunControllerName
		@analysisController.on 'amDirty', =>
			@trigger 'amDirty'
		@analysisController.on 'amClean', =>
			@trigger 'amClean'
		@analysisController.on 'warning', =>
			@showWarningModal()
		@analysisController.on 'dryRunRunning', =>
			@showValidateProgressBar()
		@analysisController.on 'dryRunDone', =>
			@hideValidateProgressBar()
		@analysisController.on 'analysisRunning', =>
			@showSaveProgressBar()
		@analysisController.on 'analysisDone', =>
			@hideSaveProgressBar()
		@setupModelFitController(@modelFitControllerName)
		@analysisController.on 'analysis-completed', =>
			@fetchModel()
		@$('.bv_primaryScreenDataAnalysisTab').on 'shown', (e) =>
			if @model.getAnalysisStatus().get('codeValue') is "not started"
				@analysisController.checkForSourceFile()

		@model.on "protocol_attributes_copied", @handleProtocolAttributesCopied
		@model.on 'statusChanged', @handleStatusChanged
		@experimentBaseController.render()
		@analysisController.render()
		@modelFitController.render()
		@$('.bv_cancel').attr('disabled','disabled')

	setupExperimentBaseController: ->
		if @experimentBaseController?
			@experimentBaseController.remove()
		@experimentBaseController = new ExperimentBaseController
			model: @model
			el: @$('.bv_experimentBase')
			protocolFilter: @protocolFilter
			protocolKindFilter: @protocolKindFilter
		@experimentBaseController.on 'amDirty', =>
			@trigger 'amDirty'
		@experimentBaseController.on 'amClean', =>
			@trigger 'amClean'
		@experimentBaseController.on 'reinitialize', @reinitialize

	setupModelFitController: (modelFitControllerName) ->
		newArgs =
			model: @model
			el: @$('.bv_doseResponseAnalysis')
		@modelFitController = new window[modelFitControllerName](newArgs)
		@modelFitController.on 'amDirty', =>
			@trigger 'amDirty'
		@modelFitController.on 'amClean', =>
			@trigger 'amClean'

	handleExperimentSaved: =>
		unless @model.get('subclass')?
			@model.set subclass: 'experiment'
		@analysisController.render()

	handleProtocolAttributesCopied: =>
		@analysisController.render()

	handleStatusChanged: =>
		@analysisController.handleStatusChanged()
		@modelFitController.handleModelStatusChanged()

	showWarningModal: ->
		@$('a[href="#tab3"]').tab('show')
		dryRunStatus = @model.getDryRunStatus().get('codeValue')
		dryRunResult = @model.getDryRunResultHTML().get('clobValue')
		analysisStatus = @model.getAnalysisStatus().get('codeValue')
		analysisResult = @model.getAnalysisResultHTML().get('clobValue')
		@$('.bv_dryRunStatus').html("Dry Run Status: "+dryRunStatus)
		@$('.bv_dryRunResult').html("Dry Run Result HTML: "+dryRunResult)
		@$('.bv_analysisStatus').html("Analysis Status: "+analysisStatus)
		@$('.bv_analysisResult').html("Analysis Result HTML: "+analysisResult)
		@$('.bv_invalidAnalysisStates').modal
			backdrop: "static"
		@$('.bv_invalidAnalysisStates').modal("show")
		@$('.bv_fileUploadWrapper .bv_fileUploadWrapper').hide()
		@$('.bv_fileUploadWrapper .bv_flowControl').hide()



	showValidateProgressBar: ->
		@$('a[href="#tab3"]').tab('show')
		@$('.bv_validateStatusDropDown').modal
			backdrop: "static"
		@$('.bv_validateStatusDropDown').modal("show")

	showSaveProgressBar: ->
		@$('a[href="#tab3"]').tab('show')
		@$('.bv_saveStatusDropDown').modal
			backdrop: "static"
		@$('.bv_saveStatusDropDown').modal("show")

	hideValidateProgressBar: ->
		@$('.bv_validateStatusDropDown').modal("hide")

	hideSaveProgressBar: ->
		@$('.bv_saveStatusDropDown').modal("hide")

	reinitialize: =>
		@model = null
		@completeInitialization()

	fetchModel: =>
#		@model.fetch
#			success: @updateModelFitTab()

		$.ajax
			type: 'GET'
			url: "/api/experiments/codeName/"+@model.get('codeName')
			success: (json) =>
				@model = new PrimaryScreenExperiment json
				@updateModelFitTab()
			error: (err) =>
				alert 'Could not get experiment with this codeName'
			dataType: 'json'

	updateModelFitTab: =>
		@modelFitController.model = @model
		@modelFitController.testReadyForFit()
		@$('.bv_resultsContainer').hide()
		@modelFitController.render()


class window.PrimaryScreenExperimentController extends AbstractPrimaryScreenExperimentController
	uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
	modelFitControllerName: "DoseResponseAnalysisController"
#	modelFitControllerName: "PrimaryScreenModelFitController"
#	protocolFilter: "?protocolName=FLIPR"
	protocolKindFilter: "?protocolKind=Bio Activity"
	moduleLaunchName: "primary_screen_experiment"








