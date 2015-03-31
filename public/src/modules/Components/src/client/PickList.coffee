class window.PickList extends Backbone.Model

class window.PickListList extends Backbone.Collection
	model: PickList

	setType: (type) ->
		@type = type

	getModelWithId: (id) ->
		@detect (enu) ->
			enu.get("id") is id

	getModelWithCode: (code) ->
		@detect (enu) ->
			enu.get("code") is code

	getCurrent: ->
		@filter (pl) ->
			!(pl.get 'ignored')

class window.PickListOptionController extends Backbone.View
	tagName: "option"
	initialize: ->

	render: =>
		$(@el).attr("value", @model.get("code")).text @model.get("name")
		@

class window.PickListOptionControllerForLsThing extends Backbone.View
	tagName: "option"
	initialize: ->
		if @options.insertFirstOption?
			@insertFirstOption = @options.insertFirstOption
		else
			@insertFirstOption = null

	render: =>
		preferredNames = _.filter @model.get('lsLabels'), (lab) ->
			lab.preferred && (lab.lsType == "name") && !lab.ignored
		bestName = _.max preferredNames, (lab) ->
			rd = lab.recordedDate
			(if (rd is "") then Infinity else rd)
		if bestName?
			displayValue = bestName.labelText
		else
			displayValue = @insertFirstOption.get('name')
		$(@el).attr("value", @model.get("id")).text displayValue
		@


class window.PickListSelectController extends Backbone.View
	initialize: ->
		@rendered = false
		@collection.bind "add", @addOne
		@collection.bind "reset", @handleListReset

		unless @options.selectedCode is ""
			@selectedCode = @options.selectedCode
		else
			@selectedCode = null

		if @options.showIgnored?
			@showIgnored = @options.showIgnored
		else
			@showIgnored = false

		if @options.insertFirstOption?
			@insertFirstOption = @options.insertFirstOption
		else
			@insertFirstOption = null


		if @options.autoFetch?
			@autoFetch = @options.autoFetch
		else
			@autoFetch = true

		if @autoFetch == true
			@collection.fetch
				success: @handleListReset
		else
			@handleListReset()


	handleListReset: =>
		if @insertFirstOption
			@collection.add @insertFirstOption,
				at: 0
				silent: true
			unless (@selectedCode is @insertFirstOption.get('code'))
				if (@collection.where({code: @selectedCode})).length is 0
					newOption = new PickList
						code: @selectedCode
						name: @selectedCode
					@collection.add newOption
		@render()

	render: =>
		$(@el).empty()
		self = this
		@collection.each (enm) =>
			@addOne enm

		$(@el).val @selectedCode  if @selectedCode

		# hack to fix IE bug where select doesn't work when dynamically inserted
		$(@el).hide()
		$(@el).show()
		@rendered = true

	addOne: (enm) =>
		shouldRender = @showIgnored
		if enm.get 'ignored'
			if @selectedCode?
				if @selectedCode is enm.get 'code'
					shouldRender = true
		else
			shouldRender = true

		if shouldRender
			$(@el).append new PickListOptionController(model: enm).render().el

	setSelectedCode: (code) ->
		@selectedCode = code
		#		$(@el).val @selectedCode  if @rendered
		if @rendered
			$(@el).val @selectedCode
		else
			"not done"

	getSelectedCode: ->
		$(@el).val()

	getSelectedModel: ->
		@collection.getModelWithCode @getSelectedCode()

	checkOptionInCollection: (code) => #checks to see if option already exists in the picklist list
		return @collection.findWhere({code: code})

class window.PickListForLsThingsSelectController extends PickListSelectController
	addOne: (enm) =>
		shouldRender = @showIgnored
		if enm.get 'ignored'
			if @selectedCode?
				if @selectedCode is enm.get 'code'
					shouldRender = true
		else
			shouldRender = true

		if shouldRender
			$(@el).append new PickListOptionControllerForLsThing(model: enm, insertFirstOption: @insertFirstOption).render().el

	getSelectedModel: ->
		@collection.getModelWithId parseInt(@getSelectedCode())


