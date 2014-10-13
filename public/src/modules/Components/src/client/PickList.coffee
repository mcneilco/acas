class window.PickList extends Backbone.Model

class window.PickListList extends Backbone.Collection
	model: PickList

	setType: (type) ->
		@type = type

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

class window.PickListSelectController extends Backbone.View
	initialize: ->
		@rendered = false
		@collection.bind "add", @addOne
		@collection.bind "reset", @handleListReset

		unless @options.selectedCode is ""
			@selectedCode = @options.selectedCode
		else
			@selectedCode = null

		if @options.insertFirstOption?
			@insertFirstOption = @options.insertFirstOption
		else
			@insertFirstOption = null

		if @options.autoFetch?
			@autoFetch = @options.autoFetch
		else
			@autoFetch = true

		if @autoFetch
			@collection.fetch
				success: @handleListReset
		else
			@handleListReset()


	handleListReset: =>
		if @insertFirstOption
			@collection.add @insertFirstOption,
				at: 0
				silent: true

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
		if !enm.get 'ignored'
			$(@el).append new PickListOptionController(model: enm).render().el

	setSelectedCode: (code) ->
		@selectedCode = code
		$(@el).val @selectedCode  if @rendered

	getSelectedCode: ->
		$(@el).val()

	getSelectedModel: ->
		@collection.getModelWithCode @getSelectedCode()

	checkOptionInCollection: (code) => #checks to see if option already exists in the picklist list
		console.log "checking Option"
		return @collection.findWhere({code: code})


class window.AddParameterOptionPanel extends Backbone.Model
	defaults:
		parameter: null
		newOptionLabel: null
		newOptionDescription: null
		newOptionComments: null

	validate: (attrs) ->
		console.log "validating add option panel"
		console.log attrs
		errors = []
		if attrs.newOptionLabel is null or attrs.newOptionLabel is ""
			errors.push
				attribute: 'newOptionLabel'
				message: "Label must be set"
		if attrs.newOptionDescription is null or attrs.newOptionDescription is ""
			errors.push
				attribute: 'newOptionDescription'
				message: "Description must be set"
		if attrs.newOptionComments is null or attrs.newOptionComments is ""
			errors.push
				attribute: 'newOptionComments'
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
		@showModal()


		@

	showModal: =>
		console.log "add option button clicked"
		@$('.bv_addParameterOptionModal').modal('show')
		parameterNameWithSpaces = @model.get('parameter').replace /([A-Z])/g,' $1'
		pascalCaseParameterName = (parameterNameWithSpaces).charAt(0).toUpperCase() + (parameterNameWithSpaces).slice(1)
		@$('.bv_parameter').html(pascalCaseParameterName)

	updateModel: =>
		console.log "updating model"
		@model.set # TODO: trim inputs, use Utility Function after merging with dev
			newOptionLabel: @getTrimmedInput('.bv_newOptionLabel')
			newOptionDescription: @getTrimmedInput('.bv_newOptionDescription')
			newOptionComments: @getTrimmedInput('.bv_newOptionComments')
		console.log @model.get('newOptionLabel')

	triggerAddRequest: =>
		console.log "trigger add request"
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


	initialize: ->
		console.log "initialize editable pick list"
		console.log @options.parameter

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupEditablePickList()
#		@setupAddPanel()
#		@setupContextMenu()
		@setupEditingPrivileges()


	setupEditablePickList: ->
		console.log "setting up editable picklist"
		@pickListController = new PickListSelectController
			el: @$('.bv_parameterSelectList')
			collection: @collection
			insertFirstOption: new PickList
				code: "unassigned"
				name: "Select Rule"
			selectedCode: @options.selectedCode
		console.log "finished setting up picklist"

	setupEditingPrivileges: =>
		console.log "setup editing privileges"
		console.log window.AppLaunchParams.loginUser
		console.log @options.roles
		if !UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, @options.roles #TODO: pass in role as argument
			console.log "disable add button and insert tooltip"
			@$('.bv_addOptionBtn').removeAttr('data-toggle')
			@$('.bv_addOptionBtn').removeAttr('data-target')
			@$('.bv_addOptionBtn').removeAttr('data-backdrop')
			@$('.bv_addOptionBtn').css({'color':"#cccccc"})
			@$('.bv_tooltipwrapper').tooltip();
			@$("body").tooltip selector: '.bv_tooltipwrapper'
			@$('.bv_addOptionBtn')
		else
			console.log "user can edit"

	getSelectedCode: ->
		@pickListController.getSelectedCode()

	handleShowAddPanel: =>
		console.log "handle show add panel"
		if UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, @options.roles #TODO: pass in role as argument - should it be a config option?
			console.log "setting up add panel"
			unless @addPanelController?
				@addPanelController = new AddParameterOptionPanelController
					model: new AddParameterOptionPanel
						parameter: @options.parameter
					el: @$('.bv_addOptionPanel')
				@addPanelController.on 'addOptionRequested', @handleAddOptionRequested
			@addPanelController.render()


	handleAddOptionRequested: =>
		console.log "add new parameter option clicked"
		# new short name is generated by making everything lower case in label text
		newOptionName = @addPanelController.model.get('newOptionLabel').toLowerCase() #TODO: trim input - will do after merge to use utility function
		if @pickListController.checkOptionInCollection(newOptionName) == undefined
			console.log "valid new option. will add"
			newPickList = new PickList
				code: newOptionName
				name: newOptionName
				ignored: false
				newOption: true
			@pickListController.collection.add newPickList

			@$('.bv_optionAddedMessage').show()
			@$('.bv_errorMessage').hide()

		else
			console.log "option already exists"
			@$('.bv_optionAddedMessage').hide()
			@$('.bv_errorMessage').show()

	hideAddOptionButton: ->
		console.log "hide add button"
		@$('.bv_addOptionBtn').hide()

	showAddOptionButton: ->
		console.log "show add button"
		@$('.bv_addOptionBtn').show()

	saveNewOption: -> # TODO: should be called in modules with editablePickLists
		# TODO: check to see if selected option in picklist was newly added - DONE but not with isNew
		console.log "saveNewOption"
		code = @pickListController.getSelectedCode()
		selectedModel = @pickListController.collection.getModelWithCode(code)
		console.log selectedModel
		console.log selectedModel.get('newOption')
		if selectedModel.get('newOption')
			console.log "new Option"
			selectedModel.unset('newOption')
			console.log selectedModel
			console.log @pickListController.collection.getModelWithCode(code)
			#TODO: save to database. When adding new model to collection, should include all the information (ie state type/kind and value type/kind to save)?
		else
			console.log "don't need to save to database"



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
#			#TODO: replace with edit panel
