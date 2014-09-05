class window.AbstractProtocolParameter extends Backbone.Model
	defaults:
		parameter: "abstractParameter" #to be replaced by name of actual protocol parameter

	triggerAmDirty: =>
		@trigger 'amDirty', @

class window.AssayActivity extends AbstractProtocolParameter

	defaults:
		parameter: "assayActivity"
		assayActivity: "unassigned"

#	defaults:
#		assayActivity: "unassigned"

#	triggerAmDirty: =>
#		@trigger 'amDirty', @

class window.TargetOrigin extends AbstractProtocolParameter
	defaults:
		parameter: "targetOrigin"
		targetOrigin: "unassigned"

class window.AssayType extends AbstractProtocolParameter
	defaults:
		parameter: "assayType"
		assayType: "unassigned"

class window.AssayTechnology extends AbstractProtocolParameter
	defaults:
		parameter: "assayTechnology"
		assayTechnology: "unassigned"

class window.CellLine extends AbstractProtocolParameter
	defaults:
		parameter: "cellLine"
		cellLine: "unassigned"

class window.AbstractProtocolParameterList extends Backbone.Collection

	validateCollection: ->
		modelErrors = []
		usedRules ={}
		if @.length != 0
			for index in [0..@.length-1]
				model = @.at(index)
				parameter = model.get('parameter')
				currentRule = model.get(parameter)
				if currentRule of usedRules
					modelErrors.push
						attribute: parameter+':eq('+index+')'
						message: parameter+" can not be chosen more than once"
					modelErrors.push
						attribute: parameter+':eq('+usedRules[currentRule]+')'
						message: parameter+" can not be chosen more than once"
				else
					usedRules[currentRule] = index
		return modelErrors


class window.AssayActivityList extends AbstractProtocolParameterList
	model: AssayActivity

#	validateCollection: ->
#		modelErrors = []
#		usedRules ={}
#		if @.length != 0
#			for index in [0..@.length-1]
#				model = @.at(index)
#				currentRule = model.get('assayActivity')
#				if currentRule of usedRules
#					modelErrors.push
#						attribute: 'assayActivity:eq('+index+')'
#						message: "Assay Activity can not be chosen more than once"
#					modelErrors.push
#						attribute: 'assayActivity:eq('+usedRules[currentRule]+')'
#						message: "Assay Activity can not be chosen more than once"
#				else
#					usedRules[currentRule] = index
#		return modelErrors

class window.TargetOriginList extends AbstractProtocolParameterList
	model: TargetOrigin

class window.AssayTypeList extends AbstractProtocolParameterList
	model: AssayType

class window.AssayTechnologyList extends AbstractProtocolParameterList
	model: AssayTechnology

class window.CellLineList extends AbstractProtocolParameterList
	model: CellLine

