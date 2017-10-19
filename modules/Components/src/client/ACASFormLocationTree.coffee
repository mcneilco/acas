class window.ACASFormLocationTreeController extends ACASFormAbstractFieldController
	###
		Launching controller must:
		- Initialize the model with an LSValue
    Do whatever else is required or optional in ACASFormAbstractFieldController
	###
	events: ->
		"click .bv_editIcon": "handleEditIconClicked"
		"click .bv_searchClear": "handleSearchClear"
		"click .bv_updateLocation": "handleUpdateLocationClicked"

	template: _.template($("#ACASFormLocationTreeView").html())

	initialize: ->
		super()
		@tubeCode = @options.tubeCode
		if @tubeCode?
			$.ajax
				type: 'POST'
				url: "/api/getBreadCrumbByContainerCode"
				data: JSON.stringify [@tubeCode]
				contentType: 'application/json'
				success: (response) =>
					if response.length is 1
						@getModel().set
							value: response[0].currentLocationCode
							ignored: false
							breadcrumb: response[0].labelBreadCrumb
					else
						@getModel().set
							value: null
							ignored: false
							breadcrumb: ""
					@renderModelContent()

				error: (err) =>
					alert 'error getting breadcrumb for container'


	setEmptyValue: ->
		@getModel().set
			value: null
			ignored: true
			breadcrumb: null

	setInputValue: (inputValue) ->
		@$('input').val inputValue


	renderModelContent: =>
		@$('input').val @getModel().get('breadcrumb')
		super()

	handleEditIconClicked: =>
		@$('.bv_locationTreeModal').modal
			backdrop: 'static'
		@getContainerLocationTree()

	getContainerLocationTree: =>
		$.ajax
			type: 'GET'
			url: "/api/getContainerLocationTree"
			dataType: 'json'
			error: (err) =>
				alert 'Could not get container location tree. Please contact administrator'
				@$('.bv_locationTreeModal').modal 'hide'
			success: (json) =>
				@setupTree (json)

	setupTree: (locationTreeObj) ->
		_.map locationTreeObj, (loc) =>
			loc.icon = false

		@$('.bv_locationTree').jstree
			core:
				data: locationTreeObj
			search:
				fuzzy: false
				show_only_matches: true
			plugins: ["search"]

		@$('.bv_locationTree').bind "hover_node.jstree", (e, data) ->
			$(e.target).attr("title", data.node.original.breadcrumb)
		@$('.bv_locationTree').bind "select_node.jstree", (e, data) =>
			if data.selected.length is 1
				@$('.bv_updateLocation').removeAttr 'disabled'
			else
				@$('.bv_updateLocation').attr 'disabled', 'disabled'

		to = false
		@$(".bv_searchVal").keyup =>
			clearTimeout to  if to
			to = setTimeout(->
				v = @$(".bv_searchVal").val()
				@$(".bv_locationTree").jstree(true).search v
				return
			, 250)
			return

		selectedLocation = @getModel().get('value')
		if selectedLocation? and $.trim(selectedLocation) != ""
			@$(".bv_locationTree").jstree('show_node', selectedLocation)
			@$(".bv_locationTree").jstree('select_node', selectedLocation)

	handleSearchClear: =>
		@$('.bv_searchVal').val("")


	handleUpdateLocationClicked: =>
		selectedLocation = @$('.bv_locationTree').jstree('get_selected', true)
		@$('.bv_locationTreeModal').modal 'hide'
		value = selectedLocation[0].original.id
		breadcrumb = selectedLocation[0].original.breadcrumb

		@$('input').val breadcrumb
		@handleInputChanged(value, breadcrumb)

	handleInputChanged: (value, breadcrumb) =>
		@clearError()
		@userInputEvent = true
		if value == ""
			@setEmptyValue()
		else
			@getModel().set
				value: value
				ignored: false
				breadcrumb: breadcrumb
		@checkEmptyAndRequired()
		@trigger 'formFieldChanged'
