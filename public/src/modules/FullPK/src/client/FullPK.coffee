class window.FullPK extends Backbone.Model
	defaults:
		format: "In Vivo Full PK"
		protocolName: ""
		experimentName: ""
		scientist: ""
		notebook: ""
		inLifeNotebook: ""
		assayDate: null
		project: ""
		bioavailability: ""
		aucType: ""

	validate: (attrs) ->
		errors = []
		if  attrs.protocolName == ""
			errors.push
				attribute: 'protocolName'
				message: "Protocol Name must be provided"
		if attrs.experimentName == ""
			errors.push
				attribute: 'experimentName'
				message: "Experiment Name must be provided"
		if attrs.scientist == ""
			errors.push
				attribute: 'scientist'
				message: "Scientist must be provided"
		if attrs.notebook == ""
			errors.push
				attribute: 'notebook'
				message: "Notebook must be provided"
		if attrs.inLifeNotebook == ""
			errors.push
				attribute: 'inLifeNotebook'
				message: "inLifeNotebook must be provided"
		if attrs.project == "unassigned"
			errors.push
				attribute: 'project'
				message: "Project must be provided"
		if attrs.bioavailability == ""
			errors.push
				attribute: 'bioavailability'
				message: "Bioavailability must be provided"
		if attrs.aucType == ""
			errors.push
				attribute: 'aucType'
				message: "AUC Type must be provided"
		if _.isNaN(attrs.assayDate)
			errors.push
				attribute: 'assayDate'
				message: "Assay date must be set"

		if errors.length > 0
			return errors
		else
			return null

class window.FullPKController extends AbstractFormController
	template: _.template($("#FullPKView").html())

	events:
		'change .bv_protocolName': "attributeChanged"
		'change .bv_experimentName': "attributeChanged"
		'change .bv_scientist': "attributeChanged"
		'change .bv_notebook': "attributeChanged"
		'change .bv_inLifeNotebook': "attributeChanged"
		'change .bv_project': "attributeChanged"
		'change .bv_bioavailability': "attributeChanged"
		'change .bv_aucType': "attributeChanged"
		'change .bv_assayDate': "attributeChanged"

	initialize: ->
		@errorOwnerName = 'FullPKController'
		$(@el).html @template()
		@setBindings()
		@setupProjectSelect()

	render: =>
		@$('.bv_assayDate').datepicker( );
		@$('.bv_assayDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.get('assayDate') != null
			date = new Date(@model.get('assayDate'))
			@$('.bv_assayDate').val(date.getFullYear()+'-'+date.getMonth()+'-'+date.getDate())
		@

	attributeChanged: =>
		@trigger 'amDirty'
		@updateModel()

	updateModel: ->
		@model.set
			protocolName: @$('.bv_protocolName').val()
			experimentName: @$('.bv_experimentName').val()
			scientist: @$('.bv_scientist').val()
			notebook: @$('.bv_notebook').val()
			inLifeNotebook: @$('.bv_inLifeNotebook').val()
			project: @$('.bv_project').val()
			bioavailability: @$('.bv_bioavailability').val()
			aucType: @$('.bv_aucType').val()
			assayDate: new Date(@$('.bv_assayDate').val().trim()).getTime()

	setupProjectSelect: ->
		@projectList = new PickListList()
		@projectList.url = "/api/projects"
		@projectListController = new PickListSelectController
			el: @$('.bv_project')
			collection: @projectList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Category"
			selectedCode: "unassigned"

	disableAllInputs: ->
		@$('input').attr 'disabled', 'disabled'
		@$('select').attr 'disabled', 'disabled'

	enableAllInputs: ->
		@$('input').removeAttr 'disabled'


class window.FullPKParserController extends BasicFileValidateAndSaveController

	initialize: ->
		@fileProcessorURL = "/api/fullPKParser"
		@errorOwnerName = 'FullPKParser'
		@loadReportFile = true
		super()
		@$('.bv_moduleTitle').html('Full PK Experiment Loader')
		@fpkc = new FullPKController
			model: new FullPK()
			el: @$('.bv_additionalValuesForm')
		@fpkc.on 'valid', @handleFPKFormValid
		@fpkc.on 'invalid', @handleFPKFormInvalid
		@fpkc.on 'notifyError', @notificationController.addNotification
		@fpkc.on 'clearErrors', @notificationController.clearAllNotificiations
		@fpkc.render()

	handleFPKFormValid: =>
		if @parseFileUploaded
			@handleFormValid()

	handleFPKFormInvalid: =>
		@handleFormInvalid()

	handleFormValid: ->
		if @fpkc.isValid()
			super()

	handleValidationReturnSuccess: (json) =>
		super(json)
		@fpkc.disableAllInputs()

	showFileSelectPhase: ->
		super()
		if @fpkc?
			@fpkc.enableAllInputs()

	validateParseFile: =>
		@fpkc.updateModel()
		unless !@fpkc.isValid()
			@additionalData =
				inputParameters: @fpkc.model.toJSON()
			super()

	#TODO fix the date validation and model set