class window.Protocol extends BaseEntity
	urlRoot: "/api/protocols"

	defaults: ->
		_(super()).extend(
			assayTreeRule: null
			dnsTargetList: true
			assayStage: "unassigned"
			maxY: 100
			minY: 0
#			assayPrinciple:
			assayActivityList: new AssayActivityList()
#			molecularTarget: new MolecularTargetList()
			targetOriginList: new TargetOriginList()
			assayTypeList: new AssayTypeList()
#			assayTechnology: new AssayTechnologyList()
#			cellLine: new CellLineList()
#			attachFiles: new AttachFilesList()
		)

	initialize: ->
		@.set subclass: "protocol"
		super()

	parse: (resp) =>
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
		if resp.lsTags not instanceof TagList
			resp.lsTags = new TagList(resp.lsTags)
			resp.lsTags.on 'change', =>
				@trigger 'change'
		if resp.assayActivityList not instanceof AssayActivityList
			resp.assayActivityList = new AssayActivityList(resp.assayActivityList)
			resp.assayActivityList.on 'change', =>
				@trigger 'change'
		if resp.targetOriginList not instanceof TargetOriginList
			resp.targetOriginList = new TargetOriginList(resp.targetOriginList)
			resp.targetOriginList.on 'change', =>
				@trigger 'change'
		if resp.assayTypeList not instanceof AssayTypeList
			resp.assayTypeList = new AssayTypeList(resp.assayTypeList)
			resp.assayTypeList.on 'change', =>
				@trigger 'change'
		if resp.assayTechnologyList not instanceof AssayTechnologyList
			resp.assayTechnologyList = new AssayTechnologyList(resp.assayTechnologyList)
			resp.assayTechnologyList.on 'change', =>
				@trigger 'change'
		if resp.cellLineList not instanceof CellLineList
			resp.cellLineList = new CellLineList(resp.cellLineList)
			resp.cellLineList.on 'change', =>
				@trigger 'change'
		resp



	fixCompositeClasses: =>
		if @get('assayActivityList') not instanceof AssayActivityList
			@set assayActivityList: new AssayActivityList(@get('assayActivityList'))
		@get('assayActivityList').on "change", =>
			@trigger 'change'
		@get('assayActivityList').on "amDirty", =>
			@trigger 'amDirty'
		if @get('targetOriginList') not instanceof TargetOriginList
			@set targetOriginList: new TargetOriginList(@get('targetOriginList'))
		@get('targetOriginList').on "change", =>
			@trigger 'change'
		@get('targetOriginList').on "amDirty", =>
			@trigger 'amDirty'
		if @get('assayTypeList') not instanceof AssayTypeList
			@set assayTypeList: new AssayTypeList(@get('assayTypeList'))
		@get('assayTypeList').on "change", =>
			@trigger 'change'
		@get('assayTypeList').on "amDirty", =>
			@trigger 'amDirty'
		if @get('assayTechnologyList') not instanceof AssayTechnologyList
			@set assayTechnologyList: new AssayTechnologyList(@get('assayTechnologyList'))
		@get('assayTechnologyList').on "change", =>
			@trigger 'change'
		@get('assayTechnologyList').on "amDirty", =>
			@trigger 'amDirty'
		if @get('cellLineList') not instanceof CellLineList
			@set cellLineList: new CellLineList(@get('cellLineList'))
		@get('cellLineList').on "change", =>
			@trigger 'change'
		@get('cellLineList').on "amDirty", =>
			@trigger 'amDirty'
		super()

	validate: (attrs) ->
		errors = []
		assayActivityErrors = @get('assayActivityList').validateCollection()
		errors.push assayActivityErrors...
		targetOriginErrors = @get('targetOriginList').validateCollection()
		errors.push targetOriginErrors...
		assayTypeErrors = @get('assayTypeList').validateCollection()
		errors.push assayTypeErrors...
		assayTechnologyErrors = @get('assayTechnologyList').validateCollection()
		errors.push assayTechnologyErrors...
		cellLineErrors = @get('cellLineList').validateCollection()
		errors.push cellLineErrors...
		bestName = attrs.lsLabels.pickBestName()
		nameError = true
		if bestName?
			nameError = true
			if bestName.get('labelText') != ""
				nameError = false
		if nameError
			errors.push
				attribute: 'protocolName'
				message: attrs.subclass+" name must be set"
		if _.isNaN(attrs.recordedDate)
			errors.push
				attribute: 'recordedDate'
				message: attrs.subclass+" date must be set"
		if attrs.recordedBy is ""
			errors.push
				attribute: 'recordedBy'
				message: "Scientist must be set"
		notebook = @getNotebook().get('stringValue')
		if notebook is "" or notebook is "unassigned" or notebook is undefined
			errors.push
				attribute: 'notebook'
				message: "Notebook must be set"
		if _.isNaN(attrs.maxY)
			errors.push
				attribute: 'maxY'
				message: "maxY must be a number"
		if _.isNaN(attrs.minY)
			errors.push
				attribute: 'minY'
				message: "minY must be a number"

		if errors.length > 0
			return errors
		else
			return null

	isStub: ->
		return @get('lsLabels').length == 0 #protocol stubs won't have this

