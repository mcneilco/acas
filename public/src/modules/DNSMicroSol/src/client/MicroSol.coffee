class window.MicroSol extends Backbone.Model
	defaults:
		protocolName: ""
		scientist: ""
		notebook: ""
		project: ""

	validate: (attrs) ->
		errors = []
		if  attrs.protocolName == "Select Protocol"
			errors.push
				attribute: 'protocolName'
				message: "Protocol Name must be provided"
		if attrs.scientist == ""
			errors.push
				attribute: 'scientist'
				message: "Scientist must be provided"
		if attrs.notebook == ""
			errors.push
				attribute: 'notebook'
				message: "Notebook must be provided"
		if attrs.project == "unassigned"
			errors.push
				attribute: 'project'
				message: "Project must be provided"

		if errors.length > 0
			return errors
		else
			return null

class window.MicroSolController extends AbstractFormController
	template: _.template($("#MicroSolView").html())

	events:
		'change .bv_protocolName': "attributeChanged"
		'change .bv_scientist': "attributeChanged"
		'change .bv_notebook': "attributeChanged"
		'change .bv_project': "attributeChanged"

	initialize: ->
		@errorOwnerName = 'MicroSolController'
		$(@el).html @template()
		@setBindings()
		@setupProjectSelect()
		@setupProtocolSelect()

	render: =>
		@

	attributeChanged: =>
		@trigger 'amDirty'
		@updateModel()

	updateModel: ->
		@model.set
			protocolName: @$('.bv_protocolName').find(":selected").text()
			scientist: @getTrimmedInput('.bv_scientist')
			notebook: @getTrimmedInput('.bv_notebook')
			project: @getTrimmedInput('.bv_project')
		@trigger 'amDirty'

	setupProjectSelect: ->
		@projectList = new PickListList()
		@projectList.url = "/api/projects"
		@projectListController = new PickListSelectController
			el: @$('.bv_project')
			collection: @projectList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Project"
			selectedCode: "unassigned"

	setupProtocolSelect: ->
		@protocolList = new PickListList()
#		@protocolList.url = "api/protocolCodes"
		@protocolList.url = "api/protocolCodes/filter/uSol"
		@protocolListController = new PickListSelectController
			el: @$('.bv_protocolName')
			collection: @protocolList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Protocol"
			selectedCode: "unassigned"

	disableAllInputs: ->
		@$('input').attr 'disabled', 'disabled'
		@$('select').attr 'disabled', 'disabled'

	enableAllInputs: ->
		@$('input').removeAttr 'disabled'
		@$('select').removeAttr 'disabled'

class window.MicroSolParserController extends BasicFileValidateAndSaveController

	initialize: ->
		@fileProcessorURL = "/api/microSolParser"
		@errorOwnerName = 'MicroSolParserController'
		@loadReportFile = false
		super()
		@$('.bv_moduleTitle').html('Micro Solubility Experiment Loader')
		@msc = new MicroSolController
			model: new MicroSol()
			el: @$('.bv_additionalValuesForm')
		@msc.on 'valid', @handleMSFormValid
		@msc.on 'invalid', @handleMSFormInvalid
		@msc.on 'notifyError', @notificationController.addNotification
		@msc.on 'clearErrors', @notificationController.clearAllNotificiations
		@msc.on 'amDirty', =>
			@trigger 'amDirty'
		@msc.render()

	handleMSFormValid: =>
		if @parseFileUploaded
			@handleFormValid()

	handleMSFormInvalid: =>
		@handleFormInvalid()

	handleFormValid: ->
		if @msc.isValid()
			super()

	handleValidationReturnSuccess: (json) =>
		super(json)
		@msc.disableAllInputs()

	showFileSelectPhase: ->
		super()
		if @msc?
			@msc.enableAllInputs()

	validateParseFile: =>
		@msc.updateModel()
		unless !@msc.isValid()
			@additionalData =
				inputParameters: @msc.model.toJSON()
			super()

	validateParseFile: =>
		@msc.updateModel()
		unless !@msc.isValid()
			@additionalData =
				inputParameters: @msc.model.toJSON()
			super()
