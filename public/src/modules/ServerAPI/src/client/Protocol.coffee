class window.Protocol extends BaseEntity
	urlRoot: "/api/protocols"

	defaults: ->
		_(super()).extend(
			assayTreeRule: null
#			assayPrinciple:
#			attachFiles: new AttachFilesList()
		)

	initialize: ->
		@.set subclass: "protocol"
		super()

	validate: (attrs) ->
		errors = []
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
		cDate = @getCompletionDate().get('dateValue')
		if cDate is undefined or cDate is "" then cDate = "fred"
		if isNaN(cDate)
			errors.push
				attribute: 'completionDate'
				message: "Assay completion date must be set"
		notebook = @getNotebook().get('stringValue')
		if notebook is "" or notebook is "unassigned" or notebook is undefined
			errors.push
				attribute: 'notebook'
				message: "Notebook must be set"

		if errors.length > 0
			return errors
		else
			return null

	isStub: ->
		return @get('lsLabels').length == 0 #protocol stubs won't have this

class window.ProtocolList extends Backbone.Collection
	model: Protocol

class window.ProtocolBaseController extends BaseEntityController
	template: _.template($("#ProtocolBaseView").html())

	events: ->
		_(super()).extend(
			"change .bv_protocolName": "handleNameChanged"
			"change .bv_assayTreeRule": "attributeChanged"
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

	render: =>
		@$('.bv_assayTreeRule').val(@model.get('assayTreeRule'))
		super()
		@


	updateModel: =>
		@model.set
			assayTreeRule: @getTrimmedInput('.bv_assayTreeRule')

