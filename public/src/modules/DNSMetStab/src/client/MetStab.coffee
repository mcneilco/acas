class window.MetStab extends Backbone.Model
	defaults:
		protocolName: ""
		scientist: ""
		notebook: ""
		project: ""
		assayDate: null

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
		if _.isNaN(attrs.assayDate)
			errors.push
				attribute: 'assayDate'
				message: "Assay date must be set"

		if errors.length > 0
			return errors
		else
			return null

class window.MetStabController extends AbstractParserFormController
	template: _.template($("#MetStabView").html())

	events:
		'change .bv_protocolName': "attributeChanged"
		'change .bv_scientist': "attributeChanged"
		'change .bv_notebook': "attributeChanged"
		'change .bv_project': "attributeChanged"
		'change .bv_assayDate': "attributeChanged"

	initialize: ->
		@errorOwnerName = 'MetStabController'
		super()
		@setupProjectSelect()
		@setupProtocolSelect("Microsome Stability")

	render: =>
		super()
		@$('.bv_assayDate').datepicker( );
		@$('.bv_assayDate').datepicker( "option", "dateFormat", "yy-mm-dd" );
		if @model.get('assayDate') != null
			date = new Date(@model.get('assayDate'))
			@$('.bv_assayDate').val(date.getFullYear()+'-'+date.getMonth()+'-'+date.getDate())
		@

	updateModel: ->
		@model.set
			protocolName: @$('.bv_protocolName').find(":selected").text()
			scientist: @getTrimmedInput('.bv_scientist')
			notebook: @getTrimmedInput('.bv_notebook')
			project: @getTrimmedInput('.bv_project')
			assayDate: @convertYMDDateToMs(@getTrimmedInput('.bv_assayDate'))
		@trigger 'amDirty'



class window.MetStabParserController extends BasicFileValidateAndSaveController

	initialize: ->
		@fileProcessorURL = "/api/metStabParser"
		@errorOwnerName = 'MetStabParserController'
		@loadReportFile = false
		super()
		@$('.bv_moduleTitle').html('MetStab Experiment Loader')
		@msc = new MetStabController
			model: new MetStab()
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
		@msc.showCSVPreview json.results.csvDataPreview

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