class window.ProtocolList extends Backbone.Collection
	model: Protocol

class window.AbstractProtocolParameterController extends AbstractFormController
#	template: _.template($("#AssayActivityView").html())
#	events:
#		"change .bv_assayActivity": "attributeChanged"
#		"click .bv_deleteActivity": "clear"

	initialize: ->
#		@errorOwnerName = 'AssayActivityController'
		@setBindings()
		@model.on "destroy", @remove, @


	render: =>
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@setUpParameterSelect()

		@

#	updateModel: =>
#		@model.set assayActivity: @$('.bv_assayActivity').val()
#		@model.triggerAmDirty()


	setUpParameterSelect: ->
		parameter = @model.get('parameter')
		formattedParameterName = parameter.replace(/([a-z](?=[A-Z]))/g, '$1 ')
		formattedParameterName = formattedParameterName.toLowerCase()
		@parameterList = new PickListList()
		@parameterList.url = "/api/dataDict/"+parameter+"Codes"
		@parameterList = new PickListSelectController
			el: @$('.bv_'+parameter)
			collection: @parameterList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select " + formattedParameterName
			selectedCode: @model.get(parameter)


	clear: =>
		@model.destroy()
		@model.triggerAmDirty()

class window.AssayActivityController extends AbstractProtocolParameterController
	template: _.template($("#AssayActivityView").html())
	events:
		"change .bv_assayActivity": "attributeChanged"
		"click .bv_deleteActivity": "clear"

	initialize: ->
		@errorOwnerName = 'AssayActivityController'
		super()
#		@setBindings()
#		@model.on "destroy", @remove, @
#
#
#	render: =>
#		$(@el).empty()
#		$(@el).html @template(@model.attributes)
#		@setUpAssayActivitySelect()
#
#		@
#
	updateModel: =>
		@model.set assayActivity: @$('.bv_assayActivity').val()
		@model.triggerAmDirty()


#	setUpAssayActivitySelect: ->
#		@assayActivityList = new PickListList()
#		@assayActivityList.url = "/api/dataDict/assayActivityCodes"
#		@assayActivityList = new PickListSelectController
#			el: @$('.bv_assayActivity')
#			collection: @assayActivityList
#			insertFirstOption: new PickList
#				code: "unassigned"
#				name: "Select Assay Activity"
#			selectedCode: @model.get('assayActivity')
#
#
#	clear: =>
#		@model.destroy()

class window.TargetOriginController extends AbstractProtocolParameterController
	template: _.template($("#TargetOriginView").html())
	events:
		"change .bv_targetOrigin": "attributeChanged"
		"click .bv_deleteTargetOrigin": "clear"

	initialize: ->
		@errorOwnerName = 'TargetOriginController'
		super()

	updateModel: =>
		@model.set targetOrigin: @$('.bv_targetOrigin').val()
		@model.triggerAmDirty()

class window.AssayTypeController extends AbstractProtocolParameterController
	template: _.template($("#AssayTypeView").html())
	events:
		"change .bv_assayType": "attributeChanged"
		"click .bv_deleteAssayType": "clear"

	initialize: ->
		@errorOwnerName = 'AssayTypeController'
		super()

	updateModel: =>
		@model.set assayType: @$('.bv_assayType').val()
		@model.triggerAmDirty()

class window.AssayTechnologyController extends AbstractProtocolParameterController
	template: _.template($("#AssayTechnologyView").html())
	events:
		"change .bv_assayTechnology": "attributeChanged"
		"click .bv_deleteAssayTechnology": "clear"

	initialize: ->
		@errorOwnerName = 'AssayTechnologyController'
		super()

	updateModel: =>
		@model.set assayTechnology: @$('.bv_assayTechnology').val()
		@model.triggerAmDirty()