class window.AddParameterOptionPanel extends Backbone.Model
	defaults:
		parameter: null
		codeType: null
		codeOrigin: "ACAS DDICT"
		codeKind: null
		newOptionLabel: null
		newOptionDescription: null
		newOptionComments: null

	validate: (attrs) ->
		errors = []
		if attrs.newOptionLabel is null or attrs.newOptionLabel is ""
			errors.push
				attribute: 'newOptionLabel'
				message: "Label must be set"
		if errors.length > 0
			return errors
		else
			return null




class window.AddParameterOptionPanelController extends AbstractFormController
	template: _.template($("#AddParameterOptionPanelView").html())

	events:
		"change .bv_newOptionLabel": "attributeChanged"
		"change .bv_newOptionDescription": "attributeChanged"
		"change .bv_newOptionComments": "attributeChanged"
		"click .bv_addNewParameterOption": "triggerAddRequest" #.bv_addNewParameterOption adds the option to the picklist

	initialize: ->
		@errorOwnerName = 'AddParameterOptionPanelController'
		@setBindings()


	render: =>
		$(@el).empty()
		$(@el).html @template()
		@$('.bv_addParameterOptionModal').on 'hidden.bs.modal', =>
			@trigger 'hideModal'
		@$('.bv_addParameterOptionModal').on 'show.bs.modal', =>
			@trigger 'showModal'
		@showModal()


		@

	showModal: =>
		@$('.bv_addParameterOptionModal').modal('show')
		parameterNameWithSpaces = @model.get('parameter').replace /([A-Z])/g,' $1'
		pascalCaseParameterName = (parameterNameWithSpaces).charAt(0).toUpperCase() + (parameterNameWithSpaces).slice(1)
		@$('.bv_parameter').html(pascalCaseParameterName)

	hideModal: ->
		@$('.bv_addParameterOptionModal').modal('hide')

	updateModel: =>
		@model.set
			newOptionLabel: UtilityFunctions::getTrimmedInput @$('.bv_newOptionLabel')
			newOptionDescription: UtilityFunctions::getTrimmedInput @$('.bv_newOptionDescription')
			newOptionComments: UtilityFunctions::getTrimmedInput @$('.bv_newOptionComments')

	triggerAddRequest: =>
		@trigger 'addOptionRequested'

	validationError: =>
		super()
		@$('.bv_addNewParameterOption').attr('disabled', 'disabled')

	clearValidationErrorStyles: =>
		super()
		@$('.bv_addNewParameterOption').removeAttr('disabled')



