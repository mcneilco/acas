class window.CustomMetadataValueController extends Backbone.View
	template: _.template($("#CustomExperimentMetaDataValueView").html())
	events: ->
		"change .bv_value": "handleValueInputChanged"

	initialize: ->
		@experiment = @options.experiment
		@lsType = @model.get 'lsType'

	render: ->
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_label').text(@model.get 'lsKind')
		@$('.bv_value').val(@model.get @lsType)
		@

	handleValueInputChanged: =>
		value = UtilityFunctions::getTrimmedInput @$('.bv_value')
		@handleValueChanged value

	handleValueChanged: (value) =>
		currentVal = 	@experiment.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "custom experiment metadata", @model.get('lsType'), @model.get('lsKind')
		unless currentVal.isNew()
			currentVal.set ignored: true
			currentVal = @experiment.get('lsStates').getOrCreateValueByTypeAndKind "metadata", "custom experiment metadata", @model.get('lsType'), @model.get('lsKind')
		currentVal.set currentVal.get('lsType'), value
		currentVal.set 'codeType', @model.get 'codeType'
		currentVal.set 'codeKind',  @model.get 'codeKind'
		currentVal.set 'codeOrigin', @model.get 'codeOrigin'
		@model = currentVal
		@

class window.CustomMetadataClobValueController extends CustomMetadataValueController
	template: _.template($("#CustomExperimentMetaDataClobValueView").html())

class window.CustomMetadataCodeValueController extends CustomMetadataValueController
	template: _.template($("#CustomExperimentMetaDataCodeValueView").html())

	render: ->
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_label').text(@model.get 'lsKind')
		@valueList = new PickListList()
		@valueList.url = "/api/codetables/#{@model.get 'codeType'}/#{@model.get 'codeKind'}"
		console.log @model.get('codeValue')
		console.log @valueList
		@valueListController = new PickListSelectController
			el: @$('.bv_value')
			collection: @valueList
			selectedCode: @model.get 'codeValue'
		@

class window.CustomMetadataNumericValueController extends CustomMetadataValueController
	template: _.template($("#CustomExperimentMetaDataNumericValueView").html())
	events: ->
		"keyup .bv_value": "handleValueInputChanged"

class window.CustomMetadataStringValueController extends CustomMetadataValueController
	template: _.template($("#CustomExperimentMetaDataStringValueView").html())
	events: ->
		"keyup .bv_value": "handleValueInputChanged"

class window.CustomMetadataURLValueController extends CustomMetadataValueController
	template: _.template($("#CustomExperimentMetaDataURLValueView").html())
	events: ->
		"keyup .bv_value": "handleValueInputChanged"
		"click .bv_link_btn": "handleLinkButtonClicked"

	handleLinkButtonClicked: ->
		url = UtilityFunctions::getTrimmedInput @$('.bv_value')
		window.open(url);


class window.CustomExperimentMetadataListController extends Backbone.View
	template: _.template($("#CustomExperimentMetaDataListView").html())

	initialize: ->
		# Get custom metadata values from experiment
		experimentStates = @model.get('lsStates')
		customExperimentMetaDataStateArray = experimentStates.getStatesByTypeAndKind "metadata", "custom experiment metadata"
		customExperimentMetaDataState = customExperimentMetaDataStateArray[0]
		@lsState = customExperimentMetaDataState

		# Set the values to render
		@toRender = @getRenderValues()

	render: =>
		$(@el).empty()
		$(@el).html @template()

		# Create value controller for each value in collection
		@toRender.each (value) =>
			type = value.get 'lsType'
			customExperimentMetaDataValueControllerType = switch type
				when "clobValue" then CustomMetadataClobValueController
				when "codeValue" then CustomMetadataCodeValueController
				when "numericValue" then CustomMetadataNumericValueController
				when "stringValue" then CustomMetadataStringValueController
				when "urlValue" then CustomMetadataURLValueController

		# Pass the model and state to the controller (the state is passed so that the controller can add or create models
			customMetadataValueController = new customExperimentMetaDataValueControllerType
				model: value
				experiment: @model
			@$('.bv_custom_metadata').append customMetadataValueController.render().el

	getGuiDescriptor: =>
		guiDescriptorValue = @model.get('lsStates').getStateValueByTypeAndKind("metadata", "custom experiment metadata gui", "clobValue", "GUI descriptor")
		guiDescriptor = new Backbone.Collection JSON.parse(guiDescriptorValue.get('clobValue'))
		guiDescriptor

	getRenderValues: =>
		# Get all the values
		values = @lsState.get 'lsValues'

		# Get gui descriptor from experiment
		guiDescriptor = @getGuiDescriptor()

		# Sort the custom experiment metadata values by the gui descriptor
		values.comparator = (value) =>
			order = guiDescriptor.filter (v) =>
				(v.get('lsType')==value.get('lsType') and v.get('lsKind')==value.get('lsKind'))
			order[0].get 'displayOrder'
		values.sort()
		values.comparator = undefined

		# Filter out ignored values so not to render them
		toRender = values.filter (value) ->
			!value.get('ignored')
		toRender = new Backbone.Collection toRender
		toRender