class window.CellLineController extends AbstractProtocolParameterController
	template: _.template($("#CellLineView").html())
	events:
		"change .bv_cellLine": "attributeChanged"
		"click .bv_deleteCellLine": "clear"

	initialize: ->
		@errorOwnerName = 'CellLineController'
		super()

	updateModel: =>
		@model.set cellLine: @$('.bv_cellLine').val()
		@model.triggerAmDirty()



class window.AbstractProtocolParameterListController extends AbstractFormController
#	template: _.template($("#AssayActivityListView").html())
#	events:
#		"click .bv_addActivityButton": "addNewActivity"

	initialize: =>
		@collection.on 'remove', @checkForDuplicateSelections
		@collection.on 'remove', => @collection.trigger 'amDirty'
		@collection.on 'remove', => @collection.trigger 'change'


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@collection.each (parameter) =>
			@addOneSelectList(parameter)
		if @collection.length == 0
			@addNewSelectList()

		@

#	addNewSelectList: =>
#		newModel = new ()
#		@collection.add newModel
#		@addOneSelectList(newModel)
#		newModel.triggerAmDirty()


#	addOneSelectList: (parameter) ->
#		aac = new AssayActivityController
#			model: parameter
#		@$('.bv_assayActivityInfo').append aac.render().el


	checkForDuplicateSelections: =>
		if @collection.length == 0
			@addNewSelectList()


class window.AssayActivityListController extends AbstractProtocolParameterListController
	template: _.template($("#AssayActivityListView").html())
	events:
		"click .bv_addActivityButton": "addNewSelectList"

#	initialize: =>
#		@collection.on 'remove', @checkNumberOfActivities
#		@collection.on 'remove', => @collection.trigger 'amDirty'
#		@collection.on 'remove', => @collection.trigger 'change'
#
#
#	render: =>
#		$(@el).empty()
#		$(@el).html @template()
#		@collection.each (rule) =>
#			@addOneActivity(rule)
#		if @collection.length == 0
#			@addNewActivity()
#
#		@
#
	addNewSelectList: =>
		newModel = new AssayActivity()
		@collection.add newModel
		@addOneSelectList(newModel)
		newModel.triggerAmDirty()


	addOneSelectList: (parameter) ->
		aac = new AssayActivityController
			model: parameter
		@$('.bv_assayActivityInfo').append aac.render().el


#	checkNumberOfActivities: => #ensures that there is always one rule
#		if @collection.length == 0
#			@addNewActivity()

class window.TargetOriginListController extends AbstractProtocolParameterListController
	template: _.template($("#TargetOriginListView").html())
	events:
		"click .bv_addTargetOriginButton": "addNewSelectList"

	addNewSelectList: =>
		newModel = new TargetOrigin()
		@collection.add newModel
		@addOneSelectList(newModel)
		newModel.triggerAmDirty()


	addOneSelectList: (parameter) ->
		toc = new TargetOriginController
			model: parameter
		@$('.bv_targetOriginInfo').append toc.render().el

class window.AssayTypeListController extends AbstractProtocolParameterListController
	template: _.template($("#AssayTypeListView").html())
	events:
		"click .bv_addAssayTypeButton": "addNewSelectList"

	addNewSelectList: =>
		newModel = new AssayType()
		@collection.add newModel
		@addOneSelectList(newModel)
		newModel.triggerAmDirty()


	addOneSelectList: (parameter) ->
		atc = new AssayTypeController
			model: parameter
		@$('.bv_assayTypeInfo').append atc.render().el

class window.AssayTechnologyListController extends AbstractProtocolParameterListController
	template: _.template($("#AssayTechnologyListView").html())
	events:
		"click .bv_addAssayTechnologyButton": "addNewSelectList"

	addNewSelectList: =>
		newModel = new AssayTechnology()
		@collection.add newModel
		@addOneSelectList(newModel)
		newModel.triggerAmDirty()


	addOneSelectList: (parameter) ->
		atc = new AssayTechnologyController
			model: parameter
		@$('.bv_assayTechnologyInfo').append atc.render().el

