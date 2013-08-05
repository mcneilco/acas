class window.AbstractParserFormController extends AbstractFormController

	initialize: ->
		$(@el).html @template()
		@setBindings()

	render: =>
		@$('.bv_csvPreviewContainer').hide()
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

	disableAllInputs: ->
		@$('input').attr 'disabled', 'disabled'
		@$('select').attr 'disabled', 'disabled'

	enableAllInputs: ->
		@$('input').removeAttr 'disabled'
		@$('select').removeAttr 'disabled'
		@$('.bv_csvPreviewContainer').hide()

	showCSVPreview: (csv) ->
		@$('.csvPreviewTHead').empty()
		@$('.csvPreviewTBody').empty()

		csvRows = csv.split('\n')
		headCells = csvRows[0].split(',')
		@$('.csvPreviewTHead').append "<tr></tr>"
		for val in  headCells
			@$('.csvPreviewTHead tr').append "<th>"+val+"</th>"
		for r in [1..csvRows.length-2]
			@$('.csvPreviewTBody').append "<tr></tr>"
			rowCells = csvRows[r].split(',')
			for val in rowCells
				@$('.csvPreviewTBody tr:last').append "<td>"+val+"</td>"

		@$('.bv_csvPreviewContainer').show()