class window.EditablePickListSelectController extends Backbone.View
	template: _.template($("#EditablePickListView").html())

	#when creating new controller, need to provide el, collection, selectedCode, parameter, and roles
	#will also need to call render to show the controller
	events:
		"click .bv_addOptionBtn": "handleShowAddPanel"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupEditablePickList()
		#		@setupContextMenu()
		@setupEditingPrivileges()


	setupEditablePickList: ->
		parameterNameWithSpaces = @options.parameter.replace /([A-Z])/g,' $1'
		pascalCaseParameterName = (parameterNameWithSpaces).charAt(0).toUpperCase() + (parameterNameWithSpaces).slice(1)
		@pickListController = new PickListSelectController
			el: @$('.bv_parameterSelectList')
			collection: @collection
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select "+pascalCaseParameterName
			selectedCode: @options.selectedCode

	setupEditingPrivileges: =>
		if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, @options.roles
			@$('.bv_tooltipWrapper').removeAttr('data-toggle')
			@$('.bv_tooltipWrapper').removeAttr('data-original-title')

		else
			@$('.bv_addOptionBtn').removeAttr('data-toggle')
			@$('.bv_addOptionBtn').removeAttr('data-target')
			@$('.bv_addOptionBtn').removeAttr('data-backdrop')
			@$('.bv_addOptionBtn').css({'color':"#cccccc"})
			@$('.bv_tooltipWrapper').tooltip()
			@$("body").tooltip selector: '.bv_tooltipWrapper'

	getSelectedCode: ->
		@pickListController.getSelectedCode()

	setSelectedCode: (code) ->
		@pickListController.setSelectedCode(code)

	handleShowAddPanel: =>
		if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, @options.roles
			unless @addPanelController?
				@addPanelController = new AddParameterOptionPanelController
					model: new AddParameterOptionPanel
						parameter: @options.parameter
						codeType: @options.codeType
						codeKind: @options.codeKind
					el: @$('.bv_addOptionPanel')
				@addPanelController.on 'addOptionRequested', @handleAddOptionRequested
				@addPanelController.on 'showModal', =>
					@trigger 'showModal'
				@addPanelController.on 'hideModal', =>
					@trigger 'hideModal'
			@addPanelController.render()


	handleAddOptionRequested: =>
		# new short name is generated by making everything lower case in label text
		requestedOptionModel = @addPanelController.model
		newOptionCode = requestedOptionModel.get('newOptionLabel').toLowerCase()
		if @pickListController.checkOptionInCollection(newOptionCode) == undefined
			newPickList = new PickList
				code: newOptionCode #same as codeValue
				name: requestedOptionModel.get('newOptionLabel')
				ignored: false
				codeType: requestedOptionModel.get('codeType')
				codeKind: requestedOptionModel.get('codeKind')
				codeOrigin: requestedOptionModel.get('codeOrigin')
				description: requestedOptionModel.get('newOptionDescription')
				comments: requestedOptionModel.get('newOptionComments')
			@pickListController.collection.add newPickList
			@pickListController.setSelectedCode(newPickList.get('code'))
			@trigger 'change'
			@$('.bv_errorMessage').hide()
			@addPanelController.hideModal()

		else
			@$('.bv_errorMessage').show()

	hideAddOptionButton: ->
		@$('.bv_addOptionBtn').hide()

	showAddOptionButton: ->
		@$('.bv_addOptionBtn').show()

	saveNewOption: (callback) =>
		code = @pickListController.getSelectedCode()
		selectedModel = @pickListController.collection.getModelWithCode(code)
		if selectedModel != undefined and selectedModel.get('code') != "unassigned"
			if selectedModel.get('id')?
				callback.call()
			else
				$.ajax
					type: 'POST'
					url: "/api/codetables"
					data:
						JSON.stringify(codeEntry:(selectedModel))
					contentType: 'application/json'
					dataType: 'json'
					success: (response) =>
						callback.call()
					error: (err) =>
						alert 'could not add option to code table'
						@serviceReturn = null
		else
			callback.call()

#	setupContextMenu: ->
#		$.fn.contextMenu = (settings) ->
#
#			# get left location of the context menu
#			getLeftLocation = (e) ->
#				relativeMouseWidth = e.pageX - $(window).scrollLeft()
#				absoluteMouseWidth = e.pageX
#				pageWidth = $(window).width()
#				menuWidth = $(settings.menuSelector).width()
#
#				if relativeMouseWidth + menuWidth > pageWidth and menuWidth < relativeMouseWidth
#					# opening menu would pass the side of the current view of the page
#					return absoluteMouseWidth - menuWidth
#				else
#					return absoluteMouseWidth
#
#			# get top location of the context menu
#			getTopLocation = (e) ->
#				relativeMouseHeight = e.pageY - $(window).scrollTop()
#				absoluteMouseHeight = e.pageY
#				pageHeight = $(window).height()
#				menuHeight = $(settings.menuSelector).height()
#
#				if relativeMouseHeight + menuHeight > pageHeight and menuHeight < relativeMouseHeight
#					# opening menu would pass the bottom of the current view of the page
#					return absoluteMouseHeight - menuHeight
#				else
#					return absoluteMouseHeight
#
#			return @each(->
#				$(this).on "contextmenu", (e) ->
#					$(settings.menuSelector).data("invokedOn", $(e.target)).show().css(
#						position: "absolute"
#						left: getLeftLocation(e)
#						top: getTopLocation(e)
#					).off("click").on "click", (e) ->
#						$(this).hide()
#						invokedOn = $(this).data("invokedOn")
#						$selectedMenu = $(e.target)
#						settings.menuSelected.call this, invokedOn, $selectedMenu
#
#					return false #hides the browser's generic context menu
#
#				$(document).click ->
#					$(settings.menuSelector).hide()
#
#			)
#		@$('.bv_addOptionBtn').contextMenu
#			menuSelector: ".bv_contextMenu"
#			menuSelected: (invokedOn, selectedMenu) ->
#				msg = "You selected the menu item '" + selectedMenu.text() + "' on the value '" + invokedOn.text() + "'"
#				alert msg