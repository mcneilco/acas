class window.LotPropertyBulkLoader extends Backbone.Model
	defaults:
		overwriteExisting: false

	validate: (attrs) =>
		errors = []
		return null


class window.LotPropertyBulkLoaderController extends AbstractParserFormController
	template: _.template($("#LotPropertyBulkLoaderView").html())

	events:
		"change .bv_overwriteExisting": "handleOverwriteExistingCheckboxChanged"

	initialize: ->
		@errorOwnerName = 'LotPropertyBulkLoaderController'
		$(@el).html @template @model.attributes
		@setBindings()
		@setupProjectSelect()
		@setupProtocolSelect("Lot Property Bulk Loader")

	render: =>
		super()
		@

	updateModel: ->
		@trigger 'amDirty'

	handleOverwriteExistingCheckboxChanged: () =>
		overwriteExisting = @$('.bv_overwriteExisting').is(":checked")
		@model.set overwriteExisting: overwriteExisting
		@attributeChanged()


class window.LotPropertyBulkLoaderParserController extends BasicFileValidateAndSaveController
	template: _.template($("#BasicFileValidateAndSaveViewLotPropertyBulkLoader").html())

	initialize: ->
		@fileProcessorURL = "/api/LotPropertyBulkLoader/fileProcessor"
		@errorOwnerName = 'LotPropertyBulkLoaderController'
		@allowedFileTypes = ['xls','xlsx', 'csv']
		@loadReportFile = false
		super()
		@$('.bv_moduleTitle').html('Lot Property Bulk Loader')

		@lpblc = new LotPropertyBulkLoaderController
			model: new LotPropertyBulkLoader()
			el: @$('.bv_additionalValuesForm')
		@lpblc.on 'valid', @handleLPBLFormValid
		@lpblc.on 'invalid', @handleLPBLFormInvalid
		@lpblc.on 'notifyError', @notificationController.addNotification
		@lpblc.on 'clearErrors', @notificationController.clearAllNotificiations
		@lpblc.on 'amDirty', =>
			@trigger 'amDirty'
		@lpblc.render()

	handleLPBLFormValid: =>
		if @parseFileUploaded
			@handleFormValid()

	handleLPBLFormInvalid: =>
		@handleFormInvalid()

	handleFormValid: ->
		if @lpblc.isValid()
			super()

	handleValidationReturnSuccess: (json) =>
		@additionalData =
			inputParameters: @lpblc.model.toJSON()
		super(json)
		@lpblc.disableAllInputs()

	showFileSelectPhase: ->
		super()
		if @lpblc?
			@lpblc.enableAllInputs()

	validateParseFile: =>
		@lpblc.updateModel()
		unless !@lpblc.isValid()
			@additionalData =
				inputParameters: @lpblc.model.toJSON()
			super()

	validateParseFile: =>
		@lpblc.updateModel()
		unless !@lpblc.isValid()
			@additionalData =
				inputParameters: @lpblc.model.toJSON()
			super()

