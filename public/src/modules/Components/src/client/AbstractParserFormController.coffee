class window.AbstractParserFormController extends AbstractFormController

	initialize: ->
		$(@el).html @template()
		@setBindings()

	render: =>
		@

	attributeChanged: =>
		@trigger 'amDirty'
		@updateModel()

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

	setupProtocolSelect: (search) ->
		@protocolList = new PickListList()
		#		@protocolList.url = "api/protocolCodes"
		@protocolList.url = "api/protocolCodes/filter/"+search
		@protocolListController = new PickListSelectController
			el: @$('.bv_protocolName')
			collection: @protocolList
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Protocol"
			selectedCode: "unassigned"

	enableAllInputs: ->
		super()
		@$('.bv_csvPreviewContainer').hide()
