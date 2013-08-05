class window.Pampa extends Backbone.Model
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

class window.PampaController extends AbstractParserFormController
	template: _.template($("#PampaView").html())

	events:
		'change .bv_protocolName': "attributeChanged"
		'change .bv_scientist': "attributeChanged"
		'change .bv_notebook': "attributeChanged"
		'change .bv_project': "attributeChanged"

	initialize: ->
		@errorOwnerName = 'PampaController'
		super()
		@setupProjectSelect()
		@setupProtocolSelect("pampa")

	render: =>
		super()
		@

	updateModel: ->
		@model.set
			protocolName: @$('.bv_protocolName').find(":selected").text()
			scientist: @getTrimmedInput('.bv_scientist')
			notebook: @getTrimmedInput('.bv_notebook')
			project: @getTrimmedInput('.bv_project')
		@trigger 'amDirty'



class window.PampaParserController extends BasicFileValidateAndSaveController

	initialize: ->
		@fileProcessorURL = "/api/pampaParser"
		@errorOwnerName = 'PampaParserController'
		@loadReportFile = false
		super()
		@$('.bv_moduleTitle').html('Pampa Experiment Loader')
		@msc = new PampaController
			model: new Pampa()
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