class window.CellLineListController extends AbstractProtocolParameterListController
	template: _.template($("#CellLineListView").html())
	events:
		"click .bv_addCellLineButton": "addNewSelectList"

	addNewSelectList: =>
		newModel = new CellLine()
		@collection.add newModel
		@addOneSelectList(newModel)
		newModel.triggerAmDirty()


	addOneSelectList: (parameter) ->
		clc = new CellLineController
			model: parameter
		@$('.bv_cellLineInfo').append clc.render().el


class window.ProtocolBaseController extends BaseEntityController
	template: _.template($("#ProtocolBaseView").html())

	events: ->
		_(super()).extend(
			"change .bv_protocolName": "handleNameChanged"
			"change .bv_assayTreeRule": "attributeChanged"
			"click .bv_dnsTargetList": "attributeChanged"
			"change .bv_assayStage": "attributeChanged"
			"change .bv_maxY": "attributeChanged"
			"change .bv_minY": "attributeChanged"
		)

	initialize: ->
		unless @model?
			@model = new Protocol()
		@model.on 'sync', =>
			@trigger 'amClean'
			@$('.bv_saving').hide()
			@$('.bv_updateComplete').show()
			@render()
		@model.on 'change', =>
			@trigger 'amDirty'
			@$('.bv_updateComplete').hide()
		@errorOwnerName = 'ProtocolBaseController'
		@setBindings()
		$(@el).empty()
		$(@el).html @template(@model.attributes)
		@$('.bv_save').attr('disabled', 'disabled')
		@setupStatusSelect()
		@setupTagList()
		@model.getStatus().on 'change', @updateEditable
		@setupAssayStageSelect()
#	using the code above, triggers amDirty whenever the module is clicked. is this ok?

	render: =>
		@$('.bv_assayTreeRule').val(@model.get('assayTreeRule'))
		@$('.bv_dnsTargetList').val(@model.get('dnsTargetList'))
		@$('.bv_maxY').val(@model.get('maxY'))
		@$('.bv_minY').val(@model.get('minY'))
		@setupAssayStageSelect()
		@setupAssayActivityListController()
		@setupTargetOriginListController()
		@setupAssayTypeListController()
		@setupAssayTechnologyListController()
		@setupCellLineListController()
		super()
		@

	setupAssayStageSelect: ->
		@assayStageList = new PickListList()
		@assayStageList.url = "/api/dataDict/assayStageCodes"
		@assayStageListController = new PickListSelectController
			el: @$('.bv_assayStage')
			collection: @assayStageList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select assay stage"
			selectedCode: @model.get('assayStage')

	setupAssayActivityListController: ->
		@assayActivityListController= new AssayActivityListController
			el: @$('.bv_assayActivityList')
			collection: @model.get('assayActivityList')
		@assayActivityListController.render()

	setupTargetOriginListController: ->
		@targetOriginListController= new TargetOriginListController
			el: @$('.bv_targetOriginList')
			collection: @model.get('targetOriginList')
		@targetOriginListController.render()

	setupAssayTypeListController: ->
		@assayTypeListController= new AssayTypeListController
			el: @$('.bv_assayTypeList')
			collection: @model.get('assayTypeList')
		@assayTypeListController.render()

	setupAssayTechnologyListController: ->
		@assayTechnologyListController= new AssayTechnologyListController
			el: @$('.bv_assayTechnologyList')
			collection: @model.get('assayTechnologyList')
		@assayTechnologyListController.render()

	setupCellLineListController: ->
		@cellLineListController= new CellLineListController
			el: @$('.bv_cellLineList')
			collection: @model.get('cellLineList')
		@cellLineListController.render()

	updateModel: =>
		@model.set
			assayTreeRule: @getTrimmedInput('.bv_assayTreeRule')
			dnsTargetList: @$('.bv_dnsTargetList').is(":checked")
			assayStage: @$('.bv_assayStage').val()
			maxY: parseFloat(@getTrimmedInput('.bv_maxY'))
			minY: parseFloat(@getTrimmedInput('.bv_minY'))