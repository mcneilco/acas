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

		if errors.length > 0
			return errors
		else
			return null

class window.FullPKController extends AbstractFormController
	template: _.template($("#FullPKView").html())

	events:
		'change .bv_protocolName': "attributeChanged"

	initialize: ->
		@errorOwnerName = 'FullPKController'
		$(@el).html @template()
		@setBindings()
		@setupProjectSelect()

	render: =>
		@

	attributeChanged: =>
		console.log "got attr changed"
		@trigger 'amDirty'
		@updateModel()

	updateModel: ->
		@model.set
			protocolName: @$('.bv_protocolName').val()

	setupProjectSelect: ->
		console.log @$('.bv_project')
		@projectList = new PickListList()
		@projectList.url = "/api/projects"
		@projectListController = new PickListSelectController
			el: @$('.bv_project')
			collection: @projectList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Category"
			selectedCode: "unassigned"


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
		@fpkc.render()


